// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordingSessionResult {

 ActivityType get activityType;/// UTC.
 DateTime get startedAt;/// UTC.
 DateTime get finishedAt; Duration get movingTime;/// Wall-clock duration since [RecordingSession.start]. Normally spans
/// all the way to the [RecordingSession.finish] call (mirroring the
/// live [RecordingSession.elapsedTime] getter) - but when
/// [RecordingSession.finish] is called while the session is
/// [RecordingSessionStatus.autoPaused] (the "forgotten to end" case),
/// this is trimmed back to the moment movement actually stopped: the
/// same back-dated boundary already used to close [movingTime]'s span
/// for that auto-pause (see [RecordingSession._updateAutoPause] /
/// [RecordingSession.evaluateStaleness]), not the
/// [RecordingSession.finish] call time. A recording finished an hour
/// after the runner in fact stopped therefore reports an honest
/// elapsed duration instead of claiming that hour as active. A manual
/// [RecordingSession.pause] is a deliberate stop, not a forgotten one -
/// finishing while manually paused keeps this at the
/// [RecordingSession.finish] call time, unaffected by this trimming.
 Duration get elapsedTime; double get distanceMeters;/// Every [LocationFix] accepted into the session (accuracy/implausible-
/// jump filtered fixes are excluded — see [RecordingSession] class doc),
/// paired with whether it was accepted while paused (see [RecordedFix]),
/// in arrival order. Maps 1:1 to `ActivitySample`s at the controller
/// boundary, which assigns each an id and the new activity's id and
/// carries `wasPaused` through as `ActivitySample.isPaused`.
///
/// **One exception**: on the forgotten-end path (see [elapsedTime]) the
/// trailing run of paused-status fixes is dropped — they are stationary
/// readings of wherever the user stopped, often home, and describe no
/// part of the workout. See
/// `RecordingSession._samplesWithoutTrailingPause`.
 List<RecordedFix> get samples; double? get elevationGainMeters;
/// Create a copy of RecordingSessionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingSessionResultCopyWith<RecordingSessionResult> get copyWith => _$RecordingSessionResultCopyWithImpl<RecordingSessionResult>(this as RecordingSessionResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingSessionResult&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&const DeepCollectionEquality().equals(other.samples, samples)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters));
}


@override
int get hashCode => Object.hash(runtimeType,activityType,startedAt,finishedAt,movingTime,elapsedTime,distanceMeters,const DeepCollectionEquality().hash(samples),elevationGainMeters);

@override
String toString() {
  return 'RecordingSessionResult(activityType: $activityType, startedAt: $startedAt, finishedAt: $finishedAt, movingTime: $movingTime, elapsedTime: $elapsedTime, distanceMeters: $distanceMeters, samples: $samples, elevationGainMeters: $elevationGainMeters)';
}


}

