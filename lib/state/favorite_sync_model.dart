import 'dart:collection';

import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:flutter/material.dart';

class FavoriteSyncModel extends ChangeNotifier {
  FavoriteSyncModel({
    required this.collectionRepository,
    required this.remoteFavoriteGateway,
    required this.authService,
  });

  final CollectionRepository collectionRepository;
  final RemoteFavoriteGateway remoteFavoriteGateway;
  final NhentaiAuthService authService;

  final Set<String> _favoriteIds = <String>{};
  final Set<String> _mutatingIds = <String>{};
  bool _isSyncing = false;
  bool _isAuthenticated = false;
  bool _initialized = false;
  String? _syncError;
  DateTime? _lastSyncAt;

  Set<String> get favoriteIds => UnmodifiableSetView<String>(_favoriteIds);
  bool get isSyncing => _isSyncing;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _initialized;
  String? get syncError => _syncError;
  DateTime? get lastSyncAt => _lastSyncAt;
  bool get hasCachedFavorites => _favoriteIds.isNotEmpty;

  bool isFavorite(String comicId) => _favoriteIds.contains(comicId);

  bool isMutating(String comicId) => _mutatingIds.contains(comicId);

  Future<void> initialize() async {
    final favoriteIds = await collectionRepository.loadCollectedComicIds(
      CollectionType.favorite,
    );
    final credential = await authService.loadCredential();
    _favoriteIds
      ..clear()
      ..addAll(favoriteIds);
    _isAuthenticated = !credential.isEmpty;
    _lastSyncAt = credential.lastValidatedAt;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> syncFavorites() async {
    if (_isSyncing) {
      return false;
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final isValid = await authService.validateStoredApiKey();
      _isAuthenticated = isValid;
      if (!isValid) {
        await _reloadFavoriteIdsFromCache();
        _syncError = 'API key expired or invalid. Showing cached favorites.';
        return false;
      }

      final comics = await remoteFavoriteGateway.loadRemoteFavorites();
      await collectionRepository.replaceCollectionCache(
        collectionType: CollectionType.favorite,
        comics: comics.map(StoredComic.fromComic),
      );
      _favoriteIds
        ..clear()
        ..addAll(comics.map((comic) => comic.id));
      _lastSyncAt = DateTime.now();
      _syncError = null;
      return true;
    } on RemoteFavoriteAuthException catch (error) {
      _isAuthenticated = false;
      await _reloadFavoriteIdsFromCache();
      _syncError = error.message;
      return false;
    } catch (_) {
      await _reloadFavoriteIdsFromCache();
      _syncError = 'Failed to sync API favorites.';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> saveAndValidateApiKey(String apiKey) async {
    await authService.saveAndValidateApiKey(apiKey);
    await initialize();
  }

  Future<bool> toggleFavorite(ComicCardData comic) async {
    if (_mutatingIds.contains(comic.id)) {
      return false;
    }

    final isValid = await authService.validateStoredApiKey();
    _isAuthenticated = isValid;
    if (!isValid) {
      _syncError = 'Valid API key required to edit favorites.';
      notifyListeners();
      return false;
    }

    _mutatingIds.add(comic.id);
    _syncError = null;
    notifyListeners();

    try {
      if (isFavorite(comic.id)) {
        await remoteFavoriteGateway.removeRemoteFavorite(comic.id);
      } else {
        await remoteFavoriteGateway.addRemoteFavorite(comic.id);
      }
      return syncFavorites();
    } on RemoteFavoriteAuthException catch (error) {
      _isAuthenticated = false;
      _syncError = error.message;
      return false;
    } catch (_) {
      _syncError = 'Failed to update API favorite.';
      return false;
    } finally {
      _mutatingIds.remove(comic.id);
      notifyListeners();
    }
  }

  Future<void> clearApiKey() async {
    await authService.clearApiKey();
    _isAuthenticated = false;
    _lastSyncAt = null;
    _syncError = null;
    notifyListeners();
  }

  Future<void> _reloadFavoriteIdsFromCache() async {
    final favoriteIds = await collectionRepository.loadCollectedComicIds(
      CollectionType.favorite,
    );
    _favoriteIds
      ..clear()
      ..addAll(favoriteIds);
  }
}
