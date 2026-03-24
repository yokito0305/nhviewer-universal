import 'package:concept_nhv/models/collection_summary.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:concept_nhv/widgets/collection_grid_sliver.dart';
import 'package:concept_nhv/widgets/comic_grid_sliver.dart';
import 'package:concept_nhv/widgets/loading_indicator_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'collection_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        Consumer<HomeUiModel>(
          builder: (context, homeUiModel, child) {
            return SliverAppBar(
              clipBehavior: Clip.none,
              backgroundColor: Colors.transparent,
              floating: true,
              snap: true,
              bottom: LoadingIndicatorBar(isLoading: homeUiModel.isLoading),
              title: FocusScope(
                node: _focusNode,
                onFocusChange: (isFocused) {
                  if (isFocused) {
                    _focusNode.unfocus();
                  }
                },
                child: SearchAnchor.bar(
                  searchController: homeUiModel.searchController,
                  onSubmitted: (value) => _handleSearchSubmit(context, value),
                  barTrailing: <Widget>[
                    IconButton.filledTonal(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                  barHintText: 'Search comic',
                  barElevation: WidgetStateProperty.all(0),
                  suggestionsBuilder: (buildContext, controller) {
                    return context.read<SearchHistoryRepository>().load().then(
                      (entries) => entries.map((entry) {
                        return ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Text(entry.query),
                          trailing: Text(entry.createdAt.toString()),
                          onTap: () => _handleSearchSubmit(context, entry.query),
                          onLongPress: () async {
                            await context
                                .read<SearchHistoryRepository>()
                                .remove(entry.query);
                            if (!mounted) {
                              return;
                            }
                            homeUiModel.searchController.text =
                                homeUiModel.searchController.text;
                          },
                        );
                      }),
                    );
                  },
                ),
              ),
            );
          },
        ),
        _buildBodyByNavigationIndex(context),
      ],
    );
  }

  Widget _buildBodyByNavigationIndex(BuildContext context) {
    final navigationIndex = context.watch<HomeUiModel>().navigationIndex;
    switch (navigationIndex) {
      case 1:
        return CollectionComicSliver(
          collectionType: CollectionType.favorite,
        );
      case 2:
        return const CollectionOverviewScreen();
      case 0:
      default:
        return Consumer<ComicFeedModel>(
          builder: (context, feedModel, child) {
            final comics = feedModel.comics;
            if (comics == null) {
              return SliverList(
                delegate: SliverChildListDelegate(const <Widget>[]),
              );
            }

            return ComicGridSliver(
              comics: comics.map(ComicCardData.fromComic).toList(),
              pageLoaded: feedModel.pageLoaded,
            );
          },
        );
    }
  }

  Future<void> _handleSearchSubmit(BuildContext context, String value) async {
    final homeUiModel = context.read<HomeUiModel>();
    final feedModel = context.read<ComicFeedModel>();
    final historyRepository = context.read<SearchHistoryRepository>();
    final readerModel = context.read<ComicReaderModel>();

    await historyRepository.save(value);
    if (!mounted) {
      return;
    }

    if (int.tryParse(value) != null) {
      await readerModel.loadComicDetail(value);
      if (!context.mounted) {
        return;
      }
      await context.push(
        Uri(path: '/third', queryParameters: <String, String>{'id': value}).toString(),
      );
      readerModel.clearComic();
      return;
    }

    homeUiModel.searchController.closeView(value);
    if (homeUiModel.navigationIndex != 0) {
      homeUiModel.setNavigationIndex(0);
    }

    homeUiModel.setLoading(true);
    await feedModel.searchComics(query: value, clearComic: true);
    homeUiModel.setLoading(false);
  }
}

class CollectionOverviewScreen extends StatefulWidget {
  const CollectionOverviewScreen({super.key});

  @override
  State<CollectionOverviewScreen> createState() => _CollectionOverviewScreenState();
}

class _CollectionOverviewScreenState extends State<CollectionOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedModel = context.read<ComicFeedModel>();
      if (feedModel.collectionSummariesFuture == null) {
        feedModel.refreshCollections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final future = context.watch<ComicFeedModel>().collectionSummariesFuture;
    if (future == null) {
      return const SliverFillRemaining(hasScrollBody: false);
    }

    return FutureBuilder<List<CollectionSummary>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(hasScrollBody: false);
        }

        return CollectionGridSliver(
          collections: snapshot.requireData,
        );
      },
    );
  }
}
