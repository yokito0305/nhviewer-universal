import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef DatabasePathResolver = Future<String> Function();

class LocalDatabase {
  LocalDatabase({
    DatabaseFactory? databaseFactory,
    DatabasePathResolver? databasePathResolver,
  })  : _databaseFactory = databaseFactory ?? databaseFactorySqflitePlugin,
        _databasePathResolver = databasePathResolver ?? _defaultDatabasePath;

  final DatabaseFactory _databaseFactory;
  final DatabasePathResolver _databasePathResolver;
  Future<Database>? _databaseFuture;

  Future<void> initialize() async {
    await database;
  }

  Future<Database> get database async {
    return _databaseFuture ??= _openDatabase();
  }

  Future<void> resetForTesting() async {
    if (_databaseFuture != null) {
      final db = await _databaseFuture!;
      await db.close();
      _databaseFuture = null;
    }
  }

  Future<Database> _openDatabase() async {
    final path = await _databasePathResolver();
    return _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, value TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE Comic(id TEXT NOT NULL PRIMARY KEY, mid TEXT NOT NULL, title TEXT NOT NULL, images TEXT NOT NULL, pages INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE Collection(name TEXT NOT NULL, comicid TEXT NOT NULL, dateCreated TEXT NOT NULL, PRIMARY KEY(name, comicid))',
          );
          await db.execute(
            'CREATE TABLE SearchHistory(id INTEGER PRIMARY KEY, query TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL, value TEXT NOT NULL)',
            );
          }
          if (oldVersion < 3) {
            await db.execute('DROP TABLE Options');
            await db.execute(
              'CREATE TABLE Options(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, value TEXT NOT NULL)',
            );
          }
          if (oldVersion < 4) {
            await db.execute(
              'CREATE TABLE SearchHistory(id INTEGER PRIMARY KEY, query TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)',
            );
          }
        },
      ),
    );
  }

  static Future<String> _defaultDatabasePath() async {
    if (kIsWeb) {
      throw UnsupportedError('LocalDatabase is not supported on web.');
    }

    if (Platform.isIOS) {
      return join((await getLibraryDirectory()).path, 'database.db');
    }

    return join(await getDatabasesPath(), 'database.db');
  }
}

