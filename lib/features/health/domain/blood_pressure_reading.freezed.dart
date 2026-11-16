// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blood_pressure_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BloodPressureReading {

 String get id; LocalDate get day; DateTime get measuredAt; int get systolic; int get diastolic; DateTime get createdAt; DateTime get updatedAt; int? get pulse; String? get note;
/// Create a copy of BloodPressureReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloodPressureReadingCopyWith<BloodPressureReading> get copyWith => _$BloodPressureReadingCopyWithImpl<BloodPressureReading>(this as BloodPressureReading, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BloodPressureReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.systolic, systolic) || other.systolic == systolic)&&(identical(other.diastolic, diastolic) || other.diastolic == diastolic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pulse, pulse) || other.pulse == pulse)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,systolic,diastolic,createdAt,updatedAt,pulse,note);



}

/// @nodoc
abstract mixin class $BloodPressureReadingCopyWith<$Res>  {
  factory $BloodPressureReadingCopyWith(BloodPressureReading value, $Res Function(BloodPressureReading) _then) = _$BloodPressureReadingCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, int systolic, int diastolic, DateTime createdAt, DateTime updatedAt, int? pulse, String? note
});




}
/// @nodoc
class _$BloodPressureReadingCopyWithImpl<$Res>
    implements $BloodPressureReadingCopyWith<$Res> {
  _$BloodPressureReadingCopyWithImpl(this._self, this._then);

  final BloodPressureReading _self;
  final $Res Function(BloodPressureReading) _then;

/// Create a copy of BloodPressureReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? systolic = null,Object? diastolic = null,Object? createdAt = null,Object? updatedAt = null,Object? pulse = freezed,Object? note = freezed,}) {
  return _then(BloodPressureReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,systolic: null == systolic ? _self.systolic : systolic // ignore: cast_nullable_to_non_nullable
as int,diastolic: null == diastolic ? _self.diastolic : diastolic // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pulse: freezed == pulse ? _self.pulse : pulse // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BloodPressureReading].
extension BloodPressureReadingPatterns on BloodPressureReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BloodPressureReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BloodPressureReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BloodPressureReading value)  $default,){
final _that = this;
switch (_that) {
case _BloodPressureReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BloodPressureReading value)?  $default,){
final _that = this;
switch (_that) {
case _BloodPressureReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  int systolic,  int diastolic,  DateTime createdAt,  DateTime updatedAt,  int? pulse,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BloodPressureReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.systolic,_that.diastolic,_that.createdAt,_that.updatedAt,_that.pulse,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  int systolic,  int diastolic,  DateTime createdAt,  DateTime updatedAt,  int? pulse,  String? note)  $default,) {final _that = this;
switch (_that) {
case _BloodPressureReading():
return $default(_that.id,_that.day,_that.measuredAt,_that.systolic,_that.diastolic,_that.createdAt,_that.updatedAt,_that.pulse,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  DateTime measuredAt,  int systolic,  int diastolic,  DateTime createdAt,  DateTime updatedAt,  int? pulse,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _BloodPressureReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.systolic,_that.diastolic,_that.createdAt,_that.updatedAt,_that.pulse,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _BloodPressureReading implements BloodPressureReading {
  const _BloodPressureReading({required this.id, required this.day, required this.measuredAt, required this.systolic, required this.diastolic, required this.createdAt, required this.updatedAt, this.pulse, this.note});
  

@override final  String id;
@override final  LocalDate day;
@override final  DateTime measuredAt;
@override final  int systolic;
@override final  int diastolic;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  int? pulse;
@override final  String? note;

/// Create a copy of BloodPressureReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BloodPressureReadingCopyWith<_BloodPressureReading> get copyWith => __$BloodPressureReadingCopyWithImpl<_BloodPressureReading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BloodPressureReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.systolic, systolic) || other.systolic == systolic)&&(identical(other.diastolic, diastolic) || other.diastolic == diastolic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pulse, pulse) || other.pulse == pulse)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,systolic,diastolic,createdAt,updatedAt,pulse,note);



}

/// @nodoc
abstract mixin class _$BloodPressureReadingCopyWith<$Res> implements $BloodPressureReadingCopyWith<$Res> {
  factory _$BloodPressureReadingCopyWith(_BloodPressureReading value, $Res Function(_BloodPressureReading) _then) = __$BloodPressureReadingCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, int systolic, int diastolic, DateTime createdAt, DateTime updatedAt, int? pulse, String? note
});




}
/// @nodoc
class __$BloodPressureReadingCopyWithImpl<$Res>
    implements _$BloodPressureReadingCopyWith<$Res> {
  __$BloodPressureReadingCopyWithImpl(this._self, this._then);

  final _BloodPressureReading _self;
  final $Res Function(_BloodPressureReading) _then;

/// Create a copy of BloodPressureReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? systolic = null,Object? diastolic = null,Object? createdAt = null,Object? updatedAt = null,Object? pulse = freezed,Object? note = freezed,}) {
  return _then(_BloodPressureReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,systolic: null == systolic ? _self.systolic : systolic // ignore: cast_nullable_to_non_nullable
as int,diastolic: null == diastolic ? _self.diastolic : diastolic // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pulse: freezed == pulse ? _self.pulse : pulse // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
