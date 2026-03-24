import 'package:concept_nhv/models/comic.dart';
import 'package:concept_nhv/models/comic_search_response.dart';
import 'package:concept_nhv/storage/cloudflare_cookie_store.dart';
import 'package:dio/dio.dart';

abstract class NhentaiGateway {
  Future<void> pingHomepage();

  Future<ComicSearchResponse> searchComics(Uri uri);

  Future<({Comic comic, Map<String, String>? headers})> loadComicDetail(
    String comicId,
  );
}

class NhentaiApiClient implements NhentaiGateway {
  NhentaiApiClient({
    required this.cookieStore,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final CloudflareCookieStore cookieStore;
  final Dio _dio;

  @override
  Future<void> pingHomepage() async {
    await _getWithCookieFallback(Uri.https('nhentai.net', ''));
  }

  @override
  Future<ComicSearchResponse> searchComics(Uri uri) async {
    final result = await _getWithCookieFallback(uri);
    return ComicSearchResponse.fromJson(
      result.response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<({Comic comic, Map<String, String>? headers})> loadComicDetail(
    String comicId,
  ) async {
    final result = await _getWithCookieFallback(
      Uri.https('nhentai.net', '/api/gallery/$comicId'),
    );
    return (
      comic: Comic.fromJson(result.response.data as Map<String, dynamic>),
      headers: result.headers,
    );
  }

  Future<({Response<dynamic> response, Map<String, String>? headers})>
      _getWithCookieFallback(Uri uri) async {
    try {
      final response = await _dio.getUri(uri);
      return (response: response, headers: null);
    } on DioException {
      final cookiePair = await cookieStore.load();
      if (cookiePair.isEmpty) {
        rethrow;
      }

      final headers = cookiePair.asHeaders;
      final response = await _dio.getUri(
        uri,
        options: Options(headers: headers),
      );
      return (response: response, headers: headers);
    }
  }
}

