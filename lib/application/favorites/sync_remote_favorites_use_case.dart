import 'package:concept_nhv/application/favorites/favorite_sync_result.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';
import 'package:concept_nhv/storage/collection_repository.dart';

class SyncRemoteFavoritesUseCase {
  const SyncRemoteFavoritesUseCase({
    required this.collectionRepository,
    required this.remoteFavoriteGateway,
    required this.authService,
  });

  final CollectionRepository collectionRepository;
  final RemoteFavoriteGateway remoteFavoriteGateway;
  final NhentaiAuthService authService;

  Future<FavoriteSyncResult> execute() async {
    try {
      final isValid = await authService.validateStoredApiKey();
      if (!isValid) {
        return FavoriteSyncResult(
          favoriteIds: await _loadCachedFavoriteIds(),
          isAuthenticated: false,
          lastSyncAt: null,
          success: false,
          errorMessage: 'API key expired or invalid. Showing cached favorites.',
        );
      }

      final comics = await remoteFavoriteGateway.loadRemoteFavorites();
      await collectionRepository.replaceCollectionCache(
        collectionType: CollectionType.favorite,
        comics: comics.map(StoredComic.fromComic),
      );
      return FavoriteSyncResult(
        favoriteIds: comics.map((comic) => comic.id).toSet(),
        isAuthenticated: true,
        lastSyncAt: DateTime.now(),
        success: true,
      );
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
        errorMessage: 'Failed to sync API favorites.',
      );
    }
  }

  Future<Set<String>> _loadCachedFavoriteIds() {
    return collectionRepository.loadCollectedComicIds(CollectionType.favorite);
  }
}
