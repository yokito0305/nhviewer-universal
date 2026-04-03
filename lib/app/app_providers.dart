import 'package:concept_nhv/services/image_url_resolver.dart';
import 'package:concept_nhv/services/library_import_service.dart';
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
    Provider(create: (_) => const SearchQueryBuilder()),
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
      create: (context) => LibraryImportService(
        comicRepository: context.read(),
        collectionRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider(create: (_) => HomeUiModel()),
    ChangeNotifierProvider(
      create: (context) => ComicFeedModel(
        nhentaiGateway: context.read(),
        collectionRepository: context.read(),
        searchHistoryRepository: context.read(),
        searchQueryBuilder: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) {
        final model = FavoriteSyncModel(
          collectionRepository: context.read(),
          remoteFavoriteGateway: context.read(),
          authService: context.read(),
        );
        model.initialize();
        return model;
      },
    ),
    ChangeNotifierProvider(
      create: (context) => ComicReaderModel(
        nhentaiGateway: context.read(),
        comicRepository: context.read(),
        collectionRepository: context.read(),
        optionsStore: context.read(),
      ),
    ),
  ];
}
