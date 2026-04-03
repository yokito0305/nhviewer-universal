import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';

import 'collection_page_snapshot.dart';
import 'load_collection_comics_use_case.dart';

class CollectionPageCoordinator {
  const CollectionPageCoordinator({
    required this.loadCollectionComicsUseCase,
    required this.favoriteSyncModel,
    required this.feedModel,
  });

  final LoadCollectionComicsUseCase loadCollectionComicsUseCase;
  final FavoriteSyncModel favoriteSyncModel;
  final ComicFeedModel feedModel;

  Future<CollectionPageSnapshot> load(CollectionType collectionType) async {
    var didRefreshCollections = false;
    if (collectionType == CollectionType.favorite) {
      final synced = await favoriteSyncModel.syncFavorites();
      if (synced) {
        feedModel.refreshCollections();
        didRefreshCollections = true;
      }
    }

    final comics = await loadCollectionComicsUseCase.execute(collectionType);
    return CollectionPageSnapshot(
      comics: comics,
      didRefreshCollections: didRefreshCollections,
    );
  }

  Future<List<ComicCardData>> refresh(CollectionType collectionType) {
    return loadCollectionComicsUseCase.execute(collectionType);
  }
}
