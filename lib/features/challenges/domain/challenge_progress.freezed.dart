// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChallengeSelfProgress {

/// What they actually did inside the window, in the challenge kind's
/// working unit: metres for a distance challenge, a session count for
/// a session challenge.
 double get rawValue;/// What the challenge asks of a person with no protected days —
/// identical on both devices, because it is part of the shared
/// blueprint.
 double get nominalTarget;/// What it asks of *them*, after pro-rating by their protected days. Less
/// than or equal to [nominalTarget], always. Zero when every day of
/// the window was protected.
 double get adjustedTarget;/// How many days of the window were protected recovery for them. Never
/// leaves this object.
 int get protectedDaysInWindow;/// Days in the window, both endpoints included.
 int get windowDays;/// [rawValue] against [adjustedTarget], as a percentage. Not capped:
/// 140% is a real and good answer. Zero-target windows (every day
/// protected) read as 100 — there was nothing to fall short of.
 double get percent;
/// Create a copy of ChallengeSelfProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeSelfProgressCopyWith<ChallengeSelfProgress> get copyWith => _$ChallengeSelfProgressCopyWithImpl<ChallengeSelfProgress>(this as ChallengeSelfProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallengeSelfProgress&&(identical(other.rawValue, rawValue) || other.rawValue == rawValue)&&(identical(other.nominalTarget, nominalTarget) || other.nominalTarget == nominalTarget)&&(identical(other.adjustedTarget, adjustedTarget) || other.adjustedTarget == adjustedTarget)&&(identical(other.protectedDaysInWindow, protectedDaysInWindow) || other.protectedDaysInWindow == protectedDaysInWindow)&&(identical(other.windowDays, windowDays) || other.windowDays == windowDays)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,rawValue,nominalTarget,adjustedTarget,protectedDaysInWindow,windowDays,percent);

