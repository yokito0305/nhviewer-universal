/// Code generated using [JSON to Dart converter](https://javiercbk.github.io/json_to_dart/) by Javier Lecuona. 
/// Note that id and mediaid could be both string and int
class NHList {
  List<NHComic>? result;
  int? numPages;
  int? perPage;

  NHList({this.result, this.numPages, this.perPage});

  NHList.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <NHComic>[];
      json['result'].forEach((v) {
        result!.add(NHComic.fromJson(v));
      });
    }
    numPages = json['num_pages'];
    perPage = json['per_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['num_pages'] = numPages;
    data['per_page'] = perPage;
    return data;
  }
}
class NHComic {
  String? id;
  String? mediaId;
  Title? title;
  NHImages? images;
  String? scanlator;
  int? uploadDate;
  List<Tags>? tags;
  int? numPages;
  int? numFavorites;

  NHComic(
      {String? id,
      String? mediaId,
      Title? title,
      NHImages? images,
      String? scanlator,
      int? uploadDate,
      List<Tags>? tags,
      int? numPages,
      int? numFavorites}) {
    if (id != null) {
      this.id = id;
    }
    if (mediaId != null) {
      this.mediaId = mediaId;
    }
    if (title != null) {
      this.title = title;
    }
    if (images != null) {
      this.images = images;
    }
    if (scanlator != null) {
      this.scanlator = scanlator;
    }
    if (uploadDate != null) {
      this.uploadDate = uploadDate;
    }
    if (tags != null) {
      this.tags = tags;
    }
    if (numPages != null) {
      this.numPages = numPages;
    }
    if (numFavorites != null) {
      this.numFavorites = numFavorites;
    }
  }

  NHComic.fromJson(Map<String, dynamic> json) {
    id = "${json['id']}";
    mediaId = "${json['media_id']}";
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    images =
        json['images'] != null ? NHImages.fromJson(json['images']) : null;
    scanlator = json['scanlator'];
    uploadDate = json['upload_date'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
    numPages = json['num_pages'];
    numFavorites = json['num_favorites'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['media_id'] = mediaId;
    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (images != null) {
      data['images'] = images!.toJson();
    }
    data['scanlator'] = scanlator;
    data['upload_date'] = uploadDate;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['num_pages'] = numPages;
    data['num_favorites'] = numFavorites;
    return data;
  }
}

class Title {
  String? english;
  String? japanese;
  String? pretty;

  Title({String? english, String? japanese, String? pretty}) {
    if (english != null) {
      this.english = english;
    }
    if (japanese != null) {
      this.japanese = japanese;
    }
    if (pretty != null) {
      this.pretty = pretty;
    }
  }

  Title.fromJson(Map<String, dynamic> json) {
    english = json['english'];
    japanese = json['japanese'];
    pretty = json['pretty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['english'] = english;
    data['japanese'] = japanese;
    data['pretty'] = pretty;
    return data;
  }
}

class NHImages {
  List<Pages>? pages;
  Pages? cover;
  Pages? thumbnail;

  NHImages({List<Pages>? pages, Pages? cover, Pages? thumbnail}) {
    if (pages != null) {
      this.pages = pages;
    }
    if (cover != null) {
      this.cover = cover;
    }
    if (thumbnail != null) {
      this.thumbnail = thumbnail;
    }
  }

  NHImages.fromJson(Map<String, dynamic> json) {
    if (json['pages'] != null) {
      pages = <Pages>[];
      json['pages'].forEach((v) {
        pages!.add(Pages.fromJson(v));
      });
    }
    cover = json['cover'] != null ? Pages.fromJson(json['cover']) : null;
    thumbnail = json['thumbnail'] != null
        ? Pages.fromJson(json['thumbnail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pages != null) {
      data['pages'] = pages!.map((v) => v.toJson()).toList();
    }
    if (cover != null) {
      data['cover'] = cover!.toJson();
    }
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    return data;
  }
}

class Pages {
  String? t;
  int? w;
  int? h;

  Pages({String? t, int? w, int? h}) {
    if (t != null) {
      this.t = t;
    }
    if (w != null) {
      this.w = w;
    }
    if (h != null) {
      this.h = h;
    }
  }

  Pages.fromJson(Map<String, dynamic> json) {
    t = json['t'];
    w = json['w'];
    h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t'] = t;
    data['w'] = w;
    data['h'] = h;
    return data;
  }
}

class Tags {
  int? id;
  String? type;
  String? name;
  String? url;
  int? count;

  Tags({int? id, String? type, String? name, String? url, int? count}) {
    if (id != null) {
      this.id = id;
    }
    if (type != null) {
      this.type = type;
    }
    if (name != null) {
      this.name = name;
    }
    if (url != null) {
      this.url = url;
    }
    if (count != null) {
      this.count = count;
    }
  }

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    url = json['url'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['url'] = url;
    data['count'] = count;
    return data;
  }
}
