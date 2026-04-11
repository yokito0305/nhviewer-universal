import 'dart:io';
import 'dart:typed_data';

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
