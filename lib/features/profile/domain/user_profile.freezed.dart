// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfile {

 String get id; String get displayName; UnitSystem get unitSystem; DateTime get createdAt; DateTime get updatedAt;/// Target sessions per week. `null` means no goal set yet.
 int? get weeklyActivityGoal;/// `null` means never provided. S2-tier — see class doc.
 LocalDate? get dateOfBirth;/// Canonical metric (centimetres). `null` means never provided.
/// S2-tier — see class doc.
 double? get heightCm;/// Canonical metric (kilograms). `null` means never provided.
/// S2-tier — see class doc.
 double? get weightKg;/// `null` means never chosen.
 FitnessGoal? get fitnessGoal;/// Multiple chosen fitness goals. Empty set when none chosen.
 Set<FitnessGoal> get fitnessGoals;/// `null` means never chosen.
 ExperienceLevel? get runningExperience;/// `null` means never chosen.
 ExperienceLevel? get strengthExperience;/// Preferred training days. An empty set means none chosen — the same
/// as "not yet asked"; this field carries no tri-state meaning (see
/// `core/db/tables/user_profiles.dart#trainingDays`'s doc).
 Set<Weekday> get trainingDays;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.weeklyActivityGoal, weeklyActivityGoal) || other.weeklyActivityGoal == weeklyActivityGoal)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.fitnessGoal, fitnessGoal) || other.fitnessGoal == fitnessGoal)&&const DeepCollectionEquality().equals(other.fitnessGoals, fitnessGoals)&&(identical(other.runningExperience, runningExperience) || other.runningExperience == runningExperience)&&(identical(other.strengthExperience, strengthExperience) || other.strengthExperience == strengthExperience)&&const DeepCollectionEquality().equals(other.trainingDays, trainingDays));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,unitSystem,createdAt,updatedAt,weeklyActivityGoal,dateOfBirth,heightCm,weightKg,fitnessGoal,const DeepCollectionEquality().hash(fitnessGoals),runningExperience,strengthExperience,const DeepCollectionEquality().hash(trainingDays));

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, unitSystem: $unitSystem, createdAt: $createdAt, updatedAt: $updatedAt, weeklyActivityGoal: $weeklyActivityGoal, dateOfBirth: $dateOfBirth, heightCm: $heightCm, weightKg: $weightKg, fitnessGoal: $fitnessGoal, fitnessGoals: $fitnessGoals, runningExperience: $runningExperience, strengthExperience: $strengthExperience, trainingDays: $trainingDays)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, UnitSystem unitSystem, DateTime createdAt, DateTime updatedAt, int? weeklyActivityGoal, LocalDate? dateOfBirth, double? heightCm, double? weightKg, FitnessGoal? fitnessGoal, Set<FitnessGoal> fitnessGoals, ExperienceLevel? runningExperience, ExperienceLevel? strengthExperience, Set<Weekday> trainingDays
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? unitSystem = null,Object? createdAt = null,Object? updatedAt = null,Object? weeklyActivityGoal = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? fitnessGoal = freezed,Object? fitnessGoals = null,Object? runningExperience = freezed,Object? strengthExperience = freezed,Object? trainingDays = null,}) {
  return _then(UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weeklyActivityGoal: freezed == weeklyActivityGoal ? _self.weeklyActivityGoal : weeklyActivityGoal // ignore: cast_nullable_to_non_nullable
as int?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as LocalDate?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,fitnessGoal: freezed == fitnessGoal ? _self.fitnessGoal : fitnessGoal // ignore: cast_nullable_to_non_nullable
as FitnessGoal?,fitnessGoals: null == fitnessGoals ? _self.fitnessGoals : fitnessGoals // ignore: cast_nullable_to_non_nullable
as Set<FitnessGoal>,runningExperience: freezed == runningExperience ? _self.runningExperience : runningExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,strengthExperience: freezed == strengthExperience ? _self.strengthExperience : strengthExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,trainingDays: null == trainingDays ? _self.trainingDays : trainingDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  UnitSystem unitSystem,  DateTime createdAt,  DateTime updatedAt,  int? weeklyActivityGoal,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  ExperienceLevel? strengthExperience,  Set<Weekday> trainingDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.unitSystem,_that.createdAt,_that.updatedAt,_that.weeklyActivityGoal,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.strengthExperience,_that.trainingDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  UnitSystem unitSystem,  DateTime createdAt,  DateTime updatedAt,  int? weeklyActivityGoal,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  ExperienceLevel? strengthExperience,  Set<Weekday> trainingDays)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.displayName,_that.unitSystem,_that.createdAt,_that.updatedAt,_that.weeklyActivityGoal,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.strengthExperience,_that.trainingDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  UnitSystem unitSystem,  DateTime createdAt,  DateTime updatedAt,  int? weeklyActivityGoal,  LocalDate? dateOfBirth,  double? heightCm,  double? weightKg,  FitnessGoal? fitnessGoal,  Set<FitnessGoal> fitnessGoals,  ExperienceLevel? runningExperience,  ExperienceLevel? strengthExperience,  Set<Weekday> trainingDays)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.unitSystem,_that.createdAt,_that.updatedAt,_that.weeklyActivityGoal,_that.dateOfBirth,_that.heightCm,_that.weightKg,_that.fitnessGoal,_that.fitnessGoals,_that.runningExperience,_that.strengthExperience,_that.trainingDays);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile extends UserProfile {
  const _UserProfile({required this.id, required this.displayName, required this.unitSystem, required this.createdAt, required this.updatedAt, this.weeklyActivityGoal, this.dateOfBirth, this.heightCm, this.weightKg, this.fitnessGoal,  Set<FitnessGoal> fitnessGoals = const <FitnessGoal>{}, this.runningExperience, this.strengthExperience,  Set<Weekday> trainingDays = const <Weekday>{}}): _fitnessGoals = fitnessGoals,_trainingDays = trainingDays,super._();
  

@override final  String id;
@override final  String displayName;
@override final  UnitSystem unitSystem;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Target sessions per week. `null` means no goal set yet.
@override final  int? weeklyActivityGoal;
/// `null` means never provided. S2-tier — see class doc.
@override final  LocalDate? dateOfBirth;
/// Canonical metric (centimetres). `null` means never provided.
/// S2-tier — see class doc.
@override final  double? heightCm;
/// Canonical metric (kilograms). `null` means never provided.
/// S2-tier — see class doc.
@override final  double? weightKg;
/// `null` means never chosen.
@override final  FitnessGoal? fitnessGoal;
/// Multiple chosen fitness goals. Empty set when none chosen.
 final  Set<FitnessGoal> _fitnessGoals;
/// Multiple chosen fitness goals. Empty set when none chosen.
@override@JsonKey() Set<FitnessGoal> get fitnessGoals {
  if (_fitnessGoals is EqualUnmodifiableSetView) return _fitnessGoals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_fitnessGoals);
}

