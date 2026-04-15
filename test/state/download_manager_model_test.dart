import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_images.dart';
import 'package:concept_nhv/models/comic_page_image.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/models/download_page_status.dart';
import 'package:concept_nhv/models/download_request.dart';
import 'package:concept_nhv/services/download_asset_store.dart';
import 'package:concept_nhv/services/nhentai_cdn_config_service.dart';
import 'package:concept_nhv/state/download_manager_model.dart';
import 'package:concept_nhv/storage/download_settings_store.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fakes/fake_image_compression_service.dart';
import '../test_support/fakes/fake_nhentai_gateway.dart';
import '../test_support/fakes/fake_remote_asset_fetcher.dart';
import '../test_support/fixtures/sample_comic.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadManagerModel', () {
    late SqliteTestHarness harness;
    late Directory tempDirectory;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
      tempDirectory = await Directory.systemTemp.createTemp('nhv-download-test');
    });

    tearDown(() async {
      await harness.dispose();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('downloads pages, stores offline snapshot, and marks job complete', () async {
      final comic = sampleComic(id: '900', mediaId: '321');
      final manager = DownloadManagerModel(
        nhentaiGateway: FakeNhentaiGateway(detailComic: comic),
        cdnConfigService: _FakeCdnConfigService(),
        downloadQueueRepository: harness.downloadQueueRepository,
        downloadedLibraryRepository: harness.downloadedLibraryRepository,
        downloadSettingsRepository: DownloadSettingsStore(
          optionsStore: OptionsStore(localDatabase: harness.localDatabase),
        ),
        downloadAssetStore: DownloadAssetStore(
          directoryResolver: () async => tempDirectory,
        ),
        imageCompressionService: FakeImageCompressionService(
          result: Uint8List.fromList(<int>[1, 2, 3, 4]),
        ),
        remoteAssetFetcher: FakeRemoteAssetFetcher(
          responses: <String, Uint8List>{
            'https://i1.nhentai.net/galleries/321/1.jpg': Uint8List.fromList(<int>[1]),
            'https://i1.nhentai.net/galleries/321/2.jpg': Uint8List.fromList(<int>[2]),
            'https://i1.nhentai.net/galleries/321/cover.jpg': Uint8List.fromList(<int>[3]),
          },
        ),
      );

      await manager.initialize();
      await manager.enqueue(const DownloadRequest(comicId: '900', title: 'Sample'));
      await _waitForJobStatus(
        harness: harness,
        comicId: '900',
        status: 'completed',
      );
      await manager.waitForIdle();

      final job = await harness.downloadQueueRepository.loadJob('900');
      final pages = await harness.downloadQueueRepository.loadPages('900');
      final downloadedRows = await harness.localDatabase
          .customSelect('SELECT comic_id, cover_local_path FROM DownloadedComic')
          .get();

      expect(job?.completedPages, comic.numPages);
      expect(pages.every((page) => page.storedFormat == 'webp'), isTrue);
      expect(downloadedRows.single.read<String>('comic_id'), '900');
      final firstPageFile = File(pages.first.localPath!);
      expect(await firstPageFile.exists(), isTrue);

      manager.dispose();
    });

    test('falls back to original page format when WebP compression is unsupported', () async {
      final comic = sampleComic(id: '901', mediaId: '654');
      final manager = DownloadManagerModel(
        nhentaiGateway: FakeNhentaiGateway(detailComic: comic),
        cdnConfigService: _FakeCdnConfigService(),
        downloadQueueRepository: harness.downloadQueueRepository,
        downloadedLibraryRepository: harness.downloadedLibraryRepository,
        downloadSettingsRepository: DownloadSettingsStore(
          optionsStore: OptionsStore(localDatabase: harness.localDatabase),
        ),
        downloadAssetStore: DownloadAssetStore(
          directoryResolver: () async => tempDirectory,
        ),
        imageCompressionService: FakeImageCompressionService(
          error: UnsupportedError('webp'),
        ),
        remoteAssetFetcher: FakeRemoteAssetFetcher(
          responses: <String, Uint8List>{
            'https://i1.nhentai.net/galleries/654/1.jpg': Uint8List.fromList(<int>[1]),
            'https://i1.nhentai.net/galleries/654/2.jpg': Uint8List.fromList(<int>[2]),
            'https://i1.nhentai.net/galleries/654/cover.jpg': Uint8List.fromList(<int>[3]),
          },
        ),
      );

      await manager.initialize();
      await manager.enqueue(const DownloadRequest(comicId: '901', title: 'Fallback'));
      await _waitForJobStatus(
        harness: harness,
        comicId: '901',
        status: 'completed',
      );
      await manager.waitForIdle();

      final pages = await harness.downloadQueueRepository.loadPages('901');
      expect(pages.every((page) => page.storedFormat == 'jpg'), isTrue);
      expect(pages.every((page) => page.localPath!.endsWith('.jpg')), isTrue);

      manager.dispose();
    });

    test('ignores duplicate enqueue requests for the same comic while one is already starting', () async {
      final comic = sampleComic(id: '902', mediaId: '777');
      final gateway = FakeNhentaiGateway(detailComic: comic);
      final manager = DownloadManagerModel(
        nhentaiGateway: gateway,
        cdnConfigService: _FakeCdnConfigService(),
        downloadQueueRepository: harness.downloadQueueRepository,
        downloadedLibraryRepository: harness.downloadedLibraryRepository,
        downloadSettingsRepository: DownloadSettingsStore(
          optionsStore: OptionsStore(localDatabase: harness.localDatabase),
        ),
        downloadAssetStore: DownloadAssetStore(
          directoryResolver: () async => tempDirectory,
        ),
        imageCompressionService: FakeImageCompressionService(),
        remoteAssetFetcher: FakeRemoteAssetFetcher(
          responses: <String, Uint8List>{
            'https://i1.nhentai.net/galleries/777/1.jpg': Uint8List.fromList(<int>[1]),
            'https://i1.nhentai.net/galleries/777/2.jpg': Uint8List.fromList(<int>[2]),
            'https://i1.nhentai.net/galleries/777/cover.jpg': Uint8List.fromList(<int>[3]),
          },
        ),
      );

      await manager.initialize();
      await Future.wait(<Future<void>>[
        manager.enqueue(const DownloadRequest(comicId: '902', title: 'Dupe')),
        manager.enqueue(const DownloadRequest(comicId: '902', title: 'Dupe')),
      ]);
      await _waitForJobStatus(
        harness: harness,
        comicId: '902',
        status: 'completed',
      );
      await manager.waitForIdle();

      expect(gateway.loadedComicDetailIds, hasLength(2));
      expect(
        gateway.loadedComicDetailIds.every((comicId) => comicId == '902'),
        isTrue,
      );
      expect(manager.isMutating('902'), isFalse);
      expect(await harness.downloadQueueRepository.loadJobs(), hasLength(1));
      expect(await harness.downloadQueueRepository.loadJob('902'), isNotNull);

      manager.dispose();
    });

    test('pause after resume stays paused when the current page finishes in flight', () async {
      final comic = _threePageComic(id: '903', mediaId: '778');
      final secondPageCompleter = Completer<Uint8List>();
      final manager = DownloadManagerModel(
        nhentaiGateway: FakeNhentaiGateway(detailComic: comic),
        cdnConfigService: _FakeCdnConfigService(),
        downloadQueueRepository: harness.downloadQueueRepository,
        downloadedLibraryRepository: harness.downloadedLibraryRepository,
        downloadSettingsRepository: DownloadSettingsStore(
          optionsStore: OptionsStore(localDatabase: harness.localDatabase),
        ),
        downloadAssetStore: DownloadAssetStore(
          directoryResolver: () async => tempDirectory,
        ),
        imageCompressionService: FakeImageCompressionService(),
        remoteAssetFetcher: FakeRemoteAssetFetcher(
          responses: <String, Uint8List>{
            'https://i1.nhentai.net/galleries/778/1.jpg': Uint8List.fromList(<int>[1]),
            'https://i1.nhentai.net/galleries/778/3.jpg': Uint8List.fromList(<int>[4]),
            'https://i1.nhentai.net/galleries/778/cover.jpg': Uint8List.fromList(<int>[3]),
          },
          deferredResponses: <String, Future<Uint8List> Function()>{
            'https://i1.nhentai.net/galleries/778/2.jpg': () => secondPageCompleter.future,
          },
        ),
      );

      await manager.initialize();
      await manager.enqueue(const DownloadRequest(comicId: '903', title: 'Pause Resume'));
      await _waitForJobStatus(
        harness: harness,
        comicId: '903',
        status: 'downloading',
      );
      await _waitForPageStatus(
        harness: harness,
        comicId: '903',
        pageNumber: 1,
        status: 'completed',
      );
      await _waitForPageStatus(
        harness: harness,
        comicId: '903',
        pageNumber: 2,
        status: 'pending',
      );

      await manager.pause('903');
      expect((await harness.downloadQueueRepository.loadJob('903'))?.status, DownloadJobStatus.paused);
      await manager.waitForIdle();

      await manager.resume('903');
      await _waitForJobStatus(
        harness: harness,
        comicId: '903',
        status: 'downloading',
      );
      await _waitForPageStatus(
        harness: harness,
        comicId: '903',
        pageNumber: 2,
        status: 'downloading',
      );

      await manager.pause('903');
      expect((await harness.downloadQueueRepository.loadJob('903'))?.status, DownloadJobStatus.paused);

      secondPageCompleter.complete(Uint8List.fromList(<int>[2]));
      await manager.waitForIdle();

      final job = await harness.downloadQueueRepository.loadJob('903');
      final pages = await harness.downloadQueueRepository.loadPages('903');

      expect(job, isNotNull);
      expect(job!.status, DownloadJobStatus.paused);
      expect(job.completedPages, 2);
      expect(job.nextPageNumber, 3);
      expect(job.completedAt, isNull);
      expect(pages[1].status, DownloadPageStatus.completed);
      expect(pages, hasLength(comic.numPages));
      expect(pages[2].status, DownloadPageStatus.pending);

      manager.dispose();
    });
  });
}

