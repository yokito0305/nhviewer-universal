import 'package:concept_nhv/storage/local_database.dart';
import 'package:sqflite/sqflite.dart';

class OptionsStore {
  const OptionsStore({required this.localDatabase});

  final LocalDatabase localDatabase;

  Future<void> saveOption(String name, String value) async {
    final db = await localDatabase.database;
    await db.insert('Options', <String, Object?>{
      'name': name,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> loadOption(String name) async {
    final db = await localDatabase.database;
    final option = await db.query(
      'Options',
      where: 'name = ?',
      whereArgs: <Object?>[name],
    );
    if (option.isEmpty) {
      return '';
    }
    return option.first['value']! as String;
  }

  Future<int> deleteOptions(Iterable<String> names) async {
    final db = await localDatabase.database;
    final placeholders = List<String>.filled(names.length, '?').join(', ');
    return db.delete(
      'Options',
      where: 'name IN ($placeholders)',
      whereArgs: names.toList(),
    );
  }
}
