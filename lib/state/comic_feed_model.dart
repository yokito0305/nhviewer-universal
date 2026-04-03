import 'package:concept_nhv/application/feed/load_collection_summaries_use_case.dart';
import 'package:concept_nhv/application/feed/search_comics_use_case.dart';
import 'package:concept_nhv/models/collection_summary.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/models/popular_sort_type.dart';
import 'package:flutter/material.dart';

class ComicFeedModel extends ChangeNotifier {
  ComicFeedModel({
    required this.searchComicsUseCase,
    required this.loadCollectionSummariesUseCase,
  });

  final SearchComicsUseCase searchComicsUseCase;
  final LoadCollectionSummariesUseCase loadCollectionSummariesUseCase;

  final List<Comic> _comics = <Comic>[];
  Future<List<CollectionSummary>>? collectionSummariesFuture;
  int pageLoaded = 1;
  bool _noMorePage = false;
  String _lastQuery = '';
  String? _feedErrorMessage;
  ComicLanguage currentLanguage = ComicLanguage.chinese;
  PopularSortType? sortByPopularType;

  List<Comic>? get comics {
    if (_comics.isEmpty) {
      return null;
    }
    return List<Comic>.unmodifiable(_comics);
  }

  bool get noMorePage => _noMorePage;
  int get comicsLoaded => _comics.length;
  String? get feedErrorMessage => _feedErrorMessage;

  void setLanguage(ComicLanguage language) {
    currentLanguage = language;
    notifyListeners();
  }

  void toggleSort(PopularSortType type) {
    sortByPopularType = sortByPopularType == type ? null : type;
    notifyListeners();
  }

  void refreshCollections() {
    collectionSummariesFuture = loadCollectionSummariesUseCase.execute();
    notifyListeners();
  }

  Future<int?> loadHomeFeed({int page = 1, bool clearComic = false}) {
    return searchComics(query: '', page: page, clearComic: clearComic);
  }

  Future<int?> searchComics({
    required String query,
    int page = 1,
    PopularSortType? sortType,
    bool clearComic = false,
  }) async {
    if (clearComic) {
      _comics.clear();
      _noMorePage = false;
    }

    _lastQuery = query;
    final result = await searchComicsUseCase.execute(
      query: query,
      page: page,
      language: currentLanguage,
      sortType: sortType ?? sortByPopularType,
    );

    _feedErrorMessage = result.errorMessage;
    _noMorePage = result.noMorePage;
    if (!_noMorePage) {
      _comics.addAll(result.comics);
    }
    pageLoaded = result.pageLoaded;
    notifyListeners();
    return result.statusCode;
  }

  Future<void> fetchNextPage({int? page}) async {
    final targetPage = page ?? pageLoaded + 1;
    await searchComics(
      query: _lastQuery,
      page: targetPage,
      clearComic: targetPage == 1,
    );
  }
}
