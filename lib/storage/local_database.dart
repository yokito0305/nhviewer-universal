import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

part 'local_database.g.dart';

typedef DatabasePathResolver = Future<String> Function();

class AppOptions extends Table {
  @override
  String get tableName => 'Options';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{name},
  ];
}

class Comics extends Table {
  @override
  String get tableName => 'Comic';

  TextColumn get id => text()();
  TextColumn get mid => text()();
  TextColumn get title => text()();
  TextColumn get images => text()();
  IntColumn get pages => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Collections extends Table {
  @override
  String get tableName => 'Collection';

  TextColumn get name => text()();
  TextColumn get comicid => text()();
  TextColumn get dateCreated => text().named('dateCreated')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{name, comicid};
}

class SearchHistories extends Table {
  @override
  String get tableName => 'SearchHistory';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get createdAt =>
      text().named('created_at').customConstraint('NOT NULL DEFAULT CURRENT_TIMESTAMP')();
}

@DriftDatabase(tables: [AppOptions, Comics, Collections, SearchHistories])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase({
    QueryExecutor? executor,
    DatabasePathResolver? databasePathResolver,
  }) : _databasePathResolver = databasePathResolver ?? _defaultDatabasePath,
       super(
         executor ??
             _openConnection(databasePathResolver ?? _defaultDatabasePath),
       );

  final DatabasePathResolver _databasePathResolver;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL, value TEXT NOT NULL)',
        );
      }
      if (from < 3) {
        await customStatement('DROP TABLE IF EXISTS Options');
        await customStatement(
          'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, value TEXT NOT NULL)',
        );
      }
      if (from < 4) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS SearchHistory(id INTEGER PRIMARY KEY, query TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)',
        );
      }
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT 1').get();
  }

  Future<void> resetForTesting() => close();

  Future<String> resolveDatabasePath() => _databasePathResolver();

  static QueryExecutor _openConnection(
    DatabasePathResolver databasePathResolver,
  ) {
    return LazyDatabase(() async {
      final path = await databasePathResolver();
      final file = File(path);
      final temporaryDirectory = await getTemporaryDirectory();
      sqlite3.tempDirectory = temporaryDirectory.path;
      return NativeDatabase.createInBackground(file);
    });
  }

  static Future<String> _defaultDatabasePath() async {
    if (kIsWeb) {
      throw UnsupportedError('LocalDatabase is not supported on web.');
    }

    if (Platform.isIOS) {
      return p.join((await getLibraryDirectory()).path, 'database.db');
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final databasesDirectory = Directory(
      p.join(supportDirectory.parent.path, 'databases'),
    );
    await databasesDirectory.create(recursive: true);
    return p.join(databasesDirectory.path, 'database.db');
  }
}
