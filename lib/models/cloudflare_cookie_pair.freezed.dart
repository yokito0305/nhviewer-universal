// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloudflare_cookie_pair.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudflareCookiePair {

 String get userAgent; String get token;
/// Create a copy of CloudflareCookiePair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudflareCookiePairCopyWith<CloudflareCookiePair> get copyWith => _$CloudflareCookiePairCopyWithImpl<CloudflareCookiePair>(this as CloudflareCookiePair, _$identity);

  /// Serializes this CloudflareCookiePair to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudflareCookiePair&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userAgent,token);

@override
String toString() {
  return 'CloudflareCookiePair(userAgent: $userAgent, token: $token)';
}


}

/// @nodoc
abstract mixin class $CloudflareCookiePairCopyWith<$Res>  {
  factory $CloudflareCookiePairCopyWith(CloudflareCookiePair value, $Res Function(CloudflareCookiePair) _then) = _$CloudflareCookiePairCopyWithImpl;
@useResult
$Res call({
 String userAgent, String token
});




}
/// @nodoc
class _$CloudflareCookiePairCopyWithImpl<$Res>
    implements $CloudflareCookiePairCopyWith<$Res> {
  _$CloudflareCookiePairCopyWithImpl(this._self, this._then);

  final CloudflareCookiePair _self;
  final $Res Function(CloudflareCookiePair) _then;

/// Create a copy of CloudflareCookiePair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userAgent = null,Object? token = null,}) {
  return _then(_self.copyWith(
userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudflareCookiePair].
extension CloudflareCookiePairPatterns on CloudflareCookiePair {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudflareCookiePair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudflareCookiePair() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudflareCookiePair value)  $default,){
final _that = this;
switch (_that) {
case _CloudflareCookiePair():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudflareCookiePair value)?  $default,){
final _that = this;
switch (_that) {
case _CloudflareCookiePair() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userAgent,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudflareCookiePair() when $default != null:
return $default(_that.userAgent,_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userAgent,  String token)  $default,) {final _that = this;
switch (_that) {
case _CloudflareCookiePair():
return $default(_that.userAgent,_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userAgent,  String token)?  $default,) {final _that = this;
switch (_that) {
case _CloudflareCookiePair() when $default != null:
return $default(_that.userAgent,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloudflareCookiePair extends CloudflareCookiePair {
  const _CloudflareCookiePair({this.userAgent = '', this.token = ''}): super._();
  factory _CloudflareCookiePair.fromJson(Map<String, dynamic> json) => _$CloudflareCookiePairFromJson(json);

@override@JsonKey() final  String userAgent;
@override@JsonKey() final  String token;

/// Create a copy of CloudflareCookiePair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudflareCookiePairCopyWith<_CloudflareCookiePair> get copyWith => __$CloudflareCookiePairCopyWithImpl<_CloudflareCookiePair>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloudflareCookiePairToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudflareCookiePair&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userAgent,token);

@override
String toString() {
  return 'CloudflareCookiePair(userAgent: $userAgent, token: $token)';
}


}

/// @nodoc
abstract mixin class _$CloudflareCookiePairCopyWith<$Res> implements $CloudflareCookiePairCopyWith<$Res> {
  factory _$CloudflareCookiePairCopyWith(_CloudflareCookiePair value, $Res Function(_CloudflareCookiePair) _then) = __$CloudflareCookiePairCopyWithImpl;
@override @useResult
$Res call({
 String userAgent, String token
});




}
/// @nodoc
class __$CloudflareCookiePairCopyWithImpl<$Res>
    implements _$CloudflareCookiePairCopyWith<$Res> {
  __$CloudflareCookiePairCopyWithImpl(this._self, this._then);

  final _CloudflareCookiePair _self;
  final $Res Function(_CloudflareCookiePair) _then;

/// Create a copy of CloudflareCookiePair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userAgent = null,Object? token = null,}) {
  return _then(_CloudflareCookiePair(
userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
