// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkin_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckinFormState {

 LocalDate get day; int? get energy; int? get sleep; int? get soreness; int? get stress; int? get pain; List<SymptomType> get symptoms; String? get otherSymptom; String? get dayError; String? get energyError; String? get sleepError; String? get sorenessError; String? get stressError; String? get painError; bool get isSubmitting; String? get submitError;/// Flips to `true` once [CheckinController.save] completes
/// successfully (whether or not anything was actually persisted — see
/// its dartdoc's empty-checkin no-op rule) - the sheet listens for this
/// to close itself, exactly once, instead of the controller closing it
/// directly (same convention as `PeriodEntryState.didSave`).
 bool get didSave;
/// Create a copy of CheckinFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinFormStateCopyWith<CheckinFormState> get copyWith => _$CheckinFormStateCopyWithImpl<CheckinFormState>(this as CheckinFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.pain, pain) || other.pain == pain)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&(identical(other.otherSymptom, otherSymptom) || other.otherSymptom == otherSymptom)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.energyError, energyError) || other.energyError == energyError)&&(identical(other.sleepError, sleepError) || other.sleepError == sleepError)&&(identical(other.sorenessError, sorenessError) || other.sorenessError == sorenessError)&&(identical(other.stressError, stressError) || other.stressError == stressError)&&(identical(other.painError, painError) || other.painError == painError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hash(runtimeType,day,energy,sleep,soreness,stress,pain,const DeepCollectionEquality().hash(symptoms),otherSymptom,dayError,energyError,sleepError,sorenessError,stressError,painError,isSubmitting,submitError,didSave);

