// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreakResult {

 int get currentStreak; int get longestStreak; DayStatus get todayStatus; bool get todaySatisfied;
/// Create a copy of StreakResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakResultCopyWith<StreakResult> get copyWith => _$StreakResultCopyWithImpl<StreakResult>(this as StreakResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakResult&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.todayStatus, todayStatus) || other.todayStatus == todayStatus)&&(identical(other.todaySatisfied, todaySatisfied) || other.todaySatisfied == todaySatisfied));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,todayStatus,todaySatisfied);

@override
String toString() {
  return 'StreakResult(currentStreak: $currentStreak, longestStreak: $longestStreak, todayStatus: $todayStatus, todaySatisfied: $todaySatisfied)';
}


}

/// @nodoc
abstract mixin class $StreakResultCopyWith<$Res>  {
  factory $StreakResultCopyWith(StreakResult value, $Res Function(StreakResult) _then) = _$StreakResultCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int longestStreak, DayStatus todayStatus, bool todaySatisfied
});




}
/// @nodoc
class _$StreakResultCopyWithImpl<$Res>
    implements $StreakResultCopyWith<$Res> {
  _$StreakResultCopyWithImpl(this._self, this._then);

  final StreakResult _self;
  final $Res Function(StreakResult) _then;

/// Create a copy of StreakResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? todayStatus = null,Object? todaySatisfied = null,}) {
  return _then(StreakResult(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,todayStatus: null == todayStatus ? _self.todayStatus : todayStatus // ignore: cast_nullable_to_non_nullable
as DayStatus,todaySatisfied: null == todaySatisfied ? _self.todaySatisfied : todaySatisfied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakResult].
extension StreakResultPatterns on StreakResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakResult value)  $default,){
final _that = this;
switch (_that) {
case _StreakResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakResult value)?  $default,){
final _that = this;
switch (_that) {
case _StreakResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DayStatus todayStatus,  bool todaySatisfied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakResult() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.todayStatus,_that.todaySatisfied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DayStatus todayStatus,  bool todaySatisfied)  $default,) {final _that = this;
switch (_that) {
case _StreakResult():
return $default(_that.currentStreak,_that.longestStreak,_that.todayStatus,_that.todaySatisfied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int longestStreak,  DayStatus todayStatus,  bool todaySatisfied)?  $default,) {final _that = this;
switch (_that) {
case _StreakResult() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.todayStatus,_that.todaySatisfied);case _:
  return null;

}
}

}

/// @nodoc


class _StreakResult extends StreakResult {
  const _StreakResult({required this.currentStreak, required this.longestStreak, required this.todayStatus, required this.todaySatisfied}): super._();
  

@override final  int currentStreak;
@override final  int longestStreak;
@override final  DayStatus todayStatus;
@override final  bool todaySatisfied;

/// Create a copy of StreakResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakResultCopyWith<_StreakResult> get copyWith => __$StreakResultCopyWithImpl<_StreakResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakResult&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.todayStatus, todayStatus) || other.todayStatus == todayStatus)&&(identical(other.todaySatisfied, todaySatisfied) || other.todaySatisfied == todaySatisfied));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,todayStatus,todaySatisfied);

@override
String toString() {
  return 'StreakResult(currentStreak: $currentStreak, longestStreak: $longestStreak, todayStatus: $todayStatus, todaySatisfied: $todaySatisfied)';
}


}

/// @nodoc
abstract mixin class _$StreakResultCopyWith<$Res> implements $StreakResultCopyWith<$Res> {
  factory _$StreakResultCopyWith(_StreakResult value, $Res Function(_StreakResult) _then) = __$StreakResultCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int longestStreak, DayStatus todayStatus, bool todaySatisfied
});




}
/// @nodoc
class __$StreakResultCopyWithImpl<$Res>
    implements _$StreakResultCopyWith<$Res> {
  __$StreakResultCopyWithImpl(this._self, this._then);

  final _StreakResult _self;
  final $Res Function(_StreakResult) _then;

/// Create a copy of StreakResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? todayStatus = null,Object? todaySatisfied = null,}) {
  return _then(_StreakResult(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,todayStatus: null == todayStatus ? _self.todayStatus : todayStatus // ignore: cast_nullable_to_non_nullable
as DayStatus,todaySatisfied: null == todaySatisfied ? _self.todaySatisfied : todaySatisfied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
