import 'package:concept_nhv/application/favorites/clear_favorite_auth_use_case.dart';
import 'package:concept_nhv/application/favorites/initialize_favorites_use_case.dart';
import 'package:concept_nhv/application/favorites/save_api_key_use_case.dart';
import 'package:concept_nhv/application/favorites/sync_remote_favorites_use_case.dart';
import 'package:concept_nhv/application/favorites/toggle_favorite_use_case.dart';
import 'package:concept_nhv/application/feed/load_collection_summaries_use_case.dart';
import 'package:concept_nhv/application/feed/search_comics_use_case.dart';
import 'package:concept_nhv/application/library/load_collection_comics_use_case.dart';
import 'package:concept_nhv/application/library/remove_comic_from_collection_use_case.dart';
import 'package:concept_nhv/application/library/save_comic_to_collection_use_case.dart';
import 'package:concept_nhv/application/reader/load_comic_detail_use_case.dart';
import 'package:concept_nhv/application/reader/open_comic_use_case.dart';
import 'package:concept_nhv/application/reader/reader_progress_repository.dart';
import 'package:concept_nhv/services/image_url_resolver.dart';
import 'package:concept_nhv/services/library_import_service.dart';
import 'package:concept_nhv/services/comic_page_source_resolver.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/services/nhentai_cdn_config_service.dart';
import 'package:concept_nhv/services/remote_favorite_gateway.dart';
import 'package:concept_nhv/services/search_query_builder.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/nhentai_api_key_store.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:concept_nhv/storage/reader_progress_store.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:concept_nhv/storage/secure_key_value_store.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> buildAppProviders(LocalDatabase localDatabase) {
  return <SingleChildWidget>[
    Provider<LocalDatabase>.value(value: localDatabase),
    Provider(
      create: (context) => OptionsStore(localDatabase: context.read()),
    ),
    Provider<SecureKeyValueStore>(create: (_) => FlutterSecureKeyValueStore()),
    Provider(
      create: (context) => NhentaiApiKeyStore(secureStore: context.read()),
    ),
    Provider(
      create: (context) => ComicRepository(localDatabase: context.read()),
    ),
    Provider(
      create: (context) =>
          CollectionRepository(localDatabase: context.read()),
    ),
    Provider(
      create: (context) =>
          SearchHistoryRepository(localDatabase: context.read()),
    ),
    Provider<ReaderProgressRepository>(
      create: (context) => ReaderProgressStore(optionsStore: context.read()),
    ),
    Provider(create: (_) => const SearchQueryBuilder()),
    Provider(create: (_) => const ComicPageSourceResolver()),
    Provider(
      create: (_) {
        final service = NhentaiCdnConfigService();
        service.refreshInBackground();
        return service;
      },
    ),
    Provider(
      create: (context) => ImageUrlResolver(cdnConfigService: context.read()),
    ),
    Provider(
      create: (context) => NhentaiAuthService(apiKeyStore: context.read()),
    ),
    Provider<NhentaiGateway>(
      create: (context) => NhentaiApiClient(
        apiKeyStore: context.read(),
        cdnConfigService: context.read(),
      ),
    ),
    Provider<RemoteFavoriteGateway>(
      create: (context) => NhentaiApiRemoteFavoriteGateway(
        apiKeyStore: context.read(),
        authService: context.read(),
      ),
    ),
    Provider(
      create: (context) => SearchComicsUseCase(
        nhentaiGateway: context.read(),
        searchQueryBuilder: context.read(),
      ),
    ),
    Provider(
      create: (context) => LoadCollectionSummariesUseCase(
        collectionRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => LoadCollectionComicsUseCase(
        collectionRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => LoadComicDetailUseCase(
        nhentaiGateway: context.read(),
      ),
    ),
    Provider(
      create: (context) => OpenComicUseCase(
        comicRepository: context.read(),
        collectionRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => SaveComicToCollectionUseCase(
        comicRepository: context.read(),
        collectionRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => RemoveComicFromCollectionUseCase(
        collectionRepository: context.read(),
      ),
    ),
    Provider(
      create: (context) => InitializeFavoritesUseCase(
        collectionRepository: context.read(),
        authService: context.read(),
      ),
    ),
    Provider(
      create: (context) => SaveApiKeyUseCase(authService: context.read()),
    ),
    Provider(
      create: (context) => ClearFavoriteAuthUseCase(authService: context.read()),
    ),
    Provider(
      create: (context) => SyncRemoteFavoritesUseCase(
        collectionRepository: context.read(),
        remoteFavoriteGateway: context.read(),
        authService: context.read(),
      ),
    ),
    Provider(
      create: (context) => ToggleFavoriteUseCase(
        collectionRepository: context.read(),
        remoteFavoriteGateway: context.read(),
        authService: context.read(),
        syncRemoteFavoritesUseCase: context.read(),
      ),
    ),
    Provider(
      create: (context) => LibraryImportService(
        comicRepository: context.read(),
        collectionRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider(create: (_) => HomeUiModel()),
    ChangeNotifierProvider(
      create: (context) => ComicFeedModel(
        searchComicsUseCase: context.read(),
        loadCollectionSummariesUseCase: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) {
        final model = FavoriteSyncModel(
          initializeFavoritesUseCase: context.read(),
          saveApiKeyUseCase: context.read(),
          clearFavoriteAuthUseCase: context.read(),
          syncRemoteFavoritesUseCase: context.read(),
          toggleFavoriteUseCase: context.read(),
        );
        model.initialize();
        return model;
      },
    ),
    ChangeNotifierProvider(
      create: (context) => ComicReaderModel(
        loadComicDetailUseCase: context.read(),
        openComicUseCase: context.read(),
        readerProgressRepository: context.read(),
      ),
    ),
  ];
}