/// @nodoc
abstract mixin class $RecordingSessionResultCopyWith<$Res>  {
  factory $RecordingSessionResultCopyWith(RecordingSessionResult value, $Res Function(RecordingSessionResult) _then) = _$RecordingSessionResultCopyWithImpl;
@useResult
$Res call({
 ActivityType activityType, DateTime startedAt, DateTime finishedAt, Duration movingTime, Duration elapsedTime, double distanceMeters, List<RecordedFix> samples, double? elevationGainMeters
});




}
/// @nodoc
class _$RecordingSessionResultCopyWithImpl<$Res>
    implements $RecordingSessionResultCopyWith<$Res> {
  _$RecordingSessionResultCopyWithImpl(this._self, this._then);

  final RecordingSessionResult _self;
  final $Res Function(RecordingSessionResult) _then;

/// Create a copy of RecordingSessionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activityType = null,Object? startedAt = null,Object? finishedAt = null,Object? movingTime = null,Object? elapsedTime = null,Object? distanceMeters = null,Object? samples = null,Object? elevationGainMeters = freezed,}) {
  return _then(RecordingSessionResult(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<RecordedFix>,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingSessionResult].
extension RecordingSessionResultPatterns on RecordingSessionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingSessionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingSessionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingSessionResult value)  $default,){
final _that = this;
switch (_that) {
case _RecordingSessionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingSessionResult value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingSessionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActivityType activityType,  DateTime startedAt,  DateTime finishedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  List<RecordedFix> samples,  double? elevationGainMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingSessionResult() when $default != null:
return $default(_that.activityType,_that.startedAt,_that.finishedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.samples,_that.elevationGainMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActivityType activityType,  DateTime startedAt,  DateTime finishedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  List<RecordedFix> samples,  double? elevationGainMeters)  $default,) {final _that = this;
switch (_that) {
case _RecordingSessionResult():
return $default(_that.activityType,_that.startedAt,_that.finishedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.samples,_that.elevationGainMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActivityType activityType,  DateTime startedAt,  DateTime finishedAt,  Duration movingTime,  Duration elapsedTime,  double distanceMeters,  List<RecordedFix> samples,  double? elevationGainMeters)?  $default,) {final _that = this;
switch (_that) {
case _RecordingSessionResult() when $default != null:
return $default(_that.activityType,_that.startedAt,_that.finishedAt,_that.movingTime,_that.elapsedTime,_that.distanceMeters,_that.samples,_that.elevationGainMeters);case _:
  return null;

}
}

}

/// @nodoc


class _RecordingSessionResult implements RecordingSessionResult {
  const _RecordingSessionResult({required this.activityType, required this.startedAt, required this.finishedAt, required this.movingTime, required this.elapsedTime, required this.distanceMeters, required  List<RecordedFix> samples, this.elevationGainMeters}): _samples = samples;
  

@override final  ActivityType activityType;
/// UTC.
@override final  DateTime startedAt;
/// UTC.
@override final  DateTime finishedAt;
@override final  Duration movingTime;
/// Wall-clock duration since [RecordingSession.start]. Normally spans
/// all the way to the [RecordingSession.finish] call (mirroring the
/// live [RecordingSession.elapsedTime] getter) - but when
/// [RecordingSession.finish] is called while the session is
/// [RecordingSessionStatus.autoPaused] (the "forgotten to end" case),
/// this is trimmed back to the moment movement actually stopped: the
/// same back-dated boundary already used to close [movingTime]'s span
/// for that auto-pause (see [RecordingSession._updateAutoPause] /
/// [RecordingSession.evaluateStaleness]), not the
/// [RecordingSession.finish] call time. A recording finished an hour
/// after the runner in fact stopped therefore reports an honest
/// elapsed duration instead of claiming that hour as active. A manual
/// [RecordingSession.pause] is a deliberate stop, not a forgotten one -
/// finishing while manually paused keeps this at the
/// [RecordingSession.finish] call time, unaffected by this trimming.
@override final  Duration elapsedTime;
@override final  double distanceMeters;
/// Every [LocationFix] accepted into the session (accuracy/implausible-
/// jump filtered fixes are excluded — see [RecordingSession] class doc),
/// paired with whether it was accepted while paused (see [RecordedFix]),
/// in arrival order. Maps 1:1 to `ActivitySample`s at the controller
/// boundary, which assigns each an id and the new activity's id and
/// carries `wasPaused` through as `ActivitySample.isPaused`.
///
/// **One exception**: on the forgotten-end path (see [elapsedTime]) the
/// trailing run of paused-status fixes is dropped — they are stationary
/// readings of wherever the user stopped, often home, and describe no
/// part of the workout. See
/// `RecordingSession._samplesWithoutTrailingPause`.
 final  List<RecordedFix> _samples;
/// Every [LocationFix] accepted into the session (accuracy/implausible-
/// jump filtered fixes are excluded — see [RecordingSession] class doc),
/// paired with whether it was accepted while paused (see [RecordedFix]),
/// in arrival order. Maps 1:1 to `ActivitySample`s at the controller
/// boundary, which assigns each an id and the new activity's id and
/// carries `wasPaused` through as `ActivitySample.isPaused`.
///
/// **One exception**: on the forgotten-end path (see [elapsedTime]) the
/// trailing run of paused-status fixes is dropped — they are stationary
/// readings of wherever the user stopped, often home, and describe no
/// part of the workout. See
/// `RecordingSession._samplesWithoutTrailingPause`.
@override List<RecordedFix> get samples {
  if (_samples is EqualUnmodifiableListView) return _samples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samples);
}

@override final  double? elevationGainMeters;

/// Create a copy of RecordingSessionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingSessionResultCopyWith<_RecordingSessionResult> get copyWith => __$RecordingSessionResultCopyWithImpl<_RecordingSessionResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingSessionResult&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&const DeepCollectionEquality().equals(other._samples, _samples)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters));
}


@override
int get hashCode => Object.hash(runtimeType,activityType,startedAt,finishedAt,movingTime,elapsedTime,distanceMeters,const DeepCollectionEquality().hash(_samples),elevationGainMeters);

@override
String toString() {
  return 'RecordingSessionResult(activityType: $activityType, startedAt: $startedAt, finishedAt: $finishedAt, movingTime: $movingTime, elapsedTime: $elapsedTime, distanceMeters: $distanceMeters, samples: $samples, elevationGainMeters: $elevationGainMeters)';
}


}

/// @nodoc
abstract mixin class _$RecordingSessionResultCopyWith<$Res> implements $RecordingSessionResultCopyWith<$Res> {
  factory _$RecordingSessionResultCopyWith(_RecordingSessionResult value, $Res Function(_RecordingSessionResult) _then) = __$RecordingSessionResultCopyWithImpl;
@override @useResult
$Res call({
 ActivityType activityType, DateTime startedAt, DateTime finishedAt, Duration movingTime, Duration elapsedTime, double distanceMeters, List<RecordedFix> samples, double? elevationGainMeters
});




}
/// @nodoc
class __$RecordingSessionResultCopyWithImpl<$Res>
    implements _$RecordingSessionResultCopyWith<$Res> {
  __$RecordingSessionResultCopyWithImpl(this._self, this._then);

  final _RecordingSessionResult _self;
  final $Res Function(_RecordingSessionResult) _then;

/// Create a copy of RecordingSessionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activityType = null,Object? startedAt = null,Object? finishedAt = null,Object? movingTime = null,Object? elapsedTime = null,Object? distanceMeters = null,Object? samples = null,Object? elevationGainMeters = freezed,}) {
  return _then(_RecordingSessionResult(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: null == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,samples: null == samples ? _self._samples : samples // ignore: cast_nullable_to_non_nullable
as List<RecordedFix>,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
