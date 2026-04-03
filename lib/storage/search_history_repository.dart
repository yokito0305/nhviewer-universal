import 'package:concept_nhv/models/search_history_entry.dart';
import 'package:concept_nhv/storage/local_database.dart';

class SearchHistoryRepository {
  const SearchHistoryRepository({required this.localDatabase});

  final LocalDatabase localDatabase;

  Future<void> save(String query) async {
    final db = await localDatabase.database;
    await db.insert('SearchHistory', <String, Object?>{'query': query});
  }

  Future<List<SearchHistoryEntry>> load() async {
    final db = await localDatabase.database;
    final rows = await db.query('SearchHistory', orderBy: 'created_at DESC');

    return rows.map((row) {
      return SearchHistoryEntry(
        query: row['query']! as String,
        createdAt: DateTime.parse('${row['created_at']}Z').toLocal(),
      );
    }).toList();
  }

  Future<void> remove(String query) async {
    final db = await localDatabase.database;
    await db.delete(
      'SearchHistory',
      where: 'query = ?',
      whereArgs: <Object?>[query],
    );
  }
}
