// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_entry_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LogEntryFormState {

 LocalDate get day; MealType get meal; NutritionFacts get perServing; String get displayName; String? get servingDescription;/// The food's grams per serving — the entry's snapshot when editing.
/// `null` means weight units are unavailable here, which [availableUnits]
/// turns into a one-entry picker.
 double? get servingGrams;/// The food's millilitres per serving — the entry's snapshot when editing.
/// `null` when volume units are not configured.
 double? get servingVolumeMl;/// `null` once the field has been cleared or typed into with something
/// that isn't a number — [validateNutritionEntry] turns that into the
/// "add a number" message rather than this guessing one.
 double? get amount; QuantityUnit get unit; String? get quantityError; String? get dayError; bool get isSubmitting; String? get submitError;/// Flips to `true` once [LogEntryController.save] persists — same
/// convention as `CheckinFormState.didSave`.
 bool get didSave; bool get didDelete;
/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogEntryFormStateCopyWith<LogEntryFormState> get copyWith => _$LogEntryFormStateCopyWithImpl<LogEntryFormState>(this as LogEntryFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogEntryFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.meal, meal) || other.meal == meal)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantityError, quantityError) || other.quantityError == quantityError)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave)&&(identical(other.didDelete, didDelete) || other.didDelete == didDelete));
}


@override
int get hashCode => Object.hash(runtimeType,day,meal,perServing,displayName,servingDescription,servingGrams,servingVolumeMl,amount,unit,quantityError,dayError,isSubmitting,submitError,didSave,didDelete);

@override
String toString() {
  return 'LogEntryFormState(day: $day, meal: $meal, perServing: $perServing, displayName: $displayName, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, amount: $amount, unit: $unit, quantityError: $quantityError, dayError: $dayError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave, didDelete: $didDelete)';
}


}

/// @nodoc
abstract mixin class $LogEntryFormStateCopyWith<$Res>  {
  factory $LogEntryFormStateCopyWith(LogEntryFormState value, $Res Function(LogEntryFormState) _then) = _$LogEntryFormStateCopyWithImpl;
@useResult
$Res call({
 LocalDate day, MealType meal, NutritionFacts perServing, String displayName, String? servingDescription, double? servingGrams, double? servingVolumeMl, double? amount, QuantityUnit unit, String? quantityError, String? dayError, bool isSubmitting, String? submitError, bool didSave, bool didDelete
});


$NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class _$LogEntryFormStateCopyWithImpl<$Res>
    implements $LogEntryFormStateCopyWith<$Res> {
  _$LogEntryFormStateCopyWithImpl(this._self, this._then);

  final LogEntryFormState _self;
  final $Res Function(LogEntryFormState) _then;

/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? meal = null,Object? perServing = null,Object? displayName = null,Object? servingDescription = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? amount = freezed,Object? unit = null,Object? quantityError = freezed,Object? dayError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,Object? didDelete = null,}) {
  return _then(LogEntryFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,meal: null == meal ? _self.meal : meal // ignore: cast_nullable_to_non_nullable
as MealType,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,quantityError: freezed == quantityError ? _self.quantityError : quantityError // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,didDelete: null == didDelete ? _self.didDelete : didDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}


/// Adds pattern-matching-related methods to [LogEntryFormState].
extension LogEntryFormStatePatterns on LogEntryFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogEntryFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogEntryFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogEntryFormState value)  $default,){
final _that = this;
switch (_that) {
case _LogEntryFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogEntryFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LogEntryFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate day,  MealType meal,  NutritionFacts perServing,  String displayName,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? amount,  QuantityUnit unit,  String? quantityError,  String? dayError,  bool isSubmitting,  String? submitError,  bool didSave,  bool didDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogEntryFormState() when $default != null:
return $default(_that.day,_that.meal,_that.perServing,_that.displayName,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.amount,_that.unit,_that.quantityError,_that.dayError,_that.isSubmitting,_that.submitError,_that.didSave,_that.didDelete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate day,  MealType meal,  NutritionFacts perServing,  String displayName,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? amount,  QuantityUnit unit,  String? quantityError,  String? dayError,  bool isSubmitting,  String? submitError,  bool didSave,  bool didDelete)  $default,) {final _that = this;
switch (_that) {
case _LogEntryFormState():
return $default(_that.day,_that.meal,_that.perServing,_that.displayName,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.amount,_that.unit,_that.quantityError,_that.dayError,_that.isSubmitting,_that.submitError,_that.didSave,_that.didDelete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate day,  MealType meal,  NutritionFacts perServing,  String displayName,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? amount,  QuantityUnit unit,  String? quantityError,  String? dayError,  bool isSubmitting,  String? submitError,  bool didSave,  bool didDelete)?  $default,) {final _that = this;
switch (_that) {
case _LogEntryFormState() when $default != null:
return $default(_that.day,_that.meal,_that.perServing,_that.displayName,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.amount,_that.unit,_that.quantityError,_that.dayError,_that.isSubmitting,_that.submitError,_that.didSave,_that.didDelete);case _:
  return null;

}
}

}

/// @nodoc


class _LogEntryFormState extends LogEntryFormState {
  const _LogEntryFormState({required this.day, required this.meal, required this.perServing, required this.displayName, this.servingDescription, this.servingGrams, this.servingVolumeMl, this.amount = 1, this.unit = QuantityUnit.serving, this.quantityError, this.dayError, this.isSubmitting = false, this.submitError, this.didSave = false, this.didDelete = false}): super._();
  

@override final  LocalDate day;
@override final  MealType meal;
@override final  NutritionFacts perServing;
@override final  String displayName;
@override final  String? servingDescription;
/// The food's grams per serving — the entry's snapshot when editing.
/// `null` means weight units are unavailable here, which [availableUnits]
/// turns into a one-entry picker.
@override final  double? servingGrams;
/// The food's millilitres per serving — the entry's snapshot when editing.
/// `null` when volume units are not configured.
@override final  double? servingVolumeMl;
/// `null` once the field has been cleared or typed into with something
/// that isn't a number — [validateNutritionEntry] turns that into the
/// "add a number" message rather than this guessing one.
@override@JsonKey() final  double? amount;
@override@JsonKey() final  QuantityUnit unit;
@override final  String? quantityError;
@override final  String? dayError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;
/// Flips to `true` once [LogEntryController.save] persists — same
/// convention as `CheckinFormState.didSave`.
@override@JsonKey() final  bool didSave;
@override@JsonKey() final  bool didDelete;

/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogEntryFormStateCopyWith<_LogEntryFormState> get copyWith => __$LogEntryFormStateCopyWithImpl<_LogEntryFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogEntryFormState&&(identical(other.day, day) || other.day == day)&&(identical(other.meal, meal) || other.meal == meal)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantityError, quantityError) || other.quantityError == quantityError)&&(identical(other.dayError, dayError) || other.dayError == dayError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave)&&(identical(other.didDelete, didDelete) || other.didDelete == didDelete));
}


