import 'package:freezed_annotation/freezed_annotation.dart';

part 'comic_tag.freezed.dart';
part 'comic_tag.g.dart';

@freezed
abstract class ComicTag with _$ComicTag {
  factory ComicTag({
    int? id,
    String? type,
    String? name,
    String? url,
    int? count,
  }) = _ComicTag;

  factory ComicTag.fromJson(Map<String, dynamic> json) =>
      _$ComicTagFromJson(json);
}
