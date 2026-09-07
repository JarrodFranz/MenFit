// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flare_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlareFormState {

 LocalDate get day; FlareSeverity? get severity; FlareImpact? get impact; List<SymptomType> get symptoms; String? get otherSymptom; FlareCategory? get category; String? get notes;/// Whether the form is in "Date range" mode. [endDay] is only read
/// when this is `true` — a flare saved in "Single day" mode always
/// persists a null `endDay`, so switching to range and back leaves a
/// single-day flare single-day. Keeping the last-picked [endDay]
/// around while single-day is selected is what lets the user toggle
/// back and forth without re-picking it.
 bool get isRange; LocalDate? get endDay; String? get dayError; String? get endDayError; String? get severityError; String? get impactError;/// The "also mark these as recovery days" tick box, or `null` while
/// the user hasn't touched it — in which case the box shows
/// [FlareController.rangeFullyMarked] for the range as it stands.
/// Modelling "untouched" explicitly (rather than seeding a bool at
/// build time) keeps the default correct as the range changes, without
/// this controller needing to watch the recovery-day stream.
 bool? get markAsRecovery; bool get isSubmitting; String? get submitError;/// Set when the flare itself saved but updating recovery days failed —
/// see [FlareController.save]. Distinct from [submitError] because the
/// flare is *not* rolled back in that case and the copy must say so.
 String? get recoveryError;/// Flips to `true` once [FlareController.save] persists successfully —
/// same convention as `CheckinFormState.didSave`.
 bool get didSave;/// Flips to `true` once [FlareController.delete] succeeds.
 bool get didDelete;
/// Create a copy of FlareFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlareFormStateCopyWith<FlareFormState> get copyWith => _$FlareFormStateCopyWithImpl<FlareFormState>(this as FlareFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlareFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.impact, impact) || other.impact == impact)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&(identical(other.otherSymptom, otherSymptom) || other.otherSymptom == otherSymptom)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isRange, isRange) || other.isRange == isRange)&&(identical(other.endDay, endDay) || other.endDay == endDay)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.endDayError, endDayError) || other.endDayError == endDayError)&&(identical(other.severityError, severityError) || other.severityError == severityError)&&(identical(other.impactError, impactError) || other.impactError == impactError)&&(identical(other.markAsRecovery, markAsRecovery) || other.markAsRecovery == markAsRecovery)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.recoveryError, recoveryError) || other.recoveryError == recoveryError)&&(identical(other.didSave, didSave) || other.didSave == didSave)&&(identical(other.didDelete, didDelete) || other.didDelete == didDelete));
}


@override
int get hashCode => Object.hashAll([runtimeType,day,severity,impact,const DeepCollectionEquality().hash(symptoms),otherSymptom,category,notes,isRange,endDay,dayError,endDayError,severityError,impactError,markAsRecovery,isSubmitting,submitError,recoveryError,didSave,didDelete]);

@override
String toString() {
  return 'FlareFormState(day: $day, severity: $severity, impact: $impact, symptoms: $symptoms, otherSymptom: $otherSymptom, category: $category, notes: $notes, isRange: $isRange, endDay: $endDay, dayError: $dayError, endDayError: $endDayError, severityError: $severityError, impactError: $impactError, markAsRecovery: $markAsRecovery, isSubmitting: $isSubmitting, submitError: $submitError, recoveryError: $recoveryError, didSave: $didSave, didDelete: $didDelete)';
}


}

