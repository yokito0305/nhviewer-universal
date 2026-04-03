import 'package:concept_nhv/models/comic_card_data.dart';

class CollectionPageSnapshot {
  const CollectionPageSnapshot({
    required this.comics,
    required this.didRefreshCollections,
  });

  final List<ComicCardData> comics;
  final bool didRefreshCollections;
}
