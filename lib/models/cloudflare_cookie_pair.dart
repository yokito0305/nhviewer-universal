import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudflare_cookie_pair.freezed.dart';
part 'cloudflare_cookie_pair.g.dart';

@freezed
abstract class CloudflareCookiePair with _$CloudflareCookiePair {
  const CloudflareCookiePair._();

  factory CloudflareCookiePair({
    @Default('') String userAgent,
    @Default('') String token,
  }) = _CloudflareCookiePair;

  factory CloudflareCookiePair.fromJson(Map<String, dynamic> json) =>
      _$CloudflareCookiePairFromJson(json);

  bool get isEmpty => userAgent.isEmpty || token.isEmpty;

  Map<String, String> get asHeaders => <String, String>{
        'User-Agent': userAgent,
        'Cookie': 'cf_clearance=$token',
      };
}
