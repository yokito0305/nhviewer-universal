import 'package:concept_nhv/application/reader/reader_settings_repository.dart';

/// In-memory implementation of [ReaderSettingsRepository] for use in tests.
///
/// All values are stored in-memory maps and reset between test runs via the
/// standard setUp / tearDown lifecycle.
class FakeReaderSettingsRepository implements ReaderSettingsRepository {
  int _prefetchPageCount = ReaderSettingsRepository.defaultPrefetchPageCount;
  final Map<String, int> _lastSeenPages = {};

  @override
  Future<int> loadPrefetchPageCount() async => _prefetchPageCount;

  @override
  Future<void> savePrefetchPageCount(int count) async {
    _prefetchPageCount = count;
  }

  @override
  Future<int?> loadLastSeenPage(String comicId) async => _lastSeenPages[comicId];

  @override
  Future<void> saveLastSeenPage(String comicId, int page) async {
    _lastSeenPages[comicId] = page;
  }
}
