import 'package:concept_nhv/models/cloudflare_cookie_pair.dart';
import 'package:concept_nhv/services/nhentai_api_client.dart';
import 'package:concept_nhv/services/platform/cloudflare_cookie_bridge.dart';
import 'package:concept_nhv/storage/cloudflare_cookie_store.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CloudflareCookieService {
  const CloudflareCookieService({
    required this.bridge,
    required this.cookieStore,
    required this.nhentaiGateway,
  });

  final CloudflareCookieBridge bridge;
  final CloudflareCookieStore cookieStore;
  final NhentaiGateway nhentaiGateway;

  Future<bool> validateStoredCloudflareCookies() async {
    try {
      await nhentaiGateway.pingHomepage();
      return true;
    } on DioException {
      await cookieStore.clear();
      return false;
    }
  }

  Future<CloudflareCookiePair> captureAndPersistCloudflareCookies(
    WebViewController controller,
  ) async {
    final rawCookieString = await bridge.readCookieStringFromPlatform();
    final token = extractCloudflareToken(rawCookieString);
    final userAgent = await controller.getUserAgent() ?? '';

    final pair = CloudflareCookiePair(
      userAgent: userAgent,
      token: token,
    );

    if (!pair.isEmpty) {
      await cookieStore.save(pair);
    }

    return pair;
  }

  String extractCloudflareToken(String cookieString) {
    if (!cookieString.contains('cf_clearance=')) {
      return '';
    }

    return cookieString
        .split('; ')
        .firstWhere(
          (segment) => segment.startsWith('cf_clearance='),
          orElse: () => '',
        )
        .replaceFirst('cf_clearance=', '');
  }
}
