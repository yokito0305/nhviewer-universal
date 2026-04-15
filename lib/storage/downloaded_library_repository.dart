import 'dart:convert';

import 'package:concept_nhv/models/comic.dart' as model;
import 'package:concept_nhv/storage/local_database.dart';
import 'package:drift/drift.dart' as drift;

class DownloadedLibraryRepository {
  const DownloadedLibraryRepository({required this.localDatabase});

  final LocalDatabase localDatabase;

  Future<void> saveDownloadedComic({
    required model.Comic comic,
    required String rootDirectoryPath,
    required String? coverLocalPath,
    DateTime? downloadedAt,
  }) async {
    final timestamp = downloadedAt ?? DateTime.now();
    await localDatabase.into(localDatabase.downloadedComics).insert(
      DownloadedComicsCompanion.insert(
        comicId: comic.id,
        mediaId: comic.mediaId,
        titleEnglish: drift.Value(comic.title.english),
        titleJapanese: drift.Value(comic.title.japanese),
        titlePretty: drift.Value(comic.title.pretty),
        coverLocalPath: drift.Value(coverLocalPath),
        rootDirectoryPath: rootDirectoryPath,
        pageCount: comic.numPages,
        downloadedAt: timestamp.toIso8601String(),
        lastReadAt: const drift.Value.absent(),
        tagsJson: jsonEncode(
          comic.tags
              .map(
                (tag) => <String, dynamic>{
                  'id': tag.id,
                  'type': tag.type,
                  'name': tag.name,
                  'url': tag.url,
                  'count': tag.count,
                },
              )
              .toList(growable: false),
        ),
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteDownloadedComic(String comicId) async {
    final statement = localDatabase.delete(localDatabase.downloadedComics)
      ..where((table) => table.comicId.equals(comicId));
    await statement.go();
  }

  Future<void> saveLastReadAt(String comicId, DateTime timestamp) async {
    final updateStatement = localDatabase.update(localDatabase.downloadedComics)
      ..where((table) => table.comicId.equals(comicId));
    await updateStatement.write(
      DownloadedComicsCompanion(
        lastReadAt: drift.Value(timestamp.toIso8601String()),
      ),
    );
  }

  Future<String?> loadCoverLocalPath(String comicId) async {
    final query = localDatabase.select(localDatabase.downloadedComics)
      ..where((table) => table.comicId.equals(comicId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.coverLocalPath;
  }
}
