import 'package:concept_nhv/application/favorites/sync_remote_favorites_use_case.dart';
import 'package:concept_nhv/application/favorites/toggle_favorite_use_case.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/storage/nhentai_api_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fakes/fake_nhentai_auth_service.dart';
import '../test_support/fakes/fake_remote_favorite_gateway.dart';
import '../test_support/fakes/memory_secure_store.dart';
import '../test_support/fixtures/sample_comic.dart';
import '../test_support/storage/sqlite_test_harness.dart';

void main() {
  group('ToggleFavoriteUseCase', () {
    late SqliteTestHarness harness;
    late NhentaiApiKeyStore apiKeyStore;
    late FakeNhentaiAuthService authService;
    late FakeRemoteFavoriteGateway remoteFavoriteGateway;
    late SyncRemoteFavoritesUseCase syncRemoteFavoritesUseCase;
    late ToggleFavoriteUseCase useCase;

    setUp(() async {
      harness = SqliteTestHarness();
      await harness.initialize();
      apiKeyStore = NhentaiApiKeyStore(
        secureStore: MemorySecureKeyValueStore(),
      );
      authService = FakeNhentaiAuthService(apiKeyStore);
      remoteFavoriteGateway = FakeRemoteFavoriteGateway();
      syncRemoteFavoritesUseCase = SyncRemoteFavoritesUseCase(
        collectionRepository: harness.collectionRepository,
        remoteFavoriteGateway: remoteFavoriteGateway,
        authService: authService,
      );
      useCase = ToggleFavoriteUseCase(
        collectionRepository: harness.collectionRepository,
        remoteFavoriteGateway: remoteFavoriteGateway,
        authService: authService,
        syncRemoteFavoritesUseCase: syncRemoteFavoritesUseCase,
      );
    });

    tearDown(() async {
      await harness.dispose();
    });

    test('updates remote favorite and resyncs cache when authenticated', () async {
      authService.isValid = true;
      final comic = ComicCardData.fromComic(sampleComic(id: '7'));

      final addResult = await useCase.execute(comic: comic, isFavorite: false);
      final removeResult = await useCase.execute(comic: comic, isFavorite: true);

      expect(addResult.success, isTrue);
      expect(removeResult.success, isTrue);
      expect(remoteFavoriteGateway.addedComicIds, <String>['7']);
      expect(remoteFavoriteGateway.removedComicIds, <String>['7']);
    });

    test('returns cached ids when no valid api key is available', () async {
      authService.isValid = false;
      final comic = ComicCardData.fromComic(sampleComic(id: '7'));

      final result = await useCase.execute(comic: comic, isFavorite: false);

      expect(result.success, isFalse);
      expect(result.isAuthenticated, isFalse);
      expect(result.errorMessage, 'Valid API key required to edit favorites.');
    });
  });
}
