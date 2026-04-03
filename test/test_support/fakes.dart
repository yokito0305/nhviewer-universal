import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_images.dart';
import 'package:concept_nhv/models/comic_page_image.dart';
import 'package:concept_nhv/models/comic_search_response.dart';
import 'package:concept_nhv/models/comic_tag.dart';
import 'package:concept_nhv/models/comic_title.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/storage/secure_key_value_store.dart';
import 'package:dio/dio.dart';

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

class MemorySecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

Comic sampleComic({String id = '1001', String mediaId = '9'}) {
  return Comic(
    id: id,
    mediaId: mediaId,
    title: ComicTitle(
      english: 'Sample Comic',
      japanese: '?萸?',
      pretty: 'Sample Comic',
    ),
    images: ComicImages(
      pages: <ComicPageImage>[
        ComicPageImage(t: 'j', w: 1200, h: 1800),
        ComicPageImage(t: 'j', w: 1200, h: 1800),
      ],
      cover: ComicPageImage(t: 'j', w: 350, h: 500),
      thumbnail: ComicPageImage(t: 'w', w: 350, h: 500),
    ),
    scanlator: null,
    uploadDate: 0,
    tags: <ComicTag>[
      ComicTag(
        id: 1,
        type: 'tag',
        name: 'sample',
        url: '/tag/sample',
        count: 1,
      ),
    ],
    numPages: 2,
    numFavorites: 1,
  );
}

DioException sampleDioException([int? statusCode]) {
  return DioException(
    requestOptions: RequestOptions(path: '/'),
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: statusCode,
          ),
  );
}
