import 'package:concept_nhv/application/feed/load_collection_summaries_use_case.dart';
import 'package:concept_nhv/application/feed/search_comics_use_case.dart';
import 'package:concept_nhv/application/favorites/clear_favorite_auth_use_case.dart';
import 'package:concept_nhv/application/favorites/initialize_favorites_use_case.dart';
import 'package:concept_nhv/application/favorites/save_api_key_use_case.dart';
import 'package:concept_nhv/application/favorites/sync_remote_favorites_use_case.dart';
import 'package:concept_nhv/application/favorites/toggle_favorite_use_case.dart';
import 'package:concept_nhv/application/library/collection_page_coordinator.dart';
import 'package:concept_nhv/application/library/load_collection_comics_use_case.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/services/search_query_builder.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/storage/nhentai_api_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fakes/fake_nhentai_auth_service.dart';
import '../test_support/fakes/fake_nhentai_gateway.dart';
import '../test_support/fakes/fake_remote_favorite_gateway.dart';
import '../test_support/fakes/memory_secure_store.dart';
import '../test_support/fixtures/sample_comic.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('CollectionPageCoordinator', () {
    late SqliteTestHarness harness;
    late ComicFeedModel feedModel;
    late FavoriteSyncModel favoriteSyncModel;
    late FakeRemoteFavoriteGateway remoteFavoriteGateway;
    late FakeNhentaiAuthService authService;
    late CollectionPageCoordinator coordinator;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
      feedModel = ComicFeedModel(
        searchComicsUseCase: SearchComicsUseCase(
          nhentaiGateway: FakeNhentaiGateway(),
          searchQueryBuilder: const SearchQueryBuilder(),
        ),
        loadCollectionSummariesUseCase: LoadCollectionSummariesUseCase(
          collectionRepository: harness.collectionRepository,
        ),
      );
      final apiKeyStore = NhentaiApiKeyStore(
        secureStore: MemorySecureKeyValueStore(),
      );
      authService = FakeNhentaiAuthService(apiKeyStore);
      remoteFavoriteGateway = FakeRemoteFavoriteGateway();
      favoriteSyncModel = FavoriteSyncModel(
        initializeFavoritesUseCase: InitializeFavoritesUseCase(
          collectionRepository: harness.collectionRepository,
          authService: authService,
        ),
        saveApiKeyUseCase: SaveApiKeyUseCase(authService: authService),
        clearFavoriteAuthUseCase: ClearFavoriteAuthUseCase(
          authService: authService,
        ),
        syncRemoteFavoritesUseCase: SyncRemoteFavoritesUseCase(
          collectionRepository: harness.collectionRepository,
          remoteFavoriteGateway: remoteFavoriteGateway,
          authService: authService,
        ),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(
          collectionRepository: harness.collectionRepository,
          remoteFavoriteGateway: remoteFavoriteGateway,
          authService: authService,
          syncRemoteFavoritesUseCase: SyncRemoteFavoritesUseCase(
            collectionRepository: harness.collectionRepository,
            remoteFavoriteGateway: remoteFavoriteGateway,
            authService: authService,
          ),
        ),
      );
      coordinator = CollectionPageCoordinator(
        loadCollectionComicsUseCase: LoadCollectionComicsUseCase(
          collectionRepository: harness.collectionRepository,
        ),
        favoriteSyncModel: favoriteSyncModel,
        feedModel: feedModel,
      );
    });

    tearDown(() async {
      favoriteSyncModel.dispose();
      feedModel.dispose();
      await harness.dispose();
    });

    test('syncs favorites before loading the favorite collection', () async {
      authService.isValid = true;
      remoteFavoriteGateway.remoteFavorites = <Comic>[
        sampleComic(id: '11'),
      ];

      final snapshot = await coordinator.load(CollectionType.favorite);

      expect(snapshot.didRefreshCollections, isTrue);
      expect(snapshot.comics.map((comic) => comic.id).toList(), <String>['11']);
      expect(feedModel.collectionSummariesFuture, isNotNull);
    });

    test('refresh loads collection records without favorite sync side effects', () async {
      await harness.comicRepository.upsertComic(
        StoredComic.fromComic(sampleComic(id: '12')),
      );
      await harness.collectionRepository.addComicToCollection(
        collectionType: CollectionType.next,
        comicId: '12',
      );

      final comics = await coordinator.refresh(CollectionType.next);

      expect(comics.map((comic) => comic.id).toList(), <String>['12']);
      expect(feedModel.collectionSummariesFuture, isNull);
    });
  });
}
