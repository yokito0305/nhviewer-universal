import 'package:concept_nhv/application/reader/load_comic_detail_use_case.dart';
import 'package:concept_nhv/application/reader/open_comic_use_case.dart';
import 'package:concept_nhv/application/reader/reader_progress_repository.dart';
import 'package:concept_nhv/application/reader/reader_settings_repository.dart';
import 'package:concept_nhv/models/comic.dart';
import 'package:flutter/material.dart';

/// State model for the comic reader.
///
/// Manages the currently open comic, page-level navigation, pre-fetch settings,
/// and the visibility of the reader controls overlay.
class ComicReaderModel extends ChangeNotifier {
  ComicReaderModel({
    required this.loadComicDetailUseCase,
    required this.openComicUseCase,
    required this.readerProgressRepository,
    required this.readerSettingsRepository,
  });

  final LoadComicDetailUseCase loadComicDetailUseCase;
  final OpenComicUseCase openComicUseCase;
  final ReaderProgressRepository readerProgressRepository;
  final ReaderSettingsRepository readerSettingsRepository;

  final PageController pageController = PageController();

  Comic? _currentComic;
  Map<String, String>? _currentHeaders;
  int _currentPage = 1;
  bool _showControls = false;
  int _prefetchPageCount = ReaderSettingsRepository.defaultPrefetchPageCount;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  Comic? get currentComic => _currentComic;
  Map<String, String>? get currentHeaders => _currentHeaders;

  /// 1-indexed current page number.
  int get currentPage => _currentPage;

  int get totalPages => _currentComic?.numPages ?? 0;

  /// Favorites count of the current comic, or null if not yet loaded.
  int? get numFavorites => _currentComic?.numFavorites;

  /// Whether the bottom controls overlay should be visible.
  bool get showControls => _showControls;

  /// How many pages before and after the current page to pre-cache.
  int get prefetchPageCount => _prefetchPageCount;

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Loads persisted reader preferences. Call once after construction.
  Future<void> loadSettings() async {
    _prefetchPageCount = await readerSettingsRepository.loadPrefetchPageCount();
    notifyListeners();
  }

  /// Updates and persists [count] as the new prefetch page count.
  Future<void> savePrefetchPageCount(int count) async {
    _prefetchPageCount = count;
    await readerSettingsRepository.savePrefetchPageCount(count);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Comic loading
  // ---------------------------------------------------------------------------

  Future<void> loadComicDetail(String comicId) async {
    final result = await loadComicDetailUseCase.execute(comicId);
    _currentHeaders = result.headers;
    await openComic(result.comic);
  }

  Future<void> openComic(Comic comic) async {
    _currentComic = comic;
    _currentPage = 1;
    _showControls = false;
    await openComicUseCase.execute(comic);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Page navigation
  // ---------------------------------------------------------------------------

  /// Called by [PageView.onPageChanged]. Keeps [_currentPage] in sync and
  /// persists progress.
  void onPageChanged(int pageIndex, String comicId) {
    _currentPage = pageIndex + 1;
    notifyListeners();
    readerSettingsRepository.saveLastSeenPage(comicId, _currentPage);
  }

  /// Animates [pageController] to the given 1-indexed [page].
  void goToPage(int page) {
    if (_currentComic == null) return;
    final target = page.clamp(1, totalPages);
    pageController.jumpToPage(target - 1);
  }

  // ---------------------------------------------------------------------------
  // Controls overlay
  // ---------------------------------------------------------------------------

  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  void hideControls() {
    if (!_showControls) return;
    _showControls = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Progress persistence (legacy offset-based, kept for backward compat)
  // ---------------------------------------------------------------------------

  Future<void> persistLastSeenOffset(String comicId, double offset) async {
    if (offset == 0) return;
    await readerProgressRepository.saveLastSeenOffset(comicId, offset);
  }

  Future<double?> loadLastSeenOffset(String comicId) {
    return readerProgressRepository.loadLastSeenOffset(comicId);
  }

  // ---------------------------------------------------------------------------
  // Progress persistence (page-based)
  // ---------------------------------------------------------------------------

  Future<int?> loadLastSeenPage(String comicId) {
    return readerSettingsRepository.loadLastSeenPage(comicId);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void clearComic() {
    _currentComic = null;
    _currentHeaders = null;
    _currentPage = 1;
    _showControls = false;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
