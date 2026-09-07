// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manual_entry_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManualEntryState {

 DateTime get startedAt; ActivityType get activityType; int get hours; int get minutes; int get seconds;/// Raw text as typed, in whatever unit ([UnitSystem]) the caller
/// passes to [ManualEntryController.save] / pre-fills via
/// [ManualEntryController.loadForEdit] - parsed (and converted to
/// canonical metres) only at save time.
 String get distanceInput; String get elevationInput; String get title; String get notes; String get strengthRoutineName; List<StrengthExercise> get strengthExercises; int get hiitWorkSeconds; int get hiitRestSeconds; int get hiitTotalRounds; int get hiitRpe; String get mindfulStyle; String get mindfulFocusArea; int get mindfulRpe; double get swimPoolLengthMeters; int get swimLaps; String get swimStroke; String? get dateTimeError; String? get durationError; String? get distanceError; bool get isSubmitting; String? get submitError;/// Flips to `true` once [ManualEntryController.save] persists
/// successfully - the screen listens for this to navigate away,
/// exactly once, instead of the controller navigating itself.
 bool get didSave;
/// Create a copy of ManualEntryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManualEntryStateCopyWith<ManualEntryState> get copyWith => _$ManualEntryStateCopyWithImpl<ManualEntryState>(this as ManualEntryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualEntryState&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.distanceInput, distanceInput) || other.distanceInput == distanceInput)&&(identical(other.elevationInput, elevationInput) || other.elevationInput == elevationInput)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.strengthRoutineName, strengthRoutineName) || other.strengthRoutineName == strengthRoutineName)&&const DeepCollectionEquality().equals(other.strengthExercises, strengthExercises)&&(identical(other.hiitWorkSeconds, hiitWorkSeconds) || other.hiitWorkSeconds == hiitWorkSeconds)&&(identical(other.hiitRestSeconds, hiitRestSeconds) || other.hiitRestSeconds == hiitRestSeconds)&&(identical(other.hiitTotalRounds, hiitTotalRounds) || other.hiitTotalRounds == hiitTotalRounds)&&(identical(other.hiitRpe, hiitRpe) || other.hiitRpe == hiitRpe)&&(identical(other.mindfulStyle, mindfulStyle) || other.mindfulStyle == mindfulStyle)&&(identical(other.mindfulFocusArea, mindfulFocusArea) || other.mindfulFocusArea == mindfulFocusArea)&&(identical(other.mindfulRpe, mindfulRpe) || other.mindfulRpe == mindfulRpe)&&(identical(other.swimPoolLengthMeters, swimPoolLengthMeters) || other.swimPoolLengthMeters == swimPoolLengthMeters)&&(identical(other.swimLaps, swimLaps) || other.swimLaps == swimLaps)&&(identical(other.swimStroke, swimStroke) || other.swimStroke == swimStroke)&&(identical(other.dateTimeError, dateTimeError) || other.dateTimeError == dateTimeError)&&(identical(other.durationError, durationError) || other.durationError == durationError)&&(identical(other.distanceError, distanceError) || other.distanceError == distanceError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hashAll([runtimeType,startedAt,activityType,hours,minutes,seconds,distanceInput,elevationInput,title,notes,strengthRoutineName,const DeepCollectionEquality().hash(strengthExercises),hiitWorkSeconds,hiitRestSeconds,hiitTotalRounds,hiitRpe,mindfulStyle,mindfulFocusArea,mindfulRpe,swimPoolLengthMeters,swimLaps,swimStroke,dateTimeError,durationError,distanceError,isSubmitting,submitError,didSave]);

