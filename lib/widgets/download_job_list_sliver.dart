import 'dart:io';

import 'package:concept_nhv/models/download_job_snapshot.dart';
import 'package:concept_nhv/models/download_job_status.dart';
import 'package:concept_nhv/state/download_manager_model.dart';
import 'package:concept_nhv/widgets/fallback_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<DownloadJobSnapshot> sortDownloadJobs(Iterable<DownloadJobSnapshot> jobs) {
  final sortedJobs = jobs.toList(growable: false);
  return sortedJobs..sort(compareDownloadJobs);
}

int compareDownloadJobs(DownloadJobSnapshot a, DownloadJobSnapshot b) {
  final statusComparison = downloadJobStatusPriority(a.status).compareTo(
    downloadJobStatusPriority(b.status),
  );
  if (statusComparison != 0) {
    return statusComparison;
  }
  return b.requestedAt.compareTo(a.requestedAt);
}

int downloadJobStatusPriority(DownloadJobStatus status) {
  return switch (status) {
    DownloadJobStatus.downloading => 0,
    DownloadJobStatus.queued => 1,
    DownloadJobStatus.failed => 2,
    DownloadJobStatus.paused => 3,
    DownloadJobStatus.completed => 4,
  };
}

class DownloadJobListSliver extends StatefulWidget {
  const DownloadJobListSliver({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<DownloadJobListSliver> createState() => _DownloadJobListSliverState();
}

class _DownloadJobListSliverState extends State<DownloadJobListSliver> {
  String? _expandedComicId;

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManagerModel>(
      builder: (context, model, _) {
        final filteredJobs = model.jobs
            .where(
              (job) => job.title.toLowerCase().contains(
                widget.searchQuery.trim().toLowerCase(),
              ),
            )
            .toList(growable: false);
        final sortedJobs = sortDownloadJobs(filteredJobs);

        if (sortedJobs.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                widget.searchQuery.trim().isEmpty
                    ? 'No download jobs yet'
                    : 'No downloads match "${widget.searchQuery.trim()}"',
              ),
            ),
          );
        }

        return SliverList.builder(
          itemCount: sortedJobs.length,
          itemBuilder: (context, index) {
            final job = sortedJobs[index];
            return _DownloadJobCard(
              key: ValueKey<String>(job.comicId),
              job: job,
              isExpanded: _expandedComicId == job.comicId,
              isMutating: model.isMutating(job.comicId),
              onToggleExpanded: () {
                setState(() {
                  _expandedComicId = _expandedComicId == job.comicId
                      ? null
                      : job.comicId;
                });
              },
            );
          },
        );
      },
    );
  }
}

class _DownloadJobCard extends StatelessWidget {
  const _DownloadJobCard({
    super.key,
    required this.job,
    required this.isExpanded,
    required this.isMutating,
    required this.onToggleExpanded,
  });

  final DownloadJobSnapshot job;
  final bool isExpanded;
  final bool isMutating;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final progress = job.totalPages == 0
        ? 0.0
        : (job.completedPages / job.totalPages).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onToggleExpanded,
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
                      child: _DownloadJobCover(job: job),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_statusLabel(job)),
                        const SizedBox(height: 8),
                        Text('${job.completedPages} / ${job.totalPages}'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
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
    return switch (job.status) {
      DownloadJobStatus.downloading => <Widget>[
        FilledButton.tonal(
          onPressed: isMutating
              ? null
              : () => _runAction(
                  context,
                  successMessage: 'Download paused',
                  action: () => model.pause(job.comicId),
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
                  action: () => model.pause(job.comicId),
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
                  action: () => model.resume(job.comicId),
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
                  action: () => model.retry(job.comicId),
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
      DownloadJobStatus.completed => <Widget>[
        OutlinedButton(
          onPressed: isMutating
              ? null
              : () => _confirmAndDelete(
                  context,
                  title: 'Delete downloaded comic?',
                  message:
                      'This deletes the saved download, cover, offline snapshot, and the completed job record.',
                  successMessage: 'Downloaded comic deleted',
                ),
          child: const Text('Delete Download'),
        ),
      ],
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
      action: () => context.read<DownloadManagerModel>().deleteJob(job.comicId),
    );
  }

  Future<void> _runAction(
    BuildContext context, {
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
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

  String _statusLabel(DownloadJobSnapshot job) {
    return switch (job.status) {
      DownloadJobStatus.downloading => 'Downloading',
      DownloadJobStatus.queued => 'Queued',
      DownloadJobStatus.paused => 'Paused',
      DownloadJobStatus.failed => 'Failed',
      DownloadJobStatus.completed => 'Completed',
    };
  }
}

class _DownloadJobCover extends StatelessWidget {
  const _DownloadJobCover({required this.job});

  final DownloadJobSnapshot job;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: context.read<DownloadManagerModel>().loadCoverLocalPath(job.comicId),
      builder: (context, snapshot) {
        final localCoverPath = snapshot.data;
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
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    final thumbnailPath = job.thumbnailPath;
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
