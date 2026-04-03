import 'package:concept_nhv/models/stored_comic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('ComicRepository', () {
    late SqliteTestHarness harness;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('upserts a comic into the local comic table', () async {
      await harness.comicRepository.upsertComic(
        StoredComic(
          id: '1',
          mediaId: '9',
          title: 'Stored Comic',
          serializedImages: '{"thumbnail":{"t":"w","w":50,"h":100}}',
          pages: 1,
        ),
      );

      final db = await harness.localDatabase.database;
      final rows = await db.query('Comic');

      expect(rows, hasLength(1));
      expect(rows.single['id'], '1');
      expect(rows.single['mid'], '9');
      expect(rows.single['title'], 'Stored Comic');
    });
  });
}
