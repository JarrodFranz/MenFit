// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionEntry {

 String get id; LocalDate get day; MealType get meal;/// The food's name at log time — see the class doc's snapshot section.
 String get foodName;/// How many servings were eaten. Always greater than zero (see
/// `domain/nutrition_validation.dart`); fractions are normal.
 double get quantityServings;/// The number the user typed, in [quantityUnit] — see the class doc's
/// "Two numbers" section.
 double get quantityAmount;/// The food's per-serving nutrition at log time — see the class doc's
/// snapshot section.
 NutritionFacts get perServing;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// The `Food.id` this was logged from, when it is still worth linking
/// back to. Never required, and never trusted to still resolve.
 String? get foodId;/// The food's brand at log time. `null` when it had none.
 String? get foodBrand;/// The food's serving description at log time, e.g. `'1 cup (dry)'`.
 String? get servingDescription;/// The unit [quantityAmount] is in. Defaults to
/// [QuantityUnit.serving] for the same reason the column does: before
/// units existed, servings were the only thing an entry could hold.
/// (It sits down here among the optionals only because a defaulted
/// parameter may not precede a required one.)
 QuantityUnit get quantityUnit;/// The food's grams per serving **at log time**, or `null` when it had
/// The food's grams per serving **at log time**, or `null` when it had
/// none recorded — see the class doc's snapshot section, which applies
/// to this field for the same reason it applies to [perServing].
///
/// `null` means weight units are unavailable for this entry, and is
/// what every entry logged before units existed carries. It is never
/// re-read from the food to fill the gap: that would measure an old
/// entry against a weight it was never logged against.
 double? get servingGrams;/// The food's volume in millilitres per serving **at log time**, or `null`
/// when it had none recorded.
 double? get servingVolumeMl;
/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionEntryCopyWith<NutritionEntry> get copyWith => _$NutritionEntryCopyWithImpl<NutritionEntry>(this as NutritionEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.meal, meal) || other.meal == meal)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.quantityServings, quantityServings) || other.quantityServings == quantityServings)&&(identical(other.quantityAmount, quantityAmount) || other.quantityAmount == quantityAmount)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.foodBrand, foodBrand) || other.foodBrand == foodBrand)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,meal,foodName,quantityServings,quantityAmount,perServing,createdAt,updatedAt,foodId,foodBrand,servingDescription,quantityUnit,servingGrams,servingVolumeMl);

@override
String toString() {
  return 'NutritionEntry(id: $id, day: $day, meal: $meal, foodName: $foodName, quantityServings: $quantityServings, quantityAmount: $quantityAmount, perServing: $perServing, createdAt: $createdAt, updatedAt: $updatedAt, foodId: $foodId, foodBrand: $foodBrand, servingDescription: $servingDescription, quantityUnit: $quantityUnit, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl)';
}


}

/// @nodoc
abstract mixin class $NutritionEntryCopyWith<$Res>  {
  factory $NutritionEntryCopyWith(NutritionEntry value, $Res Function(NutritionEntry) _then) = _$NutritionEntryCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, MealType meal, String foodName, double quantityServings, double quantityAmount, NutritionFacts perServing, DateTime createdAt, DateTime updatedAt, String? foodId, String? foodBrand, String? servingDescription, QuantityUnit quantityUnit, double? servingGrams, double? servingVolumeMl
});


$NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class _$NutritionEntryCopyWithImpl<$Res>
    implements $NutritionEntryCopyWith<$Res> {
  _$NutritionEntryCopyWithImpl(this._self, this._then);

  final NutritionEntry _self;
  final $Res Function(NutritionEntry) _then;

/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? meal = null,Object? foodName = null,Object? quantityServings = null,Object? quantityAmount = null,Object? perServing = null,Object? createdAt = null,Object? updatedAt = null,Object? foodId = freezed,Object? foodBrand = freezed,Object? servingDescription = freezed,Object? quantityUnit = null,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,}) {
  return _then(NutritionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,meal: null == meal ? _self.meal : meal // ignore: cast_nullable_to_non_nullable
as MealType,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,quantityServings: null == quantityServings ? _self.quantityServings : quantityServings // ignore: cast_nullable_to_non_nullable
as double,quantityAmount: null == quantityAmount ? _self.quantityAmount : quantityAmount // ignore: cast_nullable_to_non_nullable
as double,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,foodBrand: freezed == foodBrand ? _self.foodBrand : foodBrand // ignore: cast_nullable_to_non_nullable
as String?,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}


/// Adds pattern-matching-related methods to [NutritionEntry].
extension NutritionEntryPatterns on NutritionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionEntry value)  $default,){
final _that = this;
switch (_that) {
case _NutritionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  MealType meal,  String foodName,  double quantityServings,  double quantityAmount,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? foodId,  String? foodBrand,  String? servingDescription,  QuantityUnit quantityUnit,  double? servingGrams,  double? servingVolumeMl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionEntry() when $default != null:
return $default(_that.id,_that.day,_that.meal,_that.foodName,_that.quantityServings,_that.quantityAmount,_that.perServing,_that.createdAt,_that.updatedAt,_that.foodId,_that.foodBrand,_that.servingDescription,_that.quantityUnit,_that.servingGrams,_that.servingVolumeMl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  MealType meal,  String foodName,  double quantityServings,  double quantityAmount,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? foodId,  String? foodBrand,  String? servingDescription,  QuantityUnit quantityUnit,  double? servingGrams,  double? servingVolumeMl)  $default,) {final _that = this;
switch (_that) {
case _NutritionEntry():
return $default(_that.id,_that.day,_that.meal,_that.foodName,_that.quantityServings,_that.quantityAmount,_that.perServing,_that.createdAt,_that.updatedAt,_that.foodId,_that.foodBrand,_that.servingDescription,_that.quantityUnit,_that.servingGrams,_that.servingVolumeMl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  MealType meal,  String foodName,  double quantityServings,  double quantityAmount,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? foodId,  String? foodBrand,  String? servingDescription,  QuantityUnit quantityUnit,  double? servingGrams,  double? servingVolumeMl)?  $default,) {final _that = this;
switch (_that) {
case _NutritionEntry() when $default != null:
return $default(_that.id,_that.day,_that.meal,_that.foodName,_that.quantityServings,_that.quantityAmount,_that.perServing,_that.createdAt,_that.updatedAt,_that.foodId,_that.foodBrand,_that.servingDescription,_that.quantityUnit,_that.servingGrams,_that.servingVolumeMl);case _:
  return null;

}
}

}

/// @nodoc


class _NutritionEntry extends NutritionEntry {
  const _NutritionEntry({required this.id, required this.day, required this.meal, required this.foodName, required this.quantityServings, required this.quantityAmount, required this.perServing, required this.createdAt, required this.updatedAt, this.foodId, this.foodBrand, this.servingDescription, this.quantityUnit = QuantityUnit.serving, this.servingGrams, this.servingVolumeMl}): super._();
  

@override final  String id;
@override final  LocalDate day;
@override final  MealType meal;
/// The food's name at log time — see the class doc's snapshot section.
@override final  String foodName;
/// How many servings were eaten. Always greater than zero (see
/// `domain/nutrition_validation.dart`); fractions are normal.
@override final  double quantityServings;
/// The number the user typed, in [quantityUnit] — see the class doc's
/// "Two numbers" section.
@override final  double quantityAmount;
/// The food's per-serving nutrition at log time — see the class doc's
/// snapshot section.
@override final  NutritionFacts perServing;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// The `Food.id` this was logged from, when it is still worth linking
/// back to. Never required, and never trusted to still resolve.
@override final  String? foodId;
/// The food's brand at log time. `null` when it had none.
@override final  String? foodBrand;
/// The food's serving description at log time, e.g. `'1 cup (dry)'`.
@override final  String? servingDescription;
/// The unit [quantityAmount] is in. Defaults to
/// [QuantityUnit.serving] for the same reason the column does: before
/// units existed, servings were the only thing an entry could hold.
/// (It sits down here among the optionals only because a defaulted
/// parameter may not precede a required one.)
@override@JsonKey() final  QuantityUnit quantityUnit;
/// The food's grams per serving **at log time**, or `null` when it had
/// The food's grams per serving **at log time**, or `null` when it had
/// none recorded — see the class doc's snapshot section, which applies
/// to this field for the same reason it applies to [perServing].
///
/// `null` means weight units are unavailable for this entry, and is
/// what every entry logged before units existed carries. It is never
/// re-read from the food to fill the gap: that would measure an old
/// entry against a weight it was never logged against.
@override final  double? servingGrams;
/// The food's volume in millilitres per serving **at log time**, or `null`
/// when it had none recorded.
@override final  double? servingVolumeMl;

/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionEntryCopyWith<_NutritionEntry> get copyWith => __$NutritionEntryCopyWithImpl<_NutritionEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.meal, meal) || other.meal == meal)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.quantityServings, quantityServings) || other.quantityServings == quantityServings)&&(identical(other.quantityAmount, quantityAmount) || other.quantityAmount == quantityAmount)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.foodBrand, foodBrand) || other.foodBrand == foodBrand)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,meal,foodName,quantityServings,quantityAmount,perServing,createdAt,updatedAt,foodId,foodBrand,servingDescription,quantityUnit,servingGrams,servingVolumeMl);

