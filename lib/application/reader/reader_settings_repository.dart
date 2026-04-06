/// Repository interface for persisting reader-specific user preferences.
abstract class ReaderSettingsRepository {
  static const int defaultPrefetchPageCount = 3;
  static const int minPrefetchPageCount = 1;
  static const int maxPrefetchPageCount = 10;

  /// Returns how many pages before and after the current page to pre-cache.
  Future<int> loadPrefetchPageCount();

  /// Persists the prefetch page count preference.
  Future<void> savePrefetchPageCount(int count);

  /// Returns the last read page for [comicId], or null if never opened.
  Future<int?> loadLastSeenPage(String comicId);

  /// Persists the last read page for [comicId].
  Future<void> saveLastSeenPage(String comicId, int page);
}
