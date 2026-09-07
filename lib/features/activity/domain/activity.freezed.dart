// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Activity {

 String get id; ActivityType get activityType; String get title;/// UTC.
 DateTime get startedAt;/// Time actually moving. Equal to [elapsedTime] for manually-logged
/// activities, which don't track pauses.
 Duration get movingTime;/// Total elapsed time, including any stopped time.
 Duration get elapsedTime; double get distanceMeters; ActivitySource get source;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt; String? get notes; double? get elevationGainMeters; int? get avgHeartRate;/// The saved route this activity was started from, if any (see
/// `features/routes/domain/saved_route.dart`). Kept when the route is
/// later deleted — presentation simply stops resolving a name for it.
 String? get routeId;/// Type-specific structured metadata (e.g. Strength sets/reps/rest,
/// HIIT intervals, Yoga/Pilates mindfulness, Swim laps).
 WorkoutDetails? get workoutDetails;
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCopyWith<Activity> get copyWith => _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.title, title) || other.title == title)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters)&&(identical(other.avgHeartRate, avgHeartRate) || other.avgHeartRate == avgHeartRate)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.workoutDetails, workoutDetails) || other.workoutDetails == workoutDetails));
}


@override
int get hashCode => Object.hash(runtimeType,id,activityType,title,startedAt,movingTime,elapsedTime,distanceMeters,source,createdAt,updatedAt,notes,elevationGainMeters,avgHeartRate,routeId,workoutDetails);

@override
String toString() {
  return 'Activity(id: $id, activityType: $activityType, title: $title, startedAt: $startedAt, movingTime: $movingTime, elapsedTime: $elapsedTime, distanceMeters: $distanceMeters, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, elevationGainMeters: $elevationGainMeters, avgHeartRate: $avgHeartRate, routeId: $routeId, workoutDetails: $workoutDetails)';
}


}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res>  {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) = _$ActivityCopyWithImpl;
@useResult
$Res call({
 String id, ActivityType activityType, String title, DateTime startedAt, Duration movingTime, Duration elapsedTime, double distanceMeters, ActivitySource source, DateTime createdAt, DateTime updatedAt, String? notes, double? elevationGainMeters, int? avgHeartRate, String? routeId, WorkoutDetails? workoutDetails
});




}
/// @nodoc
class _$ActivityCopyWithImpl<$Res>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityType = null,Object? title = null,Object? startedAt = null,Object? movingTime = null,Object? elapsedTime = null,Object? distanceMeters = null,Object? source = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? elevationGainMeters = freezed,Object? avgHeartRate = freezed,Object? routeId = freezed,Object? workoutDetails = freezed,}) {
  return _then(Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ActivitySource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,avgHeartRate: freezed == avgHeartRate ? _self.avgHeartRate : avgHeartRate // ignore: cast_nullable_to_non_nullable
as int?,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,workoutDetails: freezed == workoutDetails ? _self.workoutDetails : workoutDetails // ignore: cast_nullable_to_non_nullable
as WorkoutDetails?,
  ));
}

}


/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Activity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Activity value)  $default,){
final _that = this;
switch (_that) {
case _Activity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Activity value)?  $default,){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ActivityType activityType,  String title,  DateTime startedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  ActivitySource source,  DateTime createdAt,  DateTime updatedAt,  String? notes,  double? elevationGainMeters,  int? avgHeartRate,  String? routeId,  WorkoutDetails? workoutDetails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.activityType,_that.title,_that.startedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.source,_that.createdAt,_that.updatedAt,_that.notes,_that.elevationGainMeters,_that.avgHeartRate,_that.routeId,_that.workoutDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ActivityType activityType,  String title,  DateTime startedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  ActivitySource source,  DateTime createdAt,  DateTime updatedAt,  String? notes,  double? elevationGainMeters,  int? avgHeartRate,  String? routeId,  WorkoutDetails? workoutDetails)  $default,) {final _that = this;
switch (_that) {
case _Activity():
return $default(_that.id,_that.activityType,_that.title,_that.startedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.source,_that.createdAt,_that.updatedAt,_that.notes,_that.elevationGainMeters,_that.avgHeartRate,_that.routeId,_that.workoutDetails);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ActivityType activityType,  String title,  DateTime startedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  ActivitySource source,  DateTime createdAt,  DateTime updatedAt,  String? notes,  double? elevationGainMeters,  int? avgHeartRate,  String? routeId,  WorkoutDetails? workoutDetails)?  $default,) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.activityType,_that.title,_that.startedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.source,_that.createdAt,_that.updatedAt,_that.notes,_that.elevationGainMeters,_that.avgHeartRate,_that.routeId,_that.workoutDetails);case _:
  return null;

}
}

}

