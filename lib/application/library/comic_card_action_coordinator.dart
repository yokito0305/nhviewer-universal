import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';

import 'comic_card_action_result.dart';
import 'remove_comic_from_collection_use_case.dart';
import 'save_comic_to_collection_use_case.dart';

class ComicCardActionCoordinator {
  const ComicCardActionCoordinator({
    required this.saveComicToCollectionUseCase,
    required this.removeComicFromCollectionUseCase,
    required this.favoriteSyncModel,
    required this.feedModel,
    required this.readerModel,
  });

  final SaveComicToCollectionUseCase saveComicToCollectionUseCase;
  final RemoveComicFromCollectionUseCase removeComicFromCollectionUseCase;
  final FavoriteSyncModel favoriteSyncModel;
  final ComicFeedModel feedModel;
  final ComicReaderModel readerModel;

  Future<void> openComic(ComicCardData comic) {
    return readerModel.loadComicDetail(comic.id);
  }

  Future<ComicCardActionResult> saveToCollection({
    required ComicCardData comic,
    required CollectionType targetCollection,
  }) async {
    await saveComicToCollectionUseCase.execute(
      comic: comic,
      targetCollection: targetCollection,
    );
    feedModel.refreshCollections();
    return ComicCardActionResult(
      success: true,
      message: 'Added comic to ${targetCollection.displayName}',
      triggerHaptic: true,
    );
  }

  Future<ComicCardActionResult> removeFromCollection({
    required ComicCardData comic,
    required CollectionType collectionType,
  }) async {
    if (collectionType == CollectionType.favorite) {
      return toggleFavorite(comic: comic, collectionType: collectionType);
    }

    await removeComicFromCollectionUseCase.execute(
      collectionType: collectionType,
      comicId: comic.id,
    );
    feedModel.refreshCollections();
    return const ComicCardActionResult(
      success: true,
      shouldRefreshCollection: true,
    );
  }

  Future<ComicCardActionResult> toggleFavorite({
    required ComicCardData comic,
    CollectionType? collectionType,
  }) async {
    final success = await favoriteSyncModel.toggleFavorite(comic);
    feedModel.refreshCollections();
    final isFavorite = favoriteSyncModel.isFavorite(comic.id);
    final message = success
        ? isFavorite
              ? 'Added comic to Website Favorite'
              : 'Removed comic from Website Favorite'
        : favoriteSyncModel.syncError ?? 'Failed to update Website Favorite';

    return ComicCardActionResult(
      success: success,
      message: message,
      triggerHaptic: success,
      shouldRefreshCollection:
          success && collectionType == CollectionType.favorite,
    );
  }
}
