// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_fix.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationFix {

/// UTC.
 DateTime get timestamp; double get latitude; double get longitude; double? get elevationMeters; double? get horizontalAccuracyMeters; double? get speedMetersPerSecond;
/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationFixCopyWith<LocationFix> get copyWith => _$LocationFixCopyWithImpl<LocationFix>(this as LocationFix, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationFix&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.horizontalAccuracyMeters, horizontalAccuracyMeters) || other.horizontalAccuracyMeters == horizontalAccuracyMeters)&&(identical(other.speedMetersPerSecond, speedMetersPerSecond) || other.speedMetersPerSecond == speedMetersPerSecond));
}


@override
int get hashCode => Object.hash(runtimeType,timestamp,latitude,longitude,elevationMeters,horizontalAccuracyMeters,speedMetersPerSecond);

@override
String toString() {
  return 'LocationFix(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, horizontalAccuracyMeters: $horizontalAccuracyMeters, speedMetersPerSecond: $speedMetersPerSecond)';
}


}

/// @nodoc
abstract mixin class $LocationFixCopyWith<$Res>  {
  factory $LocationFixCopyWith(LocationFix value, $Res Function(LocationFix) _then) = _$LocationFixCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp, double latitude, double longitude, double? elevationMeters, double? horizontalAccuracyMeters, double? speedMetersPerSecond
});




}
/// @nodoc
class _$LocationFixCopyWithImpl<$Res>
    implements $LocationFixCopyWith<$Res> {
  _$LocationFixCopyWithImpl(this._self, this._then);

  final LocationFix _self;
  final $Res Function(LocationFix) _then;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? horizontalAccuracyMeters = freezed,Object? speedMetersPerSecond = freezed,}) {
  return _then(LocationFix(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,horizontalAccuracyMeters: freezed == horizontalAccuracyMeters ? _self.horizontalAccuracyMeters : horizontalAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,speedMetersPerSecond: freezed == speedMetersPerSecond ? _self.speedMetersPerSecond : speedMetersPerSecond // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationFix].
extension LocationFixPatterns on LocationFix {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationFix value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationFix value)  $default,){
final _that = this;
switch (_that) {
case _LocationFix():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationFix value)?  $default,){
final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  double? speedMetersPerSecond)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
return $default(_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.speedMetersPerSecond);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  double? speedMetersPerSecond)  $default,) {final _that = this;
switch (_that) {
case _LocationFix():
return $default(_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.speedMetersPerSecond);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  double? speedMetersPerSecond)?  $default,) {final _that = this;
switch (_that) {
case _LocationFix() when $default != null:
return $default(_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.speedMetersPerSecond);case _:
  return null;

}
}

}

/// @nodoc


class _LocationFix implements LocationFix {
  const _LocationFix({required this.timestamp, required this.latitude, required this.longitude, this.elevationMeters, this.horizontalAccuracyMeters, this.speedMetersPerSecond});
  

/// UTC.
@override final  DateTime timestamp;
@override final  double latitude;
@override final  double longitude;
@override final  double? elevationMeters;
@override final  double? horizontalAccuracyMeters;
@override final  double? speedMetersPerSecond;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationFixCopyWith<_LocationFix> get copyWith => __$LocationFixCopyWithImpl<_LocationFix>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationFix&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.horizontalAccuracyMeters, horizontalAccuracyMeters) || other.horizontalAccuracyMeters == horizontalAccuracyMeters)&&(identical(other.speedMetersPerSecond, speedMetersPerSecond) || other.speedMetersPerSecond == speedMetersPerSecond));
}


@override
int get hashCode => Object.hash(runtimeType,timestamp,latitude,longitude,elevationMeters,horizontalAccuracyMeters,speedMetersPerSecond);

@override
String toString() {
  return 'LocationFix(timestamp: $timestamp, latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, horizontalAccuracyMeters: $horizontalAccuracyMeters, speedMetersPerSecond: $speedMetersPerSecond)';
}


}

/// @nodoc
abstract mixin class _$LocationFixCopyWith<$Res> implements $LocationFixCopyWith<$Res> {
  factory _$LocationFixCopyWith(_LocationFix value, $Res Function(_LocationFix) _then) = __$LocationFixCopyWithImpl;
@override @useResult
$Res call({
 DateTime timestamp, double latitude, double longitude, double? elevationMeters, double? horizontalAccuracyMeters, double? speedMetersPerSecond
});




}
/// @nodoc
class __$LocationFixCopyWithImpl<$Res>
    implements _$LocationFixCopyWith<$Res> {
  __$LocationFixCopyWithImpl(this._self, this._then);

  final _LocationFix _self;
  final $Res Function(_LocationFix) _then;

/// Create a copy of LocationFix
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? horizontalAccuracyMeters = freezed,Object? speedMetersPerSecond = freezed,}) {
  return _then(_LocationFix(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,horizontalAccuracyMeters: freezed == horizontalAccuracyMeters ? _self.horizontalAccuracyMeters : horizontalAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,speedMetersPerSecond: freezed == speedMetersPerSecond ? _self.speedMetersPerSecond : speedMetersPerSecond // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
