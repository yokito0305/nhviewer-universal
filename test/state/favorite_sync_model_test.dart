import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/models/nhentai_api_credential.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/nhentai_api_key_store.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_support/fakes.dart';

void main() {
  late LocalDatabase localDatabase;
  late ComicRepository comicRepository;
  late CollectionRepository collectionRepository;
  late NhentaiApiKeyStore apiKeyStore;
  late FakeNhentaiAuthService authService;
  late FakeRemoteFavoriteGateway remoteFavoriteGateway;
  late FavoriteSyncModel model;

  setUp(() async {
    sqfliteFfiInit();
    localDatabase = LocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePathResolver: () async => inMemoryDatabasePath,
    );
    await localDatabase.initialize();
    comicRepository = ComicRepository(localDatabase: localDatabase);
    collectionRepository = CollectionRepository(localDatabase: localDatabase);
    apiKeyStore = NhentaiApiKeyStore(secureStore: MemorySecureKeyValueStore());
    authService = FakeNhentaiAuthService(apiKeyStore);
    remoteFavoriteGateway = FakeRemoteFavoriteGateway();
    model = FavoriteSyncModel(
      collectionRepository: collectionRepository,
      remoteFavoriteGateway: remoteFavoriteGateway,
      authService: authService,
    );
  });

  tearDown(() async {
    await localDatabase.resetForTesting();
  });

  test('initialize loads cached favorites and auth state', () async {
    await comicRepository.upsertComic(StoredComic.fromComic(sampleComic(id: '1')));
    await collectionRepository.addComicToCollection(
      collectionType: CollectionType.favorite,
      comicId: '1',
    );
    await apiKeyStore.save(await authService.saveAndValidateApiKey('key-123'));

    await model.initialize();

    expect(model.favoriteIds, <String>{'1'});
    expect(model.isAuthenticated, isTrue);
    expect(model.isInitialized, isTrue);
    expect(model.lastSyncAt, isNotNull);
  });

  test('syncFavorites refreshes remote favorites into local cache', () async {
    remoteFavoriteGateway.remoteFavorites = <Comic>[
      sampleComic(id: '11'),
      sampleComic(id: '22'),
    ];
    authService.isValid = true;
    await model.initialize();

    final ok = await model.syncFavorites();
    final ids = await collectionRepository.loadCollectedComicIds(
      CollectionType.favorite,
    );

    expect(ok, isTrue);
    expect(model.isAuthenticated, isTrue);
    expect(model.syncError, isNull);
    expect(model.favoriteIds, <String>{'11', '22'});
    expect(ids, <String>{'11', '22'});
  });

  test('syncFavorites keeps cached favorites on auth failure', () async {
    await comicRepository.upsertComic(StoredComic.fromComic(sampleComic(id: '1')));
    await collectionRepository.addComicToCollection(
      collectionType: CollectionType.favorite,
      comicId: '1',
    );
    authService.isValid = false;
    await model.initialize();

    final ok = await model.syncFavorites();

    expect(ok, isFalse);
    expect(model.isAuthenticated, isFalse);
    expect(model.favoriteIds, <String>{'1'});
    expect(
      model.syncError,
      'API key expired or invalid. Showing cached favorites.',
    );
  });

  test('toggleFavorite adds and removes remote favorite after auth', () async {
    remoteFavoriteGateway.remoteFavorites = <Comic>[];
    authService.isValid = true;
    await model.initialize();
    final comic = ComicCardData.fromComic(sampleComic(id: '7'));

    final addOk = await model.toggleFavorite(comic);

    expect(addOk, isTrue);
    expect(remoteFavoriteGateway.addedComicIds, <String>['7']);
    expect(model.isFavorite('7'), isTrue);

    final removeOk = await model.toggleFavorite(comic);

    expect(removeOk, isTrue);
    expect(remoteFavoriteGateway.removedComicIds, <String>['7']);
    expect(model.isFavorite('7'), isFalse);
  });

  test('clearApiKey resets auth state and last sync metadata', () async {
    authService.isValid = true;
    await model.saveAndValidateApiKey('key-123');

    await model.clearApiKey();

    expect(model.isAuthenticated, isFalse);
    expect(model.lastSyncAt, isNull);
    expect(model.syncError, isNull);
    expect((await apiKeyStore.load()).isEmpty, isTrue);
  });
}

class FakeNhentaiAuthService extends NhentaiAuthService {
  FakeNhentaiAuthService(NhentaiApiKeyStore apiKeyStore)
    : _apiKeyStore = apiKeyStore,
      super(apiKeyStore: apiKeyStore);

  final NhentaiApiKeyStore _apiKeyStore;
  bool isValid = false;
  String username = 'tester';

  @override
  Future<bool> validateStoredApiKey() async {
    return isValid;
  }

  @override
  Future<void> clearApiKey() {
    isValid = false;
    return _apiKeyStore.clear();
  }

  @override
  Future<NhentaiApiCredential> saveAndValidateApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw const NhentaiAuthException('API key cannot be empty.');
    }

    final credential = NhentaiApiCredential(
      apiKey: apiKey.trim(),
      username: username,
      lastValidatedAt: DateTime.now(),
    );
    isValid = true;
    await _apiKeyStore.save(credential);
    return credential;
  }
}

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