@override
String toString() {
  return 'NutritionEntry(id: $id, day: $day, meal: $meal, foodName: $foodName, quantityServings: $quantityServings, quantityAmount: $quantityAmount, perServing: $perServing, createdAt: $createdAt, updatedAt: $updatedAt, foodId: $foodId, foodBrand: $foodBrand, servingDescription: $servingDescription, quantityUnit: $quantityUnit, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl)';
}


}

/// @nodoc
abstract mixin class _$NutritionEntryCopyWith<$Res> implements $NutritionEntryCopyWith<$Res> {
  factory _$NutritionEntryCopyWith(_NutritionEntry value, $Res Function(_NutritionEntry) _then) = __$NutritionEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, MealType meal, String foodName, double quantityServings, double quantityAmount, NutritionFacts perServing, DateTime createdAt, DateTime updatedAt, String? foodId, String? foodBrand, String? servingDescription, QuantityUnit quantityUnit, double? servingGrams, double? servingVolumeMl
});


@override $NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class __$NutritionEntryCopyWithImpl<$Res>
    implements _$NutritionEntryCopyWith<$Res> {
  __$NutritionEntryCopyWithImpl(this._self, this._then);

  final _NutritionEntry _self;
  final $Res Function(_NutritionEntry) _then;

/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? meal = null,Object? foodName = null,Object? quantityServings = null,Object? quantityAmount = null,Object? perServing = null,Object? createdAt = null,Object? updatedAt = null,Object? foodId = freezed,Object? foodBrand = freezed,Object? servingDescription = freezed,Object? quantityUnit = null,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,}) {
  return _then(_NutritionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,meal: null == meal ? _self.meal : meal // ignore: cast_nullable_to_non_nullable
as MealType,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,quantityServings: null == quantityServings ? _self.quantityServings : quantityServings // ignore: cast_nullable_to_non_nullable
as double,quantityAmount: null == quantityAmount ? _self.quantityAmount : quantityAmount // ignore: cast_nullable_to_non_nullable
as double,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,foodBrand: freezed == foodBrand ? _self.foodBrand : foodBrand // ignore: cast_nullable_to_non_nullable
as String?,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of NutritionEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}

// dart format on
