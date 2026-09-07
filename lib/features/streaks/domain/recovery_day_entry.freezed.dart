// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery_day_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecoveryDayEntry {

 LocalDate get day; String? get note;
/// Create a copy of RecoveryDayEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryDayEntryCopyWith<RecoveryDayEntry> get copyWith => _$RecoveryDayEntryCopyWithImpl<RecoveryDayEntry>(this as RecoveryDayEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryDayEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,day,note);

@override
String toString() {
  return 'RecoveryDayEntry(day: $day, note: $note)';
}


}

/// @nodoc
abstract mixin class $RecoveryDayEntryCopyWith<$Res>  {
  factory $RecoveryDayEntryCopyWith(RecoveryDayEntry value, $Res Function(RecoveryDayEntry) _then) = _$RecoveryDayEntryCopyWithImpl;
@useResult
$Res call({
 LocalDate day, String? note
});




}
/// @nodoc
class _$RecoveryDayEntryCopyWithImpl<$Res>
    implements $RecoveryDayEntryCopyWith<$Res> {
  _$RecoveryDayEntryCopyWithImpl(this._self, this._then);

  final RecoveryDayEntry _self;
  final $Res Function(RecoveryDayEntry) _then;

/// Create a copy of RecoveryDayEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? note = freezed,}) {
  return _then(RecoveryDayEntry(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveryDayEntry].
extension RecoveryDayEntryPatterns on RecoveryDayEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryDayEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryDayEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryDayEntry value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryDayEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryDayEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryDayEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate day,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryDayEntry() when $default != null:
return $default(_that.day,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate day,  String? note)  $default,) {final _that = this;
switch (_that) {
case _RecoveryDayEntry():
return $default(_that.day,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate day,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryDayEntry() when $default != null:
return $default(_that.day,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _RecoveryDayEntry implements RecoveryDayEntry {
  const _RecoveryDayEntry({required this.day, this.note});
  

@override final  LocalDate day;
@override final  String? note;

/// Create a copy of RecoveryDayEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryDayEntryCopyWith<_RecoveryDayEntry> get copyWith => __$RecoveryDayEntryCopyWithImpl<_RecoveryDayEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryDayEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,day,note);

@override
String toString() {
  return 'RecoveryDayEntry(day: $day, note: $note)';
}


}

/// @nodoc
abstract mixin class _$RecoveryDayEntryCopyWith<$Res> implements $RecoveryDayEntryCopyWith<$Res> {
  factory _$RecoveryDayEntryCopyWith(_RecoveryDayEntry value, $Res Function(_RecoveryDayEntry) _then) = __$RecoveryDayEntryCopyWithImpl;
@override @useResult
$Res call({
 LocalDate day, String? note
});




}
/// @nodoc
class __$RecoveryDayEntryCopyWithImpl<$Res>
    implements _$RecoveryDayEntryCopyWith<$Res> {
  __$RecoveryDayEntryCopyWithImpl(this._self, this._then);

  final _RecoveryDayEntry _self;
  final $Res Function(_RecoveryDayEntry) _then;

/// Create a copy of RecoveryDayEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? note = freezed,}) {
  return _then(_RecoveryDayEntry(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
