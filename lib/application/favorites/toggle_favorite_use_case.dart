import 'package:concept_nhv/application/favorites/favorite_sync_result.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';
import 'package:concept_nhv/storage/collection_repository.dart';

import 'sync_remote_favorites_use_case.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase({
    required this.collectionRepository,
    required this.remoteFavoriteGateway,
    required this.authService,
    required this.syncRemoteFavoritesUseCase,
  });

  final CollectionRepository collectionRepository;
  final RemoteFavoriteGateway remoteFavoriteGateway;
  final NhentaiAuthService authService;
  final SyncRemoteFavoritesUseCase syncRemoteFavoritesUseCase;

  Future<FavoriteSyncResult> execute({
    required ComicCardData comic,
    required bool isFavorite,
  }) async {
    final isValid = await authService.validateStoredApiKey();
    if (!isValid) {
      return FavoriteSyncResult(
        favoriteIds: await _loadCachedFavoriteIds(),
        isAuthenticated: false,
        lastSyncAt: null,
        success: false,
        errorMessage: 'Valid API key required to edit favorites.',
      );
    }

    try {
      if (isFavorite) {
        await remoteFavoriteGateway.removeRemoteFavorite(comic.id);
      } else {
        await remoteFavoriteGateway.addRemoteFavorite(comic.id);
      }
      return syncRemoteFavoritesUseCase.execute();
    } on RemoteFavoriteAuthException catch (error) {
      return FavoriteSyncResult(
        favoriteIds: await _loadCachedFavoriteIds(),
        isAuthenticated: false,
        lastSyncAt: null,
        success: false,
        errorMessage: error.message,
      );
    } catch (_) {
      return FavoriteSyncResult(
        favoriteIds: await _loadCachedFavoriteIds(),
        isAuthenticated: true,
        lastSyncAt: null,
        success: false,
        errorMessage: 'Failed to update API favorite.',
      );
    }
  }

  Future<Set<String>> _loadCachedFavoriteIds() {
    return collectionRepository.loadCollectedComicIds(
      CollectionType.favorite,
    );
  }
}
