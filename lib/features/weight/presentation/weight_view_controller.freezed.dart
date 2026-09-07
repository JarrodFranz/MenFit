// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_view_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeightViewState {

 WeightRange get range; WeightSeriesMode get seriesMode;
/// Create a copy of WeightViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightViewStateCopyWith<WeightViewState> get copyWith => _$WeightViewStateCopyWithImpl<WeightViewState>(this as WeightViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightViewState&&(identical(other.range, range) || other.range == range)&&(identical(other.seriesMode, seriesMode) || other.seriesMode == seriesMode));
}


@override
int get hashCode => Object.hash(runtimeType,range,seriesMode);

@override
String toString() {
  return 'WeightViewState(range: $range, seriesMode: $seriesMode)';
}


}

/// @nodoc
abstract mixin class $WeightViewStateCopyWith<$Res>  {
  factory $WeightViewStateCopyWith(WeightViewState value, $Res Function(WeightViewState) _then) = _$WeightViewStateCopyWithImpl;
@useResult
$Res call({
 WeightRange range, WeightSeriesMode seriesMode
});




}
/// @nodoc
class _$WeightViewStateCopyWithImpl<$Res>
    implements $WeightViewStateCopyWith<$Res> {
  _$WeightViewStateCopyWithImpl(this._self, this._then);

  final WeightViewState _self;
  final $Res Function(WeightViewState) _then;

/// Create a copy of WeightViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? seriesMode = null,}) {
  return _then(WeightViewState(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as WeightRange,seriesMode: null == seriesMode ? _self.seriesMode : seriesMode // ignore: cast_nullable_to_non_nullable
as WeightSeriesMode,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightViewState].
extension WeightViewStatePatterns on WeightViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightViewState value)  $default,){
final _that = this;
switch (_that) {
case _WeightViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightViewState value)?  $default,){
final _that = this;
switch (_that) {
case _WeightViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WeightRange range,  WeightSeriesMode seriesMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightViewState() when $default != null:
return $default(_that.range,_that.seriesMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WeightRange range,  WeightSeriesMode seriesMode)  $default,) {final _that = this;
switch (_that) {
case _WeightViewState():
return $default(_that.range,_that.seriesMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WeightRange range,  WeightSeriesMode seriesMode)?  $default,) {final _that = this;
switch (_that) {
case _WeightViewState() when $default != null:
return $default(_that.range,_that.seriesMode);case _:
  return null;

}
}

}

/// @nodoc


class _WeightViewState extends WeightViewState {
  const _WeightViewState({this.range = WeightRange.threeMonths, this.seriesMode = WeightSeriesMode.readingsAndTrend}): super._();
  

@override@JsonKey() final  WeightRange range;
@override@JsonKey() final  WeightSeriesMode seriesMode;

/// Create a copy of WeightViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightViewStateCopyWith<_WeightViewState> get copyWith => __$WeightViewStateCopyWithImpl<_WeightViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightViewState&&(identical(other.range, range) || other.range == range)&&(identical(other.seriesMode, seriesMode) || other.seriesMode == seriesMode));
}


@override
int get hashCode => Object.hash(runtimeType,range,seriesMode);

@override
String toString() {
  return 'WeightViewState(range: $range, seriesMode: $seriesMode)';
}


}

/// @nodoc
abstract mixin class _$WeightViewStateCopyWith<$Res> implements $WeightViewStateCopyWith<$Res> {
  factory _$WeightViewStateCopyWith(_WeightViewState value, $Res Function(_WeightViewState) _then) = __$WeightViewStateCopyWithImpl;
@override @useResult
$Res call({
 WeightRange range, WeightSeriesMode seriesMode
});




}
/// @nodoc
class __$WeightViewStateCopyWithImpl<$Res>
    implements _$WeightViewStateCopyWith<$Res> {
  __$WeightViewStateCopyWithImpl(this._self, this._then);

  final _WeightViewState _self;
  final $Res Function(_WeightViewState) _then;

/// Create a copy of WeightViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? seriesMode = null,}) {
  return _then(_WeightViewState(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as WeightRange,seriesMode: null == seriesMode ? _self.seriesMode : seriesMode // ignore: cast_nullable_to_non_nullable
as WeightSeriesMode,
  ));
}


}

// dart format on
