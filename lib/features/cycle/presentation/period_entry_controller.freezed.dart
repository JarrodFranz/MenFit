// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_entry_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodEntryState {

 LocalDate get periodStart; LocalDate? get periodEnd; String? get startError; String? get endError; bool get isSubmitting; String? get submitError;/// Flips to `true` once [PeriodEntryController.save] persists
/// successfully - the dialog listens for this to close itself, exactly
/// once, instead of the controller closing it directly (same
/// convention as `ManualEntryState.didSave`).
 bool get didSave;
/// Create a copy of PeriodEntryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodEntryStateCopyWith<PeriodEntryState> get copyWith => _$PeriodEntryStateCopyWithImpl<PeriodEntryState>(this as PeriodEntryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodEntryState&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.startError, startError) || other.startError == startError)&&(identical(other.endError, endError) || other.endError == endError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,startError,endError,isSubmitting,submitError,didSave);

@override
String toString() {
  return 'PeriodEntryState(periodStart: $periodStart, periodEnd: $periodEnd, startError: $startError, endError: $endError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class $PeriodEntryStateCopyWith<$Res>  {
  factory $PeriodEntryStateCopyWith(PeriodEntryState value, $Res Function(PeriodEntryState) _then) = _$PeriodEntryStateCopyWithImpl;
@useResult
$Res call({
 LocalDate periodStart, LocalDate? periodEnd, String? startError, String? endError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class _$PeriodEntryStateCopyWithImpl<$Res>
    implements $PeriodEntryStateCopyWith<$Res> {
  _$PeriodEntryStateCopyWithImpl(this._self, this._then);

  final PeriodEntryState _self;
  final $Res Function(PeriodEntryState) _then;

/// Create a copy of PeriodEntryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? periodEnd = freezed,Object? startError = freezed,Object? endError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(PeriodEntryState(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as LocalDate,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as LocalDate?,startError: freezed == startError ? _self.startError : startError // ignore: cast_nullable_to_non_nullable
as String?,endError: freezed == endError ? _self.endError : endError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodEntryState].
extension PeriodEntryStatePatterns on PeriodEntryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodEntryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodEntryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodEntryState value)  $default,){
final _that = this;
switch (_that) {
case _PeriodEntryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodEntryState value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodEntryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate periodStart,  LocalDate? periodEnd,  String? startError,  String? endError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodEntryState() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.startError,_that.endError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate periodStart,  LocalDate? periodEnd,  String? startError,  String? endError,  bool isSubmitting,  String? submitError,  bool didSave)  $default,) {final _that = this;
switch (_that) {
case _PeriodEntryState():
return $default(_that.periodStart,_that.periodEnd,_that.startError,_that.endError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate periodStart,  LocalDate? periodEnd,  String? startError,  String? endError,  bool isSubmitting,  String? submitError,  bool didSave)?  $default,) {final _that = this;
switch (_that) {
case _PeriodEntryState() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.startError,_that.endError,_that.isSubmitting,_that.submitError,_that.didSave);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodEntryState implements PeriodEntryState {
  const _PeriodEntryState({required this.periodStart, this.periodEnd, this.startError, this.endError, this.isSubmitting = false, this.submitError, this.didSave = false});
  

@override final  LocalDate periodStart;
@override final  LocalDate? periodEnd;
@override final  String? startError;
@override final  String? endError;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;
/// Flips to `true` once [PeriodEntryController.save] persists
/// successfully - the dialog listens for this to close itself, exactly
/// once, instead of the controller closing it directly (same
/// convention as `ManualEntryState.didSave`).
@override@JsonKey() final  bool didSave;

/// Create a copy of PeriodEntryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodEntryStateCopyWith<_PeriodEntryState> get copyWith => __$PeriodEntryStateCopyWithImpl<_PeriodEntryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodEntryState&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.startError, startError) || other.startError == startError)&&(identical(other.endError, endError) || other.endError == endError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.didSave, didSave) || other.didSave == didSave));
}


@override
int get hashCode => Object.hash(runtimeType,periodStart,periodEnd,startError,endError,isSubmitting,submitError,didSave);

@override
String toString() {
  return 'PeriodEntryState(periodStart: $periodStart, periodEnd: $periodEnd, startError: $startError, endError: $endError, isSubmitting: $isSubmitting, submitError: $submitError, didSave: $didSave)';
}


}

/// @nodoc
abstract mixin class _$PeriodEntryStateCopyWith<$Res> implements $PeriodEntryStateCopyWith<$Res> {
  factory _$PeriodEntryStateCopyWith(_PeriodEntryState value, $Res Function(_PeriodEntryState) _then) = __$PeriodEntryStateCopyWithImpl;
@override @useResult
$Res call({
 LocalDate periodStart, LocalDate? periodEnd, String? startError, String? endError, bool isSubmitting, String? submitError, bool didSave
});




}
/// @nodoc
class __$PeriodEntryStateCopyWithImpl<$Res>
    implements _$PeriodEntryStateCopyWith<$Res> {
  __$PeriodEntryStateCopyWithImpl(this._self, this._then);

  final _PeriodEntryState _self;
  final $Res Function(_PeriodEntryState) _then;

/// Create a copy of PeriodEntryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? periodEnd = freezed,Object? startError = freezed,Object? endError = freezed,Object? isSubmitting = null,Object? submitError = freezed,Object? didSave = null,}) {
  return _then(_PeriodEntryState(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as LocalDate,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as LocalDate?,startError: freezed == startError ? _self.startError : startError // ignore: cast_nullable_to_non_nullable
as String?,endError: freezed == endError ? _self.endError : endError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,didSave: null == didSave ? _self.didSave : didSave // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
