import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/image_format.dart';

class ComicPageSourceResolver {
  const ComicPageSourceResolver();

  String resolvePageUrl({
    required Comic comic,
    required int pageNumber,
  }) {
    final pageImage = comic.images.pages[pageNumber - 1];
    final path = pageImage.path;
    if (path != null && path.isNotEmpty) {
      return 'https://i1.nhentai.net/$path';
    }

    return 'https://i1.nhentai.net/galleries/${comic.mediaId}/$pageNumber.${imageTypeCodeToExtension(pageImage.t)}';
  }
}
