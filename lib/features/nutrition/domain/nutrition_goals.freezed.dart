// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_goals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionGoals {

 String get id;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// Daily energy target in kilocalories. `null` means none set.
 int? get calorieTargetKcal;/// Daily protein target in grams. `null` means none set.
 double? get proteinTargetGrams;/// Daily carbohydrate target in grams. `null` means none set.
 double? get carbTargetGrams;/// Daily fat target in grams. `null` means none set.
 double? get fatTargetGrams;/// Which of the two macro representations counts. Defaults to
/// [MacroTargetMode.grams] — what every row written before this field
/// existed already means.
 MacroTargetMode get macroTargetMode;/// Daily protein target as a percentage of the day's energy target,
/// 0-100. `null` means none set. Only authoritative when
/// [macroTargetMode] is [MacroTargetMode.percent].
 double? get proteinTargetPercent;/// Daily carbohydrate target as a percentage of the day's energy
/// target, 0-100. `null` means none set.
 double? get carbTargetPercent;/// Daily fat target as a percentage of the day's energy target, 0-100.
/// `null` means none set.
 double? get fatTargetPercent;/// Which gram targets the user has pinned, so the one she left free can
/// be worked out from her calorie target
/// (`domain/macro_targets.dart#solveMacroTargets`). Defaults to
/// [MacroLocks.none] — nothing is locked until she says so, and nothing
/// is prefilled.
///
/// Only meaningful in [MacroTargetMode.grams]; a percentage split is
/// already determined by its own add-to-100 rule.
 MacroLocks get macroLocks;/// The user's typical activity level, for the TDEE estimate. `null`
/// means never chosen, and no TDEE is estimated.
 ActivityLevel? get activityLevel;/// When `true`, the app shows the food diary without calorie figures.
/// A display preference only — calories are still recorded, so turning
/// it off again loses nothing.
 bool get hideCalorieNumbers;/// Which way the user wants their weight to go. Defaults to
/// [WeightGoal.maintain]; the app never assumes otherwise.
 WeightGoal get weightGoal;/// The daily energy gap the user asked for, as a **magnitude** in
/// kilocalories — [weightGoal] carries the direction. `0` means no gap.
 int get dailyDeficitKcal;
/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionGoalsCopyWith<NutritionGoals> get copyWith => _$NutritionGoalsCopyWithImpl<NutritionGoals>(this as NutritionGoals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionGoals&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.calorieTargetKcal, calorieTargetKcal) || other.calorieTargetKcal == calorieTargetKcal)&&(identical(other.proteinTargetGrams, proteinTargetGrams) || other.proteinTargetGrams == proteinTargetGrams)&&(identical(other.carbTargetGrams, carbTargetGrams) || other.carbTargetGrams == carbTargetGrams)&&(identical(other.fatTargetGrams, fatTargetGrams) || other.fatTargetGrams == fatTargetGrams)&&(identical(other.macroTargetMode, macroTargetMode) || other.macroTargetMode == macroTargetMode)&&(identical(other.proteinTargetPercent, proteinTargetPercent) || other.proteinTargetPercent == proteinTargetPercent)&&(identical(other.carbTargetPercent, carbTargetPercent) || other.carbTargetPercent == carbTargetPercent)&&(identical(other.fatTargetPercent, fatTargetPercent) || other.fatTargetPercent == fatTargetPercent)&&(identical(other.macroLocks, macroLocks) || other.macroLocks == macroLocks)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.hideCalorieNumbers, hideCalorieNumbers) || other.hideCalorieNumbers == hideCalorieNumbers)&&(identical(other.weightGoal, weightGoal) || other.weightGoal == weightGoal)&&(identical(other.dailyDeficitKcal, dailyDeficitKcal) || other.dailyDeficitKcal == dailyDeficitKcal));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,calorieTargetKcal,proteinTargetGrams,carbTargetGrams,fatTargetGrams,macroTargetMode,proteinTargetPercent,carbTargetPercent,fatTargetPercent,macroLocks,activityLevel,hideCalorieNumbers,weightGoal,dailyDeficitKcal);