@override
int get hashCode => Object.hash(runtimeType,day,meal,perServing,displayName,servingDescription,servingGrams,servingVolumeMl,amount,unit,quantityError,dayError,isSubmitting,submitError,didSave,didDelete);

@override
String toString() {
  return 'LogEntryFormState(day: $day, meal: $meal, perServing: $perServing, displayName: $displayName, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, amount: $amount, unit: $unit, quantityError: $quantityError, dayError: $dayError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave, didDelete: $didDelete)';
}


}

/// @nodoc
abstract mixin class _$LogEntryFormStateCopyWith<$Res> implements $LogEntryFormStateCopyWith<$Res> {
  factory _$LogEntryFormStateCopyWith(_LogEntryFormState value, $Res Function(_LogEntryFormState) _then) = __$LogEntryFormStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate day, MealType meal, NutritionFacts perServing, String displayName, String? servingDescription, double? servingGrams, double? servingVolumeMl, double? amount, QuantityUnit unit, String? quantityError, String? dayError, bool isSubmitting, String? submitError, bool didSave, bool didDelete
});


@override $NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class __$LogEntryFormStateCopyWithImpl<$Res>
    implements _$LogEntryFormStateCopyWith<$Res> {
  __$LogEntryFormStateCopyWithImpl(this._self, this._then);

  final _LogEntryFormState _self;
  final $Res Function(_LogEntryFormState) _then;

/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? meal = null,Object? perServing = null,Object? displayName = null,Object? servingDescription = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? amount = freezed,Object? unit = null,Object? quantityError = freezed,Object? dayError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,Object? didDelete = null,}) {
  return _then(_LogEntryFormState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,meal: null == meal ? _self.meal : meal // ignore: cast_nullable_to_non_nullable
as MealType,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,quantityError: freezed == quantityError ? _self.quantityError : quantityError // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,didDelete: null == didDelete ? _self.didDelete : didDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LogEntryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}

// dart format on
