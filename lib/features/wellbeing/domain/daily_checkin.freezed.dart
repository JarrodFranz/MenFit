// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_checkin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyCheckin {

 String get id; LocalDate get day;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// 1-5, higher is better. `null` when not answered.
 int? get energy;/// 1-5, higher is better. `null` when not answered.
 int? get sleep;/// 1-5, higher is worse (more soreness). `null` when not answered.
 int? get soreness;/// 1-5, higher is worse (more stress). `null` when not answered.
 int? get stress;/// 1-5, higher is worse (more pain). `null` when not answered.
 int? get pain; List<SymptomType> get symptoms;/// Free-text description when [SymptomType.other] is selected.
 String? get customSymptom;
/// Create a copy of DailyCheckin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyCheckinCopyWith<DailyCheckin> get copyWith => _$DailyCheckinCopyWithImpl<DailyCheckin>(this as DailyCheckin, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyCheckin&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.pain, pain) || other.pain == pain)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&(identical(other.customSymptom, customSymptom) || other.customSymptom == customSymptom));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,createdAt,updatedAt,energy,sleep,soreness,stress,pain,const DeepCollectionEquality().hash(symptoms),customSymptom);

@override
String toString() {
  return 'DailyCheckin(id: $id, day: $day, createdAt: $createdAt, updatedAt: $updatedAt, energy: $energy, sleep: $sleep, soreness: $soreness, stress: $stress, pain: $pain, symptoms: $symptoms, customSymptom: $customSymptom)';
}


}

/// @nodoc
abstract mixin class $DailyCheckinCopyWith<$Res>  {
  factory $DailyCheckinCopyWith(DailyCheckin value, $Res Function(DailyCheckin) _then) = _$DailyCheckinCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, DateTime createdAt, DateTime updatedAt, int? energy, int? sleep, int? soreness, int? stress, int? pain, List<SymptomType> symptoms, String? customSymptom
});




}
/// @nodoc
class _$DailyCheckinCopyWithImpl<$Res>
    implements $DailyCheckinCopyWith<$Res> {
  _$DailyCheckinCopyWithImpl(this._self, this._then);

  final DailyCheckin _self;
  final $Res Function(DailyCheckin) _then;

/// Create a copy of DailyCheckin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? createdAt = null,Object? updatedAt = null,Object? energy = freezed,Object? sleep = freezed,Object? soreness = freezed,Object? stress = freezed,Object? pain = freezed,Object? symptoms = null,Object? customSymptom = freezed,}) {
  return _then(DailyCheckin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as int?,soreness: freezed == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int?,stress: freezed == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int?,pain: freezed == pain ? _self.pain : pain // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,customSymptom: freezed == customSymptom ? _self.customSymptom : customSymptom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyCheckin].
extension DailyCheckinPatterns on DailyCheckin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyCheckin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyCheckin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyCheckin value)  $default,){
final _that = this;
switch (_that) {
case _DailyCheckin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyCheckin value)?  $default,){
final _that = this;
switch (_that) {
case _DailyCheckin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime createdAt,  DateTime updatedAt,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? customSymptom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyCheckin() when $default != null:
return $default(_that.id,_that.day,_that.createdAt,_that.updatedAt,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.customSymptom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  DateTime createdAt,  DateTime updatedAt,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? customSymptom)  $default,) {final _that = this;
switch (_that) {
case _DailyCheckin():
return $default(_that.id,_that.day,_that.createdAt,_that.updatedAt,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.customSymptom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  DateTime createdAt,  DateTime updatedAt,  int? energy,  int? sleep,  int? soreness,  int? stress,  int? pain,  List<SymptomType> symptoms,  String? customSymptom)?  $default,) {final _that = this;
switch (_that) {
case _DailyCheckin() when $default != null:
return $default(_that.id,_that.day,_that.createdAt,_that.updatedAt,_that.energy,_that.sleep,_that.soreness,_that.stress,_that.pain,_that.symptoms,_that.customSymptom);case _:
  return null;

}
}

}

/// @nodoc


class _DailyCheckin extends DailyCheckin {
  const _DailyCheckin({required this.id, required this.day, required this.createdAt, required this.updatedAt, this.energy, this.sleep, this.soreness, this.stress, this.pain,  List<SymptomType> symptoms = const <SymptomType>[], this.customSymptom}): _symptoms = symptoms,super._();
  

@override final  String id;
@override final  LocalDate day;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// 1-5, higher is better. `null` when not answered.
@override final  int? energy;
/// 1-5, higher is better. `null` when not answered.
@override final  int? sleep;
/// 1-5, higher is worse (more soreness). `null` when not answered.
@override final  int? soreness;
/// 1-5, higher is worse (more stress). `null` when not answered.
@override final  int? stress;
/// 1-5, higher is worse (more pain). `null` when not answered.
@override final  int? pain;
 final  List<SymptomType> _symptoms;
@override@JsonKey() List<SymptomType> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

/// Free-text description when [SymptomType.other] is selected.
@override final  String? customSymptom;

/// Create a copy of DailyCheckin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyCheckinCopyWith<_DailyCheckin> get copyWith => __$DailyCheckinCopyWithImpl<_DailyCheckin>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyCheckin&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.soreness, soreness) || other.soreness == soreness)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.pain, pain) || other.pain == pain)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&(identical(other.customSymptom, customSymptom) || other.customSymptom == customSymptom));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,createdAt,updatedAt,energy,sleep,soreness,stress,pain,const DeepCollectionEquality().hash(_symptoms),customSymptom);

@override
String toString() {
  return 'DailyCheckin(id: $id, day: $day, createdAt: $createdAt, updatedAt: $updatedAt, energy: $energy, sleep: $sleep, soreness: $soreness, stress: $stress, pain: $pain, symptoms: $symptoms, customSymptom: $customSymptom)';
}


}

/// @nodoc
abstract mixin class _$DailyCheckinCopyWith<$Res> implements $DailyCheckinCopyWith<$Res> {
  factory _$DailyCheckinCopyWith(_DailyCheckin value, $Res Function(_DailyCheckin) _then) = __$DailyCheckinCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, DateTime createdAt, DateTime updatedAt, int? energy, int? sleep, int? soreness, int? stress, int? pain, List<SymptomType> symptoms, String? customSymptom
});




}
/// @nodoc
class __$DailyCheckinCopyWithImpl<$Res>
    implements _$DailyCheckinCopyWith<$Res> {
  __$DailyCheckinCopyWithImpl(this._self, this._then);

  final _DailyCheckin _self;
  final $Res Function(_DailyCheckin) _then;

/// Create a copy of DailyCheckin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? createdAt = null,Object? updatedAt = null,Object? energy = freezed,Object? sleep = freezed,Object? soreness = freezed,Object? stress = freezed,Object? pain = freezed,Object? symptoms = null,Object? customSymptom = freezed,}) {
  return _then(_DailyCheckin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int?,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as int?,soreness: freezed == soreness ? _self.soreness : soreness // ignore: cast_nullable_to_non_nullable
as int?,stress: freezed == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as int?,pain: freezed == pain ? _self.pain : pain // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,customSymptom: freezed == customSymptom ? _self.customSymptom : customSymptom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
