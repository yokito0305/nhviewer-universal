import 'package:concept_nhv/application/reader/reader_settings_repository.dart';
import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/services/library_import_service.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(title: Text('Settings')),
          SliverList.list(
            children: <Widget>[
              // ── nhentai API ──────────────────────────────────────────────
              const ListTile(title: Text('nhentai API Key')),
              _buildSessionStatusTile(context),
              _buildLoginTile(context),
              _buildSyncFavoritesTile(context),
              _buildLogoutTile(context),
              const Divider(),

              // ── Reader ───────────────────────────────────────────────────
              const ListTile(title: Text('Reader')),
              _buildPrefetchCountTile(context),
              _buildClearCacheTile(context),
              const Divider(),

              // ── General ──────────────────────────────────────────────────
              _buildLanguageTile(context),
              _buildDiagnoseTile(),
              const Divider(),

              // ── About ────────────────────────────────────────────────────
              const ListTile(title: Text('About')),
              _buildImportTile(context),
              const Divider(),
              _buildLicenseTile(context),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // nhentai API tiles
  // ---------------------------------------------------------------------------

  Widget _buildSessionStatusTile(BuildContext context) {
    final favoriteModel = context.watch<FavoriteSyncModel>();
    final status = favoriteModel.isAuthenticated
        ? 'Authenticated'
        : 'Not configured';
    final lastSync = favoriteModel.lastSyncAt?.toLocal().toString() ?? 'Never';
    final syncError = favoriteModel.syncError;
    return ListTile(
      title: const Text('Status'),
      subtitle: Text(
        syncError == null
            ? '$status\nLast sync: $lastSync'
            : '$status\n$syncError',
      ),
    );
  }

  Widget _buildLoginTile(BuildContext context) {
    return ListTile(
      title: const Text('Set / Update API Key'),
      subtitle: const Text(
        'Paste your personal nhentai API key from account settings',
      ),
      onTap: () async {
        final favoriteModel = context.read<FavoriteSyncModel>();
        final feedModel = context.read<ComicFeedModel>();
        final messenger = ScaffoldMessenger.of(context);
        final apiKey = await _promptApiKey(
          context,
          favoriteModel.isAuthenticated,
        );
        if (apiKey == null || apiKey.trim().isEmpty || !context.mounted) {
          return;
        }

        try {
          await favoriteModel.saveAndValidateApiKey(apiKey);
          await favoriteModel.syncFavorites();
          messenger.showSnackBar(
            const SnackBar(content: Text('API key saved and validated')),
          );
        } on NhentaiAuthException catch (error) {
          messenger.showSnackBar(SnackBar(content: Text(error.message)));
        }
        feedModel.refreshCollections();
      },
    );
  }

  Widget _buildSyncFavoritesTile(BuildContext context) {
    return ListTile(
      title: const Text('Sync Favorites Now'),
      subtitle: const Text('Refresh the local favorite cache from the official API'),
      onTap: () async {
        final favoriteModel = context.read<FavoriteSyncModel>();
        final feedModel = context.read<ComicFeedModel>();
        final ok = await favoriteModel.syncFavorites();
        if (!context.mounted) return;

        feedModel.refreshCollections();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Favorites synced from API' : favoriteModel.syncError ?? 'Sync failed',
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      title: const Text('Clear API Key'),
      subtitle: const Text('Remove the saved API key from secure storage'),
      onTap: () async {
        final favoriteModel = context.read<FavoriteSyncModel>();
        final messenger = ScaffoldMessenger.of(context);
        await favoriteModel.clearApiKey();
        messenger.showSnackBar(
          const SnackBar(content: Text('API key cleared')),
        );
      },
    );
  }

  Future<String?> _promptApiKey(BuildContext context, bool isEditing) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Update API Key' : 'Set API Key'),
          content: TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Paste your nhentai API key',
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Reader tiles
  // ---------------------------------------------------------------------------

  /// Shows the current prefetch page count and allows changing it via a slider.
  Widget _buildPrefetchCountTile(BuildContext context) {
    final readerModel = context.watch<ComicReaderModel>();
    final count = readerModel.prefetchPageCount;
    return ListTile(
      title: const Text('Pre-fetch Pages'),
      subtitle: Text(
        'Cache $count page(s) before and after the current page (default: '
        '${ReaderSettingsRepository.defaultPrefetchPageCount})',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPrefetchDialog(context, readerModel),
    );
  }

  Future<void> _showPrefetchDialog(
    BuildContext context,
    ComicReaderModel model,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _PrefetchCountDialog(model: model);
      },
    );
  }

  /// Clears all cached images from disk and memory.
  Widget _buildClearCacheTile(BuildContext context) {
    return ListTile(
      title: const Text('Clear Image Cache'),
      subtitle: const Text('Delete all cached comic images from disk'),
      trailing: const Icon(Icons.delete_outline),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        // Disk cache (flutter_cache_manager / cached_network_image)
        await DefaultCacheManager().emptyCache();
        // Flutter's in-memory image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        if (!context.mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Image cache cleared')),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // General tiles
  // ---------------------------------------------------------------------------

  Widget _buildLanguageTile(BuildContext context) {
    final feedModel = context.watch<ComicFeedModel>();
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(feedModel.currentLanguage.displayName),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final selected = await showDialog<ComicLanguage>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Language'),
              children: ComicLanguage.values.map((language) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(language),
                  child: Text(language.displayName),
                );
              }).toList(),
            );
          },
        );

        if (selected == null || !context.mounted) return;

        feedModel.setLanguage(selected);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(content: Text('Language set to `${selected.displayName}`')),
        );
      },
    );
  }

  Widget _buildDiagnoseTile() {
    return const ListTile(
      title: Text('Diagnose'),
      subtitle: Text('Reserved for future diagnostics'),
    );
  }

  // ---------------------------------------------------------------------------
  // About tiles
  // ---------------------------------------------------------------------------

  Widget _buildImportTile(BuildContext context) {
    return ListTile(
      title: const Text('Load json (network)'),
      onTap: () async {
        final feedModel = context.read<ComicFeedModel>();
        final url = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enter URL'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(labelText: 'URL'),
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
            );
          },
        );

        if (url == null || url.isEmpty || !context.mounted) return;

        await context.read<LibraryImportService>().importFromBaseUrl(url);
        feedModel.refreshCollections();
      },
    );
  }

  Widget _buildLicenseTile(BuildContext context) {
    return ListTile(
      title: const Text('Open Source Licenses'),
      onTap: () => showLicensePage(context: context),
    );
  }
}

// ---------------------------------------------------------------------------
// Prefetch count dialog widget
// ---------------------------------------------------------------------------

class _PrefetchCountDialog extends StatefulWidget {
  const _PrefetchCountDialog({required this.model});

  final ComicReaderModel model;

  @override
  State<_PrefetchCountDialog> createState() => _PrefetchCountDialogState();
}

class _PrefetchCountDialogState extends State<_PrefetchCountDialog> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.model.prefetchPageCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pre-fetch Pages'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pre-cache $_count page(s) before and after the current page.',
          ),
          const SizedBox(height: 16),
          Slider(
            value: _count.toDouble(),
            min: ReaderSettingsRepository.minPrefetchPageCount.toDouble(),
            max: ReaderSettingsRepository.maxPrefetchPageCount.toDouble(),
            divisions: ReaderSettingsRepository.maxPrefetchPageCount -
                ReaderSettingsRepository.minPrefetchPageCount,
            label: '$_count',
            onChanged: (value) => setState(() => _count = value.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ReaderSettingsRepository.minPrefetchPageCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${ReaderSettingsRepository.maxPrefetchPageCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.model.savePrefetchPageCount(_count);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
