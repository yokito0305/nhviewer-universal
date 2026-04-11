import 'dart:async';
import 'dart:typed_data';

import 'package:concept_nhv/application/downloads/download_settings_repository.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/download_job_snapshot.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/models/download_page_snapshot.dart';
import 'package:concept_nhv/models/download_page_status.dart';
import 'package:concept_nhv/models/download_request.dart';
import 'package:concept_nhv/services/download_asset_store.dart';
import 'package:concept_nhv/services/image_compression_service.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/services/nhentai_cdn_config_service.dart';
import 'package:concept_nhv/services/remote_asset_fetcher.dart';
import 'package:concept_nhv/storage/download_queue_repository.dart';
import 'package:concept_nhv/storage/downloaded_library_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

class DownloadManagerModel extends ChangeNotifier with WidgetsBindingObserver {
  DownloadManagerModel({
    required this.nhentaiGateway,
    required this.cdnConfigService,
    required this.downloadQueueRepository,
    required this.downloadedLibraryRepository,
    required this.downloadSettingsRepository,
    required this.downloadAssetStore,
    required this.imageCompressionService,
    required this.remoteAssetFetcher,
  });

  final NhentaiGateway nhentaiGateway;
  final NhentaiCdnConfigService cdnConfigService;
  final DownloadQueueRepository downloadQueueRepository;
  final DownloadedLibraryRepository downloadedLibraryRepository;
  final DownloadSettingsRepository downloadSettingsRepository;
  final DownloadAssetStore downloadAssetStore;
  final ImageCompressionService imageCompressionService;
  final RemoteAssetFetcher remoteAssetFetcher;

