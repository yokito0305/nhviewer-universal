import 'dart:async';
import 'dart:typed_data';

import 'package:concept_nhv/application/downloads/download_settings_repository.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/download_list_item_snapshot.dart';
import 'package:concept_nhv/models/download_job_snapshot.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/models/download_page_snapshot.dart';
import 'package:concept_nhv/models/download_page_status.dart';
import 'package:concept_nhv/models/download_request.dart';
import 'package:concept_nhv/models/downloaded_comic_snapshot.dart';
import 'package:concept_nhv/models/downloads_sort_mode.dart';
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
  List<DownloadListItemSnapshot> _downloadItems =
      const <DownloadListItemSnapshot>[];
  DownloadsSortMode _downloadsSortMode = DownloadsSortMode.latestDownloaded;
  DownloadsSortDirection _downloadsSortDirection =
      DownloadsSortDirection.descending;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;
  final Set<String> _mutatingComicIds = <String>{};

  List<DownloadJobSnapshot> get jobs => _jobs;
  List<DownloadListItemSnapshot> get downloadItems => _downloadItems;
  DownloadsSortMode get downloadsSortMode => _downloadsSortMode;
  DownloadsSortDirection get downloadsSortDirection =>
      _downloadsSortDirection;
  bool get isRefreshing => _isRefreshing;
  bool isMutating(String comicId) => _mutatingComicIds.contains(comicId);

  List<DownloadListItemSnapshot> get sortedDownloadItems {
    final activeItems = _downloadItems
        .where((item) => item.status != DownloadJobStatus.completed)
        .toList(growable: false)
      ..sort(_compareActiveItems);
    final completedItems = _downloadItems
        .where((item) => item.status == DownloadJobStatus.completed)
        .toList(growable: false)
      ..sort(_compareCompletedItems);
    return List<DownloadListItemSnapshot>.unmodifiable(
      <DownloadListItemSnapshot>[
        ...activeItems,
        ...completedItems,
      ],
    );
  }

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
    final jobs = await downloadQueueRepository.loadJobs();
    final downloadedComics =
        await downloadedLibraryRepository.loadDownloadedComics();
    _jobs = jobs;
    _downloadItems = _buildDownloadItems(jobs, downloadedComics);
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

  void setDownloadsSortMode(DownloadsSortMode mode) {
    if (_downloadsSortMode == mode) {
      return;
    }
    _downloadsSortMode = mode;
    notifyListeners();
  }

  void setDownloadsSortDirection(DownloadsSortDirection direction) {
    if (_downloadsSortDirection == direction) {
      return;
    }
    _downloadsSortDirection = direction;
    notifyListeners();
  }

  List<DownloadListItemSnapshot> _buildDownloadItems(
    List<DownloadJobSnapshot> jobs,
    List<DownloadedComicSnapshot> downloadedComics,
  ) {
    final downloadedByComicId = <String, DownloadedComicSnapshot>{
      for (final downloadedComic in downloadedComics)
        downloadedComic.comicId: downloadedComic,
    };
    final items = <DownloadListItemSnapshot>[];
    for (final job in jobs) {
      final downloadedComic = downloadedByComicId.remove(job.comicId);
      items.add(
        DownloadListItemSnapshot.fromJob(
          job,
          downloadedComic: downloadedComic,
        ),
      );
    }
    for (final downloadedComic in downloadedByComicId.values) {
      items.add(
        DownloadListItemSnapshot.fromDownloadedComic(downloadedComic),
      );
    }
    return List<DownloadListItemSnapshot>.unmodifiable(items);
  }

  int _compareActiveItems(
    DownloadListItemSnapshot a,
    DownloadListItemSnapshot b,
  ) {
    final statusComparison = _downloadJobStatusPriority(a.status).compareTo(
      _downloadJobStatusPriority(b.status),
    );
    if (statusComparison != 0) {
      return statusComparison;
    }
    return b.requestedAt.compareTo(a.requestedAt);
  }

  int _compareCompletedItems(
    DownloadListItemSnapshot a,
    DownloadListItemSnapshot b,
  ) {
    return switch (_downloadsSortMode) {
      DownloadsSortMode.latestDownloaded => _compareByDirection(
        a.downloadedAt ?? a.updatedAt,
        b.downloadedAt ?? b.updatedAt,
      ),
      DownloadsSortMode.lastRead => _compareLastReadItems(a, b),
      DownloadsSortMode.mostFavorited => _compareMostFavoritedItems(a, b),
    };
  }

  int _compareLastReadItems(
    DownloadListItemSnapshot a,
    DownloadListItemSnapshot b,
  ) {
    final aTimestamp = a.lastReadAt ?? a.downloadedAt ?? a.updatedAt;
    final bTimestamp = b.lastReadAt ?? b.downloadedAt ?? b.updatedAt;
    return _compareByDirection(aTimestamp, bTimestamp);
  }

  int _compareMostFavoritedItems(
    DownloadListItemSnapshot a,
    DownloadListItemSnapshot b,
  ) {
    final aFavorites = a.numFavorites;
    final bFavorites = b.numFavorites;
    if (aFavorites == null && bFavorites == null) {
      return (b.downloadedAt ?? b.updatedAt).compareTo(
        a.downloadedAt ?? a.updatedAt,
      );
    }
    if (aFavorites == null) {
      return 1;
    }
    if (bFavorites == null) {
      return -1;
    }
    return _compareByDirection(aFavorites, bFavorites);
  }

  int _compareByDirection<T extends Comparable<T>>(T a, T b) {
    return switch (_downloadsSortDirection) {
      DownloadsSortDirection.descending => b.compareTo(a),
      DownloadsSortDirection.ascending => a.compareTo(b),
    };
  }

  int _downloadJobStatusPriority(DownloadJobStatus status) {
    return switch (status) {
      DownloadJobStatus.downloading => 0,
      DownloadJobStatus.queued => 1,
      DownloadJobStatus.failed => 2,
      DownloadJobStatus.paused => 3,
      DownloadJobStatus.completed => 4,
    };
  }

  Future<void> enqueue(DownloadRequest request) async {
    await _runMutatingJobAction(request.comicId, () async {
      final existingJob = await downloadQueueRepository.loadJob(request.comicId);
      if (existingJob != null) {
        await refresh();
        return;
      }

      final result = await nhentaiGateway.loadComicDetail(request.comicId);
      await downloadQueueRepository.upsertJobManifest(
        comic: result.comic,
        title: request.title,
      );
      await refresh();
      unawaited(_processQueue());
    });
  }

  Future<void> pause(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      await downloadQueueRepository.markJobPaused(comicId);
      await refresh();
    });
  }

  Future<void> resume(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      await downloadQueueRepository.requeueJob(comicId);
      await refresh();
      unawaited(_processQueue());
    });
  }

  Future<void> retry(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      await downloadQueueRepository.requeueJob(comicId);
      await refresh();
      unawaited(_processQueue());
    });
  }

  Future<void> deleteJob(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      await downloadQueueRepository.markJobPaused(comicId);
      await downloadQueueRepository.deleteJob(comicId);
      await downloadedLibraryRepository.deleteDownloadedComic(comicId);
      await downloadAssetStore.deleteComicAssets(comicId);
      await refresh();
    });
  }

  /// Re-downloads a completed comic from scratch while preserving its library
  /// metadata (lastReadAt, tags, numFavorites).
  ///
  /// Steps:
  /// 1. Delete existing queue records and assets (library row is kept).
  /// 2. Call the API to obtain the fresh page manifest.
  /// 3. Enqueue the new job and kick the download engine.
  Future<void> reloadCompleted(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      await downloadQueueRepository.deleteQueueOnly(comicId);
      await downloadAssetStore.deleteComicAssets(comicId);

      final detail = await nhentaiGateway.loadComicDetail(comicId);
      final comic = detail.comic;
      final title = _libraryTitle(comicId) ??
          comic.title.pretty ??
          comic.title.english ??
          comic.title.japanese ??
          comicId;
      await downloadQueueRepository.upsertJobManifest(
        comic: comic,
        title: title,
      );
      await refresh();
      unawaited(_processQueue());
    });
  }

  /// Re-downloads only the pages that are missing or have zero byte size on disk.
  ///
  /// Steps:
  /// 1. Load pages from DB and verify each file.
  /// 2. Reset missing page records to pending.
  /// 3. Requeue the job and kick the download engine.
  ///
  /// If all pages are intact, this is a no-op (returns without re-queuing).
  Future<void> repairCompleted(String comicId) async {
    await _runMutatingJobAction(comicId, () async {
      final pages = await downloadQueueRepository.loadPages(comicId);
      final pageLocalPaths = <int, String?>{
        for (final page in pages) page.pageNumber: page.localPath,
      };
      final missingPageNumbers = await downloadAssetStore.verifyPages(pageLocalPaths);
      if (missingPageNumbers.isEmpty) {
        return;
      }
      await downloadQueueRepository.resetMissingPages(comicId, missingPageNumbers);
      await downloadQueueRepository.requeueJob(comicId);
      await refresh();
      unawaited(_processQueue());
    });
  }

  /// Returns the title stored in the downloaded library for [comicId], if any.
  String? _libraryTitle(String comicId) {
    for (final item in _downloadItems) {
      if (item.comicId == comicId) {
        return item.title;
      }
    }
    return null;
  }

  Future<String?> loadCoverLocalPath(String comicId) {
    return downloadedLibraryRepository.loadCoverLocalPath(comicId);
  }

  Future<void> _maybeAutoResume() async {
    final autoResumeEnabled =
        await downloadSettingsRepository.loadAutoResumeEnabled();
    if (!autoResumeEnabled) {
      await downloadQueueRepository.pauseInterruptedJobs();
      await refresh();
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

  Future<void> _runMutatingJobAction(
    String comicId,
    Future<void> Function() action,
  ) async {
    if (_mutatingComicIds.contains(comicId)) {
      return;
    }
    _mutatingComicIds.add(comicId);
    notifyListeners();
    try {
      await action();
    } finally {
      _mutatingComicIds.remove(comicId);
      if (!_isDisposed) {
        notifyListeners();
      }
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
