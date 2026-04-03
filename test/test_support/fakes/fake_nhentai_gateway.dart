import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_search_response.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:dio/dio.dart';

import '../fixtures/sample_comic.dart';

class FakeNhentaiGateway implements NhentaiGateway {
  FakeNhentaiGateway({
    this.pingError,
    this.searchResponse,
    this.detailComic,
    this.detailHeaders,
  });

  final DioException? pingError;
  final ComicSearchResponse? searchResponse;
  final Comic? detailComic;
  final Map<String, String>? detailHeaders;

  @override
  Future<void> pingHomepage() async {
    if (pingError != null) {
      throw pingError!;
    }
  }

  @override
  Future<ComicSearchResponse> searchComics(Uri uri) async {
    if (searchResponse != null) {
      return searchResponse!;
    }

    return ComicSearchResponse(
      result: <Comic>[sampleComic()],
      numPages: 1,
      perPage: 25,
    );
  }

  @override
  Future<({Comic comic, Map<String, String>? headers})> loadComicDetail(
    String comicId,
  ) async {
    return (
      comic: detailComic ?? sampleComic(id: comicId),
      headers: detailHeaders,
    );
  }
}
