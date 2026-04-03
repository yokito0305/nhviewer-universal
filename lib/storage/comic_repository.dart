import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:sqflite/sqflite.dart';

class ComicRepository {
  const ComicRepository({required this.localDatabase});

  final LocalDatabase localDatabase;

  Future<int> upsertComic(StoredComic comic) async {
    final db = await localDatabase.database;
    return db.insert(
      'Comic',
      comic.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertComics(Iterable<StoredComic> comics) async {
    final db = await localDatabase.database;
    final batch = db.batch();
    for (final comic in comics) {
      batch.insert(
        'Comic',
        comic.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
