// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_protection_sources.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayProtectionSources {

 bool get hasExplicitRecoveryDay; bool get hasProtectingFlare;/// The note attached when marking today via `hasExplicitRecoveryDay`,
/// if any. Always `null` when `hasExplicitRecoveryDay` is `false`.
 String? get recoveryNote;
/// Create a copy of TodayProtectionSources
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayProtectionSourcesCopyWith<TodayProtectionSources> get copyWith => _$TodayProtectionSourcesCopyWithImpl<TodayProtectionSources>(this as TodayProtectionSources, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayProtectionSources&&(identical(other.hasExplicitRecoveryDay, hasExplicitRecoveryDay) || other.hasExplicitRecoveryDay == hasExplicitRecoveryDay)&&(identical(other.hasProtectingFlare, hasProtectingFlare) || other.hasProtectingFlare == hasProtectingFlare)&&(identical(other.recoveryNote, recoveryNote) || other.recoveryNote == recoveryNote));
}


@override
int get hashCode => Object.hash(runtimeType,hasExplicitRecoveryDay,hasProtectingFlare,recoveryNote);

@override
String toString() {
  return 'TodayProtectionSources(hasExplicitRecoveryDay: $hasExplicitRecoveryDay, hasProtectingFlare: $hasProtectingFlare, recoveryNote: $recoveryNote)';
}


}

/// @nodoc
abstract mixin class $TodayProtectionSourcesCopyWith<$Res>  {
  factory $TodayProtectionSourcesCopyWith(TodayProtectionSources value, $Res Function(TodayProtectionSources) _then) = _$TodayProtectionSourcesCopyWithImpl;
@useResult
$Res call({
 bool hasExplicitRecoveryDay, bool hasProtectingFlare, String? recoveryNote
});




}
/// @nodoc
class _$TodayProtectionSourcesCopyWithImpl<$Res>
    implements $TodayProtectionSourcesCopyWith<$Res> {
  _$TodayProtectionSourcesCopyWithImpl(this._self, this._then);

  final TodayProtectionSources _self;
  final $Res Function(TodayProtectionSources) _then;

/// Create a copy of TodayProtectionSources
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasExplicitRecoveryDay = null,Object? hasProtectingFlare = null,Object? recoveryNote = freezed,}) {
  return _then(TodayProtectionSources(
hasExplicitRecoveryDay: null == hasExplicitRecoveryDay ? _self.hasExplicitRecoveryDay : hasExplicitRecoveryDay // ignore: cast_nullable_to_non_nullable
as bool,hasProtectingFlare: null == hasProtectingFlare ? _self.hasProtectingFlare : hasProtectingFlare // ignore: cast_nullable_to_non_nullable
as bool,recoveryNote: freezed == recoveryNote ? _self.recoveryNote : recoveryNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayProtectionSources].
extension TodayProtectionSourcesPatterns on TodayProtectionSources {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayProtectionSources value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayProtectionSources() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayProtectionSources value)  $default,){
final _that = this;
switch (_that) {
case _TodayProtectionSources():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayProtectionSources value)?  $default,){
final _that = this;
switch (_that) {
case _TodayProtectionSources() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasExplicitRecoveryDay,  bool hasProtectingFlare,  String? recoveryNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayProtectionSources() when $default != null:
return $default(_that.hasExplicitRecoveryDay,_that.hasProtectingFlare,_that.recoveryNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasExplicitRecoveryDay,  bool hasProtectingFlare,  String? recoveryNote)  $default,) {final _that = this;
switch (_that) {
case _TodayProtectionSources():
return $default(_that.hasExplicitRecoveryDay,_that.hasProtectingFlare,_that.recoveryNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasExplicitRecoveryDay,  bool hasProtectingFlare,  String? recoveryNote)?  $default,) {final _that = this;
switch (_that) {
case _TodayProtectionSources() when $default != null:
return $default(_that.hasExplicitRecoveryDay,_that.hasProtectingFlare,_that.recoveryNote);case _:
  return null;

}
}

}

/// @nodoc


class _TodayProtectionSources extends TodayProtectionSources {
  const _TodayProtectionSources({required this.hasExplicitRecoveryDay, required this.hasProtectingFlare, this.recoveryNote}): super._();
  

@override final  bool hasExplicitRecoveryDay;
@override final  bool hasProtectingFlare;
/// The note attached when marking today via `hasExplicitRecoveryDay`,
/// if any. Always `null` when `hasExplicitRecoveryDay` is `false`.
@override final  String? recoveryNote;

/// Create a copy of TodayProtectionSources
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayProtectionSourcesCopyWith<_TodayProtectionSources> get copyWith => __$TodayProtectionSourcesCopyWithImpl<_TodayProtectionSources>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayProtectionSources&&(identical(other.hasExplicitRecoveryDay, hasExplicitRecoveryDay) || other.hasExplicitRecoveryDay == hasExplicitRecoveryDay)&&(identical(other.hasProtectingFlare, hasProtectingFlare) || other.hasProtectingFlare == hasProtectingFlare)&&(identical(other.recoveryNote, recoveryNote) || other.recoveryNote == recoveryNote));
}


@override
int get hashCode => Object.hash(runtimeType,hasExplicitRecoveryDay,hasProtectingFlare,recoveryNote);

@override
String toString() {
  return 'TodayProtectionSources(hasExplicitRecoveryDay: $hasExplicitRecoveryDay, hasProtectingFlare: $hasProtectingFlare, recoveryNote: $recoveryNote)';
}


}

/// @nodoc
abstract mixin class _$TodayProtectionSourcesCopyWith<$Res> implements $TodayProtectionSourcesCopyWith<$Res> {
  factory _$TodayProtectionSourcesCopyWith(_TodayProtectionSources value, $Res Function(_TodayProtectionSources) _then) = __$TodayProtectionSourcesCopyWithImpl;
@override @useResult
$Res call({
 bool hasExplicitRecoveryDay, bool hasProtectingFlare, String? recoveryNote
});




}
/// @nodoc
class __$TodayProtectionSourcesCopyWithImpl<$Res>
    implements _$TodayProtectionSourcesCopyWith<$Res> {
  __$TodayProtectionSourcesCopyWithImpl(this._self, this._then);

  final _TodayProtectionSources _self;
  final $Res Function(_TodayProtectionSources) _then;

/// Create a copy of TodayProtectionSources
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasExplicitRecoveryDay = null,Object? hasProtectingFlare = null,Object? recoveryNote = freezed,}) {
  return _then(_TodayProtectionSources(
hasExplicitRecoveryDay: null == hasExplicitRecoveryDay ? _self.hasExplicitRecoveryDay : hasExplicitRecoveryDay // ignore: cast_nullable_to_non_nullable
as bool,hasProtectingFlare: null == hasProtectingFlare ? _self.hasProtectingFlare : hasProtectingFlare // ignore: cast_nullable_to_non_nullable
as bool,recoveryNote: freezed == recoveryNote ? _self.recoveryNote : recoveryNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
