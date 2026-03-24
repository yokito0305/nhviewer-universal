// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudflare_cookie_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudflareCookiePair _$CloudflareCookiePairFromJson(
  Map<String, dynamic> json,
) => _CloudflareCookiePair(
  userAgent: json['userAgent'] as String? ?? '',
  token: json['token'] as String? ?? '',
);

Map<String, dynamic> _$CloudflareCookiePairToJson(
  _CloudflareCookiePair instance,
) => <String, dynamic>{
  'userAgent': instance.userAgent,
  'token': instance.token,
};
