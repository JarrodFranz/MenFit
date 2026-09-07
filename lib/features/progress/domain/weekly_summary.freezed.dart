// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeeklySummary {

/// The Monday that starts this week (see [mondayOf]).
 LocalDate get weekStart; double get distanceMeters; Duration get movingTime; int get activityCount;
/// Create a copy of WeeklySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklySummaryCopyWith<WeeklySummary> get copyWith => _$WeeklySummaryCopyWithImpl<WeeklySummary>(this as WeeklySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklySummary&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.activityCount, activityCount) || other.activityCount == activityCount));
}


@override
int get hashCode => Object.hash(runtimeType,weekStart,distanceMeters,movingTime,activityCount);

@override
String toString() {
  return 'WeeklySummary(weekStart: $weekStart, distanceMeters: $distanceMeters, movingTime: $movingTime, activityCount: $activityCount)';
}


}

/// @nodoc
abstract mixin class $WeeklySummaryCopyWith<$Res>  {
  factory $WeeklySummaryCopyWith(WeeklySummary value, $Res Function(WeeklySummary) _then) = _$WeeklySummaryCopyWithImpl;
@useResult
$Res call({
 LocalDate weekStart, double distanceMeters, Duration movingTime, int activityCount
});




}
/// @nodoc
class _$WeeklySummaryCopyWithImpl<$Res>
    implements $WeeklySummaryCopyWith<$Res> {
  _$WeeklySummaryCopyWithImpl(this._self, this._then);

  final WeeklySummary _self;
  final $Res Function(WeeklySummary) _then;

/// Create a copy of WeeklySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekStart = null,Object? distanceMeters = null,Object? movingTime = null,Object? activityCount = null,}) {
  return _then(WeeklySummary(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as LocalDate,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,activityCount: null == activityCount ? _self.activityCount : activityCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklySummary].
extension WeeklySummaryPatterns on WeeklySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklySummary value)  $default,){
final _that = this;
switch (_that) {
case _WeeklySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklySummary value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate weekStart,  double distanceMeters,  Duration movingTime,  int activityCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklySummary() when $default != null:
return $default(_that.weekStart,_that.distanceMeters,_that.movingTime,_that.activityCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate weekStart,  double distanceMeters,  Duration movingTime,  int activityCount)  $default,) {final _that = this;
switch (_that) {
case _WeeklySummary():
return $default(_that.weekStart,_that.distanceMeters,_that.movingTime,_that.activityCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate weekStart,  double distanceMeters,  Duration movingTime,  int activityCount)?  $default,) {final _that = this;
switch (_that) {
case _WeeklySummary() when $default != null:
return $default(_that.weekStart,_that.distanceMeters,_that.movingTime,_that.activityCount);case _:
  return null;

}
}

}

/// @nodoc


class _WeeklySummary implements WeeklySummary {
  const _WeeklySummary({required this.weekStart, required this.distanceMeters, required this.movingTime, required this.activityCount});
  

/// The Monday that starts this week (see [mondayOf]).
@override final  LocalDate weekStart;
@override final  double distanceMeters;
@override final  Duration movingTime;
@override final  int activityCount;

/// Create a copy of WeeklySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklySummaryCopyWith<_WeeklySummary> get copyWith => __$WeeklySummaryCopyWithImpl<_WeeklySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklySummary&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.movingTime, movingTime) || other.movingTime == movingTime)&&(identical(other.activityCount, activityCount) || other.activityCount == activityCount));
}


@override
int get hashCode => Object.hash(runtimeType,weekStart,distanceMeters,movingTime,activityCount);

@override
String toString() {
  return 'WeeklySummary(weekStart: $weekStart, distanceMeters: $distanceMeters, movingTime: $movingTime, activityCount: $activityCount)';
}


}

/// @nodoc
abstract mixin class _$WeeklySummaryCopyWith<$Res> implements $WeeklySummaryCopyWith<$Res> {
  factory _$WeeklySummaryCopyWith(_WeeklySummary value, $Res Function(_WeeklySummary) _then) = __$WeeklySummaryCopyWithImpl;
@override @useResult
$Res call({
 LocalDate weekStart, double distanceMeters, Duration movingTime, int activityCount
});




}
/// @nodoc
class __$WeeklySummaryCopyWithImpl<$Res>
    implements _$WeeklySummaryCopyWith<$Res> {
  __$WeeklySummaryCopyWithImpl(this._self, this._then);

  final _WeeklySummary _self;
  final $Res Function(_WeeklySummary) _then;

/// Create a copy of WeeklySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekStart = null,Object? distanceMeters = null,Object? movingTime = null,Object? activityCount = null,}) {
  return _then(_WeeklySummary(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as LocalDate,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,movingTime: null == movingTime ? _self.movingTime : movingTime // ignore: cast_nullable_to_non_nullable
as Duration,activityCount: null == activityCount ? _self.activityCount : activityCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
