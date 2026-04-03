import 'package:concept_nhv/application/reader/load_comic_detail_use_case.dart';
import 'package:concept_nhv/application/reader/open_comic_use_case.dart';
import 'package:concept_nhv/application/reader/reader_progress_repository.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:flutter/material.dart';

class ComicReaderModel extends ChangeNotifier {
  ComicReaderModel({
    required this.loadComicDetailUseCase,
    required this.openComicUseCase,
    required this.readerProgressRepository,
  });

  final LoadComicDetailUseCase loadComicDetailUseCase;
  final OpenComicUseCase openComicUseCase;
  final ReaderProgressRepository readerProgressRepository;

  final ScrollController scrollController = ScrollController();
  Comic? _currentComic;
  Map<String, String>? _currentHeaders;

  Comic? get currentComic => _currentComic;
  Map<String, String>? get currentHeaders => _currentHeaders;

  Future<void> loadComicDetail(String comicId) async {
    final result = await loadComicDetailUseCase.execute(comicId);
    _currentHeaders = result.headers;
    await openComic(result.comic);
  }

  Future<void> openComic(Comic comic) async {
    _currentComic = comic;
    await openComicUseCase.execute(comic);
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
    await readerProgressRepository.saveLastSeenOffset(comicId, offset);
  }

  Future<double?> loadLastSeenOffset(String comicId) async {
    return readerProgressRepository.loadLastSeenOffset(comicId);
  }

  void clearComic() {
    _currentComic = null;
    _currentHeaders = null;
    notifyListeners();
  }
}