@override
String toString() {
  return 'ManualEntryState(startedAt: $startedAt, activityType: $activityType, hours: $hours, minutes: $minutes, seconds: $seconds, distanceInput: $distanceInput, elevationInput: $elevationInput, title: $title, notes: $notes, strengthRoutineName: $strengthRoutineName, strengthExercises: $strengthExercises, hiitWorkSeconds: $hiitWorkSeconds, hiitRestSeconds: $hiitRestSeconds, hiitTotalRounds: $hiitTotalRounds, hiitRpe: $hiitRpe, mindfulStyle: $mindfulStyle, mindfulFocusArea: $mindfulFocusArea, mindfulRpe: $mindfulRpe, swimPoolLengthMeters: $swimPoolLengthMeters, swimLaps: $swimLaps, swimStroke: $swimStroke, dateTimeError: $dateTimeError, durationError: $durationError, distanceError: $distanceError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class $ManualEntryStateCopyWith<$Res>  {
  factory $ManualEntryStateCopyWith(ManualEntryState value, $Res Function(ManualEntryState) _then) = _$ManualEntryStateCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt, ActivityType activityType, int hours, int minutes, int seconds, String distanceInput, String elevationInput, String title, String notes, String strengthRoutineName, List<StrengthExercise> strengthExercises, int hiitWorkSeconds, int hiitRestSeconds, int hiitTotalRounds, int hiitRpe, String mindfulStyle, String mindfulFocusArea, int mindfulRpe, double swimPoolLengthMeters, int swimLaps, String swimStroke, String? dateTimeError, String? durationError, String? distanceError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class _$ManualEntryStateCopyWithImpl<$Res>
    implements $ManualEntryStateCopyWith<$Res> {
  _$ManualEntryStateCopyWithImpl(this._self, this._then);

  final ManualEntryState _self;
  final $Res Function(ManualEntryState) _then;

/// Create a copy of ManualEntryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startedAt = null,Object? activityType = null,Object? hours = null,Object? minutes = null,Object? seconds = null,Object? distanceInput = null,Object? elevationInput = null,Object? title = null,Object? notes = null,Object? strengthRoutineName = null,Object? strengthExercises = null,Object? hiitWorkSeconds = null,Object? hiitRestSeconds = null,Object? hiitTotalRounds = null,Object? hiitRpe = null,Object? mindfulStyle = null,Object? mindfulFocusArea = null,Object? mindfulRpe = null,Object? swimPoolLengthMeters = null,Object? swimLaps = null,Object? swimStroke = null,Object? dateTimeError = freezed,Object? durationError = freezed,Object? distanceError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(ManualEntryState(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,distanceInput: null == distanceInput ? _self.distanceInput : distanceInput // ignore: cast_nullable_to_non_nullable
as String,elevationInput: null == elevationInput ? _self.elevationInput : elevationInput // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,strengthRoutineName: null == strengthRoutineName ? _self.strengthRoutineName : strengthRoutineName // ignore: cast_nullable_to_non_nullable
as String,strengthExercises: null == strengthExercises ? _self.strengthExercises : strengthExercises // ignore: cast_nullable_to_non_nullable
as List<StrengthExercise>,hiitWorkSeconds: null == hiitWorkSeconds ? _self.hiitWorkSeconds : hiitWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,hiitRestSeconds: null == hiitRestSeconds ? _self.hiitRestSeconds : hiitRestSeconds // ignore: cast_nullable_to_non_nullable
as int,hiitTotalRounds: null == hiitTotalRounds ? _self.hiitTotalRounds : hiitTotalRounds // ignore: cast_nullable_to_non_nullable
as int,hiitRpe: null == hiitRpe ? _self.hiitRpe : hiitRpe // ignore: cast_nullable_to_non_nullable
as int,mindfulStyle: null == mindfulStyle ? _self.mindfulStyle : mindfulStyle // ignore: cast_nullable_to_non_nullable
as String,mindfulFocusArea: null == mindfulFocusArea ? _self.mindfulFocusArea : mindfulFocusArea // ignore: cast_nullable_to_non_nullable
as String,mindfulRpe: null == mindfulRpe ? _self.mindfulRpe : mindfulRpe // ignore: cast_nullable_to_non_nullable
as int,swimPoolLengthMeters: null == swimPoolLengthMeters ? _self.swimPoolLengthMeters : swimPoolLengthMeters // ignore: cast_nullable_to_non_nullable
as double,swimLaps: null == swimLaps ? _self.swimLaps : swimLaps // ignore: cast_nullable_to_non_nullable
as int,swimStroke: null == swimStroke ? _self.swimStroke : swimStroke // ignore: cast_nullable_to_non_nullable
as String,dateTimeError: freezed == dateTimeError ? _self.dateTimeError : dateTimeError // ignore: cast_nullable_to_non_nullable
as String?,durationError: freezed == durationError ? _self.durationError : durationError // ignore: cast_nullable_to_non_nullable
as String?,distanceError: freezed == distanceError ? _self.distanceError : distanceError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ManualEntryState].
extension ManualEntryStatePatterns on ManualEntryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManualEntryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManualEntryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManualEntryState value)  $default,){
final _that = this;
switch (_that) {
case _ManualEntryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManualEntryState value)?  $default,){
final _that = this;
switch (_that) {
case _ManualEntryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startedAt,  ActivityType activityType,  int hours,  int minutes,  int seconds,  String distanceInput,  String elevationInput,  String title,  String notes,  String strengthRoutineName,  List<StrengthExercise> strengthExercises,  int hiitWorkSeconds,  int hiitRestSeconds,  int hiitTotalRounds,  int hiitRpe,  String mindfulStyle,  String mindfulFocusArea,  int mindfulRpe,  double swimPoolLengthMeters,  int swimLaps,  String swimStroke,  String? dateTimeError,  String? durationError,  String? distanceError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManualEntryState() when $default != null:
return $default(_that.startedAt,_that.activityType,_that.hours,_that.minutes,_that.seconds,_that.distanceInput,_that.elevationInput,_that.title,_that.notes,_that.strengthRoutineName,_that.strengthExercises,_that.hiitWorkSeconds,_that.hiitRestSeconds,_that.hiitTotalRounds,_that.hiitRpe,_that.mindfulStyle,_that.mindfulFocusArea,_that.mindfulRpe,_that.swimPoolLengthMeters,_that.swimLaps,_that.swimStroke,_that.dateTimeError,_that.durationError,_that.distanceError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startedAt,  ActivityType activityType,  int hours,  int minutes,  int seconds,  String distanceInput,  String elevationInput,  String title,  String notes,  String strengthRoutineName,  List<StrengthExercise> strengthExercises,  int hiitWorkSeconds,  int hiitRestSeconds,  int hiitTotalRounds,  int hiitRpe,  String mindfulStyle,  String mindfulFocusArea,  int mindfulRpe,  double swimPoolLengthMeters,  int swimLaps,  String swimStroke,  String? dateTimeError,  String? durationError,  String? distanceError,  bool isSubmitting,  String? submitError,  bool didSave)  $default,) {final _that = this;
switch (_that) {
case _ManualEntryState():
return $default(_that.startedAt,_that.activityType,_that.hours,_that.minutes,_that.seconds,_that.distanceInput,_that.elevationInput,_that.title,_that.notes,_that.strengthRoutineName,_that.strengthExercises,_that.hiitWorkSeconds,_that.hiitRestSeconds,_that.hiitTotalRounds,_that.hiitRpe,_that.mindfulStyle,_that.mindfulFocusArea,_that.mindfulRpe,_that.swimPoolLengthMeters,_that.swimLaps,_that.swimStroke,_that.dateTimeError,_that.durationError,_that.distanceError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startedAt,  ActivityType activityType,  int hours,  int minutes,  int seconds,  String distanceInput,  String elevationInput,  String title,  String notes,  String strengthRoutineName,  List<StrengthExercise> strengthExercises,  int hiitWorkSeconds,  int hiitRestSeconds,  int hiitTotalRounds,  int hiitRpe,  String mindfulStyle,  String mindfulFocusArea,  int mindfulRpe,  double swimPoolLengthMeters,  int swimLaps,  String swimStroke,  String? dateTimeError,  String? durationError,  String? distanceError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,) {final _that = this;
switch (_that) {
case _ManualEntryState() when $default != null:
return $default(_that.startedAt,_that.activityType,_that.hours,_that.minutes,_that.seconds,_that.distanceInput,_that.elevationInput,_that.title,_that.notes,_that.strengthRoutineName,_that.strengthExercises,_that.hiitWorkSeconds,_that.hiitRestSeconds,_that.hiitTotalRounds,_that.hiitRpe,_that.mindfulStyle,_that.mindfulFocusArea,_that.mindfulRpe,_that.swimPoolLengthMeters,_that.swimLaps,_that.swimStroke,_that.dateTimeError,_that.durationError,_that.distanceError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
  return null;

}
}

}

/// @nodoc


class _ManualEntryState implements ManualEntryState {
  const _ManualEntryState({required this.startedAt, this.activityType = ActivityType.run, this.hours = 0, this.minutes = 0, this.seconds = 0, this.distanceInput = '', this.elevationInput = '', this.title = '', this.notes = '', this.strengthRoutineName = '',  List<StrengthExercise> strengthExercises = const [], this.hiitWorkSeconds = 40, this.hiitRestSeconds = 20, this.hiitTotalRounds = 8, this.hiitRpe = 7, this.mindfulStyle = 'Vinyasa', this.mindfulFocusArea = 'Full Body Flow', this.mindfulRpe = 6, this.swimPoolLengthMeters = 25.0, this.swimLaps = 0, this.swimStroke = 'Freestyle', this.dateTimeError, this.durationError, this.distanceError, this.isSubmitting = false, this.submitError, this.didSave = false}): _strengthExercises = strengthExercises;
  

@override final  DateTime startedAt;
@override@JsonKey() final  ActivityType activityType;
@override@JsonKey() final  int hours;
@override@JsonKey() final  int minutes;
@override@JsonKey() final  int seconds;
/// Raw text as typed, in whatever unit ([UnitSystem]) the caller
/// passes to [ManualEntryController.save] / pre-fills via
/// [ManualEntryController.loadForEdit] - parsed (and converted to
/// canonical metres) only at save time.
@override@JsonKey() final  String distanceInput;
@override@JsonKey() final  String elevationInput;
@override@JsonKey() final  String title;
@override@JsonKey() final  String notes;
@override@JsonKey() final  String strengthRoutineName;
 final  List<StrengthExercise> _strengthExercises;
@override@JsonKey() List<StrengthExercise> get strengthExercises {
  if (_strengthExercises is EqualUnmodifiableListView) return _strengthExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strengthExercises);
}

@override@JsonKey() final  int hiitWorkSeconds;
@override@JsonKey() final  int hiitRestSeconds;
@override@JsonKey() final  int hiitTotalRounds;
@override@JsonKey() final  int hiitRpe;
@override@JsonKey() final  String mindfulStyle;
@override@JsonKey() final  String mindfulFocusArea;
@override@JsonKey() final  int mindfulRpe;
@override@JsonKey() final  double swimPoolLengthMeters;
@override@JsonKey() final  int swimLaps;
@override@JsonKey() final  String swimStroke;
@override final  String? dateTimeError;
@override final  String? durationError;
@override final  String? distanceError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;
/// Flips to `true` once [ManualEntryController.save] persists
/// successfully - the screen listens for this to navigate away,
/// exactly once, instead of the controller navigating itself.
@override@JsonKey() final  bool didSave;

/// Create a copy of ManualEntryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManualEntryStateCopyWith<_ManualEntryState> get copyWith => __$ManualEntryStateCopyWithImpl<_ManualEntryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManualEntryState&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.distanceInput, distanceInput) || other.distanceInput == distanceInput)&&(identical(other.elevationInput, elevationInput) || other.elevationInput == elevationInput)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.strengthRoutineName, strengthRoutineName) || other.strengthRoutineName == strengthRoutineName)&&const DeepCollectionEquality().equals(other._strengthExercises, _strengthExercises)&&(identical(other.hiitWorkSeconds, hiitWorkSeconds) || other.hiitWorkSeconds == hiitWorkSeconds)&&(identical(other.hiitRestSeconds, hiitRestSeconds) || other.hiitRestSeconds == hiitRestSeconds)&&(identical(other.hiitTotalRounds, hiitTotalRounds) || other.hiitTotalRounds == hiitTotalRounds)&&(identical(other.hiitRpe, hiitRpe) || other.hiitRpe == hiitRpe)&&(identical(other.mindfulStyle, mindfulStyle) || other.mindfulStyle == mindfulStyle)&&(identical(other.mindfulFocusArea, mindfulFocusArea) || other.mindfulFocusArea == mindfulFocusArea)&&(identical(other.mindfulRpe, mindfulRpe) || other.mindfulRpe == mindfulRpe)&&(identical(other.swimPoolLengthMeters, swimPoolLengthMeters) || other.swimPoolLengthMeters == swimPoolLengthMeters)&&(identical(other.swimLaps, swimLaps) || other.swimLaps == swimLaps)&&(identical(other.swimStroke, swimStroke) || other.swimStroke == swimStroke)&&(identical(other.dateTimeError, dateTimeError) || other.dateTimeError == dateTimeError)&&(identical(other.durationError, durationError) || other.durationError == durationError)&&(identical(other.distanceError, distanceError) || other.distanceError == distanceError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hashAll([runtimeType,startedAt,activityType,hours,minutes,seconds,distanceInput,elevationInput,title,notes,strengthRoutineName,const DeepCollectionEquality().hash(_strengthExercises),hiitWorkSeconds,hiitRestSeconds,hiitTotalRounds,hiitRpe,mindfulStyle,mindfulFocusArea,mindfulRpe,swimPoolLengthMeters,swimLaps,swimStroke,dateTimeError,durationError,distanceError,isSubmitting,submitError,didSave]);

@override
String toString() {
  return 'ManualEntryState(startedAt: $startedAt, activityType: $activityType, hours: $hours, minutes: $minutes, seconds: $seconds, distanceInput: $distanceInput, elevationInput: $elevationInput, title: $title, notes: $notes, strengthRoutineName: $strengthRoutineName, strengthExercises: $strengthExercises, hiitWorkSeconds: $hiitWorkSeconds, hiitRestSeconds: $hiitRestSeconds, hiitTotalRounds: $hiitTotalRounds, hiitRpe: $hiitRpe, mindfulStyle: $mindfulStyle, mindfulFocusArea: $mindfulFocusArea, mindfulRpe: $mindfulRpe, swimPoolLengthMeters: $swimPoolLengthMeters, swimLaps: $swimLaps, swimStroke: $swimStroke, dateTimeError: $dateTimeError, durationError: $durationError, distanceError: $distanceError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class _$ManualEntryStateCopyWith<$Res> implements $ManualEntryStateCopyWith<$Res> {
  factory _$ManualEntryStateCopyWith(_ManualEntryState value, $Res Function(_ManualEntryState) _then) = __$ManualEntryStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime startedAt, ActivityType activityType, int hours, int minutes, int seconds, String distanceInput, String elevationInput, String title, String notes, String strengthRoutineName, List<StrengthExercise> strengthExercises, int hiitWorkSeconds, int hiitRestSeconds, int hiitTotalRounds, int hiitRpe, String mindfulStyle, String mindfulFocusArea, int mindfulRpe, double swimPoolLengthMeters, int swimLaps, String swimStroke, String? dateTimeError, String? durationError, String? distanceError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class __$ManualEntryStateCopyWithImpl<$Res>
    implements _$ManualEntryStateCopyWith<$Res> {
  __$ManualEntryStateCopyWithImpl(this._self, this._then);

  final _ManualEntryState _self;
  final $Res Function(_ManualEntryState) _then;

/// Create a copy of ManualEntryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startedAt = null,Object? activityType = null,Object? hours = null,Object? minutes = null,Object? seconds = null,Object? distanceInput = null,Object? elevationInput = null,Object? title = null,Object? notes = null,Object? strengthRoutineName = null,Object? strengthExercises = null,Object? hiitWorkSeconds = null,Object? hiitRestSeconds = null,Object? hiitTotalRounds = null,Object? hiitRpe = null,Object? mindfulStyle = null,Object? mindfulFocusArea = null,Object? mindfulRpe = null,Object? swimPoolLengthMeters = null,Object? swimLaps = null,Object? swimStroke = null,Object? dateTimeError = freezed,Object? durationError = freezed,Object? distanceError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(_ManualEntryState(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,distanceInput: null == distanceInput ? _self.distanceInput : distanceInput // ignore: cast_nullable_to_non_nullable
as String,elevationInput: null == elevationInput ? _self.elevationInput : elevationInput // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,strengthRoutineName: null == strengthRoutineName ? _self.strengthRoutineName : strengthRoutineName // ignore: cast_nullable_to_non_nullable
as String,strengthExercises: null == strengthExercises ? _self._strengthExercises : strengthExercises // ignore: cast_nullable_to_non_nullable
as List<StrengthExercise>,hiitWorkSeconds: null == hiitWorkSeconds ? _self.hiitWorkSeconds : hiitWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,hiitRestSeconds: null == hiitRestSeconds ? _self.hiitRestSeconds : hiitRestSeconds // ignore: cast_nullable_to_non_nullable
as int,hiitTotalRounds: null == hiitTotalRounds ? _self.hiitTotalRounds : hiitTotalRounds // ignore: cast_nullable_to_non_nullable
as int,hiitRpe: null == hiitRpe ? _self.hiitRpe : hiitRpe // ignore: cast_nullable_to_non_nullable
as int,mindfulStyle: null == mindfulStyle ? _self.mindfulStyle : mindfulStyle // ignore: cast_nullable_to_non_nullable
as String,mindfulFocusArea: null == mindfulFocusArea ? _self.mindfulFocusArea : mindfulFocusArea // ignore: cast_nullable_to_non_nullable
as String,mindfulRpe: null == mindfulRpe ? _self.mindfulRpe : mindfulRpe // ignore: cast_nullable_to_non_nullable
as int,swimPoolLengthMeters: null == swimPoolLengthMeters ? _self.swimPoolLengthMeters : swimPoolLengthMeters // ignore: cast_nullable_to_non_nullable
as double,swimLaps: null == swimLaps ? _self.swimLaps : swimLaps // ignore: cast_nullable_to_non_nullable
as int,swimStroke: null == swimStroke ? _self.swimStroke : swimStroke // ignore: cast_nullable_to_non_nullable
as String,dateTimeError: freezed == dateTimeError ? _self.dateTimeError : dateTimeError // ignore: cast_nullable_to_non_nullable
as String?,durationError: freezed == durationError ? _self.durationError : durationError // ignore: cast_nullable_to_non_nullable
as String?,distanceError: freezed == distanceError ? _self.distanceError : distanceError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
