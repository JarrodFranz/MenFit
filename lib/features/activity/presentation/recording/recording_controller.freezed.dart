// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordingControllerState {

 RecordingLifecycle get lifecycle; ActivityType? get activityType; Duration get elapsedTime; Duration get movingTime; double get distanceMeters; double? get elevationGainMeters; double? get currentPaceSecondsPerKm; int get sampleCount;/// The back-dated clock boundary the current auto-pause episode began
/// at (mirrors [RecordingSession.autoPausedAt]) - `null` whenever
/// [lifecycle] isn't [RecordingLifecycle.autoPaused]. Kept as its own
/// state field (rather than left for the screen to derive) so
/// [RecordingController]'s ticker can compare it against "now" once a
/// second without the screen needing its own timer.
 DateTime? get autoPausedSince;/// Whether `record_screen.dart` should show the "Looks like you've
/// stopped" forgotten-end prompt: true once [autoPausedSince] is at
/// least 10 minutes in the past and
/// [RecordingController.dismissForgottenEndPrompt] hasn't been called
/// for the current auto-pause episode. Re-evaluated on
/// [RecordingController]'s existing 1s ticker - see
/// [RecordingController._syncStateFromSession].
 bool get showForgottenEndPrompt;/// Set when permission was checked/requested and came back anything
/// other than granted — lets the screen show a specific CTA (e.g. "Open
/// Settings" for [LocationPermissionResult.deniedForever]).
 LocationPermissionResult? get permissionResult;/// Already-resolved user-facing message (via `userMessageFor`) for a
/// failure — never a raw exception, per `error_handling.md`'s
/// values-not-exceptions convention for expected UI-surfaced failures.
 String? get error; String? get savedActivityId; String? get routeId; LocationFix? get latestFix; List<LocationFix> get trackPoints; double? get currentElevationMeters; double? get currentSpeedMps; bool get isAudioMuted;
/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingControllerStateCopyWith<RecordingControllerState> get copyWith => _$RecordingControllerStateCopyWithImpl<RecordingControllerState>(this as RecordingControllerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingControllerState&&(identical(other.lifecycle, lifecycle) || other.lifecycle == lifecycle)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters)&&(identical(other.currentPaceSecondsPerKm, currentPaceSecondsPerKm) || other.currentPaceSecondsPerKm == currentPaceSecondsPerKm)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.autoPausedSince, autoPausedSince) || other.autoPausedSince == autoPausedSince)&&(identical(other.showForgottenEndPrompt, showForgottenEndPrompt) || other.showForgottenEndPrompt == showForgottenEndPrompt)&&(identical(other.permissionResult, permissionResult) || other.permissionResult == permissionResult)&&(identical(other.error, error) || other.error == error)&&(identical(other.savedActivityId, savedActivityId) || other.savedActivityId == savedActivityId)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.latestFix, latestFix) || other.latestFix == latestFix)&&const DeepCollectionEquality().equals(other.trackPoints, trackPoints)&&(identical(other.currentElevationMeters, currentElevationMeters) || other.currentElevationMeters == currentElevationMeters)&&(identical(other.currentSpeedMps, currentSpeedMps) || other.currentSpeedMps == currentSpeedMps)&&(identical(other.isAudioMuted, isAudioMuted) || other.isAudioMuted == isAudioMuted));
}


@override
int get hashCode => Object.hashAll([runtimeType,lifecycle,activityType,elapsedTime,movingTime,distanceMeters,elevationGainMeters,currentPaceSecondsPerKm,sampleCount,autoPausedSince,showForgottenEndPrompt,permissionResult,error,savedActivityId,routeId,latestFix,const DeepCollectionEquality().hash(trackPoints),currentElevationMeters,currentSpeedMps,isAudioMuted]);

@override
String toString() {
  return 'RecordingControllerState(lifecycle: $lifecycle, activityType: $activityType, elapsedTime: $elapsedTime, movingTime: $movingTime, distanceMeters: $distanceMeters, elevationGainMeters: $elevationGainMeters, currentPaceSecondsPerKm: $currentPaceSecondsPerKm, sampleCount: $sampleCount, autoPausedSince: $autoPausedSince, showForgottenEndPrompt: $showForgottenEndPrompt, permissionResult: $permissionResult, error: $error, savedActivityId: $savedActivityId, routeId: $routeId, latestFix: $latestFix, trackPoints: $trackPoints, currentElevationMeters: $currentElevationMeters, currentSpeedMps: $currentSpeedMps, isAudioMuted: $isAudioMuted)';
}


}