/// @nodoc


class _Activity extends Activity {
  const _Activity({required this.id, required this.activityType, required this.title, required this.startedAt, required this.movingTime, required this.elapsedTime, required this.distanceMeters, required this.source, required this.createdAt, required this.updatedAt, this.notes, this.elevationGainMeters, this.avgHeartRate, this.routeId, this.workoutDetails}): super._();
  

@override final  String id;
@override final  ActivityType activityType;
@override final  String title;
/// UTC.
@override final  DateTime startedAt;
/// Time actually moving. Equal to [elapsedTime] for manually-logged
/// activities, which don't track pauses.
@override final  Duration movingTime;
/// Total elapsed time, including any stopped time.
@override final  Duration elapsedTime;
@override final  double distanceMeters;
@override final  ActivitySource source;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
@override final  String? notes;
@override final  double? elevationGainMeters;
@override final  int? avgHeartRate;
/// The saved route this activity was started from, if any (see
/// `features/routes/domain/saved_route.dart`). Kept when the route is
/// later deleted — presentation simply stops resolving a name for it.
@override final  String? routeId;
/// Type-specific structured metadata (e.g. Strength sets/reps/rest,
/// HIIT intervals, Yoga/Pilates mindfulness, Swim laps).
@override final  WorkoutDetails? workoutDetails;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCopyWith<_Activity> get copyWith => __$ActivityCopyWithImpl<_Activity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.title, title) || other.title == title)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters)&&(identical(other.avgHeartRate, avgHeartRate) || other.avgHeartRate == avgHeartRate)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.workoutDetails, workoutDetails) || other.workoutDetails == workoutDetails));
}


@override
int get hashCode => Object.hash(runtimeType,id,activityType,title,startedAt,movingTime,elapsedTime,distanceMeters,source,createdAt,updatedAt,notes,elevationGainMeters,avgHeartRate,routeId,workoutDetails);

@override
String toString() {
  return 'Activity(id: $id, activityType: $activityType, title: $title, startedAt: $startedAt, movingTime: $movingTime, elapsedTime: $elapsedTime, distanceMeters: $distanceMeters, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, elevationGainMeters: $elevationGainMeters, avgHeartRate: $avgHeartRate, routeId: $routeId, workoutDetails: $workoutDetails)';
}


}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) = __$ActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, ActivityType activityType, String title, DateTime startedAt, Duration movingTime, Duration elapsedTime, double distanceMeters, ActivitySource source, DateTime createdAt, DateTime updatedAt, String? notes, double? elevationGainMeters, int? avgHeartRate, String? routeId, WorkoutDetails? workoutDetails
});




}
/// @nodoc
class __$ActivityCopyWithImpl<$Res>
    implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityType = null,Object? title = null,Object? startedAt = null,Object? movingTime = null,Object? elapsedTime = null,Object? distanceMeters = null,Object? source = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? elevationGainMeters = freezed,Object? avgHeartRate = freezed,Object? routeId = freezed,Object? workoutDetails = freezed,}) {
  return _then(_Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ActivitySource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,avgHeartRate: freezed == avgHeartRate ? _self.avgHeartRate : avgHeartRate // ignore: cast_nullable_to_non_nullable
as int?,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,workoutDetails: freezed == workoutDetails ? _self.workoutDetails : workoutDetails // ignore: cast_nullable_to_non_nullable
as WorkoutDetails?,
  ));
}


}

// dart format on
