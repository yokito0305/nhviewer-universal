import 'package:concept_nhv/application/library/collection_page_coordinator.dart';
import 'package:concept_nhv/application/library/comic_card_action_coordinator.dart';
import 'package:concept_nhv/application/home/home_shell_controller.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/widgets/comic_grid_sliver.dart';
import 'package:concept_nhv/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, required this.collectionName});

  final String collectionName;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  bool _selectionMode = false;
  final Map<String, ComicCardData> _selectedComics = {};
  // A State-owned controller (rather than CustomScrollView's default
  // PrimaryScrollController/PageStorage) so scroll position survives even if
  // the Element tree gets rebuilt — see .codex/phases/P52-collections-screen-reliability.md.
  final ScrollController _scrollController = ScrollController();

  CollectionType? get _collectionType =>
      CollectionType.fromStorageName(widget.collectionName);

  bool get _isFavorite => _collectionType == CollectionType.favorite;

  void _toggleSelection(ComicCardData comic) {
    setState(() {
      if (_selectedComics.containsKey(comic.id)) {
        _selectedComics.remove(comic.id);
      } else {
        _selectedComics[comic.id] = comic;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedComics.clear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _downloadSelected(BuildContext context) async {
    final coordinator = context.read<ComicCardActionCoordinator>();
    final messenger = ScaffoldMessenger.of(context);
    final comics = _selectedComics.values.toList();
    _exitSelectionMode();

    var queued = 0;
    for (final comic in comics) {
      if (!mounted) break;
      final result = await coordinator.enqueueDownload(comic);
      if (result.success) queued++;
    }

    final total = comics.length;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          queued == total
              ? '$queued comic${queued > 1 ? 's' : ''} added to Downloads'
              : '$queued / $total comics added to Downloads',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionType = _collectionType;
    if (collectionType == null) {
      return Scaffold(
        body: Center(child: Text('Unknown collection: ${widget.collectionName}')),
      );
    }

    final selectedCount = _selectedComics.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: GlassContainer.bar(child: const SizedBox.expand()),
            floating: true,
            snap: true,
            title: _selectionMode
                ? Text('$selectedCount selected')
                : Text(collectionType.displayName),
            actions: <Widget>[
              if (_isFavorite && !_selectionMode)
                IconButton(
                  icon: const Icon(Icons.checklist_outlined),
                  tooltip: 'Select comics',
                  onPressed: () => setState(() => _selectionMode = true),
                ),
              if (_selectionMode)
                TextButton(
                  onPressed: _exitSelectionMode,
                  child: const Text('Done'),
                ),
            ],
          ),
          if (collectionType == CollectionType.favorite)
            Consumer<FavoriteSyncModel>(
              builder: (context, favoriteModel, child) {
                final message = favoriteModel.syncError;
                if (message == null) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(message),
                          if (!favoriteModel.isAuthenticated)
                            TextButton(
                              onPressed: () => context.push('/settings'),
                              child: const Text('Open Settings'),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          CollectionComicSliver(
            collectionType: collectionType,
            selectedIds: _selectedComics.keys.toSet(),
            onToggleSelection: _selectionMode ? _toggleSelection : null,
          ),
        ],
      ),
      bottomNavigationBar: _selectionMode && selectedCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FilledButton.icon(
                  onPressed: () => _downloadSelected(context),
                  icon: const Icon(Icons.download_outlined),
                  label: Text(
                    'Download $selectedCount comic${selectedCount > 1 ? 's' : ''}',
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class CollectionComicSliver extends StatefulWidget {
  const CollectionComicSliver({
    super.key,
    required this.collectionType,
    this.selectedIds = const <String>{},
    this.onToggleSelection,
  });

  final CollectionType collectionType;
  final Set<String> selectedIds;
  final void Function(ComicCardData comic)? onToggleSelection;

  @override
  State<CollectionComicSliver> createState() => _CollectionComicSliverState();
}

class _CollectionComicSliverState extends State<CollectionComicSliver> {
  late Future<List<ComicCardData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadInitialComics();
  }

  @override
  void didUpdateWidget(covariant CollectionComicSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionType != widget.collectionType) {
      _future = _loadInitialComics();
    }
  }

  Future<List<ComicCardData>> _loadInitialComics() async {
    final snapshot = await context.read<CollectionPageCoordinator>().load(
      widget.collectionType,
    );
    return snapshot.comics;
  }

  void _refresh() {
    setState(() {
      _future = context.read<CollectionPageCoordinator>().refresh(
        widget.collectionType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComicCardData>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(hasScrollBody: false);
        }

        final comics = snapshot.requireData;
        if (comics.isEmpty) {
          final favoriteModel = context.watch<FavoriteSyncModel>();
          final isFavoriteCollection =
              widget.collectionType == CollectionType.favorite;
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('No comics in ${widget.collectionType.displayName}'),
                  if (isFavoriteCollection && !favoriteModel.isAuthenticated)
                    TextButton(
                      onPressed: () => context.push('/settings'),
                      child: const Text('Login from Settings'),
                    ),
                ],
              ),
            ),
          );
        }

        return ComicGridSliver(
          comics: comics,
          collectionType: widget.collectionType,
          onCollectionChanged: _refresh,
          onTagSelected: (tagQueries) async {
            await context
                .read<HomeShellController>()
                .submitTagSearch(tagQueries);
            if (context.mounted) {
              context.goNamed('index');
            }
          },
          selectedIds: widget.selectedIds,
          onToggleSelection: widget.onToggleSelection,
        );
      },
    );
  }
}
