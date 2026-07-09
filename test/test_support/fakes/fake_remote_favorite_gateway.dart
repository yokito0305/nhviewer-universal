import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';

import '../fixtures/sample_comic.dart';

class FakeRemoteFavoriteGateway implements RemoteFavoriteGateway {
  List<Comic> remoteFavorites = <Comic>[];
  final List<String> addedComicIds = <String>[];
  final List<String> removedComicIds = <String>[];
  bool throwAuthException = false;

  @override
  Future<void> addRemoteFavorite(String comicId) async {
    addedComicIds.add(comicId);
    if (remoteFavorites.every((comic) => comic.id != comicId)) {
      remoteFavorites = <Comic>[...remoteFavorites, sampleComic(id: comicId)];
    }
  }

  @override
  Future<List<Comic>> loadRemoteFavorites({
    void Function(int page, int totalPages)? onProgress,
    void Function(Duration retryIn)? onRateLimit,
  }) async {
    if (throwAuthException) {
      throw const RemoteFavoriteAuthException(
        'API key expired or invalid. Showing cached favorites.',
      );
    }
    return List<Comic>.from(remoteFavorites);
  }

  @override
  Future<void> removeRemoteFavorite(String comicId) async {
    removedComicIds.add(comicId);
    remoteFavorites =
        remoteFavorites.where((comic) => comic.id != comicId).toList();
  }
}
