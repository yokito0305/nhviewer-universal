import 'package:concept_nhv/models/popular_sort_type.dart';

class SearchQueryBuilder {
  const SearchQueryBuilder();

  Uri buildSearchUri({
    required String userQuery,
    required String languageQuery,
    required int page,
    PopularSortType? sortType,
  }) {
    final normalizedQuery = [
      userQuery.trim(),
      languageQuery.trim(),
    ].where((element) => element.isNotEmpty).join(' ').trim();

    return Uri.https(
      'nhentai.net',
      '/api/galleries/search',
      <String, String>{
        'query': normalizedQuery,
        'page': '$page',
        if (sortType != null) 'sort': sortType.apiValue,
      },
    );
  }
}

