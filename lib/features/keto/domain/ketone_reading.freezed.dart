// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ketone_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KetoneReading {

 String get id; LocalDate get day; DateTime get measuredAt; KetoneMeasurementType get type; String get result; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of KetoneReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KetoneReadingCopyWith<KetoneReading> get copyWith => _$KetoneReadingCopyWithImpl<KetoneReading>(this as KetoneReading, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KetoneReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.result, result) || other.result == result)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,type,result,createdAt,updatedAt);



}

/// @nodoc
abstract mixin class $KetoneReadingCopyWith<$Res>  {
  factory $KetoneReadingCopyWith(KetoneReading value, $Res Function(KetoneReading) _then) = _$KetoneReadingCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, KetoneMeasurementType type, String result, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$KetoneReadingCopyWithImpl<$Res>
    implements $KetoneReadingCopyWith<$Res> {
  _$KetoneReadingCopyWithImpl(this._self, this._then);

  final KetoneReading _self;
  final $Res Function(KetoneReading) _then;

/// Create a copy of KetoneReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? type = null,Object? result = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(KetoneReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KetoneMeasurementType,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [KetoneReading].
extension KetoneReadingPatterns on KetoneReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KetoneReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KetoneReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KetoneReading value)  $default,){
final _that = this;
switch (_that) {
case _KetoneReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KetoneReading value)?  $default,){
final _that = this;
switch (_that) {
case _KetoneReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  KetoneMeasurementType type,  String result,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KetoneReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.type,_that.result,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime measuredAt,  KetoneMeasurementType type,  String result,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _KetoneReading():
return $default(_that.id,_that.day,_that.measuredAt,_that.type,_that.result,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  DateTime measuredAt,  KetoneMeasurementType type,  String result,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _KetoneReading() when $default != null:
return $default(_that.id,_that.day,_that.measuredAt,_that.type,_that.result,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _KetoneReading implements KetoneReading {
  const _KetoneReading({required this.id, required this.day, required this.measuredAt, required this.type, required this.result, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  LocalDate day;
@override final  DateTime measuredAt;
@override final  KetoneMeasurementType type;
@override final  String result;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of KetoneReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KetoneReadingCopyWith<_KetoneReading> get copyWith => __$KetoneReadingCopyWithImpl<_KetoneReading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KetoneReading&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.result, result) || other.result == result)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,measuredAt,type,result,createdAt,updatedAt);



}

/// @nodoc
abstract mixin class _$KetoneReadingCopyWith<$Res> implements $KetoneReadingCopyWith<$Res> {
  factory _$KetoneReadingCopyWith(_KetoneReading value, $Res Function(_KetoneReading) _then) = __$KetoneReadingCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, DateTime measuredAt, KetoneMeasurementType type, String result, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$KetoneReadingCopyWithImpl<$Res>
    implements _$KetoneReadingCopyWith<$Res> {
  __$KetoneReadingCopyWithImpl(this._self, this._then);

  final _KetoneReading _self;
  final $Res Function(_KetoneReading) _then;

/// Create a copy of KetoneReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? measuredAt = null,Object? type = null,Object? result = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_KetoneReading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as KetoneMeasurementType,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
