// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeightLog {

 String get id; LocalDate get day;/// Canonical metric (kilograms).
 double get weightKg;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// Free-text note. `null` when the user attached none — never an
/// empty string standing in for absence.
 String? get notes;/// Provenance. Defaults to [WeightLogSource.manual], which is what a
/// value the user typed is.
 WeightLogSource get source;
/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightLogCopyWith<WeightLog> get copyWith => _$WeightLogCopyWithImpl<WeightLog>(this as WeightLog, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightLog&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,weightKg,createdAt,updatedAt,notes,source);

@override
String toString() {
  return 'WeightLog(id: $id, day: $day, weightKg: $weightKg, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, source: $source)';
}


}

/// @nodoc
abstract mixin class $WeightLogCopyWith<$Res>  {
  factory $WeightLogCopyWith(WeightLog value, $Res Function(WeightLog) _then) = _$WeightLogCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, double weightKg, DateTime createdAt, DateTime updatedAt, String? notes, WeightLogSource source
});




}
/// @nodoc
class _$WeightLogCopyWithImpl<$Res>
    implements $WeightLogCopyWith<$Res> {
  _$WeightLogCopyWithImpl(this._self, this._then);

  final WeightLog _self;
  final $Res Function(WeightLog) _then;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? weightKg = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? source = null,}) {
  return _then(WeightLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WeightLogSource,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightLog].
extension WeightLogPatterns on WeightLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightLog value)  $default,){
final _that = this;
switch (_that) {
case _WeightLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightLog value)?  $default,){
final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  double weightKg,  DateTime createdAt,  DateTime updatedAt,  String? notes,  WeightLogSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
return $default(_that.id,_that.day,_that.weightKg,_that.createdAt,_that.updatedAt,_that.notes,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  double weightKg,  DateTime createdAt,  DateTime updatedAt,  String? notes,  WeightLogSource source)  $default,) {final _that = this;
switch (_that) {
case _WeightLog():
return $default(_that.id,_that.day,_that.weightKg,_that.createdAt,_that.updatedAt,_that.notes,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  double weightKg,  DateTime createdAt,  DateTime updatedAt,  String? notes,  WeightLogSource source)?  $default,) {final _that = this;
switch (_that) {
case _WeightLog() when $default != null:
return $default(_that.id,_that.day,_that.weightKg,_that.createdAt,_that.updatedAt,_that.notes,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _WeightLog implements WeightLog {
  const _WeightLog({required this.id, required this.day, required this.weightKg, required this.createdAt, required this.updatedAt, this.notes, this.source = WeightLogSource.manual});
  

@override final  String id;
@override final  LocalDate day;
/// Canonical metric (kilograms).
@override final  double weightKg;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// Free-text note. `null` when the user attached none — never an
/// empty string standing in for absence.
@override final  String? notes;
/// Provenance. Defaults to [WeightLogSource.manual], which is what a
/// value the user typed is.
@override@JsonKey() final  WeightLogSource source;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightLogCopyWith<_WeightLog> get copyWith => __$WeightLogCopyWithImpl<_WeightLog>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightLog&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,weightKg,createdAt,updatedAt,notes,source);

@override
String toString() {
  return 'WeightLog(id: $id, day: $day, weightKg: $weightKg, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, source: $source)';
}


}

/// @nodoc
abstract mixin class _$WeightLogCopyWith<$Res> implements $WeightLogCopyWith<$Res> {
  factory _$WeightLogCopyWith(_WeightLog value, $Res Function(_WeightLog) _then) = __$WeightLogCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, double weightKg, DateTime createdAt, DateTime updatedAt, String? notes, WeightLogSource source
});




}
/// @nodoc
class __$WeightLogCopyWithImpl<$Res>
    implements _$WeightLogCopyWith<$Res> {
  __$WeightLogCopyWithImpl(this._self, this._then);

  final _WeightLog _self;
  final $Res Function(_WeightLog) _then;

/// Create a copy of WeightLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? weightKg = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? source = null,}) {
  return _then(_WeightLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WeightLogSource,
  ));
}


}

// dart format on