/// @nodoc
abstract mixin class $RecordingControllerStateCopyWith<$Res>  {
  factory $RecordingControllerStateCopyWith(RecordingControllerState value, $Res Function(RecordingControllerState) _then) = _$RecordingControllerStateCopyWithImpl;
@useResult
$Res call({
 RecordingLifecycle lifecycle, ActivityType? activityType, Duration elapsedTime, Duration movingTime, double distanceMeters, double? elevationGainMeters, double? currentPaceSecondsPerKm, int sampleCount, DateTime? autoPausedSince, bool showForgottenEndPrompt, LocationPermissionResult? permissionResult, String? error, String? savedActivityId, String? routeId, LocationFix? latestFix, List<LocationFix> trackPoints, double? currentElevationMeters, double? currentSpeedMps, bool isAudioMuted
});


$LocationFixCopyWith<$Res>? get latestFix;

}
/// @nodoc
class _$RecordingControllerStateCopyWithImpl<$Res>
    implements $RecordingControllerStateCopyWith<$Res> {
  _$RecordingControllerStateCopyWithImpl(this._self, this._then);

  final RecordingControllerState _self;
  final $Res Function(RecordingControllerState) _then;

/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lifecycle = null,Object? activityType = freezed,Object? elapsedTime = null,Object? movingTime = null,Object? distanceMeters = null,Object? elevationGainMeters = freezed,Object? currentPaceSecondsPerKm = freezed,Object? sampleCount = null,Object? autoPausedSince = freezed,Object? showForgottenEndPrompt = null,Object? permissionResult = freezed,Object? error = freezed,Object? savedActivityId = freezed,Object? routeId = freezed,Object? latestFix = freezed,Object? trackPoints = null,Object? currentElevationMeters = freezed,Object? currentSpeedMps = freezed,Object? isAudioMuted = null,}) {
  return _then(RecordingControllerState(
lifecycle: null == lifecycle ? _self.lifecycle : lifecycle // ignore: cast_nullable_to_non_nullable
as RecordingLifecycle,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType?,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,currentPaceSecondsPerKm: freezed == currentPaceSecondsPerKm ? _self.currentPaceSecondsPerKm : currentPaceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double?,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,autoPausedSince: freezed == autoPausedSince ? _self.autoPausedSince : autoPausedSince // ignore: cast_nullable_to_non_nullable
as DateTime?,showForgottenEndPrompt: null == showForgottenEndPrompt ? _self.showForgottenEndPrompt : showForgottenEndPrompt // ignore: cast_nullable_to_non_nullable
as bool,permissionResult: freezed == permissionResult ? _self.permissionResult : permissionResult // ignore: cast_nullable_to_non_nullable
as LocationPermissionResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,savedActivityId: freezed == savedActivityId ? _self.savedActivityId : savedActivityId // ignore: cast_nullable_to_non_nullable
as String?,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,latestFix: freezed == latestFix ? _self.latestFix : latestFix // ignore: cast_nullable_to_non_nullable
as LocationFix?,trackPoints: null == trackPoints ? _self.trackPoints : trackPoints // ignore: cast_nullable_to_non_nullable
as List<LocationFix>,currentElevationMeters: freezed == currentElevationMeters ? _self.currentElevationMeters : currentElevationMeters // ignore: cast_nullable_to_non_nullable
as double?,currentSpeedMps: freezed == currentSpeedMps ? _self.currentSpeedMps : currentSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,isAudioMuted: null == isAudioMuted ? _self.isAudioMuted : isAudioMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationFixCopyWith<$Res>? get latestFix {
    if (_self.latestFix == null) {
    return null;
  }

  return $LocationFixCopyWith<$Res>(_self.latestFix!, (value) {
    return _then(_self.copyWith(latestFix: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecordingControllerState].
extension RecordingControllerStatePatterns on RecordingControllerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingControllerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingControllerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingControllerState value)  $default,){
final _that = this;
switch (_that) {
case _RecordingControllerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingControllerState value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingControllerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordingLifecycle lifecycle,  ActivityType? activityType,  Duration elapsedTime,  Duration movingTime,  double distanceMeters,  double? elevationGainMeters,  double? currentPaceSecondsPerKm,  int sampleCount,  DateTime? autoPausedSince,  bool showForgottenEndPrompt,  LocationPermissionResult? permissionResult,  String? error,  String? savedActivityId,  String? routeId,  LocationFix? latestFix,  List<LocationFix> trackPoints,  double? currentElevationMeters,  double? currentSpeedMps,  bool isAudioMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingControllerState() when $default != null:
return $default(_that.lifecycle,_that.activityType,_that.elapsedTime,_that.movingTime,_that.distanceMeters,_that.elevationGainMeters,_that.currentPaceSecondsPerKm,_that.sampleCount,_that.autoPausedSince,_that.showForgottenEndPrompt,_that.permissionResult,_that.error,_that.savedActivityId,_that.routeId,_that.latestFix,_that.trackPoints,_that.currentElevationMeters,_that.currentSpeedMps,_that.isAudioMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordingLifecycle lifecycle,  ActivityType? activityType,  Duration elapsedTime,  Duration movingTime,  double distanceMeters,  double? elevationGainMeters,  double? currentPaceSecondsPerKm,  int sampleCount,  DateTime? autoPausedSince,  bool showForgottenEndPrompt,  LocationPermissionResult? permissionResult,  String? error,  String? savedActivityId,  String? routeId,  LocationFix? latestFix,  List<LocationFix> trackPoints,  double? currentElevationMeters,  double? currentSpeedMps,  bool isAudioMuted)  $default,) {final _that = this;
switch (_that) {
case _RecordingControllerState():
return $default(_that.lifecycle,_that.activityType,_that.elapsedTime,_that.movingTime,_that.distanceMeters,_that.elevationGainMeters,_that.currentPaceSecondsPerKm,_that.sampleCount,_that.autoPausedSince,_that.showForgottenEndPrompt,_that.permissionResult,_that.error,_that.savedActivityId,_that.routeId,_that.latestFix,_that.trackPoints,_that.currentElevationMeters,_that.currentSpeedMps,_that.isAudioMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordingLifecycle lifecycle,  ActivityType? activityType,  Duration elapsedTime,  Duration movingTime,  double distanceMeters,  double? elevationGainMeters,  double? currentPaceSecondsPerKm,  int sampleCount,  DateTime? autoPausedSince,  bool showForgottenEndPrompt,  LocationPermissionResult? permissionResult,  String? error,  String? savedActivityId,  String? routeId,  LocationFix? latestFix,  List<LocationFix> trackPoints,  double? currentElevationMeters,  double? currentSpeedMps,  bool isAudioMuted)?  $default,) {final _that = this;
switch (_that) {
case _RecordingControllerState() when $default != null:
return $default(_that.lifecycle,_that.activityType,_that.elapsedTime,_that.movingTime,_that.distanceMeters,_that.elevationGainMeters,_that.currentPaceSecondsPerKm,_that.sampleCount,_that.autoPausedSince,_that.showForgottenEndPrompt,_that.permissionResult,_that.error,_that.savedActivityId,_that.routeId,_that.latestFix,_that.trackPoints,_that.currentElevationMeters,_that.currentSpeedMps,_that.isAudioMuted);case _:
  return null;

}
}

}

/// @nodoc


class _RecordingControllerState implements RecordingControllerState {
  const _RecordingControllerState({this.lifecycle = RecordingLifecycle.idle, this.activityType, this.elapsedTime = Duration.zero, this.movingTime = Duration.zero, this.distanceMeters = 0, this.elevationGainMeters, this.currentPaceSecondsPerKm, this.sampleCount = 0, this.autoPausedSince, this.showForgottenEndPrompt = false, this.permissionResult, this.error, this.savedActivityId, this.routeId, this.latestFix,  List<LocationFix> trackPoints = const [], this.currentElevationMeters, this.currentSpeedMps, this.isAudioMuted = false}): _trackPoints = trackPoints;
  

@override@JsonKey() final  RecordingLifecycle lifecycle;
@override final  ActivityType? activityType;
@override@JsonKey() final  Duration elapsedTime;
@override@JsonKey() final  Duration movingTime;
@override@JsonKey() final  double distanceMeters;
@override final  double? elevationGainMeters;
@override final  double? currentPaceSecondsPerKm;
@override@JsonKey() final  int sampleCount;
/// The back-dated clock boundary the current auto-pause episode began
/// at (mirrors [RecordingSession.autoPausedAt]) - `null` whenever
/// [lifecycle] isn't [RecordingLifecycle.autoPaused]. Kept as its own
/// state field (rather than left for the screen to derive) so
/// [RecordingController]'s ticker can compare it against "now" once a
/// second without the screen needing its own timer.
@override final  DateTime? autoPausedSince;
/// Whether `record_screen.dart` should show the "Looks like you've
/// stopped" forgotten-end prompt: true once [autoPausedSince] is at
/// least 10 minutes in the past and
/// [RecordingController.dismissForgottenEndPrompt] hasn't been called
/// for the current auto-pause episode. Re-evaluated on
/// [RecordingController]'s existing 1s ticker - see
/// [RecordingController._syncStateFromSession].
@override@JsonKey() final  bool showForgottenEndPrompt;
/// Set when permission was checked/requested and came back anything
/// other than granted — lets the screen show a specific CTA (e.g. "Open
/// Settings" for [LocationPermissionResult.deniedForever]).
@override final  LocationPermissionResult? permissionResult;
/// Already-resolved user-facing message (via `userMessageFor`) for a
/// failure — never a raw exception, per `error_handling.md`'s
/// values-not-exceptions convention for expected UI-surfaced failures.
@override final  String? error;
@override final  String? savedActivityId;
@override final  String? routeId;
@override final  LocationFix? latestFix;
 final  List<LocationFix> _trackPoints;
@override@JsonKey() List<LocationFix> get trackPoints {
  if (_trackPoints is EqualUnmodifiableListView) return _trackPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackPoints);
}

@override final  double? currentElevationMeters;
@override final  double? currentSpeedMps;
@override@JsonKey() final  bool isAudioMuted;

/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingControllerStateCopyWith<_RecordingControllerState> get copyWith => __$RecordingControllerStateCopyWithImpl<_RecordingControllerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingControllerState&&(identical(other.lifecycle, lifecycle) || other.lifecycle == lifecycle)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.elevationGainMeters, elevationGainMeters) || other.elevationGainMeters == elevationGainMeters)&&(identical(other.currentPaceSecondsPerKm, currentPaceSecondsPerKm) || other.currentPaceSecondsPerKm == currentPaceSecondsPerKm)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.autoPausedSince, autoPausedSince) || other.autoPausedSince == autoPausedSince)&&(identical(other.showForgottenEndPrompt, showForgottenEndPrompt) || other.showForgottenEndPrompt == showForgottenEndPrompt)&&(identical(other.permissionResult, permissionResult) || other.permissionResult == permissionResult)&&(identical(other.error, error) || other.error == error)&&(identical(other.savedActivityId, savedActivityId) || other.savedActivityId == savedActivityId)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.latestFix, latestFix) || other.latestFix == latestFix)&&const DeepCollectionEquality().equals(other._trackPoints, _trackPoints)&&(identical(other.currentElevationMeters, currentElevationMeters) || other.currentElevationMeters == currentElevationMeters)&&(identical(other.currentSpeedMps, currentSpeedMps) || other.currentSpeedMps == currentSpeedMps)&&(identical(other.isAudioMuted, isAudioMuted) || other.isAudioMuted == isAudioMuted));
}


