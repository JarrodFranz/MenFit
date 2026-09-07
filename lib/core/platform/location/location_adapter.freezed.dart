// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_adapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationCapabilities {

 bool get canRecordActivities;/// Plain-language reason shown to the user when
/// [canRecordActivities] is `false`. `null` when it's `true`.
 String? get reason;/// Whether [LocationAdapter.getCurrentPosition] works on this
/// platform/build. Broader than [canRecordActivities]: a one-shot
/// position needs no background stream or foreground service, so it
/// also works on Web and Windows (geolocator's endorsed
/// implementations), where continuous recording doesn't. Defaults to
/// `false` so existing test fakes that only script recording stay
/// honest.
 bool get canGetCurrentPosition;/// Plain-language reason shown to the user when
/// [canGetCurrentPosition] is `false`. `null` when it's `true`.
 String? get currentPositionReason;
/// Create a copy of LocationCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCapabilitiesCopyWith<LocationCapabilities> get copyWith => _$LocationCapabilitiesCopyWithImpl<LocationCapabilities>(this as LocationCapabilities, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationCapabilities&&(identical(other.canRecordActivities, canRecordActivities) || other.canRecordActivities == canRecordActivities)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.canGetCurrentPosition, canGetCurrentPosition) || other.canGetCurrentPosition == canGetCurrentPosition)&&(identical(other.currentPositionReason, currentPositionReason) || other.currentPositionReason == currentPositionReason));
}


@override
int get hashCode => Object.hash(runtimeType,canRecordActivities,reason,canGetCurrentPosition,currentPositionReason);

@override
String toString() {
  return 'LocationCapabilities(canRecordActivities: $canRecordActivities, reason: $reason, canGetCurrentPosition: $canGetCurrentPosition, currentPositionReason: $currentPositionReason)';
}


}

/// @nodoc
abstract mixin class $LocationCapabilitiesCopyWith<$Res>  {
  factory $LocationCapabilitiesCopyWith(LocationCapabilities value, $Res Function(LocationCapabilities) _then) = _$LocationCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool canRecordActivities, String? reason, bool canGetCurrentPosition, String? currentPositionReason
});




}
/// @nodoc
class _$LocationCapabilitiesCopyWithImpl<$Res>
    implements $LocationCapabilitiesCopyWith<$Res> {
  _$LocationCapabilitiesCopyWithImpl(this._self, this._then);

  final LocationCapabilities _self;
  final $Res Function(LocationCapabilities) _then;

/// Create a copy of LocationCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canRecordActivities = null,Object? reason = freezed,Object? canGetCurrentPosition = null,Object? currentPositionReason = freezed,}) {
  return _then(LocationCapabilities(
canRecordActivities: null == canRecordActivities ? _self.canRecordActivities : canRecordActivities // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,canGetCurrentPosition: null == canGetCurrentPosition ? _self.canGetCurrentPosition : canGetCurrentPosition // ignore: cast_nullable_to_non_nullable
as bool,currentPositionReason: freezed == currentPositionReason ? _self.currentPositionReason : currentPositionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationCapabilities].
extension LocationCapabilitiesPatterns on LocationCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _LocationCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _LocationCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canRecordActivities,  String? reason,  bool canGetCurrentPosition,  String? currentPositionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationCapabilities() when $default != null:
return $default(_that.canRecordActivities,_that.reason,_that.canGetCurrentPosition,_that.currentPositionReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canRecordActivities,  String? reason,  bool canGetCurrentPosition,  String? currentPositionReason)  $default,) {final _that = this;
switch (_that) {
case _LocationCapabilities():
return $default(_that.canRecordActivities,_that.reason,_that.canGetCurrentPosition,_that.currentPositionReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canRecordActivities,  String? reason,  bool canGetCurrentPosition,  String? currentPositionReason)?  $default,) {final _that = this;
switch (_that) {
case _LocationCapabilities() when $default != null:
return $default(_that.canRecordActivities,_that.reason,_that.canGetCurrentPosition,_that.currentPositionReason);case _:
  return null;

}
}

}

/// @nodoc


class _LocationCapabilities implements LocationCapabilities {
  const _LocationCapabilities({required this.canRecordActivities, this.reason, this.canGetCurrentPosition = false, this.currentPositionReason});
  

@override final  bool canRecordActivities;
/// Plain-language reason shown to the user when
/// [canRecordActivities] is `false`. `null` when it's `true`.
@override final  String? reason;
/// Whether [LocationAdapter.getCurrentPosition] works on this
/// platform/build. Broader than [canRecordActivities]: a one-shot
/// position needs no background stream or foreground service, so it
/// also works on Web and Windows (geolocator's endorsed
/// implementations), where continuous recording doesn't. Defaults to
/// `false` so existing test fakes that only script recording stay
/// honest.
@override@JsonKey() final  bool canGetCurrentPosition;
/// Plain-language reason shown to the user when
/// [canGetCurrentPosition] is `false`. `null` when it's `true`.
@override final  String? currentPositionReason;

/// Create a copy of LocationCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCapabilitiesCopyWith<_LocationCapabilities> get copyWith => __$LocationCapabilitiesCopyWithImpl<_LocationCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationCapabilities&&(identical(other.canRecordActivities, canRecordActivities) || other.canRecordActivities == canRecordActivities)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.canGetCurrentPosition, canGetCurrentPosition) || other.canGetCurrentPosition == canGetCurrentPosition)&&(identical(other.currentPositionReason, currentPositionReason) || other.currentPositionReason == currentPositionReason));
}


@override
int get hashCode => Object.hash(runtimeType,canRecordActivities,reason,canGetCurrentPosition,currentPositionReason);

@override
String toString() {
  return 'LocationCapabilities(canRecordActivities: $canRecordActivities, reason: $reason, canGetCurrentPosition: $canGetCurrentPosition, currentPositionReason: $currentPositionReason)';
}


}

/// @nodoc
abstract mixin class _$LocationCapabilitiesCopyWith<$Res> implements $LocationCapabilitiesCopyWith<$Res> {
  factory _$LocationCapabilitiesCopyWith(_LocationCapabilities value, $Res Function(_LocationCapabilities) _then) = __$LocationCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool canRecordActivities, String? reason, bool canGetCurrentPosition, String? currentPositionReason
});




}
/// @nodoc
class __$LocationCapabilitiesCopyWithImpl<$Res>
    implements _$LocationCapabilitiesCopyWith<$Res> {
  __$LocationCapabilitiesCopyWithImpl(this._self, this._then);

  final _LocationCapabilities _self;
  final $Res Function(_LocationCapabilities) _then;

/// Create a copy of LocationCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canRecordActivities = null,Object? reason = freezed,Object? canGetCurrentPosition = null,Object? currentPositionReason = freezed,}) {
  return _then(_LocationCapabilities(
canRecordActivities: null == canRecordActivities ? _self.canRecordActivities : canRecordActivities // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,canGetCurrentPosition: null == canGetCurrentPosition ? _self.canGetCurrentPosition : canGetCurrentPosition // ignore: cast_nullable_to_non_nullable
as bool,currentPositionReason: freezed == currentPositionReason ? _self.currentPositionReason : currentPositionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