@override
String toString() {
  return 'NutritionGoals(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, calorieTargetKcal: $calorieTargetKcal, proteinTargetGrams: $proteinTargetGrams, carbTargetGrams: $carbTargetGrams, fatTargetGrams: $fatTargetGrams, macroTargetMode: $macroTargetMode, proteinTargetPercent: $proteinTargetPercent, carbTargetPercent: $carbTargetPercent, fatTargetPercent: $fatTargetPercent, macroLocks: $macroLocks, activityLevel: $activityLevel, hideCalorieNumbers: $hideCalorieNumbers, weightGoal: $weightGoal, dailyDeficitKcal: $dailyDeficitKcal)';
}


}

/// @nodoc
abstract mixin class $NutritionGoalsCopyWith<$Res>  {
  factory $NutritionGoalsCopyWith(NutritionGoals value, $Res Function(NutritionGoals) _then) = _$NutritionGoalsCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, int? calorieTargetKcal, double? proteinTargetGrams, double? carbTargetGrams, double? fatTargetGrams, MacroTargetMode macroTargetMode, double? proteinTargetPercent, double? carbTargetPercent, double? fatTargetPercent, MacroLocks macroLocks, ActivityLevel? activityLevel, bool hideCalorieNumbers, WeightGoal weightGoal, int dailyDeficitKcal
});


