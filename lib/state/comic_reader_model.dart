import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/stored_comic.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/storage/collection_repository.dart';
import 'package:concept_nhv/storage/comic_repository.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:flutter/material.dart';

class ComicReaderModel extends ChangeNotifier {
  ComicReaderModel({
    required this.nhentaiGateway,
    required this.comicRepository,
    required this.collectionRepository,
    required this.optionsStore,
  });

  final NhentaiGateway nhentaiGateway;
  final ComicRepository comicRepository;
  final CollectionRepository collectionRepository;
  final OptionsStore optionsStore;

  final ScrollController scrollController = ScrollController();
  Comic? _currentComic;
  Map<String, String>? _currentHeaders;

  Comic? get currentComic => _currentComic;
  Map<String, String>? get currentHeaders => _currentHeaders;

  Future<void> loadComicDetail(String comicId) async {
    final result = await nhentaiGateway.loadComicDetail(comicId);
    _currentHeaders = result.headers;
    await openComic(result.comic);
  }

  Future<void> openComic(Comic comic) async {
    _currentComic = comic;
    await comicRepository.upsertComic(StoredComic.fromComic(comic));
    await collectionRepository.addComicToCollection(
      collectionType: CollectionType.history,
      comicId: comic.id,
    );
    notifyListeners();
  }

  Future<void> persistLastSeenOffset(String comicId) async {
    if (!scrollController.hasClients) {
      return;
    }
    final offset = scrollController.offset;
    if (offset == 0) {
      return;
    }
    await optionsStore.saveOption('lastSeenOffset-$comicId', offset.toString());
  }

  Future<double?> loadLastSeenOffset(String comicId) async {
    final value = await optionsStore.loadOption('lastSeenOffset-$comicId');
    if (value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }

  void clearComic() {
    _currentComic = null;
    _currentHeaders = null;
    notifyListeners();
  }
}
