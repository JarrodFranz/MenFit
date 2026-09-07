// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

 int get stepIndex; String get displayName; UnitSystem get unitSystem;/// Set on the optional "Tell us a little more" step. `null` (the
/// default) means never chosen — this step is entirely skippable.
 FitnessGoal? get fitnessGoal;/// Multiple chosen fitness goals. Empty set when none chosen.
 Set<FitnessGoal> get fitnessGoals;/// Set on the optional "Tell us a little more" step. `null` (the
/// default) means never chosen.
 ExperienceLevel? get runningExperience;/// Optional profile measurements collected during onboarding.
 LocalDate? get dateOfBirth; double? get heightCm; double? get weightKg; int? get weeklyActivityGoal; Set<Weekday> get trainingDays;/// Optional field validation errors for height/weight.
 String? get heightError; String? get weightError;/// Set when [OnboardingController.continueFromCurrentStep] or
/// [OnboardingController.finish] rejects an empty display name -
/// validation as a return/state value, not an exception, per
/// `knowledge/engineering/error_handling.md`.
 String? get displayNameError;/// User-presentable message set when [OnboardingController.finish]
/// fails partway through (profile save or onboarding-complete flag both
/// throw). `null` when there's nothing to show.
 String? get submitError; bool get isSubmitting;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.fitnessGoal, fitnessGoal) || other.fitnessGoal == fitnessGoal)&&const DeepCollectionEquality().equals(other.fitnessGoals, fitnessGoals)&&(identical(other.runningExperience, runningExperience) || other.runningExperience == runningExperience)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weeklyActivityGoal, weeklyActivityGoal) || other.weeklyActivityGoal == weeklyActivityGoal)&&const DeepCollectionEquality().equals(other.trainingDays, trainingDays)&&(identical(other.heightError, heightError) || other.heightError == heightError)&&(identical(other.weightError, weightError) || other.weightError == weightError)&&(identical(other.displayNameError, displayNameError) || other.displayNameError == displayNameError)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,stepIndex,displayName,unitSystem,fitnessGoal,const DeepCollectionEquality().hash(fitnessGoals),runningExperience,dateOfBirth,heightCm,weightKg,weeklyActivityGoal,const DeepCollectionEquality().hash(trainingDays),heightError,weightError,displayNameError,submitError,isSubmitting);

