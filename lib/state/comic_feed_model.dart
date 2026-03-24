import 'package:concept_nhv/models/collection_summary.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/models/popular_sort_type.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/services/search_query_builder.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ComicFeedModel extends ChangeNotifier {
  ComicFeedModel({
    required this.nhentaiGateway,
    required this.collectionRepository,
    required this.searchHistoryRepository,
    required this.searchQueryBuilder,
  });

  final NhentaiGateway nhentaiGateway;
  final CollectionRepository collectionRepository;
  final SearchHistoryRepository searchHistoryRepository;
  final SearchQueryBuilder searchQueryBuilder;

  final List<Comic> _comics = <Comic>[];
  Future<List<CollectionSummary>>? collectionSummariesFuture;
  int pageLoaded = 1;
  bool _noMorePage = false;
  String _lastQuery = '';
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

  void setLanguage(ComicLanguage language) {
    currentLanguage = language;
    notifyListeners();
  }

  void toggleSort(PopularSortType type) {
    sortByPopularType = sortByPopularType == type ? null : type;
    notifyListeners();
  }

  void refreshCollections() {
    collectionSummariesFuture = collectionRepository.loadCollectionSummaries();
    notifyListeners();
  }

  Future<int?> loadHomeFeed({
    int page = 1,
    bool clearComic = false,
  }) {
    return searchComics(
      query: '',
      page: page,
      clearComic: clearComic,
    );
  }

  Future<int?> searchComics({
    required String query,
    int page = 1,
    PopularSortType? sortType,
    int retryCount = 0,
    bool clearComic = false,
    int? lastStatusCode,
  }) async {
    if (clearComic) {
      _comics.clear();
      _noMorePage = false;
    }

    final languageQueries = <String>[
      currentLanguage.apiQuery,
      ...currentLanguage.fallbackQueries,
    ];
    if (retryCount >= languageQueries.length) {
      return lastStatusCode;
    }

    _lastQuery = query;
    final uri = searchQueryBuilder.buildSearchUri(
      userQuery: query,
      languageQuery: languageQueries[retryCount],
      page: page,
      sortType: sortType ?? sortByPopularType,
    );

    try {
      final freshComics = await nhentaiGateway.searchComics(uri);
      _noMorePage = freshComics.result.isEmpty;
      if (!_noMorePage) {
        _comics.addAll(freshComics.result);
      }
      pageLoaded = page;
      notifyListeners();
      return 200;
    } on DioException catch (error) {
      return searchComics(
        query: query,
        page: page,
        sortType: sortType,
        retryCount: retryCount + 1,
        clearComic: true,
        lastStatusCode: error.response?.statusCode,
      );
    }
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