$MacroLocksCopyWith<$Res> get macroLocks;

}
/// @nodoc
class _$NutritionGoalsCopyWithImpl<$Res>
    implements $NutritionGoalsCopyWith<$Res> {
  _$NutritionGoalsCopyWithImpl(this._self, this._then);

  final NutritionGoals _self;
  final $Res Function(NutritionGoals) _then;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? calorieTargetKcal = freezed,Object? proteinTargetGrams = freezed,Object? carbTargetGrams = freezed,Object? fatTargetGrams = freezed,Object? macroTargetMode = null,Object? proteinTargetPercent = freezed,Object? carbTargetPercent = freezed,Object? fatTargetPercent = freezed,Object? macroLocks = null,Object? activityLevel = freezed,Object? hideCalorieNumbers = null,Object? weightGoal = null,Object? dailyDeficitKcal = null,}) {
  return _then(NutritionGoals(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,calorieTargetKcal: freezed == calorieTargetKcal ? _self.calorieTargetKcal : calorieTargetKcal // ignore: cast_nullable_to_non_nullable
as int?,proteinTargetGrams: freezed == proteinTargetGrams ? _self.proteinTargetGrams : proteinTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,carbTargetGrams: freezed == carbTargetGrams ? _self.carbTargetGrams : carbTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,fatTargetGrams: freezed == fatTargetGrams ? _self.fatTargetGrams : fatTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,macroTargetMode: null == macroTargetMode ? _self.macroTargetMode : macroTargetMode // ignore: cast_nullable_to_non_nullable
as MacroTargetMode,proteinTargetPercent: freezed == proteinTargetPercent ? _self.proteinTargetPercent : proteinTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,carbTargetPercent: freezed == carbTargetPercent ? _self.carbTargetPercent : carbTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,fatTargetPercent: freezed == fatTargetPercent ? _self.fatTargetPercent : fatTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,macroLocks: null == macroLocks ? _self.macroLocks : macroLocks // ignore: cast_nullable_to_non_nullable
as MacroLocks,activityLevel: freezed == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,hideCalorieNumbers: null == hideCalorieNumbers ? _self.hideCalorieNumbers : hideCalorieNumbers // ignore: cast_nullable_to_non_nullable
as bool,weightGoal: null == weightGoal ? _self.weightGoal : weightGoal // ignore: cast_nullable_to_non_nullable
as WeightGoal,dailyDeficitKcal: null == dailyDeficitKcal ? _self.dailyDeficitKcal : dailyDeficitKcal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacroLocksCopyWith<$Res> get macroLocks {
  
  return $MacroLocksCopyWith<$Res>(_self.macroLocks, (value) {
    return _then(_self.copyWith(macroLocks: value));
  });
}
}


/// Adds pattern-matching-related methods to [NutritionGoals].
extension NutritionGoalsPatterns on NutritionGoals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionGoals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionGoals value)  $default,){
final _that = this;
switch (_that) {
case _NutritionGoals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionGoals value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  int? calorieTargetKcal,  double? proteinTargetGrams,  double? carbTargetGrams,  double? fatTargetGrams,  MacroTargetMode macroTargetMode,  double? proteinTargetPercent,  double? carbTargetPercent,  double? fatTargetPercent,  MacroLocks macroLocks,  ActivityLevel? activityLevel,  bool hideCalorieNumbers,  WeightGoal weightGoal,  int dailyDeficitKcal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.calorieTargetKcal,_that.proteinTargetGrams,_that.carbTargetGrams,_that.fatTargetGrams,_that.macroTargetMode,_that.proteinTargetPercent,_that.carbTargetPercent,_that.fatTargetPercent,_that.macroLocks,_that.activityLevel,_that.hideCalorieNumbers,_that.weightGoal,_that.dailyDeficitKcal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  int? calorieTargetKcal,  double? proteinTargetGrams,  double? carbTargetGrams,  double? fatTargetGrams,  MacroTargetMode macroTargetMode,  double? proteinTargetPercent,  double? carbTargetPercent,  double? fatTargetPercent,  MacroLocks macroLocks,  ActivityLevel? activityLevel,  bool hideCalorieNumbers,  WeightGoal weightGoal,  int dailyDeficitKcal)  $default,) {final _that = this;
switch (_that) {
case _NutritionGoals():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.calorieTargetKcal,_that.proteinTargetGrams,_that.carbTargetGrams,_that.fatTargetGrams,_that.macroTargetMode,_that.proteinTargetPercent,_that.carbTargetPercent,_that.fatTargetPercent,_that.macroLocks,_that.activityLevel,_that.hideCalorieNumbers,_that.weightGoal,_that.dailyDeficitKcal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime updatedAt,  int? calorieTargetKcal,  double? proteinTargetGrams,  double? carbTargetGrams,  double? fatTargetGrams,  MacroTargetMode macroTargetMode,  double? proteinTargetPercent,  double? carbTargetPercent,  double? fatTargetPercent,  MacroLocks macroLocks,  ActivityLevel? activityLevel,  bool hideCalorieNumbers,  WeightGoal weightGoal,  int dailyDeficitKcal)?  $default,) {final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.calorieTargetKcal,_that.proteinTargetGrams,_that.carbTargetGrams,_that.fatTargetGrams,_that.macroTargetMode,_that.proteinTargetPercent,_that.carbTargetPercent,_that.fatTargetPercent,_that.macroLocks,_that.activityLevel,_that.hideCalorieNumbers,_that.weightGoal,_that.dailyDeficitKcal);case _:
  return null;

}
}

}

/// @nodoc


