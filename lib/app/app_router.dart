import 'package:concept_nhv/models/popular_sort_type.dart';
import 'package:concept_nhv/screens/bootstrap_screen.dart';
import 'package:concept_nhv/screens/collection_screen.dart';
import 'package:concept_nhv/screens/comic_reader_screen.dart';
import 'package:concept_nhv/screens/home_shell.dart';
import 'package:concept_nhv/screens/settings_screen.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const BootstrapScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _AppShellScaffold(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            name: 'index',
            path: '/index',
            builder: (context, state) => const HomeShell(),
          ),
          GoRoute(
            name: 'collection',
            path: '/collection',
            builder: (context, state) {
              final collectionName =
                  state.uri.queryParameters['collectionName'] ?? '';
              return CollectionScreen(collectionName: collectionName);
            },
          ),
        ],
      ),
      GoRoute(
        name: 'third',
        path: '/third',
        builder: (context, state) {
          final comicId = state.uri.queryParameters['id'] ?? '';
          return ComicReaderScreen(comicId: comicId);
        },
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

class _AppShellScaffold extends StatelessWidget {
  const _AppShellScaffold({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: Consumer<HomeUiModel>(
        builder: (context, homeUiModel, child) {
          if (homeUiModel.navigationIndex != 0) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onLongPress: () => _toggleSortAndRefresh(
              context,
              PopularSortType.allTime,
            ),
            child: FloatingActionButton(
              onPressed: () => _toggleSortAndRefresh(
                context,
                PopularSortType.month,
              ),
              child: const Icon(Icons.sort),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<HomeUiModel>(
        builder: (context, homeUiModel, child) {
          return NavigationBar(
            selectedIndex: homeUiModel.navigationIndex,
            onDestinationSelected: (index) => _handleDestinationSelected(
              context,
              index,
            ),
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Index',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.favorite),
                icon: Icon(Icons.favorite_border),
                label: 'Favorites',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.folder),
                icon: Icon(Icons.folder_outlined),
                label: 'Collections',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDestinationSelected(BuildContext context, int index) async {
    final homeUiModel = context.read<HomeUiModel>();
    final feedModel = context.read<ComicFeedModel>();

    if (homeUiModel.searchController.isOpen) {
      homeUiModel.searchController.text = '';
      homeUiModel.searchController.closeView(null);
    }

    switch (index) {
      case 0:
        homeUiModel.setNavigationIndex(index);
        homeUiModel.setLoading(true);
        final statusCode = await feedModel.loadHomeFeed(clearComic: true);
        if (context.mounted) {
          _showStatusCodeMessage(context, statusCode);
        }
        homeUiModel.setLoading(false);
        break;
      case 1:
      case 2:
        homeUiModel.setNavigationIndex(index);
        feedModel.refreshCollections();
        break;
    }

    if (context.mounted) {
      context.goNamed('index');
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _toggleSortAndRefresh(
    BuildContext context,
    PopularSortType type,
  ) async {
    final homeUiModel = context.read<HomeUiModel>();
    final feedModel = context.read<ComicFeedModel>();
    final previous = feedModel.sortByPopularType;

    feedModel.toggleSort(type);
    if (!context.mounted) {
      return;
    }

    final current = feedModel.sortByPopularType;
    final label = current?.label ?? 'None';
    if (current != previous) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sort by popular type: $label'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    homeUiModel.setLoading(true);
    await feedModel.fetchNextPage(page: 1);
    homeUiModel.setLoading(false);
  }

  void _showStatusCodeMessage(BuildContext context, int? statusCode) {
    String? message;
    if (statusCode == 404) {
      message = 'API issue (404)';
    } else if (statusCode == 403) {
      message = 'CF Cookies issue (403)';
    }

    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