@override
String toString() {
  return 'OnboardingState(stepIndex: $stepIndex, displayName: $displayName, unitSystem: $unitSystem, fitnessGoal: $fitnessGoal, fitnessGoals: $fitnessGoals, runningExperience: $runningExperience, dateOfBirth: $dateOfBirth, heightCm: $heightCm, weightKg: $weightKg, weeklyActivityGoal: $weeklyActivityGoal, trainingDays: $trainingDays, heightError: $heightError, weightError: $weightError, displayNameError: $displayNameError, submitError: $submitError, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 int stepIndex, String displayName, UnitSystem unitSystem, FitnessGoal? fitnessGoal, Set<FitnessGoal> fitnessGoals, ExperienceLevel? runningExperience, LocalDate? dateOfBirth, double? heightCm, double? weightKg, int? weeklyActivityGoal, Set<Weekday> trainingDays, String? heightError, String? weightError, String? displayNameError, String? submitError, bool isSubmitting
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepIndex = null,Object? displayName = null,Object? unitSystem = null,Object? fitnessGoal = freezed,Object? fitnessGoals = null,Object? runningExperience = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? weeklyActivityGoal = freezed,Object? trainingDays = null,Object? heightError = freezed,Object? weightError = freezed,Object? displayNameError = freezed,Object? submitError = freezed,Object? isSubmitting = null,}) {
  return _then(OnboardingState(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,fitnessGoal: freezed == fitnessGoal ? _self.fitnessGoal : fitnessGoal // ignore: cast_nullable_to_non_nullable
as FitnessGoal?,fitnessGoals: null == fitnessGoals ? _self.fitnessGoals : fitnessGoals // ignore: cast_nullable_to_non_nullable
as Set<FitnessGoal>,runningExperience: freezed == runningExperience ? _self.runningExperience : runningExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as LocalDate?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weeklyActivityGoal: freezed == weeklyActivityGoal ? _self.weeklyActivityGoal : weeklyActivityGoal // ignore: cast_nullable_to_non_nullable
as int?,trainingDays: null == trainingDays ? _self.trainingDays : trainingDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,heightError: freezed == heightError ? _self.heightError : heightError // ignore: cast_nullable_to_non_nullable
as String?,weightError: freezed == weightError ? _self.weightError : weightError // ignore: cast_nullable_to_non_nullable
as String?,displayNameError: freezed == displayNameError ? _self.displayNameError : displayNameError // ignore: cast_nullable_to_non_nullable
as String?,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stepIndex,  String displayName,  UnitSystem unitSystem,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  int? weeklyActivityGoal,  Set<Weekday> trainingDays,  String? heightError,  String? weightError,  String? displayNameError,  String? submitError,  bool isSubmitting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.stepIndex,_that.displayName,_that.unitSystem,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.weeklyActivityGoal,_that.trainingDays,_that.heightError,_that.weightError,_that.displayNameError,_that.submitError,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stepIndex,  String displayName,  UnitSystem unitSystem,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  int? weeklyActivityGoal,  Set<Weekday> trainingDays,  String? heightError,  String? weightError,  String? displayNameError,  String? submitError,  bool isSubmitting)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.stepIndex,_that.displayName,_that.unitSystem,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.weeklyActivityGoal,_that.trainingDays,_that.heightError,_that.weightError,_that.displayNameError,_that.submitError,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stepIndex,  String displayName,  UnitSystem unitSystem,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  int? weeklyActivityGoal,  Set<Weekday> trainingDays,  String? heightError,  String? weightError,  String? displayNameError,  String? submitError,  bool isSubmitting)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.stepIndex,_that.displayName,_that.unitSystem,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.weeklyActivityGoal,_that.trainingDays,_that.heightError,_that.weightError,_that.displayNameError,_that.submitError,_that.isSubmitting);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState extends OnboardingState {
  const _OnboardingState({this.stepIndex = 0, this.displayName = '', this.unitSystem = UnitSystem.metric, this.fitnessGoal,  Set<FitnessGoal> fitnessGoals = const <FitnessGoal>{}, this.runningExperience, this.dateOfBirth, this.heightCm, this.weightKg, this.weeklyActivityGoal,  Set<Weekday> trainingDays = const <Weekday>{}, this.heightError, this.weightError, this.displayNameError, this.submitError, this.isSubmitting = false}): _fitnessGoals = fitnessGoals,_trainingDays = trainingDays,super._();
  

@override@JsonKey() final  int stepIndex;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  UnitSystem unitSystem;
/// Set on the optional "Tell us a little more" step. `null` (the
/// default) means never chosen — this step is entirely skippable.
@override final  FitnessGoal? fitnessGoal;
/// Multiple chosen fitness goals. Empty set when none chosen.
 final  Set<FitnessGoal> _fitnessGoals;
/// Multiple chosen fitness goals. Empty set when none chosen.
@override@JsonKey() Set<FitnessGoal> get fitnessGoals {
  if (_fitnessGoals is EqualUnmodifiableSetView) return _fitnessGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_fitnessGoals);
}

/// Set on the optional "Tell us a little more" step. `null` (the
/// default) means never chosen.
@override final  ExperienceLevel? runningExperience;
/// Optional profile measurements collected during onboarding.
@override final  LocalDate? dateOfBirth;
@override final  double? heightCm;
@override final  double? weightKg;
@override final  int? weeklyActivityGoal;
 final  Set<Weekday> _trainingDays;
@override@JsonKey() Set<Weekday> get trainingDays {
  if (_trainingDays is EqualUnmodifiableSetView) return _trainingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_trainingDays);
}

