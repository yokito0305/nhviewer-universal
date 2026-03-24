import 'package:concept_nhv/app/app_router.dart';
import 'package:concept_nhv/app/app_theme.dart';
import 'package:concept_nhv/services/cloudflare_cookie_service.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/services/platform/cloudflare_cookie_bridge.dart';
import 'package:concept_nhv/services/search_query_builder.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/storage/cloudflare_cookie_store.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({
    super.key,
    required this.localDatabase,
  });

  final LocalDatabase localDatabase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalDatabase>.value(value: localDatabase),
        Provider(create: (context) => OptionsStore(localDatabase: context.read())),
        Provider(
          create: (context) => CloudflareCookieStore(
            optionsStore: context.read(),
          ),
        ),
        Provider(create: (context) => ComicRepository(localDatabase: context.read())),
        Provider(
          create: (context) => CollectionRepository(localDatabase: context.read()),
        ),
        Provider(
          create: (context) => SearchHistoryRepository(
            localDatabase: context.read(),
          ),
        ),
        Provider<CloudflareCookieBridge>(
          create: (_) => const MethodChannelCloudflareCookieBridge(),
        ),
        Provider(create: (_) => const SearchQueryBuilder()),
        Provider<NhentaiGateway>(
          create: (context) => NhentaiApiClient(
            cookieStore: context.read(),
          ),
        ),
        Provider(
          create: (context) => CloudflareCookieService(
            bridge: context.read(),
            cookieStore: context.read(),
            nhentaiGateway: context.read(),
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
          create: (context) => ComicReaderModel(
            nhentaiGateway: context.read(),
            comicRepository: context.read(),
            collectionRepository: context.read(),
            optionsStore: context.read(),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: createAppRouter(),
      ),
    );
  }
}

