import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteTestHarness {
  late LocalDatabase localDatabase;
  late ComicRepository comicRepository;
  late CollectionRepository collectionRepository;
  late SearchHistoryRepository searchHistoryRepository;

  Future<void> initialize() async {
    sqfliteFfiInit();
    localDatabase = LocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePathResolver: () async => inMemoryDatabasePath,
    );
    await localDatabase.initialize();
    comicRepository = ComicRepository(localDatabase: localDatabase);
    collectionRepository = CollectionRepository(localDatabase: localDatabase);
    searchHistoryRepository = SearchHistoryRepository(
      localDatabase: localDatabase,
    );
  }

  Future<void> dispose() async {
    await localDatabase.resetForTesting();
  }
}
