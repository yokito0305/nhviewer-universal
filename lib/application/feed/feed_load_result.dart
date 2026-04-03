import 'package:concept_nhv/models/comic.dart';

class FeedLoadResult {
  const FeedLoadResult({
    required this.comics,
    required this.pageLoaded,
    required this.noMorePage,
    required this.statusCode,
    this.errorMessage,
  });

  final List<Comic> comics;
  final int pageLoaded;
  final bool noMorePage;
  final int statusCode;
  final String? errorMessage;
}
