import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/models/download_page_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fixtures/sample_comic.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('DownloadQueueRepository', () {
    late SqliteTestHarness harness;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('stores a gallery manifest as a queued job with page records', () async {
      final comic = sampleComic(id: '700', mediaId: '77');

      await harness.downloadQueueRepository.upsertJobManifest(
        comic: comic,
        title: 'Queued Comic',
      );

      final job = await harness.downloadQueueRepository.loadJob('700');
      final pages = await harness.downloadQueueRepository.loadPages('700');

      expect(job, isNotNull);
      expect(job!.status, DownloadJobStatus.queued);
      expect(job.totalPages, comic.numPages);
      expect(pages, hasLength(comic.numPages));
      expect(pages.first.remotePath, 'galleries/77/1.jpg');
      expect(pages.first.status, DownloadPageStatus.pending);
    });

    test('requeue keeps completed pages and resets incomplete ones', () async {
      final comic = sampleComic(id: '701', mediaId: '88');
      await harness.downloadQueueRepository.upsertJobManifest(
        comic: comic,
        title: 'Resume Comic',
      );
      await harness.downloadQueueRepository.markJobDownloading('701');
      await harness.downloadQueueRepository.markPageCompleted(
        comicId: '701',
        pageNumber: 1,
        sourceServer: 'i1.nhentai.net',
        localPath: '/tmp/1.webp',
        storedFormat: 'webp',
        byteSize: 123,
      );
      await harness.downloadQueueRepository.markPageFailed(
        comicId: '701',
        pageNumber: 2,
        error: 'network',
      );

      await harness.downloadQueueRepository.requeueJob('701');

      final job = await harness.downloadQueueRepository.loadJob('701');
      final pages = await harness.downloadQueueRepository.loadPages('701');

      expect(job!.status, DownloadJobStatus.queued);
      expect(job.completedPages, 1);
      expect(job.nextPageNumber, 2);
      expect(pages.first.status, DownloadPageStatus.completed);
      expect(pages.last.status, DownloadPageStatus.pending);
      expect(pages.last.localPath, isNull);
    });
  });
}
