import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/models/popular_sort_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComicLanguage', () {
    test('returns primary query and fallback queries', () {
      expect(ComicLanguage.chinese.apiQuery, 'language:chinese');
      expect(
        ComicLanguage.chinese.fallbackQueries,
        const <String>['-language:english -language:japanese'],
      );
      expect(ComicLanguage.english.fallbackQueries, isEmpty);
    });
  });

  group('PopularSortType', () {
    test('exposes API values', () {
      expect(PopularSortType.allTime.apiValue, 'popular');
      expect(PopularSortType.month.apiValue, 'popular-month');
    });
  });
}

