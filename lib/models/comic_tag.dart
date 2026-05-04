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

extension ComicTagQuery on ComicTag {
  /// Builds the search query string for this tag (e.g. `tag:full-color`).
  ///
  /// Mirrors the slug convention used by the API: lowercase, spaces replaced
  /// with hyphens. Used as the canonical query key across search entry points.
  String get query {
    final type = this.type ?? 'tag';
    final slug = (name ?? '').toLowerCase().replaceAll(' ', '-');
    return '$type:$slug';
  }
}
