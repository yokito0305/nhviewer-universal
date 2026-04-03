import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';

import '../fixtures/sample_comic.dart';

class FakeRemoteFavoriteGateway implements RemoteFavoriteGateway {
  List<Comic> remoteFavorites = <Comic>[];
  final List<String> addedComicIds = <String>[];
  final List<String> removedComicIds = <String>[];

  @override
  Future<void> addRemoteFavorite(String comicId) async {
    addedComicIds.add(comicId);
    if (remoteFavorites.every((comic) => comic.id != comicId)) {
      remoteFavorites = <Comic>[...remoteFavorites, sampleComic(id: comicId)];
    }
  }

  @override
  Future<List<Comic>> loadRemoteFavorites() async {
    return List<Comic>.from(remoteFavorites);
  }

  @override
  Future<void> removeRemoteFavorite(String comicId) async {
    removedComicIds.add(comicId);
    remoteFavorites =
        remoteFavorites.where((comic) => comic.id != comicId).toList();
  }
}
