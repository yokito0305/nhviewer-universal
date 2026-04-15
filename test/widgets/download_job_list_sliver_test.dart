import 'package:concept_nhv/application/downloads/download_settings_repository.dart';
import 'package:concept_nhv/models/download_job_snapshot.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/services/download_asset_store.dart';
import 'package:concept_nhv/services/nhentai_cdn_config_service.dart';
import 'package:concept_nhv/state/download_manager_model.dart';
import 'package:concept_nhv/widgets/download_job_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../test_support/fakes/fake_image_compression_service.dart';
import '../test_support/fakes/fake_nhentai_gateway.dart';
import '../test_support/fakes/fake_remote_asset_fetcher.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('DownloadJobListSliver', () {
    late SqliteTestHarness harness;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
    });

    tearDown(() async {
      await harness.dispose();
    });

    testWidgets('orders jobs by status group and requested time', (tester) async {
      final sortedTitles = sortDownloadJobs(<DownloadJobSnapshot>[
        _job(
          comicId: 'completed',
          title: 'Completed Comic',
          status: DownloadJobStatus.completed,
          requestedAt: DateTime(2026, 4, 10),
        ),
        _job(
          comicId: 'failed',
          title: 'Failed Comic',
          status: DownloadJobStatus.failed,
          requestedAt: DateTime(2026, 4, 11),
        ),
        _job(
          comicId: 'downloading',
          title: 'Downloading Comic',
          status: DownloadJobStatus.downloading,
          requestedAt: DateTime(2026, 4, 9),
        ),
        _job(
          comicId: 'queued-new',
          title: 'Queued New',
          status: DownloadJobStatus.queued,
          requestedAt: DateTime(2026, 4, 12),
        ),
        _job(
          comicId: 'paused',
          title: 'Paused Comic',
          status: DownloadJobStatus.paused,
          requestedAt: DateTime(2026, 4, 8),
        ),
        _job(
          comicId: 'queued-old',
          title: 'Queued Old',
          status: DownloadJobStatus.queued,
          requestedAt: DateTime(2026, 4, 1),
        ),
      ]).map((job) => job.title).toList(growable: false);

      expect(
        sortedTitles,
        <String>[
          'Downloading Comic',
          'Queued New',
          'Queued Old',
          'Failed Comic',
          'Paused Comic',
          'Completed Comic',
        ],
      );
    });

    testWidgets('filters by title and shows per-status actions when expanded', (
      tester,
    ) async {
      final model = _FakeDownloadManagerModel(
        harness: harness,
        jobsOverride: <DownloadJobSnapshot>[
          _job(
            comicId: 'paused',
            title: 'Paused Comic',
            status: DownloadJobStatus.paused,
            requestedAt: DateTime(2026, 4, 11),
          ),
          _job(
            comicId: 'completed',
            title: 'Downloaded Comic',
            status: DownloadJobStatus.completed,
            requestedAt: DateTime(2026, 4, 10),
          ),
        ],
      );

      await tester.pumpWidget(
        _buildTestWidget(model: model, searchQuery: 'Paused'),
      );
      await tester.pump();

      expect(find.text('Paused Comic'), findsOneWidget);
      expect(find.text('Downloaded Comic'), findsNothing);

      await tester.tap(find.text('Paused Comic'));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Delete Download'), findsNothing);
    });
  });
}

Widget _buildTestWidget({
  required DownloadManagerModel model,
  String searchQuery = '',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<DownloadManagerModel>.value(
      value: model,
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            DownloadJobListSliver(searchQuery: searchQuery),
          ],
        ),
      ),
    ),
  );
}

DownloadJobSnapshot _job({
  required String comicId,
  required String title,
  required DownloadJobStatus status,
  required DateTime requestedAt,
}) {
  return DownloadJobSnapshot(
    comicId: comicId,
    mediaId: comicId,
    title: title,
    thumbnailPath: null,
    status: status,
    totalPages: 10,
    completedPages: status == DownloadJobStatus.completed ? 10 : 3,
    nextPageNumber: 4,
    requestedAt: requestedAt,
    updatedAt: requestedAt,
  );
}

class _FakeDownloadManagerModel extends DownloadManagerModel {
  _FakeDownloadManagerModel({
    required this.harness,
    required this.jobsOverride,
  }) : super(
          nhentaiGateway: FakeNhentaiGateway(),
          cdnConfigService: NhentaiCdnConfigService(),
          downloadQueueRepository: harness.downloadQueueRepository,
          downloadedLibraryRepository: harness.downloadedLibraryRepository,
          downloadSettingsRepository: _FakeDownloadSettingsRepository(),
          downloadAssetStore: DownloadAssetStore(
            directoryResolver: () async => throw UnimplementedError(),
          ),
          imageCompressionService: FakeImageCompressionService(),
          remoteAssetFetcher: FakeRemoteAssetFetcher(),
        );

  final SqliteTestHarness harness;
  final List<DownloadJobSnapshot> jobsOverride;

  @override
  List<DownloadJobSnapshot> get jobs => jobsOverride;

  @override
  Future<void> refresh() async {}

  @override
  bool isMutating(String comicId) => false;

  @override
  Future<String?> loadCoverLocalPath(String comicId) async => null;
}

class _FakeDownloadSettingsRepository
    implements DownloadSettingsRepository {
  @override
  Future<bool> loadAutoResumeEnabled() async => false;

  @override
  Future<void> saveAutoResumeEnabled(bool enabled) async {}

  @override
  Future<int> loadPageIntervalMs() async => 500;

  @override
  Future<void> savePageIntervalMs(int milliseconds) async {}
}