class _FakeCdnConfigService extends NhentaiCdnConfigService {
  @override
  List<String> get imageHosts => const <String>['i1.nhentai.net'];

  @override
  Future<Never> load() async {
    throw StateError('No remote config call in tests');
  }
}

Future<void> _waitForJobStatus({
  required SqliteTestHarness harness,
  required String comicId,
  required String status,
}) async {
  for (int attempt = 0; attempt < 100; attempt++) {
    final job = await harness.downloadQueueRepository.loadJob(comicId);
    if (job != null && job.status.storageValue == status) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for job $comicId to reach status $status');
}

Future<void> _waitForPageStatus({
  required SqliteTestHarness harness,
  required String comicId,
  required int pageNumber,
  required String status,
}) async {
  for (int attempt = 0; attempt < 100; attempt++) {
    final page = (await harness.downloadQueueRepository.loadPages(comicId))
        .firstWhere((candidate) => candidate.pageNumber == pageNumber);
    if (page.status.storageValue == status) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail(
    'Timed out waiting for job $comicId page $pageNumber to reach status $status',
  );
}

Comic _threePageComic({required String id, required String mediaId}) {
  return Comic(
    id: id,
    mediaId: mediaId,
    title: sampleComic(id: id, mediaId: mediaId).title,
    images: ComicImages(
      pages: <ComicPageImage>[
        ComicPageImage(
          t: 'j',
          w: 1200,
          h: 1800,
          path: 'galleries/$mediaId/1.jpg',
        ),
        ComicPageImage(
          t: 'j',
          w: 1200,
          h: 1800,
          path: 'galleries/$mediaId/2.jpg',
        ),
        ComicPageImage(
          t: 'j',
          w: 1200,
          h: 1800,
          path: 'galleries/$mediaId/3.jpg',
        ),
      ],
      cover: ComicPageImage(
        t: 'j',
        w: 350,
        h: 500,
        path: 'galleries/$mediaId/cover.jpg',
      ),
      thumbnail: ComicPageImage(
        t: 'w',
        w: 350,
        h: 500,
        path: 'galleries/$mediaId/thumb.webp',
      ),
    ),
    scanlator: null,
    uploadDate: 0,
    tags: sampleComic(id: id, mediaId: mediaId).tags,
    numPages: 3,
    numFavorites: 1,
  );
}
