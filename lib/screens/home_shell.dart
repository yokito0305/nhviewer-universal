import 'package:concept_nhv/models/collection_summary.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/application/home/home_shell_controller.dart';
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
                          onTap: () =>
                              _handleSearchSubmit(context, entry.query),
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
        return CollectionComicSliver(collectionType: CollectionType.favorite);
      case 2:
        return const CollectionOverviewScreen();
      case 0:
      default:
        return Consumer<ComicFeedModel>(
          builder: (context, feedModel, child) {
            final comics = feedModel.comics;
            if (comics == null) {
              final errorMessage = feedModel.feedErrorMessage;
              if (errorMessage != null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => _retryHomeFeed(context),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

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
    final controller = context.read<HomeShellController>();
    final readerModel = context.read<ComicReaderModel>();
    final navigator = GoRouter.of(context);
    final result = await controller.submitSearch(value);
    if (!mounted || !result.openComicReader || result.comicId == null) {
      return;
    }

    await navigator.push(
      Uri(
        path: '/third',
        queryParameters: <String, String>{'id': result.comicId!},
      ).toString(),
    );
    if (!mounted) {
      return;
    }
    readerModel.clearComic();
  }

  Future<void> _retryHomeFeed(BuildContext context) async {
    await context.read<HomeShellController>().retryHomeFeed();
  }
}

class CollectionOverviewScreen extends StatefulWidget {
  const CollectionOverviewScreen({super.key});

  @override
  State<CollectionOverviewScreen> createState() =>
      _CollectionOverviewScreenState();
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

        return CollectionGridSliver(collections: snapshot.requireData);
      },
    );
  }
}
