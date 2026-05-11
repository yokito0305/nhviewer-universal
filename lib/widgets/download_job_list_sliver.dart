import 'dart:io';

import 'package:concept_nhv/application/home/home_shell_controller.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/models/download_list_item_snapshot.dart';
import 'package:concept_nhv/state/download_manager_model.dart';
import 'package:concept_nhv/widgets/comic_tag_bottom_sheet.dart';
import 'package:concept_nhv/widgets/fallback_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DownloadJobListSliver extends StatefulWidget {
  const DownloadJobListSliver({
    super.key,
    required this.searchQuery,
    required this.onOpenOfflineReader,
  });

  final String searchQuery;

  /// Called when the user taps a completed download card to open the reader.
  final ValueChanged<String> onOpenOfflineReader;

  @override
  State<DownloadJobListSliver> createState() => _DownloadJobListSliverState();
}

class _DownloadJobListSliverState extends State<DownloadJobListSliver> {
  String? _expandedComicId;

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManagerModel>(
      builder: (context, model, _) {
        final filteredItems = model.sortedDownloadItems
            .where(
              (item) => item.title.toLowerCase().contains(
                widget.searchQuery.trim().toLowerCase(),
              ),
            )
            .toList(growable: false);
        final activeItems = filteredItems
            .where((item) => !item.isCompletedCard)
            .toList(growable: false);
        final completedItems = filteredItems
            .where((item) => item.isCompletedCard)
            .toList(growable: false);

        if (filteredItems.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                widget.searchQuery.trim().isEmpty
                    ? 'No downloads yet'
                    : 'No downloads match "${widget.searchQuery.trim()}"',
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildListDelegate.fixed(
            <Widget>[
              if (activeItems.isNotEmpty) ...<Widget>[
                const _DownloadsSectionHeader(title: 'Active Downloads'),
                for (final item in activeItems)
                  _buildItemCard(model, item),
              ],
              if (completedItems.isNotEmpty) ...<Widget>[
                const _DownloadsSectionHeader(title: 'Completed Downloads'),
                for (final item in completedItems)
                  _buildItemCard(model, item),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(DownloadManagerModel model, DownloadListItemSnapshot item) {
    return _DownloadItemCard(
      key: ValueKey<String>(item.comicId),
      item: item,
      isExpanded: _expandedComicId == item.comicId,
      isMutating: model.isMutating(item.comicId),
      onToggleExpanded: () {
        setState(() {
          _expandedComicId = _expandedComicId == item.comicId
              ? null
              : item.comicId;
        });
      },
      onOpenOfflineReader: () => widget.onOpenOfflineReader(item.comicId),
    );
  }
}

class _DownloadsSectionHeader extends StatelessWidget {
  const _DownloadsSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _DownloadItemCard extends StatelessWidget {
  const _DownloadItemCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.isMutating,
    required this.onToggleExpanded,
    required this.onOpenOfflineReader,
  });

  final DownloadListItemSnapshot item;
  final bool isExpanded;
  final bool isMutating;
  final VoidCallback onToggleExpanded;

  /// Only invoked for completed cards; opens the offline reader.
  final VoidCallback onOpenOfflineReader;

  @override
  Widget build(BuildContext context) {
    // Completed cards: tap → open reader, long-press → open tag/action sheet.
    // Active cards: tap → expand/collapse (unchanged).
    final onTap = item.isCompletedCard ? onOpenOfflineReader : onToggleExpanded;
    final onLongPress = item.isCompletedCard
        ? () {
            HapticFeedback.selectionClick();
            _showCompletedSheet(context);
          }
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 72,
                    child: AspectRatio(
                      aspectRatio: 0.72,
                      child: _DownloadItemCover(item: item),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: item.isCompletedCard
                        ? _CompletedCardSummary(item: item)
                        : _ActiveCardSummary(item: item),
                  ),
                  if (!item.isCompletedCard) ...<Widget>[
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ],
              ),
              if (!item.isCompletedCard)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildActionButtons(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final model = context.read<DownloadManagerModel>();
    return switch (item.status) {
      DownloadJobStatus.downloading => <Widget>[
        FilledButton.tonal(
          onPressed: isMutating
              ? null
              : () => _runAction(
                  context,
                  successMessage: 'Download paused',
                  action: () => model.pause(item.comicId),
                ),
          child: const Text('Pause'),
        ),
      ],
      DownloadJobStatus.queued => <Widget>[
        FilledButton.tonal(
          onPressed: isMutating
              ? null
              : () => _runAction(
                  context,
                  successMessage: 'Download paused',
                  action: () => model.pause(item.comicId),
                ),
          child: const Text('Pause'),
        ),
      ],
      DownloadJobStatus.paused => <Widget>[
        FilledButton(
          onPressed: isMutating
              ? null
              : () => _runAction(
                  context,
                  successMessage: 'Download resumed',
                  action: () => model.resume(item.comicId),
                ),
          child: const Text('Resume'),
        ),
        OutlinedButton(
          onPressed: isMutating
              ? null
              : () => _confirmAndDelete(
                  context,
                  title: 'Remove download job?',
                  message:
                      'This removes the download job and deletes any partial files already saved.',
                  successMessage: 'Download job removed',
                ),
          child: const Text('Remove'),
        ),
      ],
      DownloadJobStatus.failed => <Widget>[
        FilledButton(
          onPressed: isMutating
              ? null
              : () => _runAction(
                  context,
                  successMessage: 'Download retried',
                  action: () => model.retry(item.comicId),
                ),
          child: const Text('Retry'),
        ),
        OutlinedButton(
          onPressed: isMutating
              ? null
              : () => _confirmAndDelete(
                  context,
                  title: 'Remove failed download?',
                  message:
                      'This removes the failed job and deletes any partial files already saved.',
                  successMessage: 'Failed download removed',
                ),
          child: const Text('Remove'),
        ),
      ],
      DownloadJobStatus.completed => <Widget>[],
    };
  }

  Future<void> _confirmAndDelete(
    BuildContext context, {
    required String title,
    required String message,
    required String successMessage,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      successMessage: successMessage,
      action: () => context.read<DownloadManagerModel>().deleteJob(item.comicId),
    );
  }

  Future<void> _showCompletedSheet(BuildContext context) async {
    final homeShellController = context.read<HomeShellController>();

    await ComicTagBottomSheet.show(
      context: context,
      title: item.title,
      tags: item.tags,
      onSearchSelected: (queries) async {
        await homeShellController.submitTagSearch(queries);
        if (context.mounted) {
          context.goNamed('index');
        }
      },
      actionSlot: _buildCompletedActionSlot(context),
    );
  }

  /// Builds the three-button action area (Delete / Reload / Repair) for
  /// completed download cards shown in the bottom sheet [actionSlot].
  Widget _buildCompletedActionSlot(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Download'),
          onPressed: isMutating
              ? null
              : () {
                  Navigator.of(context).pop();
                  _confirmAndDeleteFromSheet(context);
                },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Reload'),
          onPressed: isMutating
              ? null
              : () {
                  Navigator.of(context).pop();
                  _confirmAndReload(context);
                },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.build_outlined),
          label: const Text('Repair'),
          onPressed: isMutating
              ? null
              : () {
                  Navigator.of(context).pop();
                  _runRepair(context);
                },
        ),
      ],
    );
  }

  Future<void> _confirmAndDeleteFromSheet(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete downloaded comic?'),
          content: const Text(
            'This deletes the saved download, cover, offline snapshot, and the completed job record.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      successMessage: 'Downloaded comic deleted',
      action: () => context.read<DownloadManagerModel>().deleteJob(item.comicId),
    );
  }

  Future<void> _confirmAndReload(BuildContext context) async {
    final shouldReload = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reload download?'),
          content: const Text(
            'This deletes the saved pages and re-downloads the comic from scratch. '
            'Reading history and metadata are preserved.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reload'),
            ),
          ],
        );
      },
    );

    if (shouldReload != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      successMessage: 'Reload queued',
      action: () => context.read<DownloadManagerModel>().reloadCompleted(item.comicId),
    );
  }

  Future<void> _runRepair(BuildContext context) async {
    await _runAction(
      context,
      successMessage: 'Repair queued',
      noOpMessage: 'All pages are intact — nothing to repair',
      action: () => context.read<DownloadManagerModel>().repairCompleted(item.comicId),
    );
  }

  Future<void> _runAction(
    BuildContext context, {
    required String successMessage,
    String? noOpMessage,
    required Future<void> Function() action,
  }) async {
    final beforeItems = context.read<DownloadManagerModel>().downloadItems;
    try {
      await action();
      if (!context.mounted) {
        return;
      }
      final afterItems = context.read<DownloadManagerModel>().downloadItems;
      final changed = afterItems != beforeItems;
      final message = (!changed && noOpMessage != null) ? noOpMessage : successMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }
}