class _NutritionGoals extends NutritionGoals {
  const _NutritionGoals({required this.id, required this.createdAt, required this.updatedAt, this.calorieTargetKcal, this.proteinTargetGrams, this.carbTargetGrams, this.fatTargetGrams, this.macroTargetMode = MacroTargetMode.grams, this.proteinTargetPercent, this.carbTargetPercent, this.fatTargetPercent, this.macroLocks = MacroLocks.none, this.activityLevel, this.hideCalorieNumbers = false, this.weightGoal = WeightGoal.maintain, this.dailyDeficitKcal = 0}): super._();
  

@override final  String id;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// Daily energy target in kilocalories. `null` means none set.
@override final  int? calorieTargetKcal;
/// Daily protein target in grams. `null` means none set.
@override final  double? proteinTargetGrams;
/// Daily carbohydrate target in grams. `null` means none set.
@override final  double? carbTargetGrams;
/// Daily fat target in grams. `null` means none set.
@override final  double? fatTargetGrams;
/// Which of the two macro representations counts. Defaults to
/// [MacroTargetMode.grams] — what every row written before this field
/// existed already means.
@override@JsonKey() final  MacroTargetMode macroTargetMode;
/// Daily protein target as a percentage of the day's energy target,
/// 0-100. `null` means none set. Only authoritative when
/// [macroTargetMode] is [MacroTargetMode.percent].
@override final  double? proteinTargetPercent;
/// Daily carbohydrate target as a percentage of the day's energy
/// target, 0-100. `null` means none set.
@override final  double? carbTargetPercent;
/// Daily fat target as a percentage of the day's energy target, 0-100.
/// `null` means none set.
@override final  double? fatTargetPercent;
/// Which gram targets the user has pinned, so the one she left free can
/// be worked out from her calorie target
/// (`domain/macro_targets.dart#solveMacroTargets`). Defaults to
/// [MacroLocks.none] — nothing is locked until she says so, and nothing
/// is prefilled.
///
/// Only meaningful in [MacroTargetMode.grams]; a percentage split is
/// already determined by its own add-to-100 rule.
@override@JsonKey() final  MacroLocks macroLocks;
/// The user's typical activity level, for the TDEE estimate. `null`
/// means never chosen, and no TDEE is estimated.
@override final  ActivityLevel? activityLevel;
/// When `true`, the app shows the food diary without calorie figures.
/// A display preference only — calories are still recorded, so turning
/// it off again loses nothing.
@override@JsonKey() final  bool hideCalorieNumbers;
/// Which way the user wants their weight to go. Defaults to
/// [WeightGoal.maintain]; the app never assumes otherwise.
@override@JsonKey() final  WeightGoal weightGoal;
/// The daily energy gap the user asked for, as a **magnitude** in
/// kilocalories — [weightGoal] carries the direction. `0` means no gap.
@override@JsonKey() final  int dailyDeficitKcal;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionGoalsCopyWith<_NutritionGoals> get copyWith => __$NutritionGoalsCopyWithImpl<_NutritionGoals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionGoals&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.calorieTargetKcal, calorieTargetKcal) || other.calorieTargetKcal == calorieTargetKcal)&&(identical(other.proteinTargetGrams, proteinTargetGrams) || other.proteinTargetGrams == proteinTargetGrams)&&(identical(other.carbTargetGrams, carbTargetGrams) || other.carbTargetGrams == carbTargetGrams)&&(identical(other.fatTargetGrams, fatTargetGrams) || other.fatTargetGrams == fatTargetGrams)&&(identical(other.macroTargetMode, macroTargetMode) || other.macroTargetMode == macroTargetMode)&&(identical(other.proteinTargetPercent, proteinTargetPercent) || other.proteinTargetPercent == proteinTargetPercent)&&(identical(other.carbTargetPercent, carbTargetPercent) || other.carbTargetPercent == carbTargetPercent)&&(identical(other.fatTargetPercent, fatTargetPercent) || other.fatTargetPercent == fatTargetPercent)&&(identical(other.macroLocks, macroLocks) || other.macroLocks == macroLocks)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.hideCalorieNumbers, hideCalorieNumbers) || other.hideCalorieNumbers == hideCalorieNumbers)&&(identical(other.weightGoal, weightGoal) || other.weightGoal == weightGoal)&&(identical(other.dailyDeficitKcal, dailyDeficitKcal) || other.dailyDeficitKcal == dailyDeficitKcal));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,calorieTargetKcal,proteinTargetGrams,carbTargetGrams,fatTargetGrams,macroTargetMode,proteinTargetPercent,carbTargetPercent,fatTargetPercent,macroLocks,activityLevel,hideCalorieNumbers,weightGoal,dailyDeficitKcal);

