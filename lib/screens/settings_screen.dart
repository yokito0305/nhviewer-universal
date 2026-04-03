import 'dart:convert';

import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/services/nhentai_auth_service.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/favorite_sync_model.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
              const ListTile(title: Text('nhentai API Key')),
              _buildSessionStatusTile(context),
              _buildLoginTile(context),
              _buildSyncFavoritesTile(context),
              _buildLogoutTile(context),
              const Divider(),
              _buildLanguageTile(context),
              _buildDiagnoseTile(),
              const Divider(),
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
        final authService = context.read<NhentaiAuthService>();
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
          await authService.saveAndValidateApiKey(apiKey);
          await favoriteModel.initialize();
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
        if (!context.mounted) {
          return;
        }

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
        await favoriteModel.logout();
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

        if (selected == null || !context.mounted) {
          return;
        }

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

        if (url == null || url.isEmpty || !context.mounted) {
          return;
        }

        final comicResponse = await Dio().get<String>('$url/comics.json');
        final collectionResponse = await Dio().get<String>(
          '$url/collections.json',
        );
        if (!context.mounted) {
          return;
        }
        final comicJson = List<Map<String, dynamic>>.from(
          jsonDecode(comicResponse.data!) as List<dynamic>,
        );
        final collectionJson = List<Map<String, dynamic>>.from(
          jsonDecode(collectionResponse.data!) as List<dynamic>,
        );

        final comicRepository = context.read<ComicRepository>();
        final collectionRepository = context.read<CollectionRepository>();

        for (final json in comicJson) {
          await comicRepository.upsertComic(
            StoredComic(
              id: '${json['id']}',
              mediaId: json['mid'] as String,
              title: json['title'] as String,
              serializedImages: json['pageTypes'] as String,
              pages: json['numOfPages'] as int,
            ),
          );
        }

        for (final json in collectionJson) {
          final collectionType = CollectionType.fromStorageName(
            json['name'] as String,
          );
          if (collectionType == null) {
            continue;
          }

          await collectionRepository.addComicToCollection(
            collectionType: collectionType,
            comicId: '${json['id']}',
            dateCreated: DateTime.fromMillisecondsSinceEpoch(
              json['dateCreated'] as int,
            ).toIso8601String(),
          );
        }

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
