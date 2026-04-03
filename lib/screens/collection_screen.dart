import 'package:concept_nhv/application/library/collection_page_coordinator.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/widgets/comic_grid_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.collectionName});

  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final collectionType = CollectionType.fromStorageName(collectionName);
    if (collectionType == null) {
      return Scaffold(
        body: Center(child: Text('Unknown collection: $collectionName')),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(collectionType.displayName),
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
          CollectionComicSliver(collectionType: collectionType),
        ],
      ),
    );
  }
}

class CollectionComicSliver extends StatefulWidget {
  const CollectionComicSliver({super.key, required this.collectionType});

  final CollectionType collectionType;

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
        );
      },
    );
  }
}
