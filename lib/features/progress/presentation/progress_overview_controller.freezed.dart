// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_overview_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProgressOverviewState {

 ProgressPeriod get period; LocalDate get anchor;
/// Create a copy of ProgressOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressOverviewStateCopyWith<ProgressOverviewState> get copyWith => _$ProgressOverviewStateCopyWithImpl<ProgressOverviewState>(this as ProgressOverviewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressOverviewState&&(identical(other.period, period) || other.period == period)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,period,anchor);

@override
String toString() {
  return 'ProgressOverviewState(period: $period, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class $ProgressOverviewStateCopyWith<$Res>  {
  factory $ProgressOverviewStateCopyWith(ProgressOverviewState value, $Res Function(ProgressOverviewState) _then) = _$ProgressOverviewStateCopyWithImpl;
@useResult
$Res call({
 ProgressPeriod period, LocalDate anchor
});




}
/// @nodoc
class _$ProgressOverviewStateCopyWithImpl<$Res>
    implements $ProgressOverviewStateCopyWith<$Res> {
  _$ProgressOverviewStateCopyWithImpl(this._self, this._then);

  final ProgressOverviewState _self;
  final $Res Function(ProgressOverviewState) _then;

/// Create a copy of ProgressOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? anchor = null,}) {
  return _then(ProgressOverviewState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProgressPeriod,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressOverviewState].
extension ProgressOverviewStatePatterns on ProgressOverviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressOverviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressOverviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressOverviewState value)  $default,){
final _that = this;
switch (_that) {
case _ProgressOverviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressOverviewState value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressOverviewState() when $default != null:
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
case _ProgressOverviewState() when $default != null:
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
case _ProgressOverviewState():
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
case _ProgressOverviewState() when $default != null:
return $default(_that.period,_that.anchor);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressOverviewState implements ProgressOverviewState {
  const _ProgressOverviewState({required this.period, required this.anchor});
  

@override final  ProgressPeriod period;
@override final  LocalDate anchor;

/// Create a copy of ProgressOverviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressOverviewStateCopyWith<_ProgressOverviewState> get copyWith => __$ProgressOverviewStateCopyWithImpl<_ProgressOverviewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressOverviewState&&(identical(other.period, period) || other.period == period)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,period,anchor);

@override
String toString() {
  return 'ProgressOverviewState(period: $period, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class _$ProgressOverviewStateCopyWith<$Res> implements $ProgressOverviewStateCopyWith<$Res> {
  factory _$ProgressOverviewStateCopyWith(_ProgressOverviewState value, $Res Function(_ProgressOverviewState) _then) = __$ProgressOverviewStateCopyWithImpl;
@override @useResult
$Res call({
 ProgressPeriod period, LocalDate anchor
});




}
/// @nodoc
class __$ProgressOverviewStateCopyWithImpl<$Res>
    implements _$ProgressOverviewStateCopyWith<$Res> {
  __$ProgressOverviewStateCopyWithImpl(this._self, this._then);

  final _ProgressOverviewState _self;
  final $Res Function(_ProgressOverviewState) _then;

/// Create a copy of ProgressOverviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? anchor = null,}) {
  return _then(_ProgressOverviewState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProgressPeriod,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}

// dart format on