@override
String toString() {
  return 'CheckinFormState(day: $day, energy: $energy, sleep: $sleep, soreness: $soreness, stress: $stress, pain: $pain, symptoms: $symptoms, otherSymptom: $otherSymptom, dayError: $dayError, energyError: $energyError, sleepError: $sleepError, sorenessError: $sorenessError, stressError: $stressError, painError: $painError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class $CheckinFormStateCopyWith<$Res>  {
  factory $CheckinFormStateCopyWith(CheckinFormState value, $Res Function(CheckinFormState) _then) = _$CheckinFormStateCopyWithImpl;
@useResult
$Res call({
 LocalDate day, int? energy, int? sleep, int? soreness, int? stress, int? pain, List<SymptomType> symptoms, String? otherSymptom, String? dayError, String? energyError, String? sleepError, String? sorenessError, String? stressError, String? painError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class _$CheckinFormStateCopyWithImpl<$Res>
    implements $CheckinFormStateCopyWith<$Res> {
  _$CheckinFormStateCopyWithImpl(this._self, this._then);

  final CheckinFormState _self;
  final $Res Function(CheckinFormState) _then;

/// Create a copy of CheckinFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? energy = freezed,Object? sleep = freezed,Object? soreness = freezed,Object? stress = freezed,Object? pain = freezed,Object? symptoms = null,Object? otherSymptom = freezed,Object? dayError = freezed,Object? energyError = freezed,Object? sleepError = freezed,Object? sorenessError = freezed,Object? stressError = freezed,Object? painError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(CheckinFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as int?,soreness: freezed == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int?,stress: freezed == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int?,pain: freezed == pain ? _self.pain : pain // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,otherSymptom: freezed == otherSymptom ? _self.otherSymptom : otherSymptom // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,energyError: freezed == energyError ? _self.energyError : energyError // ignore: cast_nullable_to_non_nullable
as String?,sleepError: freezed == sleepError ? _self.sleepError : sleepError // ignore: cast_nullable_to_non_nullable
as String?,sorenessError: freezed == sorenessError ? _self.sorenessError : sorenessError // ignore: cast_nullable_to_non_nullable
as String?,stressError: freezed == stressError ? _self.stressError : stressError // ignore: cast_nullable_to_non_nullable
as String?,painError: freezed == painError ? _self.painError : painError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckinFormState].
extension CheckinFormStatePatterns on CheckinFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinFormState value)  $default,){
final _that = this;
switch (_that) {
case _CheckinFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate day,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? otherSymptom,  String? dayError,  String? energyError,  String? sleepError,  String? sorenessError,  String? stressError,  String? painError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinFormState() when $default != null:
return $default(_that.day,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.otherSymptom,_that.dayError,_that.energyError,_that.sleepError,_that.sorenessError,_that.stressError,_that.painError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate day,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? otherSymptom,  String? dayError,  String? energyError,  String? sleepError,  String? sorenessError,  String? stressError,  String? painError,  bool isSubmitting,  String? submitError,  bool didSave)  $default,) {final _that = this;
switch (_that) {
case _CheckinFormState():
return $default(_that.day,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.otherSymptom,_that.dayError,_that.energyError,_that.sleepError,_that.sorenessError,_that.stressError,_that.painError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate day,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? otherSymptom,  String? dayError,  String? energyError,  String? sleepError,  String? sorenessError,  String? stressError,  String? painError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,) {final _that = this;
switch (_that) {
case _CheckinFormState() when $default != null:
return $default(_that.day,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.otherSymptom,_that.dayError,_that.energyError,_that.sleepError,_that.sorenessError,_that.stressError,_that.painError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
  return null;

}
}

}

/// @nodoc


class _CheckinFormState implements CheckinFormState {
  const _CheckinFormState({required this.day, this.energy, this.sleep, this.soreness, this.stress, this.pain,  List<SymptomType> symptoms = const <SymptomType>[], this.otherSymptom, this.dayError, this.energyError, this.sleepError, this.sorenessError, this.stressError, this.painError, this.isSubmitting = false, this.submitError, this.didSave = false}): _symptoms = symptoms;
  

@override final  LocalDate day;
@override final  int? energy;
@override final  int? sleep;
@override final  int? soreness;
@override final  int? stress;
@override final  int? pain;
 final  List<SymptomType> _symptoms;
@override@JsonKey() List<SymptomType> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

@override final  String? otherSymptom;
@override final  String? dayError;
@override final  String? energyError;
@override final  String? sleepError;
@override final  String? sorenessError;
@override final  String? stressError;
@override final  String? painError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;
/// Flips to `true` once [CheckinController.save] completes
/// successfully (whether or not anything was actually persisted — see
/// its dartdoc's empty-checkin no-op rule) - the sheet listens for this
/// to close itself, exactly once, instead of the controller closing it
/// directly (same convention as `PeriodEntryState.didSave`).
@override@JsonKey() final  bool didSave;

/// Create a copy of CheckinFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinFormStateCopyWith<_CheckinFormState> get copyWith => __$CheckinFormStateCopyWithImpl<_CheckinFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.pain, pain) || other.pain == pain)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&(identical(other.otherSymptom, otherSymptom) || other.otherSymptom == otherSymptom)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.energyError, energyError) || other.energyError == energyError)&&(identical(other.sleepError, sleepError) || other.sleepError == sleepError)&&(identical(other.sorenessError, sorenessError) || other.sorenessError == sorenessError)&&(identical(other.stressError, stressError) || other.stressError == stressError)&&(identical(other.painError, painError) || other.painError == painError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hash(runtimeType,day,energy,sleep,soreness,stress,pain,const DeepCollectionEquality().hash(_symptoms),otherSymptom,dayError,energyError,sleepError,sorenessError,stressError,painError,isSubmitting,submitError,didSave);

@override
String toString() {
  return 'CheckinFormState(day: $day, energy: $energy, sleep: $sleep, soreness: $soreness, stress: $stress, pain: $pain, symptoms: $symptoms, otherSymptom: $otherSymptom, dayError: $dayError, energyError: $energyError, sleepError: $sleepError, sorenessError: $sorenessError, stressError: $stressError, painError: $painError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class _$CheckinFormStateCopyWith<$Res> implements $CheckinFormStateCopyWith<$Res> {
  factory _$CheckinFormStateCopyWith(_CheckinFormState value, $Res Function(_CheckinFormState) _then) = __$CheckinFormStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate day, int? energy, int? sleep, int? soreness, int? stress, int? pain, List<SymptomType> symptoms, String? otherSymptom, String? dayError, String? energyError, String? sleepError, String? sorenessError, String? stressError, String? painError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class __$CheckinFormStateCopyWithImpl<$Res>
    implements _$CheckinFormStateCopyWith<$Res> {
  __$CheckinFormStateCopyWithImpl(this._self, this._then);

  final _CheckinFormState _self;
  final $Res Function(_CheckinFormState) _then;

/// Create a copy of CheckinFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? energy = freezed,Object? sleep = freezed,Object? soreness = freezed,Object? stress = freezed,Object? pain = freezed,Object? symptoms = null,Object? otherSymptom = freezed,Object? dayError = freezed,Object? energyError = freezed,Object? sleepError = freezed,Object? sorenessError = freezed,Object? stressError = freezed,Object? painError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(_CheckinFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as int?,soreness: freezed == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int?,stress: freezed == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int?,pain: freezed == pain ? _self.pain : pain // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,otherSymptom: freezed == otherSymptom ? _self.otherSymptom : otherSymptom // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,energyError: freezed == energyError ? _self.energyError : energyError // ignore: cast_nullable_to_non_nullable
as String?,sleepError: freezed == sleepError ? _self.sleepError : sleepError // ignore: cast_nullable_to_non_nullable
as String?,sorenessError: freezed == sorenessError ? _self.sorenessError : sorenessError // ignore: cast_nullable_to_non_nullable
as String?,stressError: freezed == stressError ? _self.stressError : stressError // ignore: cast_nullable_to_non_nullable
as String?,painError: freezed == painError ? _self.painError : painError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
