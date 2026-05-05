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
