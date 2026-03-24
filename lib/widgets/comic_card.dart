import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'fallback_cached_network_image.dart';

class ComicCard extends StatelessWidget {
  const ComicCard({
    super.key,
    required this.comic,
    this.collectionType,
    this.onCollectionChanged,
  });

  final ComicCardData comic;
  final CollectionType? collectionType;
  final VoidCallback? onCollectionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () async {
                final readerModel = context.read<ComicReaderModel>();
                await readerModel.loadComicDetail(comic.id);
                if (!context.mounted) {
                  return;
                }
                await context.push(
                  Uri(
                    path: '/third',
                    queryParameters: <String, String>{'id': comic.id},
                  ).toString(),
                );
                readerModel.clearComic();
              },
              onLongPress: collectionType == null
                  ? null
                  : () => _showRemoveDialog(context),
              child: FallbackCachedNetworkImage(
                url: comic.thumbnailUrl,
                width: comic.thumbnailWidth,
                height: comic.thumbnailHeight,
              ),
            ),
          ),
        ),
        Text(
          comic.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_to_photos_outlined),
              onPressed: () => _saveToCollection(context, CollectionType.next),
            ),
            Text('${comic.pages}p'),
            IconButton(
              icon: const Icon(Icons.favorite_outline),
              onPressed: () => _saveToCollection(context, CollectionType.favorite),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showRemoveDialog(BuildContext context) async {
    final collectionRepository = context.read<CollectionRepository>();
    final feedModel = context.read<ComicFeedModel>();
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove this comic from ${collectionType!.displayName}?'),
          content: Text(
            "Careful! You can't undo this action. You are removing: ${comic.title}",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true || !context.mounted) {
      return;
    }

    await collectionRepository.removeComicFromCollection(
          collectionType: collectionType!,
          comicId: comic.id,
        );
    feedModel.refreshCollections();
    onCollectionChanged?.call();
  }

  Future<void> _saveToCollection(
    BuildContext context,
    CollectionType targetCollection,
  ) async {
    final comicRepository = context.read<ComicRepository>();
    final collectionRepository = context.read<CollectionRepository>();
    final feedModel = context.read<ComicFeedModel>();

    await comicRepository.upsertComic(comic.toStoredComic());
    await collectionRepository.addComicToCollection(
          collectionType: targetCollection,
          comicId: comic.id,
        );

    if (!context.mounted) {
      return;
    }

    feedModel.refreshCollections();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added comic to ${targetCollection.displayName}'),
      ),
    );
  }
}
