// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CycleRecord {

 String get id; LocalDate get periodStart;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// `null` while the period is ongoing.
 LocalDate? get periodEnd;
/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleRecordCopyWith<CycleRecord> get copyWith => _$CycleRecordCopyWithImpl<CycleRecord>(this as CycleRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd));
}


@override
int get hashCode => Object.hash(runtimeType,id,periodStart,createdAt,updatedAt,periodEnd);

@override
String toString() {
  return 'CycleRecord(id: $id, periodStart: $periodStart, createdAt: $createdAt, updatedAt: $updatedAt, periodEnd: $periodEnd)';
}


}

/// @nodoc
abstract mixin class $CycleRecordCopyWith<$Res>  {
  factory $CycleRecordCopyWith(CycleRecord value, $Res Function(CycleRecord) _then) = _$CycleRecordCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate periodStart, DateTime createdAt, DateTime updatedAt, LocalDate? periodEnd
});




}
/// @nodoc
class _$CycleRecordCopyWithImpl<$Res>
    implements $CycleRecordCopyWith<$Res> {
  _$CycleRecordCopyWithImpl(this._self, this._then);

  final CycleRecord _self;
  final $Res Function(CycleRecord) _then;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodStart = null,Object? createdAt = null,Object? updatedAt = null,Object? periodEnd = freezed,}) {
  return _then(CycleRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as LocalDate,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleRecord].
extension CycleRecordPatterns on CycleRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleRecord value)  $default,){
final _that = this;
switch (_that) {
case _CycleRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate periodStart,  DateTime createdAt,  DateTime updatedAt,  LocalDate? periodEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that.id,_that.periodStart,_that.createdAt,_that.updatedAt,_that.periodEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate periodStart,  DateTime createdAt,  DateTime updatedAt,  LocalDate? periodEnd)  $default,) {final _that = this;
switch (_that) {
case _CycleRecord():
return $default(_that.id,_that.periodStart,_that.createdAt,_that.updatedAt,_that.periodEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate periodStart,  DateTime createdAt,  DateTime updatedAt,  LocalDate? periodEnd)?  $default,) {final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that.id,_that.periodStart,_that.createdAt,_that.updatedAt,_that.periodEnd);case _:
  return null;

}
}

}

/// @nodoc


class _CycleRecord extends CycleRecord {
  const _CycleRecord({required this.id, required this.periodStart, required this.createdAt, required this.updatedAt, this.periodEnd}): super._();
  

@override final  String id;
@override final  LocalDate periodStart;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// `null` while the period is ongoing.
@override final  LocalDate? periodEnd;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleRecordCopyWith<_CycleRecord> get copyWith => __$CycleRecordCopyWithImpl<_CycleRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd));
}


@override
int get hashCode => Object.hash(runtimeType,id,periodStart,createdAt,updatedAt,periodEnd);

@override
String toString() {
  return 'CycleRecord(id: $id, periodStart: $periodStart, createdAt: $createdAt, updatedAt: $updatedAt, periodEnd: $periodEnd)';
}


}

/// @nodoc
abstract mixin class _$CycleRecordCopyWith<$Res> implements $CycleRecordCopyWith<$Res> {
  factory _$CycleRecordCopyWith(_CycleRecord value, $Res Function(_CycleRecord) _then) = __$CycleRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate periodStart, DateTime createdAt, DateTime updatedAt, LocalDate? periodEnd
});




}
/// @nodoc
class __$CycleRecordCopyWithImpl<$Res>
    implements _$CycleRecordCopyWith<$Res> {
  __$CycleRecordCopyWithImpl(this._self, this._then);

  final _CycleRecord _self;
  final $Res Function(_CycleRecord) _then;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodStart = null,Object? createdAt = null,Object? updatedAt = null,Object? periodEnd = freezed,}) {
  return _then(_CycleRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as LocalDate,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}


}

// dart format on
