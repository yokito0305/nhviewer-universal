import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/widgets/comic_grid_sliver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.collectionName,
  });

  final String collectionName;

  @override
  Widget build(BuildContext context) {
    final collectionType = CollectionType.fromStorageName(collectionName);
    if (collectionType == null) {
      return Scaffold(
        body: Center(
          child: Text('Unknown collection: $collectionName'),
        ),
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
          CollectionComicSliver(collectionType: collectionType),
        ],
      ),
    );
  }
}

class CollectionComicSliver extends StatefulWidget {
  const CollectionComicSliver({
    super.key,
    required this.collectionType,
  });

  final CollectionType collectionType;

  @override
  State<CollectionComicSliver> createState() => _CollectionComicSliverState();
}

class _CollectionComicSliverState extends State<CollectionComicSliver> {
  late Future<List<ComicCardData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadComics();
  }

  @override
  void didUpdateWidget(covariant CollectionComicSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionType != widget.collectionType) {
      _future = _loadComics();
    }
  }

  Future<List<ComicCardData>> _loadComics() async {
    final records = await context
        .read<CollectionRepository>()
        .loadCollectionComics(widget.collectionType);
    return records.map((record) => ComicCardData.fromStoredComic(record.comic)).toList();
  }

  void _refresh() {
    setState(() {
      _future = _loadComics();
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
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No comics in ${widget.collectionType.displayName}'),
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
