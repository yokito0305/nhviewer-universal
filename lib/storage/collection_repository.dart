import 'package:concept_nhv/models/collected_comic.dart';
import 'package:concept_nhv/models/collection_summary.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:sqflite/sqflite.dart';

class CollectionRepository {
  const CollectionRepository({
    required this.localDatabase,
  });

  final LocalDatabase localDatabase;

  Future<int> addComicToCollection({
    required CollectionType collectionType,
    required String comicId,
    String? dateCreated,
  }) async {
    final db = await localDatabase.database;
    return db.insert(
      'Collection',
      <String, Object?>{
        'name': collectionType.storageName,
        'comicid': comicId,
        'dateCreated': dateCreated ?? DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeComicFromCollection({
    required CollectionType collectionType,
    required String comicId,
  }) async {
    final db = await localDatabase.database;
    return db.delete(
      'Collection',
      where: 'name = ? AND comicid = ?',
      whereArgs: <Object?>[collectionType.storageName, comicId],
    );
  }

  Future<List<CollectedComic>> loadCollectionComics(
    CollectionType collectionType,
  ) async {
    final db = await localDatabase.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        col.name AS collection_name,
        col.comicid AS comic_id,
        col.dateCreated AS date_created,
        com.id AS id,
        com.mid AS mid,
        com.title AS title,
        com.images AS images,
        com.pages AS pages
      FROM Collection col
      LEFT JOIN Comic com ON col.comicid = com.id
      WHERE col.name = ?
      ORDER BY col.dateCreated DESC
      ''',
      <Object?>[collectionType.storageName],
    );

    return rows
        .where((row) => row['id'] != null)
        .map(_mapCollectedComic)
        .toList();
  }

  Future<List<CollectionSummary>> loadCollectionSummaries() async {
    final allCollections = await _loadAllCollectedComics();
    final grouped = <CollectionType, List<CollectedComic>>{
      for (final type in CollectionType.values) type: <CollectedComic>[],
    };

    for (final comic in allCollections) {
      final type = CollectionType.fromStorageName(comic.collectionName);
      if (type != null) {
        grouped[type]!.add(comic);
      }
    }

    return CollectionType.values.map((type) {
      final entries = grouped[type]!;
      if (entries.isEmpty) {
        return ComicCardData.placeholderSummary(
          collectionName: type.displayName,
        );
      }

      final firstComic = ComicCardData.fromStoredComic(entries.first.comic);
      return CollectionSummary(
        collectionName: type.displayName,
        collectedCount: entries.length,
        thumbnailUrl: firstComic.thumbnailUrl,
        thumbnailWidth: firstComic.thumbnailWidth,
        thumbnailHeight: firstComic.thumbnailHeight,
      );
    }).toList();
  }

  Future<List<CollectedComic>> _loadAllCollectedComics() async {
    final db = await localDatabase.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        col.name AS collection_name,
        col.comicid AS comic_id,
        col.dateCreated AS date_created,
        com.id AS id,
        com.mid AS mid,
        com.title AS title,
        com.images AS images,
        com.pages AS pages
      FROM Collection col
      LEFT JOIN Comic com ON col.comicid = com.id
      ORDER BY col.dateCreated DESC
      ''',
    );

    return rows
        .where((row) => row['id'] != null)
        .map(_mapCollectedComic)
        .toList();
  }

  CollectedComic _mapCollectedComic(Map<String, Object?> row) {
    return CollectedComic(
      collectionName: row['collection_name']! as String,
      comicId: row['comic_id']! as String,
      dateCreated: DateTime.parse(row['date_created']! as String),
      comic: StoredComic(
        id: row['id']! as String,
        mediaId: row['mid']! as String,
        title: row['title']! as String,
        serializedImages: row['images']! as String,
        pages: row['pages']! as int,
      ),
    );
  }
}

