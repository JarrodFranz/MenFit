// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'steps_view_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StepsViewState {

 ProgressPeriod get period; LocalDate get anchor;
/// Create a copy of StepsViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepsViewStateCopyWith<StepsViewState> get copyWith => _$StepsViewStateCopyWithImpl<StepsViewState>(this as StepsViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepsViewState&&(identical(other.period, period) || other.period == period)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,period,anchor);

@override
String toString() {
  return 'StepsViewState(period: $period, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class $StepsViewStateCopyWith<$Res>  {
  factory $StepsViewStateCopyWith(StepsViewState value, $Res Function(StepsViewState) _then) = _$StepsViewStateCopyWithImpl;
@useResult
$Res call({
 ProgressPeriod period, LocalDate anchor
});




}
/// @nodoc
class _$StepsViewStateCopyWithImpl<$Res>
    implements $StepsViewStateCopyWith<$Res> {
  _$StepsViewStateCopyWithImpl(this._self, this._then);

  final StepsViewState _self;
  final $Res Function(StepsViewState) _then;

/// Create a copy of StepsViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? anchor = null,}) {
  return _then(StepsViewState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProgressPeriod,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [StepsViewState].
extension StepsViewStatePatterns on StepsViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StepsViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StepsViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StepsViewState value)  $default,){
final _that = this;
switch (_that) {
case _StepsViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StepsViewState value)?  $default,){
final _that = this;
switch (_that) {
case _StepsViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProgressPeriod period,  LocalDate anchor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StepsViewState() when $default != null:
return $default(_that.period,_that.anchor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProgressPeriod period,  LocalDate anchor)  $default,) {final _that = this;
switch (_that) {
case _StepsViewState():
return $default(_that.period,_that.anchor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProgressPeriod period,  LocalDate anchor)?  $default,) {final _that = this;
switch (_that) {
case _StepsViewState() when $default != null:
return $default(_that.period,_that.anchor);case _:
  return null;

}
}

}

/// @nodoc


class _StepsViewState implements StepsViewState {
  const _StepsViewState({required this.period, required this.anchor});
  

@override final  ProgressPeriod period;
@override final  LocalDate anchor;

/// Create a copy of StepsViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepsViewStateCopyWith<_StepsViewState> get copyWith => __$StepsViewStateCopyWithImpl<_StepsViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepsViewState&&(identical(other.period, period) || other.period == period)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,period,anchor);

@override
String toString() {
  return 'StepsViewState(period: $period, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class _$StepsViewStateCopyWith<$Res> implements $StepsViewStateCopyWith<$Res> {
  factory _$StepsViewStateCopyWith(_StepsViewState value, $Res Function(_StepsViewState) _then) = __$StepsViewStateCopyWithImpl;
@override @useResult
$Res call({
 ProgressPeriod period, LocalDate anchor
});




}
/// @nodoc
class __$StepsViewStateCopyWithImpl<$Res>
    implements _$StepsViewStateCopyWith<$Res> {
  __$StepsViewStateCopyWithImpl(this._self, this._then);

  final _StepsViewState _self;
  final $Res Function(_StepsViewState) _then;

/// Create a copy of StepsViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? anchor = null,}) {
  return _then(_StepsViewState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProgressPeriod,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}

// dart format on
