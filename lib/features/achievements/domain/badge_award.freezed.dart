// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_award.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BadgeAward {

/// Client-generated UUIDv7.
 String get id;/// The catalogue id — see `domain/badge_definition.dart`'s id contract.
 String get badgeId;/// UTC.
 DateTime get awardedAt;/// `null` for a one-off badge.
 BadgeTier? get tier;
/// Create a copy of BadgeAward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeAwardCopyWith<BadgeAward> get copyWith => _$BadgeAwardCopyWithImpl<BadgeAward>(this as BadgeAward, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgeAward&&(identical(other.id, id) || other.id == id)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.awardedAt, awardedAt) || other.awardedAt == awardedAt)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,badgeId,awardedAt,tier);

@override
String toString() {
  return 'BadgeAward(id: $id, badgeId: $badgeId, awardedAt: $awardedAt, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $BadgeAwardCopyWith<$Res>  {
  factory $BadgeAwardCopyWith(BadgeAward value, $Res Function(BadgeAward) _then) = _$BadgeAwardCopyWithImpl;
@useResult
$Res call({
 String id, String badgeId, DateTime awardedAt, BadgeTier? tier
});




}
/// @nodoc
class _$BadgeAwardCopyWithImpl<$Res>
    implements $BadgeAwardCopyWith<$Res> {
  _$BadgeAwardCopyWithImpl(this._self, this._then);

  final BadgeAward _self;
  final $Res Function(BadgeAward) _then;

/// Create a copy of BadgeAward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? badgeId = null,Object? awardedAt = null,Object? tier = freezed,}) {
  return _then(BadgeAward(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,awardedAt: null == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as BadgeTier?,
  ));
}

}


/// Adds pattern-matching-related methods to [BadgeAward].
extension BadgeAwardPatterns on BadgeAward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgeAward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgeAward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgeAward value)  $default,){
final _that = this;
switch (_that) {
case _BadgeAward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgeAward value)?  $default,){
final _that = this;
switch (_that) {
case _BadgeAward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String badgeId,  DateTime awardedAt,  BadgeTier? tier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgeAward() when $default != null:
return $default(_that.id,_that.badgeId,_that.awardedAt,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String badgeId,  DateTime awardedAt,  BadgeTier? tier)  $default,) {final _that = this;
switch (_that) {
case _BadgeAward():
return $default(_that.id,_that.badgeId,_that.awardedAt,_that.tier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String badgeId,  DateTime awardedAt,  BadgeTier? tier)?  $default,) {final _that = this;
switch (_that) {
case _BadgeAward() when $default != null:
return $default(_that.id,_that.badgeId,_that.awardedAt,_that.tier);case _:
  return null;

}
}

}

/// @nodoc


class _BadgeAward extends BadgeAward {
  const _BadgeAward({required this.id, required this.badgeId, required this.awardedAt, this.tier}): super._();
  

/// Client-generated UUIDv7.
@override final  String id;
/// The catalogue id — see `domain/badge_definition.dart`'s id contract.
@override final  String badgeId;
/// UTC.
@override final  DateTime awardedAt;
/// `null` for a one-off badge.
@override final  BadgeTier? tier;

/// Create a copy of BadgeAward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeAwardCopyWith<_BadgeAward> get copyWith => __$BadgeAwardCopyWithImpl<_BadgeAward>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgeAward&&(identical(other.id, id) || other.id == id)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.awardedAt, awardedAt) || other.awardedAt == awardedAt)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,badgeId,awardedAt,tier);

@override
String toString() {
  return 'BadgeAward(id: $id, badgeId: $badgeId, awardedAt: $awardedAt, tier: $tier)';
}


}

/// @nodoc
abstract mixin class _$BadgeAwardCopyWith<$Res> implements $BadgeAwardCopyWith<$Res> {
  factory _$BadgeAwardCopyWith(_BadgeAward value, $Res Function(_BadgeAward) _then) = __$BadgeAwardCopyWithImpl;
@override @useResult
$Res call({
 String id, String badgeId, DateTime awardedAt, BadgeTier? tier
});




}
/// @nodoc
class __$BadgeAwardCopyWithImpl<$Res>
    implements _$BadgeAwardCopyWith<$Res> {
  __$BadgeAwardCopyWithImpl(this._self, this._then);

  final _BadgeAward _self;
  final $Res Function(_BadgeAward) _then;

/// Create a copy of BadgeAward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? badgeId = null,Object? awardedAt = null,Object? tier = freezed,}) {
  return _then(_BadgeAward(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,awardedAt: null == awardedAt ? _self.awardedAt : awardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as BadgeTier?,
  ));
}


}

// dart format on
