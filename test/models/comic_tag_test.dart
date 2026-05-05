import 'package:concept_nhv/models/comic_tag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComicTagQuery.query', () {
    test('builds type:slug from type and name', () {
      final tag = ComicTag(type: 'tag', name: 'full color');
      expect(tag.query, 'tag:full-color');
    });

    test('lowercases the name', () {
      final tag = ComicTag(type: 'artist', name: 'SomeArtist');
      expect(tag.query, 'artist:someartist');
    });

    test('replaces spaces with hyphens', () {
      final tag = ComicTag(type: 'parody', name: 'my hero academia');
      expect(tag.query, 'parody:my-hero-academia');
    });

    test('defaults type to "tag" when null', () {
      final tag = ComicTag(type: null, name: 'glasses');
      expect(tag.query, 'tag:glasses');
    });

    test('handles null name as empty slug', () {
      final tag = ComicTag(type: 'language', name: null);
      expect(tag.query, 'language:');
    });
  });
}