@override
String toString() {
  return 'ChallengeSelfProgress(rawValue: $rawValue, nominalTarget: $nominalTarget, adjustedTarget: $adjustedTarget, protectedDaysInWindow: $protectedDaysInWindow, windowDays: $windowDays, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $ChallengeSelfProgressCopyWith<$Res>  {
  factory $ChallengeSelfProgressCopyWith(ChallengeSelfProgress value, $Res Function(ChallengeSelfProgress) _then) = _$ChallengeSelfProgressCopyWithImpl;
@useResult
$Res call({
 double rawValue, double nominalTarget, double adjustedTarget, int protectedDaysInWindow, int windowDays, double percent
});




}
/// @nodoc
class _$ChallengeSelfProgressCopyWithImpl<$Res>
    implements $ChallengeSelfProgressCopyWith<$Res> {
  _$ChallengeSelfProgressCopyWithImpl(this._self, this._then);

  final ChallengeSelfProgress _self;
  final $Res Function(ChallengeSelfProgress) _then;

/// Create a copy of ChallengeSelfProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawValue = null,Object? nominalTarget = null,Object? adjustedTarget = null,Object? protectedDaysInWindow = null,Object? windowDays = null,Object? percent = null,}) {
  return _then(ChallengeSelfProgress(
rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as double,nominalTarget: null == nominalTarget ? _self.nominalTarget : nominalTarget // ignore: cast_nullable_to_non_nullable
as double,adjustedTarget: null == adjustedTarget ? _self.adjustedTarget : adjustedTarget // ignore: cast_nullable_to_non_nullable
as double,protectedDaysInWindow: null == protectedDaysInWindow ? _self.protectedDaysInWindow : protectedDaysInWindow // ignore: cast_nullable_to_non_nullable
as int,windowDays: null == windowDays ? _self.windowDays : windowDays // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallengeSelfProgress].
extension ChallengeSelfProgressPatterns on ChallengeSelfProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallengeSelfProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallengeSelfProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallengeSelfProgress value)  $default,){
final _that = this;
switch (_that) {
case _ChallengeSelfProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallengeSelfProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ChallengeSelfProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double rawValue,  double nominalTarget,  double adjustedTarget,  int protectedDaysInWindow,  int windowDays,  double percent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallengeSelfProgress() when $default != null:
return $default(_that.rawValue,_that.nominalTarget,_that.adjustedTarget,_that.protectedDaysInWindow,_that.windowDays,_that.percent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double rawValue,  double nominalTarget,  double adjustedTarget,  int protectedDaysInWindow,  int windowDays,  double percent)  $default,) {final _that = this;
switch (_that) {
case _ChallengeSelfProgress():
return $default(_that.rawValue,_that.nominalTarget,_that.adjustedTarget,_that.protectedDaysInWindow,_that.windowDays,_that.percent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double rawValue,  double nominalTarget,  double adjustedTarget,  int protectedDaysInWindow,  int windowDays,  double percent)?  $default,) {final _that = this;
switch (_that) {
case _ChallengeSelfProgress() when $default != null:
return $default(_that.rawValue,_that.nominalTarget,_that.adjustedTarget,_that.protectedDaysInWindow,_that.windowDays,_that.percent);case _:
  return null;

}
}

}

/// @nodoc


class _ChallengeSelfProgress extends ChallengeSelfProgress {
  const _ChallengeSelfProgress({required this.rawValue, required this.nominalTarget, required this.adjustedTarget, required this.protectedDaysInWindow, required this.windowDays, required this.percent}): super._();
  

/// What they actually did inside the window, in the challenge kind's
/// working unit: metres for a distance challenge, a session count for
/// a session challenge.
@override final  double rawValue;
/// What the challenge asks of a person with no protected days —
/// identical on both devices, because it is part of the shared
/// blueprint.
@override final  double nominalTarget;
/// What it asks of *them*, after pro-rating by their protected days. Less
/// than or equal to [nominalTarget], always. Zero when every day of
/// the window was protected.
@override final  double adjustedTarget;
/// How many days of the window were protected recovery for them. Never
/// leaves this object.
@override final  int protectedDaysInWindow;
/// Days in the window, both endpoints included.
@override final  int windowDays;
/// [rawValue] against [adjustedTarget], as a percentage. Not capped:
/// 140% is a real and good answer. Zero-target windows (every day
/// protected) read as 100 — there was nothing to fall short of.
@override final  double percent;

/// Create a copy of ChallengeSelfProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeSelfProgressCopyWith<_ChallengeSelfProgress> get copyWith => __$ChallengeSelfProgressCopyWithImpl<_ChallengeSelfProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallengeSelfProgress&&(identical(other.rawValue, rawValue) || other.rawValue == rawValue)&&(identical(other.nominalTarget, nominalTarget) || other.nominalTarget == nominalTarget)&&(identical(other.adjustedTarget, adjustedTarget) || other.adjustedTarget == adjustedTarget)&&(identical(other.protectedDaysInWindow, protectedDaysInWindow) || other.protectedDaysInWindow == protectedDaysInWindow)&&(identical(other.windowDays, windowDays) || other.windowDays == windowDays)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,rawValue,nominalTarget,adjustedTarget,protectedDaysInWindow,windowDays,percent);

@override
String toString() {
  return 'ChallengeSelfProgress(rawValue: $rawValue, nominalTarget: $nominalTarget, adjustedTarget: $adjustedTarget, protectedDaysInWindow: $protectedDaysInWindow, windowDays: $windowDays, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$ChallengeSelfProgressCopyWith<$Res> implements $ChallengeSelfProgressCopyWith<$Res> {
  factory _$ChallengeSelfProgressCopyWith(_ChallengeSelfProgress value, $Res Function(_ChallengeSelfProgress) _then) = __$ChallengeSelfProgressCopyWithImpl;
@override @useResult
$Res call({
 double rawValue, double nominalTarget, double adjustedTarget, int protectedDaysInWindow, int windowDays, double percent
});




}
/// @nodoc
class __$ChallengeSelfProgressCopyWithImpl<$Res>
    implements _$ChallengeSelfProgressCopyWith<$Res> {
  __$ChallengeSelfProgressCopyWithImpl(this._self, this._then);

  final _ChallengeSelfProgress _self;
  final $Res Function(_ChallengeSelfProgress) _then;

/// Create a copy of ChallengeSelfProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawValue = null,Object? nominalTarget = null,Object? adjustedTarget = null,Object? protectedDaysInWindow = null,Object? windowDays = null,Object? percent = null,}) {
  return _then(_ChallengeSelfProgress(
rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as double,nominalTarget: null == nominalTarget ? _self.nominalTarget : nominalTarget // ignore: cast_nullable_to_non_nullable
as double,adjustedTarget: null == adjustedTarget ? _self.adjustedTarget : adjustedTarget // ignore: cast_nullable_to_non_nullable
as double,protectedDaysInWindow: null == protectedDaysInWindow ? _self.protectedDaysInWindow : protectedDaysInWindow // ignore: cast_nullable_to_non_nullable
as int,windowDays: null == windowDays ? _self.windowDays : windowDays // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
