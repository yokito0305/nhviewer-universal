import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LocalDatabase localDatabase;
  late ComicRepository comicRepository;
  late CollectionRepository collectionRepository;
  late SearchHistoryRepository searchHistoryRepository;

  setUp(() async {
    sqfliteFfiInit();
    localDatabase = LocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePathResolver: () async => inMemoryDatabasePath,
    );
    await localDatabase.initialize();
    comicRepository = ComicRepository(localDatabase: localDatabase);
    collectionRepository = CollectionRepository(localDatabase: localDatabase);
    searchHistoryRepository = SearchHistoryRepository(localDatabase: localDatabase);
  });

  tearDown(() async {
    await localDatabase.resetForTesting();
  });

  test('upsert comics and load collection summaries', () async {
    await comicRepository.upsertComic(
      StoredComic(
        id: '1',
        mediaId: '9',
        title: 'Stored Comic',
        serializedImages:
            '{"pages":[{"t":"j","w":100,"h":200}],"cover":{"t":"j","w":100,"h":200},"thumbnail":{"t":"w","w":50,"h":100}}',
        pages: 1,
      ),
    );

    await collectionRepository.addComicToCollection(
      collectionType: CollectionType.favorite,
      comicId: '1',
    );

    final summaries = await collectionRepository.loadCollectionSummaries();
    final favorite = summaries.firstWhere(
      (summary) => summary.collectionName == 'Favorite',
    );

    expect(favorite.collectedCount, 1);
    expect(favorite.thumbnailUrl, contains('thumb.webp'));
  });

  test('legacy serialized image fallback still maps to a thumbnail', () {
    final card = ComicCardData.fromStoredComic(
      StoredComic(
        id: '1',
        mediaId: '9',
        title: 'Legacy',
        serializedImages: 'jjjj',
        pages: 4,
      ),
    );

    expect(card.thumbnailUrl, contains('thumb.jpg'));
    expect(card.thumbnailWidth, 9);
    expect(card.thumbnailHeight, 16);
  });

  test('search history saves and loads entries', () async {
    await searchHistoryRepository.save('sample');
    final entries = await searchHistoryRepository.load();

    expect(entries, hasLength(1));
    expect(entries.first.query, 'sample');
  });
}

