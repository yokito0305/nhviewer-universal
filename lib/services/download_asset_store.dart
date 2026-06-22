import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef DownloadDirectoryResolver = Future<Directory> Function();

class DownloadAssetStore {
  DownloadAssetStore({DownloadDirectoryResolver? directoryResolver})
    : _directoryResolver = directoryResolver ?? _defaultDirectoryResolver;

  final DownloadDirectoryResolver _directoryResolver;

  Future<Directory> resolveRootDirectory(String comicId) async {
    final baseDirectory = await _directoryResolver();
    final comicDirectory = Directory(p.join(baseDirectory.path, comicId));
    await comicDirectory.create(recursive: true);
    return comicDirectory;
  }

  Future<String> savePage({
    required String comicId,
    required int pageNumber,
    required Uint8List bytes,
    required String extension,
  }) async {
    final rootDirectory = await resolveRootDirectory(comicId);
    final pagesDirectory = Directory(p.join(rootDirectory.path, 'pages'));
    await pagesDirectory.create(recursive: true);
    final file = File(p.join(pagesDirectory.path, '$pageNumber.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> saveCover({
    required String comicId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final rootDirectory = await resolveRootDirectory(comicId);
    final file = File(p.join(rootDirectory.path, 'cover.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Returns the page numbers (1-based) that are missing or empty on disk.
  ///
  /// A page is considered missing if its file does not exist or its size is 0.
  /// [pageLocalPaths] maps page number → absolute local path recorded in the DB.
  Future<List<int>> verifyPages(Map<int, String?> pageLocalPaths) async {
    final missing = <int>[];
    for (final entry in pageLocalPaths.entries) {
      final localPath = entry.value;
      if (localPath == null || localPath.isEmpty) {
        missing.add(entry.key);
        continue;
      }
      final file = File(localPath);
      if (!await file.exists() || await file.length() == 0) {
        missing.add(entry.key);
      }
    }
    missing.sort();
    return missing;
  }

  /// Returns true if [coverLocalPath] points to an existing, non-empty file.
  Future<bool> coverExists(String? coverLocalPath) async {
    if (coverLocalPath == null || coverLocalPath.isEmpty) {
      return false;
    }
    final file = File(coverLocalPath);
    return await file.exists() && await file.length() > 0;
  }

  Future<void> deleteComicAssets(String comicId) async {
    final rootDirectory = Directory(
      p.join((await _directoryResolver()).path, comicId),
    );
    if (await rootDirectory.exists()) {
      await rootDirectory.delete(recursive: true);
    }
  }

  static Future<Directory> _defaultDirectoryResolver() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final downloadsDirectory = Directory(
      p.join(supportDirectory.path, 'downloads'),
    );
    await downloadsDirectory.create(recursive: true);
    return downloadsDirectory;
  }
}