  List<DownloadJobSnapshot> _jobs = const <DownloadJobSnapshot>[];
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  List<DownloadJobSnapshot> get jobs => _jobs;
  bool get isRefreshing => _isRefreshing;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    await refresh();
    await _maybeAutoResume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_maybeAutoResume());
    }
  }

  Future<void> refresh() async {
    if (_isDisposed) {
      return;
    }
    _isRefreshing = true;
    notifyListeners();
    _jobs = await downloadQueueRepository.loadJobs();
    if (_isDisposed) {
      return;
    }
    _isRefreshing = false;
    notifyListeners();
  }

  DownloadJobSnapshot? jobForComic(String comicId) {
    for (final job in _jobs) {
      if (job.comicId == comicId) {
        return job;
      }
    }
    return null;
  }

  Future<void> enqueue(DownloadRequest request) async {
    final result = await nhentaiGateway.loadComicDetail(request.comicId);
    await downloadQueueRepository.upsertJobManifest(
      comic: result.comic,
      title: request.title,
    );
    await refresh();
    unawaited(_processQueue());
  }

  Future<void> pause(String comicId) async {
    await downloadQueueRepository.markJobPaused(comicId);
    await refresh();
  }

  Future<void> resume(String comicId) async {
    await downloadQueueRepository.requeueJob(comicId);
    await refresh();
    unawaited(_processQueue());
  }

  Future<void> retry(String comicId) async {
    await downloadQueueRepository.requeueJob(comicId);
    await refresh();
    unawaited(_processQueue());
  }

  Future<void> deleteJob(String comicId) async {
    await downloadQueueRepository.markJobPaused(comicId);
    await downloadQueueRepository.deleteJob(comicId);
    await downloadedLibraryRepository.deleteDownloadedComic(comicId);
    await downloadAssetStore.deleteComicAssets(comicId);
    await refresh();
  }

  Future<void> _maybeAutoResume() async {
    final autoResumeEnabled =
        await downloadSettingsRepository.loadAutoResumeEnabled();
    if (!autoResumeEnabled) {
      return;
    }
    await downloadQueueRepository.requeueInterruptedJobs();
    await refresh();
    unawaited(_processQueue());
  }

  Future<void> _processQueue() async {
    if (_isProcessing) {
      return;
    }
    _isProcessing = true;
    try {
      while (true) {
        final nextJob = await downloadQueueRepository.loadNextQueuedJob();
        if (nextJob == null) {
          break;
        }
        await _processJob(nextJob);
      }
    } finally {
      _isProcessing = false;
      await refresh();
    }
  }

  Future<void> _processJob(DownloadJobSnapshot job) async {
    final detail = await nhentaiGateway.loadComicDetail(job.comicId);
    final comic = detail.comic;
    final imageHosts = await _loadImageHosts();
    final pageIntervalMs = await downloadSettingsRepository.loadPageIntervalMs();

    await downloadQueueRepository.markJobDownloading(job.comicId);
    await refresh();

    final pages = await downloadQueueRepository.loadPages(job.comicId);
    for (final page in pages) {
      if (await _shouldStopJob(job.comicId)) {
        return;
      }
      if (page.status == DownloadPageStatus.completed) {
        continue;
      }

      await downloadQueueRepository.markPageDownloading(
        comicId: job.comicId,
        pageNumber: page.pageNumber,
      );
      await refresh();

      try {
        final downloadedPage = await _downloadAndPersistPage(
          comicId: job.comicId,
          page: page,
          imageHosts: imageHosts,
        );
        await downloadQueueRepository.markPageCompleted(
          comicId: job.comicId,
          pageNumber: page.pageNumber,
          sourceServer: downloadedPage.sourceServer,
          localPath: downloadedPage.localPath,
          storedFormat: downloadedPage.storedFormat,
          byteSize: downloadedPage.byteSize,
        );
        await refresh();
      } catch (error) {
        await downloadQueueRepository.markPageFailed(
          comicId: job.comicId,
          pageNumber: page.pageNumber,
          error: '$error',
        );
        await refresh();
        return;
      }

      if (pageIntervalMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: pageIntervalMs));
      }
    }

    final coverLocalPath = await _downloadCover(
      comicId: job.comicId,
      comic: comic,
      imageHosts: imageHosts,
    );
    final rootDirectory = await downloadAssetStore.resolveRootDirectory(job.comicId);
    await downloadedLibraryRepository.saveDownloadedComic(
      comic: comic,
      rootDirectoryPath: rootDirectory.path,
      coverLocalPath: coverLocalPath,
    );
    await downloadQueueRepository.markJobCompleted(job.comicId);
    await refresh();
  }

  Future<bool> _shouldStopJob(String comicId) async {
    final job = await downloadQueueRepository.loadJob(comicId);
    if (job == null) {
      return true;
    }
    return job.status == DownloadJobStatus.paused ||
        job.status == DownloadJobStatus.failed;
  }

  Future<List<String>> _loadImageHosts() async {
    try {
      await cdnConfigService.load();
    } catch (_) {}
    return cdnConfigService.imageHosts;
  }

  Future<_PersistedAsset> _downloadAndPersistPage({
    required String comicId,
    required DownloadPageSnapshot page,
    required List<String> imageHosts,
  }) async {
    Object? lastError;
    for (final host in imageHosts) {
      final url = Uri.https(host, page.remotePath).toString();
      try {
        final originalBytes = await remoteAssetFetcher.fetchBytes(url);
        final compressed = await _compressWithFallback(
          originalBytes,
          fallbackExtension: _extensionFromPath(page.remotePath),
        );
        final localPath = await downloadAssetStore.savePage(
          comicId: comicId,
          pageNumber: page.pageNumber,
          bytes: compressed.bytes,
          extension: compressed.extension,
        );
        return _PersistedAsset(
          sourceServer: host,
          localPath: localPath,
          storedFormat: compressed.extension,
          byteSize: compressed.bytes.length,
        );
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? StateError('Failed to download page ${page.pageNumber}');
  }

  Future<String?> _downloadCover({
    required String comicId,
    required Comic comic,
    required List<String> imageHosts,
  }) async {
    final coverPath = comic.images.cover?.path;
    if (coverPath == null || coverPath.isEmpty) {
      return null;
    }

    for (final host in imageHosts) {
      final url = Uri.https(host, coverPath).toString();
      try {
        final originalBytes = await remoteAssetFetcher.fetchBytes(url);
        final compressed = await _compressWithFallback(
          originalBytes,
          fallbackExtension: _extensionFromPath(coverPath),
        );
        return downloadAssetStore.saveCover(
          comicId: comicId,
          bytes: compressed.bytes,
          extension: compressed.extension,
        );
      } catch (_) {}
    }

    return null;
  }

  Future<_CompressedAsset> _compressWithFallback(
    Uint8List originalBytes, {
    required String fallbackExtension,
  }) async {
    try {
      final compressed = await imageCompressionService.compressToWebp(
        originalBytes,
        quality: 80,
      );
      if (compressed.isNotEmpty) {
        return _CompressedAsset(bytes: compressed, extension: 'webp');
      }
    } on UnsupportedError {
      // Keep original format below.
    } catch (_) {
      // Keep original format below.
    }

    return _CompressedAsset(bytes: originalBytes, extension: fallbackExtension);
  }

  String _extensionFromPath(String path) {
    final filename = p.basename(path);
    if (!filename.contains('.')) {
      return 'bin';
    }
    final segments = filename.split('.');
    if (segments.length >= 3 && segments.last == segments[segments.length - 2]) {
      return segments.last.toLowerCase();
    }
    return segments.last.toLowerCase();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> waitForIdle() async {
    while (_isProcessing) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }
}

class _PersistedAsset {
  const _PersistedAsset({
    required this.sourceServer,
    required this.localPath,
    required this.storedFormat,
    required this.byteSize,
  });

  final String sourceServer;
  final String localPath;
  final String storedFormat;
  final int byteSize;
}

class _CompressedAsset {
  const _CompressedAsset({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;
}
