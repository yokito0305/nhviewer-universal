import 'dart:convert';

import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_language.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
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
          const SliverAppBar(
            title: Text('Settings'),
          ),
          SliverList.list(
            children: <Widget>[
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
          SnackBar(
            content: Text('Language set to `${selected.displayName}`'),
          ),
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
        final collectionResponse = await Dio().get<String>('$url/collections.json');
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
          final collectionType = CollectionType.fromStorageName(json['name'] as String);
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
