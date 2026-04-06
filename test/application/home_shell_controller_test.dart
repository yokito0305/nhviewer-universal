import 'package:concept_nhv/application/feed/load_collection_summaries_use_case.dart';
import 'package:concept_nhv/application/feed/search_comics_use_case.dart';
import 'package:concept_nhv/application/home/home_shell_controller.dart';
import 'package:concept_nhv/application/reader/load_comic_detail_use_case.dart';
import 'package:concept_nhv/application/reader/open_comic_use_case.dart';
import 'package:concept_nhv/services/search_query_builder.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:concept_nhv/storage/reader_progress_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fakes/fake_nhentai_gateway.dart';
import '../test_support/fakes/fake_reader_settings_repository.dart';
import '../test_support/fixtures/sample_comic.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('HomeShellController', () {
    late SqliteTestHarness harness;
    late HomeUiModel homeUiModel;
    late ComicFeedModel feedModel;
    late ComicReaderModel readerModel;
    late HomeShellController controller;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
      homeUiModel = HomeUiModel();
      feedModel = ComicFeedModel(
        searchComicsUseCase: SearchComicsUseCase(
          nhentaiGateway: FakeNhentaiGateway(),
          searchQueryBuilder: const SearchQueryBuilder(),
        ),
        loadCollectionSummariesUseCase: LoadCollectionSummariesUseCase(
          collectionRepository: harness.collectionRepository,
        ),
      );
      readerModel = ComicReaderModel(
        loadComicDetailUseCase: LoadComicDetailUseCase(
          nhentaiGateway: FakeNhentaiGateway(detailComic: sampleComic(id: '77')),
        ),
        openComicUseCase: OpenComicUseCase(
          comicRepository: harness.comicRepository,
          collectionRepository: harness.collectionRepository,
        ),
        readerProgressRepository: ReaderProgressStore(
          optionsStore: OptionsStore(localDatabase: harness.localDatabase),
        ),
        readerSettingsRepository: FakeReaderSettingsRepository(),
      );
      controller = HomeShellController(
        searchHistoryRepository: harness.searchHistoryRepository,
        homeUiModel: homeUiModel,
        feedModel: feedModel,
        readerModel: readerModel,
      );
    });

    tearDown(() async {
      homeUiModel.searchController.dispose();
      homeUiModel.dispose();
      readerModel.dispose();
      feedModel.dispose();
      await harness.dispose();
    });

    test('opens the reader flow for numeric search values', () async {
      final result = await controller.submitSearch('77');
      final history = await harness.searchHistoryRepository.load();

      expect(result.openComicReader, isTrue);
      expect(result.comicId, '77');
      expect(readerModel.currentComic?.id, '77');
      expect(history.first.query, '77');
    });

    test('runs feed search for text queries and returns to index tab', () async {
      homeUiModel.setNavigationIndex(2);

      final result = await controller.submitSearch('tag:test');
      final history = await harness.searchHistoryRepository.load();

      expect(result.openComicReader, isFalse);
      expect(homeUiModel.navigationIndex, 0);
      expect(homeUiModel.isLoading, isFalse);
      expect(feedModel.comicsLoaded, greaterThan(0));
      expect(history.first.query, 'tag:test');
    });
  });
}