@override
int get hashCode => Object.hashAll([runtimeType,lifecycle,activityType,elapsedTime,movingTime,distanceMeters,elevationGainMeters,currentPaceSecondsPerKm,sampleCount,autoPausedSince,showForgottenEndPrompt,permissionResult,error,savedActivityId,routeId,latestFix,const DeepCollectionEquality().hash(_trackPoints),currentElevationMeters,currentSpeedMps,isAudioMuted]);

@override
String toString() {
  return 'RecordingControllerState(lifecycle: $lifecycle, activityType: $activityType, elapsedTime: $elapsedTime, movingTime: $movingTime, distanceMeters: $distanceMeters, elevationGainMeters: $elevationGainMeters, currentPaceSecondsPerKm: $currentPaceSecondsPerKm, sampleCount: $sampleCount, autoPausedSince: $autoPausedSince, showForgottenEndPrompt: $showForgottenEndPrompt, permissionResult: $permissionResult, error: $error, savedActivityId: $savedActivityId, routeId: $routeId, latestFix: $latestFix, trackPoints: $trackPoints, currentElevationMeters: $currentElevationMeters, currentSpeedMps: $currentSpeedMps, isAudioMuted: $isAudioMuted)';
}


}

/// @nodoc
abstract mixin class _$RecordingControllerStateCopyWith<$Res> implements $RecordingControllerStateCopyWith<$Res> {
  factory _$RecordingControllerStateCopyWith(_RecordingControllerState value, $Res Function(_RecordingControllerState) _then) = __$RecordingControllerStateCopyWithImpl;
@override @useResult
$Res call({
 RecordingLifecycle lifecycle, ActivityType? activityType, Duration elapsedTime, Duration movingTime, double distanceMeters, double? elevationGainMeters, double? currentPaceSecondsPerKm, int sampleCount, DateTime? autoPausedSince, bool showForgottenEndPrompt, LocationPermissionResult? permissionResult, String? error, String? savedActivityId, String? routeId, LocationFix? latestFix, List<LocationFix> trackPoints, double? currentElevationMeters, double? currentSpeedMps, bool isAudioMuted
});


@override $LocationFixCopyWith<$Res>? get latestFix;

}
/// @nodoc
class __$RecordingControllerStateCopyWithImpl<$Res>
    implements _$RecordingControllerStateCopyWith<$Res> {
  __$RecordingControllerStateCopyWithImpl(this._self, this._then);

  final _RecordingControllerState _self;
  final $Res Function(_RecordingControllerState) _then;

/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lifecycle = null,Object? activityType = freezed,Object? elapsedTime = null,Object? movingTime = null,Object? distanceMeters = null,Object? elevationGainMeters = freezed,Object? currentPaceSecondsPerKm = freezed,Object? sampleCount = null,Object? autoPausedSince = freezed,Object? showForgottenEndPrompt = null,Object? permissionResult = freezed,Object? error = freezed,Object? savedActivityId = freezed,Object? routeId = freezed,Object? latestFix = freezed,Object? trackPoints = null,Object? currentElevationMeters = freezed,Object? currentSpeedMps = freezed,Object? isAudioMuted = null,}) {
  return _then(_RecordingControllerState(
lifecycle: null == lifecycle ? _self.lifecycle : lifecycle // ignore: cast_nullable_to_non_nullable
as RecordingLifecycle,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType?,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,elevationGainMeters: freezed == elevationGainMeters ? _self.elevationGainMeters : elevationGainMeters // ignore: cast_nullable_to_non_nullable
as double?,currentPaceSecondsPerKm: freezed == currentPaceSecondsPerKm ? _self.currentPaceSecondsPerKm : currentPaceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double?,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,autoPausedSince: freezed == autoPausedSince ? _self.autoPausedSince : autoPausedSince // ignore: cast_nullable_to_non_nullable
as DateTime?,showForgottenEndPrompt: null == showForgottenEndPrompt ? _self.showForgottenEndPrompt : showForgottenEndPrompt // ignore: cast_nullable_to_non_nullable
as bool,permissionResult: freezed == permissionResult ? _self.permissionResult : permissionResult // ignore: cast_nullable_to_non_nullable
as LocationPermissionResult?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,savedActivityId: freezed == savedActivityId ? _self.savedActivityId : savedActivityId // ignore: cast_nullable_to_non_nullable
as String?,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,latestFix: freezed == latestFix ? _self.latestFix : latestFix // ignore: cast_nullable_to_non_nullable
as LocationFix?,trackPoints: null == trackPoints ? _self._trackPoints : trackPoints // ignore: cast_nullable_to_non_nullable
as List<LocationFix>,currentElevationMeters: freezed == currentElevationMeters ? _self.currentElevationMeters : currentElevationMeters // ignore: cast_nullable_to_non_nullable
as double?,currentSpeedMps: freezed == currentSpeedMps ? _self.currentSpeedMps : currentSpeedMps // ignore: cast_nullable_to_non_nullable
as double?,isAudioMuted: null == isAudioMuted ? _self.isAudioMuted : isAudioMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RecordingControllerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationFixCopyWith<$Res>? get latestFix {
    if (_self.latestFix == null) {
    return null;
  }

  return $LocationFixCopyWith<$Res>(_self.latestFix!, (value) {
    return _then(_self.copyWith(latestFix: value));
  });
}
}

// dart format on
