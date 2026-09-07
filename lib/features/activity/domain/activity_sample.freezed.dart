// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_sample.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivitySample {

 String get id; String get activityId;/// UTC.
 DateTime get timestamp; double get latitude; double get longitude; double? get elevationMeters; double? get horizontalAccuracyMeters; int? get heartRate;/// Whether this sample was accepted while the recording was paused
/// (manually or automatically) — see
/// `domain/recording_session.dart`'s `RecordedFix`. Schema v4; every
/// sample persisted before that migration defaults to `false` (there is
/// no pause data to backfill for pre-v4 recordings — see
/// `domain/track_analysis.dart`'s "old data" doc note).
 bool get isPaused;
/// Create a copy of ActivitySample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivitySampleCopyWith<ActivitySample> get copyWith => _$ActivitySampleCopyWithImpl<ActivitySample>(this as ActivitySample, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivitySample&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.horizontalAccuracyMeters, horizontalAccuracyMeters) || other.horizontalAccuracyMeters == horizontalAccuracyMeters)&&(identical(other.heartRate, heartRate) || other.heartRate == heartRate)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused));
}


@override
int get hashCode => Object.hash(runtimeType,id,activityId,timestamp,latitude,longitude,elevationMeters,horizontalAccuracyMeters,heartRate,isPaused);

@override
String toString() {
  return 'ActivitySample(id: $id, activityId: $activityId, timestamp: $timestamp, latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, horizontalAccuracyMeters: $horizontalAccuracyMeters, heartRate: $heartRate, isPaused: $isPaused)';
}


}

/// @nodoc
abstract mixin class $ActivitySampleCopyWith<$Res>  {
  factory $ActivitySampleCopyWith(ActivitySample value, $Res Function(ActivitySample) _then) = _$ActivitySampleCopyWithImpl;
@useResult
$Res call({
 String id, String activityId, DateTime timestamp, double latitude, double longitude, double? elevationMeters, double? horizontalAccuracyMeters, int? heartRate, bool isPaused
});




}
/// @nodoc
class _$ActivitySampleCopyWithImpl<$Res>
    implements $ActivitySampleCopyWith<$Res> {
  _$ActivitySampleCopyWithImpl(this._self, this._then);

  final ActivitySample _self;
  final $Res Function(ActivitySample) _then;

/// Create a copy of ActivitySample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityId = null,Object? timestamp = null,Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? horizontalAccuracyMeters = freezed,Object? heartRate = freezed,Object? isPaused = null,}) {
  return _then(ActivitySample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,horizontalAccuracyMeters: freezed == horizontalAccuracyMeters ? _self.horizontalAccuracyMeters : horizontalAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,heartRate: freezed == heartRate ? _self.heartRate : heartRate // ignore: cast_nullable_to_non_nullable
as int?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivitySample].
extension ActivitySamplePatterns on ActivitySample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivitySample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivitySample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivitySample value)  $default,){
final _that = this;
switch (_that) {
case _ActivitySample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivitySample value)?  $default,){
final _that = this;
switch (_that) {
case _ActivitySample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String activityId,  DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  int? heartRate,  bool isPaused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivitySample() when $default != null:
return $default(_that.id,_that.activityId,_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.heartRate,_that.isPaused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String activityId,  DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  int? heartRate,  bool isPaused)  $default,) {final _that = this;
switch (_that) {
case _ActivitySample():
return $default(_that.id,_that.activityId,_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.heartRate,_that.isPaused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String activityId,  DateTime timestamp,  double latitude,  double longitude,  double? elevationMeters,  double? horizontalAccuracyMeters,  int? heartRate,  bool isPaused)?  $default,) {final _that = this;
switch (_that) {
case _ActivitySample() when $default != null:
return $default(_that.id,_that.activityId,_that.timestamp,_that.latitude,_that.longitude,_that.elevationMeters,_that.horizontalAccuracyMeters,_that.heartRate,_that.isPaused);case _:
  return null;

}
}

}

/// @nodoc


class _ActivitySample implements ActivitySample {
  const _ActivitySample({required this.id, required this.activityId, required this.timestamp, required this.latitude, required this.longitude, this.elevationMeters, this.horizontalAccuracyMeters, this.heartRate, this.isPaused = false});
  

@override final  String id;
@override final  String activityId;
/// UTC.
@override final  DateTime timestamp;
@override final  double latitude;
@override final  double longitude;
@override final  double? elevationMeters;
@override final  double? horizontalAccuracyMeters;
@override final  int? heartRate;
/// Whether this sample was accepted while the recording was paused
/// (manually or automatically) — see
/// `domain/recording_session.dart`'s `RecordedFix`. Schema v4; every
/// sample persisted before that migration defaults to `false` (there is
/// no pause data to backfill for pre-v4 recordings — see
/// `domain/track_analysis.dart`'s "old data" doc note).
@override@JsonKey() final  bool isPaused;

/// Create a copy of ActivitySample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivitySampleCopyWith<_ActivitySample> get copyWith => __$ActivitySampleCopyWithImpl<_ActivitySample>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivitySample&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.horizontalAccuracyMeters, horizontalAccuracyMeters) || other.horizontalAccuracyMeters == horizontalAccuracyMeters)&&(identical(other.heartRate, heartRate) || other.heartRate == heartRate)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused));
}


@override
int get hashCode => Object.hash(runtimeType,id,activityId,timestamp,latitude,longitude,elevationMeters,horizontalAccuracyMeters,heartRate,isPaused);

@override
String toString() {
  return 'ActivitySample(id: $id, activityId: $activityId, timestamp: $timestamp, latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, horizontalAccuracyMeters: $horizontalAccuracyMeters, heartRate: $heartRate, isPaused: $isPaused)';
}


}

/// @nodoc
abstract mixin class _$ActivitySampleCopyWith<$Res> implements $ActivitySampleCopyWith<$Res> {
  factory _$ActivitySampleCopyWith(_ActivitySample value, $Res Function(_ActivitySample) _then) = __$ActivitySampleCopyWithImpl;
@override @useResult
$Res call({
 String id, String activityId, DateTime timestamp, double latitude, double longitude, double? elevationMeters, double? horizontalAccuracyMeters, int? heartRate, bool isPaused
});




}
/// @nodoc
class __$ActivitySampleCopyWithImpl<$Res>
    implements _$ActivitySampleCopyWith<$Res> {
  __$ActivitySampleCopyWithImpl(this._self, this._then);

  final _ActivitySample _self;
  final $Res Function(_ActivitySample) _then;

/// Create a copy of ActivitySample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityId = null,Object? timestamp = null,Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? horizontalAccuracyMeters = freezed,Object? heartRate = freezed,Object? isPaused = null,}) {
  return _then(_ActivitySample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,horizontalAccuracyMeters: freezed == horizontalAccuracyMeters ? _self.horizontalAccuracyMeters : horizontalAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,heartRate: freezed == heartRate ? _self.heartRate : heartRate // ignore: cast_nullable_to_non_nullable
as int?,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
