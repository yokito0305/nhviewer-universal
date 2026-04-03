import 'package:concept_nhv/application/library/comic_card_action_coordinator.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
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
                await context.read<ComicCardActionCoordinator>().openComic(
                  comic,
                );
                if (!context.mounted) {
                  return;
                }
                await context.push(
                  Uri(
                    path: '/third',
                    queryParameters: <String, String>{'id': comic.id},
                  ).toString(),
                );
                if (!context.mounted) {
                  return;
                }
                context.read<ComicReaderModel>().clearComic();
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
        Text(comic.title, overflow: TextOverflow.ellipsis, maxLines: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_to_photos_outlined),
              onPressed: () => _saveToCollection(context, CollectionType.next),
            ),
            Text('${comic.pages}p'),
            Consumer<FavoriteSyncModel>(
              builder: (context, favoriteModel, child) {
                final isFavorite = favoriteModel.isFavorite(comic.id);
                final isMutating = favoriteModel.isMutating(comic.id);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                  ),
                  onPressed: isMutating ? null : () => _toggleFavorite(context),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showRemoveDialog(BuildContext context) async {
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

    final result = await context.read<ComicCardActionCoordinator>().removeFromCollection(
      comic: comic,
      collectionType: collectionType!,
    );
    if (!context.mounted) {
      return;
    }
    if (result.triggerHaptic) {
      HapticFeedback.lightImpact();
    }
    if (result.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message!)));
    }
    if (result.shouldRefreshCollection) {
      onCollectionChanged?.call();
    }
  }

  Future<void> _saveToCollection(
    BuildContext context,
    CollectionType targetCollection,
  ) async {
    final result = await context.read<ComicCardActionCoordinator>().saveToCollection(
      comic: comic,
      targetCollection: targetCollection,
    );

    if (!context.mounted) {
      return;
    }

    if (result.triggerHaptic) {
      HapticFeedback.lightImpact();
    }
    if (result.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message!)));
    }
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final result = await context.read<ComicCardActionCoordinator>().toggleFavorite(
      comic: comic,
      collectionType: collectionType,
    );
    if (!context.mounted) {
      return;
    }

    if (result.triggerHaptic) {
      HapticFeedback.lightImpact();
    }
    if (result.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message!)));
    }
    if (result.shouldRefreshCollection) {
      onCollectionChanged?.call();
    }
  }
}
