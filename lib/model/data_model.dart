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
  String? _id;
  String? _mediaId;
  Title? _title;
  NHImages? _images;
  String? _scanlator;
  int? _uploadDate;
  List<Tags>? _tags;
  int? _numPages;
  int? _numFavorites;

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
      _id = id;
    }
    if (mediaId != null) {
      _mediaId = mediaId;
    }
    if (title != null) {
      _title = title;
    }
    if (images != null) {
      _images = images;
    }
    if (scanlator != null) {
      _scanlator = scanlator;
    }
    if (uploadDate != null) {
      _uploadDate = uploadDate;
    }
    if (tags != null) {
      _tags = tags;
    }
    if (numPages != null) {
      _numPages = numPages;
    }
    if (numFavorites != null) {
      _numFavorites = numFavorites;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get mediaId => _mediaId;
  set mediaId(String? mediaId) => _mediaId = mediaId;
  Title? get title => _title;
  set title(Title? title) => _title = title;
  NHImages? get images => _images;
  set images(NHImages? images) => _images = images;
  String? get scanlator => _scanlator;
  set scanlator(String? scanlator) => _scanlator = scanlator;
  int? get uploadDate => _uploadDate;
  set uploadDate(int? uploadDate) => _uploadDate = uploadDate;
  List<Tags>? get tags => _tags;
  set tags(List<Tags>? tags) => _tags = tags;
  int? get numPages => _numPages;
  set numPages(int? numPages) => _numPages = numPages;
  int? get numFavorites => _numFavorites;
  set numFavorites(int? numFavorites) => _numFavorites = numFavorites;

  NHComic.fromJson(Map<String, dynamic> json) {
    _id = "${json['id']}";
    _mediaId = "${json['media_id']}";
    _title = json['title'] != null ? Title.fromJson(json['title']) : null;
    _images =
        json['images'] != null ? NHImages.fromJson(json['images']) : null;
    _scanlator = json['scanlator'];
    _uploadDate = json['upload_date'];
    if (json['tags'] != null) {
      _tags = <Tags>[];
      json['tags'].forEach((v) {
        _tags!.add(Tags.fromJson(v));
      });
    }
    _numPages = json['num_pages'];
    _numFavorites = json['num_favorites'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['media_id'] = _mediaId;
    if (_title != null) {
      data['title'] = _title!.toJson();
    }
    if (_images != null) {
      data['images'] = _images!.toJson();
    }
    data['scanlator'] = _scanlator;
    data['upload_date'] = _uploadDate;
    if (_tags != null) {
      data['tags'] = _tags!.map((v) => v.toJson()).toList();
    }
    data['num_pages'] = _numPages;
    data['num_favorites'] = _numFavorites;
    return data;
  }
}

class Title {
  String? _english;
  String? _japanese;
  String? _pretty;

  Title({String? english, String? japanese, String? pretty}) {
    if (english != null) {
      _english = english;
    }
    if (japanese != null) {
      _japanese = japanese;
    }
    if (pretty != null) {
      _pretty = pretty;
    }
  }

  String? get english => _english;
  set english(String? english) => _english = english;
  String? get japanese => _japanese;
  set japanese(String? japanese) => _japanese = japanese;
  String? get pretty => _pretty;
  set pretty(String? pretty) => _pretty = pretty;

  Title.fromJson(Map<String, dynamic> json) {
    _english = json['english'];
    _japanese = json['japanese'];
    _pretty = json['pretty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['english'] = _english;
    data['japanese'] = _japanese;
    data['pretty'] = _pretty;
    return data;
  }
}

class NHImages {
  List<Pages>? _pages;
  Pages? _cover;
  Pages? _thumbnail;

  NHImages({List<Pages>? pages, Pages? cover, Pages? thumbnail}) {
    if (pages != null) {
      _pages = pages;
    }
    if (cover != null) {
      _cover = cover;
    }
    if (thumbnail != null) {
      _thumbnail = thumbnail;
    }
  }

  List<Pages>? get pages => _pages;
  set pages(List<Pages>? pages) => _pages = pages;
  Pages? get cover => _cover;
  set cover(Pages? cover) => _cover = cover;
  Pages? get thumbnail => _thumbnail;
  set thumbnail(Pages? thumbnail) => _thumbnail = thumbnail;

  NHImages.fromJson(Map<String, dynamic> json) {
    if (json['pages'] != null) {
      _pages = <Pages>[];
      json['pages'].forEach((v) {
        _pages!.add(Pages.fromJson(v));
      });
    }
    _cover = json['cover'] != null ? Pages.fromJson(json['cover']) : null;
    _thumbnail = json['thumbnail'] != null
        ? Pages.fromJson(json['thumbnail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_pages != null) {
      data['pages'] = _pages!.map((v) => v.toJson()).toList();
    }
    if (_cover != null) {
      data['cover'] = _cover!.toJson();
    }
    if (_thumbnail != null) {
      data['thumbnail'] = _thumbnail!.toJson();
    }
    return data;
  }
}

class Pages {
  String? _t;
  int? _w;
  int? _h;

  Pages({String? t, int? w, int? h}) {
    if (t != null) {
      _t = t;
    }
    if (w != null) {
      _w = w;
    }
    if (h != null) {
      _h = h;
    }
  }

  String? get t => _t;
  set t(String? t) => _t = t;
  int? get w => _w;
  set w(int? w) => _w = w;
  int? get h => _h;
  set h(int? h) => _h = h;

  Pages.fromJson(Map<String, dynamic> json) {
    _t = json['t'];
    _w = json['w'];
    _h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t'] = _t;
    data['w'] = _w;
    data['h'] = _h;
    return data;
  }
}

class Tags {
  int? _id;
  String? _type;
  String? _name;
  String? _url;
  int? _count;

  Tags({int? id, String? type, String? name, String? url, int? count}) {
    if (id != null) {
      _id = id;
    }
    if (type != null) {
      _type = type;
    }
    if (name != null) {
      _name = name;
    }
    if (url != null) {
      _url = url;
    }
    if (count != null) {
      _count = count;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get type => _type;
  set type(String? type) => _type = type;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get url => _url;
  set url(String? url) => _url = url;
  int? get count => _count;
  set count(int? count) => _count = count;

  Tags.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _type = json['type'];
    _name = json['name'];
    _url = json['url'];
    _count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['type'] = _type;
    data['name'] = _name;
    data['url'] = _url;
    data['count'] = _count;
    return data;
  }
}