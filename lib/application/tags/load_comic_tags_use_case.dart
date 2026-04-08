import 'package:concept_nhv/models/comic_tag.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';

class LoadComicTagsUseCase {
  const LoadComicTagsUseCase({required this.nhentaiGateway});

  final NhentaiGateway nhentaiGateway;

  Future<List<ComicTag>> execute(String comicId) {
    return nhentaiGateway.loadComicTags(comicId);
  }
}