class _ActiveCardSummary extends StatelessWidget {
  const _ActiveCardSummary({required this.item});

  final DownloadListItemSnapshot item;

  @override
  Widget build(BuildContext context) {
    final progress = item.totalPages == 0
        ? 0.0
        : (item.completedPages / item.totalPages).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(_statusLabel(item.status)),
        const SizedBox(height: 8),
        Text('${item.completedPages} / ${item.totalPages}'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}

class _CompletedCardSummary extends StatelessWidget {
  const _CompletedCardSummary({required this.item});

  final DownloadListItemSnapshot item;

  @override
  Widget build(BuildContext context) {
    final pageCount = item.pageCount ?? item.totalPages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text('Completed'),
        const SizedBox(height: 8),
        Text('$pageCount page${pageCount == 1 ? '' : 's'}'),
      ],
    );
  }
}

class _DownloadItemCover extends StatelessWidget {
  const _DownloadItemCover({required this.item});

  final DownloadListItemSnapshot item;

  @override
  Widget build(BuildContext context) {
    final localCoverPath = item.coverLocalPath;
    if (localCoverPath != null && localCoverPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(localCoverPath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(context),
        ),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final thumbnailPath = item.thumbnailPath;
    if (thumbnailPath == null || thumbnailPath.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Icon(Icons.download)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FallbackCachedNetworkImage(
        url: 'https://t1.nhentai.net/$thumbnailPath',
        width: 72,
        height: 100,
      ),
    );
  }
}

String _statusLabel(DownloadJobStatus status) {
  return switch (status) {
    DownloadJobStatus.downloading => 'Downloading',
    DownloadJobStatus.queued => 'Queued',
    DownloadJobStatus.paused => 'Paused',
    DownloadJobStatus.failed => 'Failed',
    DownloadJobStatus.completed => 'Completed',
  };
}
