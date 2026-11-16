// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blood_marker_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BloodMarkerReading {

 String get id; LocalDate get day; DateTime get measuredAt; BloodMarker get marker; double get value; BloodMarkerUnit get unit; DateTime get createdAt; DateTime get updatedAt; GlucoseContext? get context; String? get note;
/// Create a copy of BloodMarkerReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloodMarkerReadingCopyWith<BloodMarkerReading> get copyWith => _$BloodMarkerReadingCopyWithImpl<BloodMarkerReading>(this as BloodMarkerReading, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BloodMarkerReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.marker, marker) || other.marker == marker)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.context, context) || other.context == context)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,marker,value,unit,createdAt,updatedAt,context,note);



}

/// @nodoc
abstract mixin class $BloodMarkerReadingCopyWith<$Res>  {
  factory $BloodMarkerReadingCopyWith(BloodMarkerReading value, $Res Function(BloodMarkerReading) _then) = _$BloodMarkerReadingCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, BloodMarker marker, double value, BloodMarkerUnit unit, DateTime createdAt, DateTime updatedAt, GlucoseContext? context, String? note
});




}
/// @nodoc
class _$BloodMarkerReadingCopyWithImpl<$Res>
    implements $BloodMarkerReadingCopyWith<$Res> {
  _$BloodMarkerReadingCopyWithImpl(this._self, this._then);

  final BloodMarkerReading _self;
  final $Res Function(BloodMarkerReading) _then;

/// Create a copy of BloodMarkerReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? marker = null,Object? value = null,Object? unit = null,Object? createdAt = null,Object? updatedAt = null,Object? context = freezed,Object? note = freezed,}) {
  return _then(BloodMarkerReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,marker: null == marker ? _self.marker : marker // ignore: cast_nullable_to_non_nullable
as BloodMarker,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as BloodMarkerUnit,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as GlucoseContext?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BloodMarkerReading].
extension BloodMarkerReadingPatterns on BloodMarkerReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BloodMarkerReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BloodMarkerReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BloodMarkerReading value)  $default,){
final _that = this;
switch (_that) {
case _BloodMarkerReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BloodMarkerReading value)?  $default,){
final _that = this;
switch (_that) {
case _BloodMarkerReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  BloodMarker marker,  double value,  BloodMarkerUnit unit,  DateTime createdAt,  DateTime updatedAt,  GlucoseContext? context,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BloodMarkerReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.marker,_that.value,_that.unit,_that.createdAt,_that.updatedAt,_that.context,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  BloodMarker marker,  double value,  BloodMarkerUnit unit,  DateTime createdAt,  DateTime updatedAt,  GlucoseContext? context,  String? note)  $default,) {final _that = this;
switch (_that) {
case _BloodMarkerReading():
return $default(_that.id,_that.day,_that.measuredAt,_that.marker,_that.value,_that.unit,_that.createdAt,_that.updatedAt,_that.context,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  DateTime measuredAt,  BloodMarker marker,  double value,  BloodMarkerUnit unit,  DateTime createdAt,  DateTime updatedAt,  GlucoseContext? context,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _BloodMarkerReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.marker,_that.value,_that.unit,_that.createdAt,_that.updatedAt,_that.context,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _BloodMarkerReading implements BloodMarkerReading {
  const _BloodMarkerReading({required this.id, required this.day, required this.measuredAt, required this.marker, required this.value, required this.unit, required this.createdAt, required this.updatedAt, this.context, this.note});
  

@override final  String id;
@override final  LocalDate day;
@override final  DateTime measuredAt;
@override final  BloodMarker marker;
@override final  double value;
@override final  BloodMarkerUnit unit;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  GlucoseContext? context;
@override final  String? note;

/// Create a copy of BloodMarkerReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BloodMarkerReadingCopyWith<_BloodMarkerReading> get copyWith => __$BloodMarkerReadingCopyWithImpl<_BloodMarkerReading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BloodMarkerReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.marker, marker) || other.marker == marker)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.context, context) || other.context == context)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,marker,value,unit,createdAt,updatedAt,context,note);



}

/// @nodoc
abstract mixin class _$BloodMarkerReadingCopyWith<$Res> implements $BloodMarkerReadingCopyWith<$Res> {
  factory _$BloodMarkerReadingCopyWith(_BloodMarkerReading value, $Res Function(_BloodMarkerReading) _then) = __$BloodMarkerReadingCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, BloodMarker marker, double value, BloodMarkerUnit unit, DateTime createdAt, DateTime updatedAt, GlucoseContext? context, String? note
});




}
/// @nodoc
class __$BloodMarkerReadingCopyWithImpl<$Res>
    implements _$BloodMarkerReadingCopyWith<$Res> {
  __$BloodMarkerReadingCopyWithImpl(this._self, this._then);

  final _BloodMarkerReading _self;
  final $Res Function(_BloodMarkerReading) _then;

/// Create a copy of BloodMarkerReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? marker = null,Object? value = null,Object? unit = null,Object? createdAt = null,Object? updatedAt = null,Object? context = freezed,Object? note = freezed,}) {
  return _then(_BloodMarkerReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,marker: null == marker ? _self.marker : marker // ignore: cast_nullable_to_non_nullable
as BloodMarker,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as BloodMarkerUnit,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as GlucoseContext?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