/// @nodoc
abstract mixin class $FlareFormStateCopyWith<$Res>  {
  factory $FlareFormStateCopyWith(FlareFormState value, $Res Function(FlareFormState) _then) = _$FlareFormStateCopyWithImpl;
@useResult
$Res call({
 LocalDate day, FlareSeverity? severity, FlareImpact? impact, List<SymptomType> symptoms, String? otherSymptom, FlareCategory? category, String? notes, bool isRange, LocalDate? endDay, String? dayError, String? endDayError, String? severityError, String? impactError, bool? markAsRecovery, bool isSubmitting, String? submitError, String? recoveryError, bool didSave, bool didDelete
});




}
/// @nodoc
class _$FlareFormStateCopyWithImpl<$Res>
    implements $FlareFormStateCopyWith<$Res> {
  _$FlareFormStateCopyWithImpl(this._self, this._then);

  final FlareFormState _self;
  final $Res Function(FlareFormState) _then;

/// Create a copy of FlareFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? severity = freezed,Object? impact = freezed,Object? symptoms = null,Object? otherSymptom = freezed,Object? category = freezed,Object? notes = freezed,Object? isRange = null,Object? endDay = freezed,Object? dayError = freezed,Object? endDayError = freezed,Object? severityError = freezed,Object? impactError = freezed,Object? markAsRecovery = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? recoveryError = freezed,Object? didSave = null,Object? didDelete = null,}) {
  return _then(FlareFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FlareSeverity?,impact: freezed == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as FlareImpact?,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,otherSymptom: freezed == otherSymptom ? _self.otherSymptom : otherSymptom // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FlareCategory?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isRange: null == isRange ? _self.isRange : isRange // ignore: cast_nullable_to_non_nullable
as bool,endDay: freezed == endDay ? _self.endDay : endDay // ignore: cast_nullable_to_non_nullable
as LocalDate?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,endDayError: freezed == endDayError ? _self.endDayError : endDayError // ignore: cast_nullable_to_non_nullable
as String?,severityError: freezed == severityError ? _self.severityError : severityError // ignore: cast_nullable_to_non_nullable
as String?,impactError: freezed == impactError ? _self.impactError : impactError // ignore: cast_nullable_to_non_nullable
as String?,markAsRecovery: freezed == markAsRecovery ? _self.markAsRecovery : markAsRecovery // ignore: cast_nullable_to_non_nullable
as bool?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,recoveryError: freezed == recoveryError ? _self.recoveryError : recoveryError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,didDelete: null == didDelete ? _self.didDelete : didDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FlareFormState].
extension FlareFormStatePatterns on FlareFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlareFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlareFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlareFormState value)  $default,){
final _that = this;
switch (_that) {
case _FlareFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlareFormState value)?  $default,){
final _that = this;
switch (_that) {
case _FlareFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate day,  FlareSeverity? severity,  FlareImpact? impact,  List<SymptomType> symptoms,  String? otherSymptom,  FlareCategory? category,  String? notes,  bool isRange,  LocalDate? endDay,  String? dayError,  String? endDayError,  String? severityError,  String? impactError,  bool? markAsRecovery,  bool isSubmitting,  String? submitError,  String? recoveryError,  bool didSave,  bool didDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlareFormState() when $default != null:
return $default(_that.day,_that.severity,_that.impact,_that.symptoms,_that.otherSymptom,_that.category,_that.notes,_that.isRange,_that.endDay,_that.dayError,_that.endDayError,_that.severityError,_that.impactError,_that.markAsRecovery,_that.isSubmitting,_that.submitError,_that.recoveryError,_that.didSave,_that.didDelete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate day,  FlareSeverity? severity,  FlareImpact? impact,  List<SymptomType> symptoms,  String? otherSymptom,  FlareCategory? category,  String? notes,  bool isRange,  LocalDate? endDay,  String? dayError,  String? endDayError,  String? severityError,  String? impactError,  bool? markAsRecovery,  bool isSubmitting,  String? submitError,  String? recoveryError,  bool didSave,  bool didDelete)  $default,) {final _that = this;
switch (_that) {
case _FlareFormState():
return $default(_that.day,_that.severity,_that.impact,_that.symptoms,_that.otherSymptom,_that.category,_that.notes,_that.isRange,_that.endDay,_that.dayError,_that.endDayError,_that.severityError,_that.impactError,_that.markAsRecovery,_that.isSubmitting,_that.submitError,_that.recoveryError,_that.didSave,_that.didDelete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate day,  FlareSeverity? severity,  FlareImpact? impact,  List<SymptomType> symptoms,  String? otherSymptom,  FlareCategory? category,  String? notes,  bool isRange,  LocalDate? endDay,  String? dayError,  String? endDayError,  String? severityError,  String? impactError,  bool? markAsRecovery,  bool isSubmitting,  String? submitError,  String? recoveryError,  bool didSave,  bool didDelete)?  $default,) {final _that = this;
switch (_that) {
case _FlareFormState() when $default != null:
return $default(_that.day,_that.severity,_that.impact,_that.symptoms,_that.otherSymptom,_that.category,_that.notes,_that.isRange,_that.endDay,_that.dayError,_that.endDayError,_that.severityError,_that.impactError,_that.markAsRecovery,_that.isSubmitting,_that.submitError,_that.recoveryError,_that.didSave,_that.didDelete);case _:
  return null;

}
}

}

/// @nodoc


class _FlareFormState implements FlareFormState {
  const _FlareFormState({required this.day, this.severity, this.impact,  List<SymptomType> symptoms = const <SymptomType>[], this.otherSymptom, this.category, this.notes, this.isRange = false, this.endDay, this.dayError, this.endDayError, this.severityError, this.impactError, this.markAsRecovery, this.isSubmitting = false, this.submitError, this.recoveryError, this.didSave = false, this.didDelete = false}): _symptoms = symptoms;
  

@override final  LocalDate day;
@override final  FlareSeverity? severity;
@override final  FlareImpact? impact;
 final  List<SymptomType> _symptoms;
@override@JsonKey() List<SymptomType> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

@override final  String? otherSymptom;
@override final  FlareCategory? category;
@override final  String? notes;
/// Whether the form is in "Date range" mode. [endDay] is only read
/// when this is `true` — a flare saved in "Single day" mode always
/// persists a null `endDay`, so switching to range and back leaves a
/// single-day flare single-day. Keeping the last-picked [endDay]
/// around while single-day is selected is what lets the user toggle
/// back and forth without re-picking it.
@override@JsonKey() final  bool isRange;
@override final  LocalDate? endDay;
@override final  String? dayError;
@override final  String? endDayError;
@override final  String? severityError;
@override final  String? impactError;
/// The "also mark these as recovery days" tick box, or `null` while
/// the user hasn't touched it — in which case the box shows
/// [FlareController.rangeFullyMarked] for the range as it stands.
/// Modelling "untouched" explicitly (rather than seeding a bool at
/// build time) keeps the default correct as the range changes, without
/// this controller needing to watch the recovery-day stream.
@override final  bool? markAsRecovery;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;
/// Set when the flare itself saved but updating recovery days failed —
/// see [FlareController.save]. Distinct from [submitError] because the
/// flare is *not* rolled back in that case and the copy must say so.
@override final  String? recoveryError;
/// Flips to `true` once [FlareController.save] persists successfully —
/// same convention as `CheckinFormState.didSave`.
@override@JsonKey() final  bool didSave;
/// Flips to `true` once [FlareController.delete] succeeds.
@override@JsonKey() final  bool didDelete;

/// Create a copy of FlareFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlareFormStateCopyWith<_FlareFormState> get copyWith => __$FlareFormStateCopyWithImpl<_FlareFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlareFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.impact, impact) || other.impact == impact)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&(identical(other.otherSymptom, otherSymptom) || other.otherSymptom == otherSymptom)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isRange, isRange) || other.isRange == isRange)&&(identical(other.endDay, endDay) || other.endDay == endDay)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.endDayError, endDayError) || other.endDayError == endDayError)&&(identical(other.severityError, severityError) || other.severityError == severityError)&&(identical(other.impactError, impactError) || other.impactError == impactError)&&(identical(other.markAsRecovery, markAsRecovery) || other.markAsRecovery == markAsRecovery)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.recoveryError, recoveryError) || other.recoveryError == recoveryError)&&(identical(other.didSave, didSave) || other.didSave == didSave)&&(identical(other.didDelete, didDelete) || other.didDelete == didDelete));
}


@override
int get hashCode => Object.hashAll([runtimeType,day,severity,impact,const DeepCollectionEquality().hash(_symptoms),otherSymptom,category,notes,isRange,endDay,dayError,endDayError,severityError,impactError,markAsRecovery,isSubmitting,submitError,recoveryError,didSave,didDelete]);

@override
String toString() {
  return 'FlareFormState(day: $day, severity: $severity, impact: $impact, symptoms: $symptoms, otherSymptom: $otherSymptom, category: $category, notes: $notes, isRange: $isRange, endDay: $endDay, dayError: $dayError, endDayError: $endDayError, severityError: $severityError, impactError: $impactError, markAsRecovery: $markAsRecovery, isSubmitting: $isSubmitting, submitError: $submitError, recoveryError: $recoveryError, didSave: $didSave, didDelete: $didDelete)';
}


}

