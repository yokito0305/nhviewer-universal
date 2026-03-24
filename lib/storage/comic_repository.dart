import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:sqflite/sqflite.dart';

class ComicRepository {
  const ComicRepository({
    required this.localDatabase,
  });

  final LocalDatabase localDatabase;

  Future<int> upsertComic(StoredComic comic) async {
    final db = await localDatabase.database;
    return db.insert(
      'Comic',
      comic.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