@override
String toString() {
  return 'NutritionGoals(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, calorieTargetKcal: $calorieTargetKcal, proteinTargetGrams: $proteinTargetGrams, carbTargetGrams: $carbTargetGrams, fatTargetGrams: $fatTargetGrams, macroTargetMode: $macroTargetMode, proteinTargetPercent: $proteinTargetPercent, carbTargetPercent: $carbTargetPercent, fatTargetPercent: $fatTargetPercent, macroLocks: $macroLocks, activityLevel: $activityLevel, hideCalorieNumbers: $hideCalorieNumbers, weightGoal: $weightGoal, dailyDeficitKcal: $dailyDeficitKcal)';
}


}

/// @nodoc
abstract mixin class _$NutritionGoalsCopyWith<$Res> implements $NutritionGoalsCopyWith<$Res> {
  factory _$NutritionGoalsCopyWith(_NutritionGoals value, $Res Function(_NutritionGoals) _then) = __$NutritionGoalsCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, int? calorieTargetKcal, double? proteinTargetGrams, double? carbTargetGrams, double? fatTargetGrams, MacroTargetMode macroTargetMode, double? proteinTargetPercent, double? carbTargetPercent, double? fatTargetPercent, MacroLocks macroLocks, ActivityLevel? activityLevel, bool hideCalorieNumbers, WeightGoal weightGoal, int dailyDeficitKcal
});


@override $MacroLocksCopyWith<$Res> get macroLocks;

}
/// @nodoc
class __$NutritionGoalsCopyWithImpl<$Res>
    implements _$NutritionGoalsCopyWith<$Res> {
  __$NutritionGoalsCopyWithImpl(this._self, this._then);

  final _NutritionGoals _self;
  final $Res Function(_NutritionGoals) _then;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? calorieTargetKcal = freezed,Object? proteinTargetGrams = freezed,Object? carbTargetGrams = freezed,Object? fatTargetGrams = freezed,Object? macroTargetMode = null,Object? proteinTargetPercent = freezed,Object? carbTargetPercent = freezed,Object? fatTargetPercent = freezed,Object? macroLocks = null,Object? activityLevel = freezed,Object? hideCalorieNumbers = null,Object? weightGoal = null,Object? dailyDeficitKcal = null,}) {
  return _then(_NutritionGoals(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,calorieTargetKcal: freezed == calorieTargetKcal ? _self.calorieTargetKcal : calorieTargetKcal // ignore: cast_nullable_to_non_nullable
as int?,proteinTargetGrams: freezed == proteinTargetGrams ? _self.proteinTargetGrams : proteinTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,carbTargetGrams: freezed == carbTargetGrams ? _self.carbTargetGrams : carbTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,fatTargetGrams: freezed == fatTargetGrams ? _self.fatTargetGrams : fatTargetGrams // ignore: cast_nullable_to_non_nullable
as double?,macroTargetMode: null == macroTargetMode ? _self.macroTargetMode : macroTargetMode // ignore: cast_nullable_to_non_nullable
as MacroTargetMode,proteinTargetPercent: freezed == proteinTargetPercent ? _self.proteinTargetPercent : proteinTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,carbTargetPercent: freezed == carbTargetPercent ? _self.carbTargetPercent : carbTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,fatTargetPercent: freezed == fatTargetPercent ? _self.fatTargetPercent : fatTargetPercent // ignore: cast_nullable_to_non_nullable
as double?,macroLocks: null == macroLocks ? _self.macroLocks : macroLocks // ignore: cast_nullable_to_non_nullable
as MacroLocks,activityLevel: freezed == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,hideCalorieNumbers: null == hideCalorieNumbers ? _self.hideCalorieNumbers : hideCalorieNumbers // ignore: cast_nullable_to_non_nullable
as bool,weightGoal: null == weightGoal ? _self.weightGoal : weightGoal // ignore: cast_nullable_to_non_nullable
as WeightGoal,dailyDeficitKcal: null == dailyDeficitKcal ? _self.dailyDeficitKcal : dailyDeficitKcal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacroLocksCopyWith<$Res> get macroLocks {
  
  return $MacroLocksCopyWith<$Res>(_self.macroLocks, (value) {
    return _then(_self.copyWith(macroLocks: value));
  });
}
}

// dart format on