/// `null` means never chosen.
@override final  ExperienceLevel? runningExperience;
/// `null` means never chosen.
@override final  ExperienceLevel? strengthExperience;
/// Preferred training days. An empty set means none chosen — the same
/// as "not yet asked"; this field carries no tri-state meaning (see
/// `core/db/tables/user_profiles.dart#trainingDays`'s doc).
 final  Set<Weekday> _trainingDays;
/// Preferred training days. An empty set means none chosen — the same
/// as "not yet asked"; this field carries no tri-state meaning (see
/// `core/db/tables/user_profiles.dart#trainingDays`'s doc).
@override@JsonKey() Set<Weekday> get trainingDays {
  if (_trainingDays is EqualUnmodifiableSetView) return _trainingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_trainingDays);
}


/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.weeklyActivityGoal, weeklyActivityGoal) || other.weeklyActivityGoal == weeklyActivityGoal)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.fitnessGoal, fitnessGoal) || other.fitnessGoal == fitnessGoal)&&const DeepCollectionEquality().equals(other._fitnessGoals, _fitnessGoals)&&(identical(other.runningExperience, runningExperience) || other.runningExperience == runningExperience)&&(identical(other.strengthExperience, strengthExperience) || other.strengthExperience == strengthExperience)&&const DeepCollectionEquality().equals(other._trainingDays, _trainingDays));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,unitSystem,createdAt,updatedAt,weeklyActivityGoal,dateOfBirth,heightCm,weightKg,fitnessGoal,const DeepCollectionEquality().hash(_fitnessGoals),runningExperience,strengthExperience,const DeepCollectionEquality().hash(_trainingDays));

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, unitSystem: $unitSystem, createdAt: $createdAt, updatedAt: $updatedAt, weeklyActivityGoal: $weeklyActivityGoal, dateOfBirth: $dateOfBirth, heightCm: $heightCm, weightKg: $weightKg, fitnessGoal: $fitnessGoal, fitnessGoals: $fitnessGoals, runningExperience: $runningExperience, strengthExperience: $strengthExperience, trainingDays: $trainingDays)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, UnitSystem unitSystem, DateTime createdAt, DateTime updatedAt, int? weeklyActivityGoal, LocalDate? dateOfBirth, double? heightCm, double? weightKg, FitnessGoal? fitnessGoal, Set<FitnessGoal> fitnessGoals, ExperienceLevel? runningExperience, ExperienceLevel? strengthExperience, Set<Weekday> trainingDays
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? unitSystem = null,Object? createdAt = null,Object? updatedAt = null,Object? weeklyActivityGoal = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? fitnessGoal = freezed,Object? fitnessGoals = null,Object? runningExperience = freezed,Object? strengthExperience = freezed,Object? trainingDays = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weeklyActivityGoal: freezed == weeklyActivityGoal ? _self.weeklyActivityGoal : weeklyActivityGoal // ignore: cast_nullable_to_non_nullable
as int?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as LocalDate?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,fitnessGoal: freezed == fitnessGoal ? _self.fitnessGoal : fitnessGoal // ignore: cast_nullable_to_non_nullable
as FitnessGoal?,fitnessGoals: null == fitnessGoals ? _self._fitnessGoals : fitnessGoals // ignore: cast_nullable_to_non_nullable
as Set<FitnessGoal>,runningExperience: freezed == runningExperience ? _self.runningExperience : runningExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,strengthExperience: freezed == strengthExperience ? _self.strengthExperience : strengthExperience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel?,trainingDays: null == trainingDays ? _self._trainingDays : trainingDays // ignore: cast_nullable_to_non_nullable
as Set<Weekday>,
  ));
}


}

// dart format on