/// @nodoc
abstract mixin class _$FlareFormStateCopyWith<$Res> implements $FlareFormStateCopyWith<$Res> {
  factory _$FlareFormStateCopyWith(_FlareFormState value, $Res Function(_FlareFormState) _then) = __$FlareFormStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate day, FlareSeverity? severity, FlareImpact? impact, List<SymptomType> symptoms, String? otherSymptom, FlareCategory? category, String? notes, bool isRange, LocalDate? endDay, String? dayError, String? endDayError, String? severityError, String? impactError, bool? markAsRecovery, bool isSubmitting, String? submitError, String? recoveryError, bool didSave, bool didDelete
});




}
/// @nodoc
class __$FlareFormStateCopyWithImpl<$Res>
    implements _$FlareFormStateCopyWith<$Res> {
  __$FlareFormStateCopyWithImpl(this._self, this._then);

  final _FlareFormState _self;
  final $Res Function(_FlareFormState) _then;

/// Create a copy of FlareFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? severity = freezed,Object? impact = freezed,Object? symptoms = null,Object? otherSymptom = freezed,Object? category = freezed,Object? notes = freezed,Object? isRange = null,Object? endDay = freezed,Object? dayError = freezed,Object? endDayError = freezed,Object? severityError = freezed,Object? impactError = freezed,Object? markAsRecovery = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? recoveryError = freezed,Object? didSave = null,Object? didDelete = null,}) {
  return _then(_FlareFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FlareSeverity?,impact: freezed == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as FlareImpact?,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,otherSymptom: freezed == otherSymptom ? _self.otherSymptom : otherSymptom // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FlareCategory?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isRange: null == isRange ? _self.isRange : isRange // ignore: cast_nullable_to_non_nullable
as bool,endDay: freezed == endDay ? _self.endDay : endDay // ignore: cast_nullable_to_non_nullable
as LocalDate?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,endDayError: freezed == endDayError ? _self.endDayError : endDayError // ignore: cast_nullable_to_non_nullable
as String?,severityError: freezed == severityError ? _self.severityError : severityError // ignore: cast_nullable_to_non_nullable
as String?,impactError: freezed == impactError ? _self.impactError : impactError // ignore: cast_nullable_to_non_nullable
as String?,markAsRecovery: freezed == markAsRecovery ? _self.markAsRecovery : markAsRecovery // ignore: cast_nullable_to_non_nullable
as bool?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,recoveryError: freezed == recoveryError ? _self.recoveryError : recoveryError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,didDelete: null == didDelete ? _self.didDelete : didDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
