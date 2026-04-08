import 'package:concept_nhv/application/home/app_shell_navigation_controller.dart';
import 'package:concept_nhv/application/home/home_shell_controller.dart';
import 'package:concept_nhv/screens/bootstrap_screen.dart';
import 'package:concept_nhv/screens/collection_screen.dart';
import 'package:concept_nhv/screens/comic_reader_screen.dart';
import 'package:concept_nhv/screens/home_shell.dart';
import 'package:concept_nhv/screens/settings_screen.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:concept_nhv/widgets/sort_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const BootstrapScreen()),
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
  const _AppShellScaffold({required this.child});

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

          return _SortFilterFab();
        },
      ),
      bottomNavigationBar: Consumer<HomeUiModel>(
        builder: (context, homeUiModel, child) {
          return NavigationBar(
            selectedIndex: homeUiModel.navigationIndex,
            onDestinationSelected: (index) =>
                _handleDestinationSelected(context, index),
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

  Future<void> _handleDestinationSelected(
    BuildContext context,
    int index,
  ) async {
    final result = await context
        .read<AppShellNavigationController>()
        .handleDestinationSelected(index);

    if (context.mounted) {
      if (result.statusMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.statusMessage!),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      context.goNamed('index');
      HapticFeedback.lightImpact();
    }
  }
}

/// FAB that opens the sort & filter sheet.
///
/// Shows a badge dot when any filter is active (sort type or tag filters).
class _SortFilterFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ComicFeedModel>(
      builder: (context, feedModel, _) {
        final hasActiveFilters = feedModel.sortByPopularType != null ||
            feedModel.tagFilters.isNotEmpty;

        return Badge(
          isLabelVisible: hasActiveFilters,
          child: FloatingActionButton(
            tooltip: 'Sort & Filter',
            onPressed: () => _openSortFilter(context),
            child: const Icon(Icons.tune),
          ),
        );
      },
    );
  }

  Future<void> _openSortFilter(BuildContext context) async {
    final applied = await SortFilterBottomSheet.show(context);
    if (!context.mounted || !applied) return;
    await context.read<HomeShellController>().applySortAndFilters();
  }
}
