import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';

import 'home_search_action_result.dart';

class HomeShellController {
  const HomeShellController({
    required this.searchHistoryRepository,
    required this.homeUiModel,
    required this.feedModel,
    required this.readerModel,
  });

  final SearchHistoryRepository searchHistoryRepository;
  final HomeUiModel homeUiModel;
  final ComicFeedModel feedModel;
  final ComicReaderModel readerModel;

  Future<HomeSearchActionResult> submitSearch(String value) async {
    await searchHistoryRepository.save(value);

    if (int.tryParse(value) != null) {
      await readerModel.loadComicDetail(value);
      return HomeSearchActionResult(openComicReader: true, comicId: value);
    }

    homeUiModel.closeSearchView(value);
    if (homeUiModel.navigationIndex != 0) {
      homeUiModel.setNavigationIndex(0);
    }

    homeUiModel.setLoading(true);
    await feedModel.searchComics(query: value, clearComic: true);
    homeUiModel.setLoading(false);
    return const HomeSearchActionResult(openComicReader: false);
  }

  Future<int?> retryHomeFeed() async {
    homeUiModel.setLoading(true);
    final statusCode = await feedModel.loadHomeFeed(clearComic: true);
    homeUiModel.setLoading(false);
    return statusCode;
  }
}
