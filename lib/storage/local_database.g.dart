// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $AppOptionsTable extends AppOptions
    with TableInfo<$AppOptionsTable, AppOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Options';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  AppOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppOptionsTable createAlias(String alias) {
    return $AppOptionsTable(attachedDatabase, alias);
  }
}

class AppOption extends DataClass implements Insertable<AppOption> {
  final int id;
  final String name;
  final String value;
  const AppOption({required this.id, required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppOptionsCompanion toCompanion(bool nullToAbsent) {
    return AppOptionsCompanion(
      id: Value(id),
      name: Value(name),
      value: Value(value),
    );
  }

  factory AppOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppOption(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  AppOption copyWith({int? id, String? name, String? value}) => AppOption(
    id: id ?? this.id,
    name: name ?? this.name,
    value: value ?? this.value,
  );
  AppOption copyWithCompanion(AppOptionsCompanion data) {
    return AppOption(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppOption(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppOption &&
          other.id == this.id &&
          other.name == this.name &&
          other.value == this.value);
}

class AppOptionsCompanion extends UpdateCompanion<AppOption> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> value;
  const AppOptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });
  AppOptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String value,
  }) : name = Value(name),
       value = Value(value);
  static Insertable<AppOption> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  AppOptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? value,
  }) {
    return AppOptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppOptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ComicsTable extends Comics with TableInfo<$ComicsTable, Comic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _midMeta = const VerificationMeta('mid');
  @override
  late final GeneratedColumn<String> mid = GeneratedColumn<String>(
    'mid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesMeta = const VerificationMeta('pages');
  @override
  late final GeneratedColumn<int> pages = GeneratedColumn<int>(
    'pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mid, title, images, pages];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Comic';
  @override
  VerificationContext validateIntegrity(
    Insertable<Comic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mid')) {
      context.handle(
        _midMeta,
        mid.isAcceptableOrUnknown(data['mid']!, _midMeta),
      );
    } else if (isInserting) {
      context.missing(_midMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    if (data.containsKey('pages')) {
      context.handle(
        _pagesMeta,
        pages.isAcceptableOrUnknown(data['pages']!, _pagesMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Comic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Comic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      )!,
      pages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages'],
      )!,
    );
  }

  @override
  $ComicsTable createAlias(String alias) {
    return $ComicsTable(attachedDatabase, alias);
  }
}

class Comic extends DataClass implements Insertable<Comic> {
  final String id;
  final String mid;
  final String title;
  final String images;
  final int pages;
  const Comic({
    required this.id,
    required this.mid,
    required this.title,
    required this.images,
    required this.pages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mid'] = Variable<String>(mid);
    map['title'] = Variable<String>(title);
    map['images'] = Variable<String>(images);
    map['pages'] = Variable<int>(pages);
    return map;
  }

  ComicsCompanion toCompanion(bool nullToAbsent) {
    return ComicsCompanion(
      id: Value(id),
      mid: Value(mid),
      title: Value(title),
      images: Value(images),
      pages: Value(pages),
    );
  }

  factory Comic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Comic(
      id: serializer.fromJson<String>(json['id']),
      mid: serializer.fromJson<String>(json['mid']),
      title: serializer.fromJson<String>(json['title']),
      images: serializer.fromJson<String>(json['images']),
      pages: serializer.fromJson<int>(json['pages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mid': serializer.toJson<String>(mid),
      'title': serializer.toJson<String>(title),
      'images': serializer.toJson<String>(images),
      'pages': serializer.toJson<int>(pages),
    };
  }

  Comic copyWith({
    String? id,
    String? mid,
    String? title,
    String? images,
    int? pages,
  }) => Comic(
    id: id ?? this.id,
    mid: mid ?? this.mid,
    title: title ?? this.title,
    images: images ?? this.images,
    pages: pages ?? this.pages,
  );
  Comic copyWithCompanion(ComicsCompanion data) {
    return Comic(
      id: data.id.present ? data.id.value : this.id,
      mid: data.mid.present ? data.mid.value : this.mid,
      title: data.title.present ? data.title.value : this.title,
      images: data.images.present ? data.images.value : this.images,
      pages: data.pages.present ? data.pages.value : this.pages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Comic(')
          ..write('id: $id, ')
          ..write('mid: $mid, ')
          ..write('title: $title, ')
          ..write('images: $images, ')
          ..write('pages: $pages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mid, title, images, pages);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comic &&
          other.id == this.id &&
          other.mid == this.mid &&
          other.title == this.title &&
          other.images == this.images &&
          other.pages == this.pages);
}

class ComicsCompanion extends UpdateCompanion<Comic> {
  final Value<String> id;
  final Value<String> mid;
  final Value<String> title;
  final Value<String> images;
  final Value<int> pages;
  final Value<int> rowid;
  const ComicsCompanion({
    this.id = const Value.absent(),
    this.mid = const Value.absent(),
    this.title = const Value.absent(),
    this.images = const Value.absent(),
    this.pages = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComicsCompanion.insert({
    required String id,
    required String mid,
    required String title,
    required String images,
    required int pages,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mid = Value(mid),
       title = Value(title),
       images = Value(images),
       pages = Value(pages);
  static Insertable<Comic> custom({
    Expression<String>? id,
    Expression<String>? mid,
    Expression<String>? title,
    Expression<String>? images,
    Expression<int>? pages,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mid != null) 'mid': mid,
      if (title != null) 'title': title,
      if (images != null) 'images': images,
      if (pages != null) 'pages': pages,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComicsCompanion copyWith({
    Value<String>? id,
    Value<String>? mid,
    Value<String>? title,
    Value<String>? images,
    Value<int>? pages,
    Value<int>? rowid,
  }) {
    return ComicsCompanion(
      id: id ?? this.id,
      mid: mid ?? this.mid,
      title: title ?? this.title,
      images: images ?? this.images,
      pages: pages ?? this.pages,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mid.present) {
      map['mid'] = Variable<String>(mid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (pages.present) {
      map['pages'] = Variable<int>(pages.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComicsCompanion(')
          ..write('id: $id, ')
          ..write('mid: $mid, ')
          ..write('title: $title, ')
          ..write('images: $images, ')
          ..write('pages: $pages, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comicidMeta = const VerificationMeta(
    'comicid',
  );
  @override
  late final GeneratedColumn<String> comicid = GeneratedColumn<String>(
    'comicid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<String> dateCreated = GeneratedColumn<String>(
    'dateCreated',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, comicid, dateCreated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Collection';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('comicid')) {
      context.handle(
        _comicidMeta,
        comicid.isAcceptableOrUnknown(data['comicid']!, _comicidMeta),
      );
    } else if (isInserting) {
      context.missing(_comicidMeta);
    }
    if (data.containsKey('dateCreated')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['dateCreated']!,
          _dateCreatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name, comicid};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      comicid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comicid'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dateCreated'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String name;
  final String comicid;
  final String dateCreated;
  const Collection({
    required this.name,
    required this.comicid,
    required this.dateCreated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['comicid'] = Variable<String>(comicid);
    map['dateCreated'] = Variable<String>(dateCreated);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      name: Value(name),
      comicid: Value(comicid),
      dateCreated: Value(dateCreated),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      name: serializer.fromJson<String>(json['name']),
      comicid: serializer.fromJson<String>(json['comicid']),
      dateCreated: serializer.fromJson<String>(json['dateCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'comicid': serializer.toJson<String>(comicid),
      'dateCreated': serializer.toJson<String>(dateCreated),
    };
  }

  Collection copyWith({String? name, String? comicid, String? dateCreated}) =>
      Collection(
        name: name ?? this.name,
        comicid: comicid ?? this.comicid,
        dateCreated: dateCreated ?? this.dateCreated,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      name: data.name.present ? data.name.value : this.name,
      comicid: data.comicid.present ? data.comicid.value : this.comicid,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('name: $name, ')
          ..write('comicid: $comicid, ')
          ..write('dateCreated: $dateCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, comicid, dateCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.name == this.name &&
          other.comicid == this.comicid &&
          other.dateCreated == this.dateCreated);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> name;
  final Value<String> comicid;
  final Value<String> dateCreated;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.name = const Value.absent(),
    this.comicid = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String name,
    required String comicid,
    required String dateCreated,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       comicid = Value(comicid),
       dateCreated = Value(dateCreated);
  static Insertable<Collection> custom({
    Expression<String>? name,
    Expression<String>? comicid,
    Expression<String>? dateCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (comicid != null) 'comicid': comicid,
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? name,
    Value<String>? comicid,
    Value<String>? dateCreated,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      name: name ?? this.name,
      comicid: comicid ?? this.comicid,
      dateCreated: dateCreated ?? this.dateCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (comicid.present) {
      map['comicid'] = Variable<String>(comicid.value);
    }
    if (dateCreated.present) {
      map['dateCreated'] = Variable<String>(dateCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('name: $name, ')
          ..write('comicid: $comicid, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoriesTable extends SearchHistories
    with TableInfo<$SearchHistoriesTable, SearchHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'SearchHistory';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SearchHistoriesTable createAlias(String alias) {
    return $SearchHistoriesTable(attachedDatabase, alias);
  }
}

class SearchHistory extends DataClass implements Insertable<SearchHistory> {
  final int id;
  final String query;
  final String createdAt;
  const SearchHistory({
    required this.id,
    required this.query,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SearchHistoriesCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoriesCompanion(
      id: Value(id),
      query: Value(query),
      createdAt: Value(createdAt),
    );
  }

  factory SearchHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistory(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  SearchHistory copyWith({int? id, String? query, String? createdAt}) =>
      SearchHistory(
        id: id ?? this.id,
        query: query ?? this.query,
        createdAt: createdAt ?? this.createdAt,
      );
  SearchHistory copyWithCompanion(SearchHistoriesCompanion data) {
    return SearchHistory(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistory(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistory &&
          other.id == this.id &&
          other.query == this.query &&
          other.createdAt == this.createdAt);
}

class SearchHistoriesCompanion extends UpdateCompanion<SearchHistory> {
  final Value<int> id;
  final Value<String> query;
  final Value<String> createdAt;
  const SearchHistoriesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SearchHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    this.createdAt = const Value.absent(),
  }) : query = Value(query);
  static Insertable<SearchHistory> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SearchHistoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<String>? createdAt,
  }) {
    return SearchHistoriesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $AppOptionsTable appOptions = $AppOptionsTable(this);
  late final $ComicsTable comics = $ComicsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $SearchHistoriesTable searchHistories = $SearchHistoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appOptions,
    comics,
    collections,
    searchHistories,
  ];
}

typedef $$AppOptionsTableCreateCompanionBuilder =
    AppOptionsCompanion Function({
      Value<int> id,
      required String name,
      required String value,
    });
typedef $$AppOptionsTableUpdateCompanionBuilder =
    AppOptionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> value,
    });

class $$AppOptionsTableFilterComposer
    extends Composer<_$LocalDatabase, $AppOptionsTable> {
  $$AppOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppOptionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $AppOptionsTable> {
  $$AppOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppOptionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $AppOptionsTable> {
  $$AppOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppOptionsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $AppOptionsTable,
          AppOption,
          $$AppOptionsTableFilterComposer,
          $$AppOptionsTableOrderingComposer,
          $$AppOptionsTableAnnotationComposer,
          $$AppOptionsTableCreateCompanionBuilder,
          $$AppOptionsTableUpdateCompanionBuilder,
          (
            AppOption,
            BaseReferences<_$LocalDatabase, $AppOptionsTable, AppOption>,
          ),
          AppOption,
          PrefetchHooks Function()
        > {
  $$AppOptionsTableTableManager(_$LocalDatabase db, $AppOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => AppOptionsCompanion(id: id, name: name, value: value),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String value,
              }) =>
                  AppOptionsCompanion.insert(id: id, name: name, value: value),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $AppOptionsTable,
      AppOption,
      $$AppOptionsTableFilterComposer,
      $$AppOptionsTableOrderingComposer,
      $$AppOptionsTableAnnotationComposer,
      $$AppOptionsTableCreateCompanionBuilder,
      $$AppOptionsTableUpdateCompanionBuilder,
      (AppOption, BaseReferences<_$LocalDatabase, $AppOptionsTable, AppOption>),
      AppOption,
      PrefetchHooks Function()
    >;
typedef $$ComicsTableCreateCompanionBuilder =
    ComicsCompanion Function({
      required String id,
      required String mid,
      required String title,
      required String images,
      required int pages,
      Value<int> rowid,
    });
typedef $$ComicsTableUpdateCompanionBuilder =
    ComicsCompanion Function({
      Value<String> id,
      Value<String> mid,
      Value<String> title,
      Value<String> images,
      Value<int> pages,
      Value<int> rowid,
    });

class $$ComicsTableFilterComposer
    extends Composer<_$LocalDatabase, $ComicsTable> {
  $$ComicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mid => $composableBuilder(
    column: $table.mid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ComicsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ComicsTable> {
  $$ComicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mid => $composableBuilder(
    column: $table.mid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ComicsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ComicsTable> {
  $$ComicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mid =>
      $composableBuilder(column: $table.mid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<int> get pages =>
      $composableBuilder(column: $table.pages, builder: (column) => column);
}

class $$ComicsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ComicsTable,
          Comic,
          $$ComicsTableFilterComposer,
          $$ComicsTableOrderingComposer,
          $$ComicsTableAnnotationComposer,
          $$ComicsTableCreateCompanionBuilder,
          $$ComicsTableUpdateCompanionBuilder,
          (Comic, BaseReferences<_$LocalDatabase, $ComicsTable, Comic>),
          Comic,
          PrefetchHooks Function()
        > {
  $$ComicsTableTableManager(_$LocalDatabase db, $ComicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> images = const Value.absent(),
                Value<int> pages = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComicsCompanion(
                id: id,
                mid: mid,
                title: title,
                images: images,
                pages: pages,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mid,
                required String title,
                required String images,
                required int pages,
                Value<int> rowid = const Value.absent(),
              }) => ComicsCompanion.insert(
                id: id,
                mid: mid,
                title: title,
                images: images,
                pages: pages,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ComicsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ComicsTable,
      Comic,
      $$ComicsTableFilterComposer,
      $$ComicsTableOrderingComposer,
      $$ComicsTableAnnotationComposer,
      $$ComicsTableCreateCompanionBuilder,
      $$ComicsTableUpdateCompanionBuilder,
      (Comic, BaseReferences<_$LocalDatabase, $ComicsTable, Comic>),
      Comic,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String name,
      required String comicid,
      required String dateCreated,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> name,
      Value<String> comicid,
      Value<String> dateCreated,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$LocalDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comicid => $composableBuilder(
    column: $table.comicid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comicid => $composableBuilder(
    column: $table.comicid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get comicid =>
      $composableBuilder(column: $table.comicid, builder: (column) => column);

  GeneratedColumn<String> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$LocalDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$LocalDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> comicid = const Value.absent(),
                Value<String> dateCreated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                name: name,
                comicid: comicid,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String comicid,
                required String dateCreated,
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                name: name,
                comicid: comicid,
                dateCreated: dateCreated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$LocalDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoriesTableCreateCompanionBuilder =
    SearchHistoriesCompanion Function({
      Value<int> id,
      required String query,
      Value<String> createdAt,
    });
typedef $$SearchHistoriesTableUpdateCompanionBuilder =
    SearchHistoriesCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<String> createdAt,
    });

class $$SearchHistoriesTableFilterComposer
    extends Composer<_$LocalDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SearchHistoriesTable> {
  $$SearchHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SearchHistoriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SearchHistoriesTable,
          SearchHistory,
          $$SearchHistoriesTableFilterComposer,
          $$SearchHistoriesTableOrderingComposer,
          $$SearchHistoriesTableAnnotationComposer,
          $$SearchHistoriesTableCreateCompanionBuilder,
          $$SearchHistoriesTableUpdateCompanionBuilder,
          (
            SearchHistory,
            BaseReferences<
              _$LocalDatabase,
              $SearchHistoriesTable,
              SearchHistory
            >,
          ),
          SearchHistory,
          PrefetchHooks Function()
        > {
  $$SearchHistoriesTableTableManager(
    _$LocalDatabase db,
    $SearchHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => SearchHistoriesCompanion(
                id: id,
                query: query,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                Value<String> createdAt = const Value.absent(),
              }) => SearchHistoriesCompanion.insert(
                id: id,
                query: query,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SearchHistoriesTable,
      SearchHistory,
      $$SearchHistoriesTableFilterComposer,
      $$SearchHistoriesTableOrderingComposer,
      $$SearchHistoriesTableAnnotationComposer,
      $$SearchHistoriesTableCreateCompanionBuilder,
      $$SearchHistoriesTableUpdateCompanionBuilder,
      (
        SearchHistory,
        BaseReferences<_$LocalDatabase, $SearchHistoriesTable, SearchHistory>,
      ),
      SearchHistory,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$AppOptionsTableTableManager get appOptions =>
      $$AppOptionsTableTableManager(_db, _db.appOptions);
  $$ComicsTableTableManager get comics =>
      $$ComicsTableTableManager(_db, _db.comics);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$SearchHistoriesTableTableManager get searchHistories =>
      $$SearchHistoriesTableTableManager(_db, _db.searchHistories);
}
