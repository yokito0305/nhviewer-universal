import 'package:flutter/services.dart';

abstract class CloudflareCookieBridge {
  Future<String> readCookieStringFromPlatform();
}

class MethodChannelCloudflareCookieBridge implements CloudflareCookieBridge {
  const MethodChannelCloudflareCookieBridge();

  static const MethodChannel _channel =
      MethodChannel('samples.flutter.dev/cookies');

  @override
  Future<String> readCookieStringFromPlatform() async {
    final result = await _channel.invokeMethod<String>('readCloudflareCookies');
    return result ?? '';
  }
}