/// Optional field validation errors for height/weight.
@override final  String? heightError;
@override final  String? weightError;
/// Set when [OnboardingController.continueFromCurrentStep] or
/// [OnboardingController.finish] rejects an empty display name -
/// validation as a return/state value, not an exception, per
/// `knowledge/engineering/error_handling.md`.
@override final  String? displayNameError;
/// User-presentable message set when [OnboardingController.finish]
/// fails partway through (profile save or onboarding-complete flag both
/// throw). `null` when there's nothing to show.
@override final  String? submitError;
@override@JsonKey() final  bool isSubmitting;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.stepIndex, stepIndex) || other.stepIndex == stepIndex)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.fitnessGoal, fitnessGoal) || other.fitnessGoal == fitnessGoal)&&const DeepCollectionEquality().equals(other._fitnessGoals, _fitnessGoals)&&(identical(other.runningExperience, runningExperience) || other.runningExperience == runningExperience)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weeklyActivityGoal, weeklyActivityGoal) || other.weeklyActivityGoal == weeklyActivityGoal)&&const DeepCollectionEquality().equals(other._trainingDays, _trainingDays)&&(identical(other.heightError, heightError) || other.heightError == heightError)&&(identical(other.weightError, weightError) || other.weightError == weightError)&&(identical(other.displayNameError, displayNameError) || other.displayNameError == displayNameError)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,stepIndex,displayName,unitSystem,fitnessGoal,const DeepCollectionEquality().hash(_fitnessGoals),runningExperience,dateOfBirth,heightCm,weightKg,weeklyActivityGoal,const DeepCollectionEquality().hash(_trainingDays),heightError,weightError,displayNameError,submitError,isSubmitting);

@override
String toString() {
  return 'OnboardingState(stepIndex: $stepIndex, displayName: $displayName, unitSystem: $unitSystem, fitnessGoal: $fitnessGoal, fitnessGoals: $fitnessGoals, runningExperience: $runningExperience, dateOfBirth: $dateOfBirth, heightCm: $heightCm, weightKg: $weightKg, weeklyActivityGoal: $weeklyActivityGoal, trainingDays: $trainingDays, heightError: $heightError, weightError: $weightError, displayNameError: $displayNameError, submitError: $submitError, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 int stepIndex, String displayName, UnitSystem unitSystem, FitnessGoal? fitnessGoal, Set<FitnessGoal> fitnessGoals, ExperienceLevel? runningExperience, LocalDate? dateOfBirth, double? heightCm, double? weightKg, int? weeklyActivityGoal, Set<Weekday> trainingDays, String? heightError, String? weightError, String? displayNameError, String? submitError, bool isSubmitting
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepIndex = null,Object? displayName = null,Object? unitSystem = null,Object? fitnessGoal = freezed,Object? fitnessGoals = null,Object? runningExperience = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? weeklyActivityGoal = freezed,Object? trainingDays = null,Object? heightError = freezed,Object? weightError = freezed,Object? displayNameError = freezed,Object? submitError = freezed,Object? isSubmitting = null,}) {
  return _then(_OnboardingState(
stepIndex: null == stepIndex ? _self.stepIndex : stepIndex // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,fitnessGoal: freezed == fitnessGoal ? _self.fitnessGoal : fitnessGoal // ignore: cast_nullable_to_non_nullable
as FitnessGoal?,fitnessGoals: null == fitnessGoals ? _self._fitnessGoals : fitnessGoals // ignore: cast_nullable_to_non_nullable
as Set<FitnessGoal>,runningExperience: freezed == runningExperience ? _self.runningExperience : runningExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as LocalDate?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weeklyActivityGoal: freezed == weeklyActivityGoal ? _self.weeklyActivityGoal : weeklyActivityGoal // ignore: cast_nullable_to_non_nullable
as int?,trainingDays: null == trainingDays ? _self._trainingDays : trainingDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,heightError: freezed == heightError ? _self.heightError : heightError // ignore: cast_nullable_to_non_nullable
as String?,weightError: freezed == weightError ? _self.weightError : weightError // ignore: cast_nullable_to_non_nullable
as String?,displayNameError: freezed == displayNameError ? _self.displayNameError : displayNameError // ignore: cast_nullable_to_non_nullable
as String?,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
