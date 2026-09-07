// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_form_seed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FoodFormSeed {

/// The provider's **echoed** barcode — see [FoodFormSeed.fromProviderFood].
 String get barcode;/// Where the *data* in this seed came from, which is what the saved
/// [Food] must record (ADR 010: provenance records where data came from,
/// and survives the user editing every number).
///
/// **This is a discriminator, not a decoration.** The form previously
/// inferred provenance from "was there a seed at all", which made
/// [FoodFormSeed.forUnknownBarcode] — the provider had no product and
/// the user typed every figure off the packet themselves — save as
/// `openFoodFacts`. That is a false attribution in both directions: it
/// credits a database with numbers it never supplied, and it would let a
/// future sync backend treat a hand-authored row as ODbL-derived. Only a
/// seed that actually carries provider data says
/// [FoodSource.openFoodFacts].
///
/// The default is [FoodSource.custom] because the plain constructor is
/// used for hand-authored and edit-an-existing-food seeds; callers
/// re-opening an existing food pass that food's own source through, so an
/// edit never rewrites where the data came from.
 FoodSource get source; String get name; String get brand; String get servingDescription; String get servingGrams; String get servingVolumeMl; String get calories; String get protein; String get carbs; String get fat; String get iron;/// The optional nutrients, in the same raw-text form as the four above.
///
/// The provider never supplies these; they exist for
/// [FoodFormSeed.forEditing]. An edit **overwrites the food's own row**,
/// so any nutrient the seed leaves blank is one the save would erase —
/// fibre and sodium a user typed in six months ago have to survive their
/// correcting the calorie figure.
///
/// Today most of them cannot be erased because they are never stored:
/// the `foods` table carries energy, the three macros and iron, and
/// nothing else, so the rest are collected, validated and dropped at the
/// repository boundary. That gap needs a schema change and is not this
/// form's to fix — but seeding them here means the day the columns
/// arrive, the edit path is already correct instead of quietly wiping
/// them.
 String get saturatedFat; String get transFat; String get monounsaturatedFat; String get polyunsaturatedFat; String get fiber; String get sugars; String get addedSugars; String get sodium; String get potassium; String get cholesterol; String get calcium; String get vitaminD; String get vitaminC;/// The `Food.id` this form is **editing**, or `null` when it will create
/// a new food.
///
/// Present, the save is an in-place update: `NutritionRepository.saveFood`
/// upserts by id and reads `createdAt` back off the existing row, so the
/// food keeps its identity, its creation date and — crucially — every
/// diary entry's link back to it.
///
/// Absent, the controller generates a fresh id. That used to be the only
/// behaviour, which meant "Edit food details & macros" silently wrote a
/// **second catalogue row** every time it was used and left the original
/// sitting beside it.
///
/// It is also what the duplicate-barcode check compares against, so a
/// food's own row can never be mistaken for a collision with itself.
 String? get existingFoodId;/// Where the seeded per-serving numbers came from, or `null` when the
/// provider had no record at all
/// ([FoodFormSeed.forUnknownBarcode]). Surfaced on the
/// review screen so the user knows what they are looking at rather than
/// meeting three different things all labelled "per serving".
 ServingBasis? get servingBasis;/// The provider records that this product carries **no** nutrition
/// information at all — the database asserting there is nothing to
/// have, which is worth saying out loud instead of showing an empty
/// form with no explanation.
 bool get hasNoNutritionData;/// Whether energy and all three macros arrived. `false` means the user
/// has blanks to fill before they can save.
 bool get hasCompleteMacros;/// The provider's own 0–1 completeness score for the *record*, when it
/// publishes one. A statement about how many people have filled the
/// product in, never about the food.
 double? get completeness;
/// Create a copy of FoodFormSeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodFormSeedCopyWith<FoodFormSeed> get copyWith => _$FoodFormSeedCopyWithImpl<FoodFormSeed>(this as FoodFormSeed, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodFormSeed&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.iron, iron) || other.iron == iron)&&(identical(other.saturatedFat, saturatedFat) || other.saturatedFat == saturatedFat)&&(identical(other.transFat, transFat) || other.transFat == transFat)&&(identical(other.monounsaturatedFat, monounsaturatedFat) || other.monounsaturatedFat == monounsaturatedFat)&&(identical(other.polyunsaturatedFat, polyunsaturatedFat) || other.polyunsaturatedFat == polyunsaturatedFat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugars, sugars) || other.sugars == sugars)&&(identical(other.addedSugars, addedSugars) || other.addedSugars == addedSugars)&&(identical(other.sodium, sodium) || other.sodium == sodium)&&(identical(other.potassium, potassium) || other.potassium == potassium)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.calcium, calcium) || other.calcium == calcium)&&(identical(other.vitaminD, vitaminD) || other.vitaminD == vitaminD)&&(identical(other.vitaminC, vitaminC) || other.vitaminC == vitaminC)&&(identical(other.existingFoodId, existingFoodId) || other.existingFoodId == existingFoodId)&&(identical(other.servingBasis, servingBasis) || other.servingBasis == servingBasis)&&(identical(other.hasNoNutritionData, hasNoNutritionData) || other.hasNoNutritionData == hasNoNutritionData)&&(identical(other.hasCompleteMacros, hasCompleteMacros) || other.hasCompleteMacros == hasCompleteMacros)&&(identical(other.completeness, completeness) || other.completeness == completeness));
}


@override
int get hashCode => Object.hashAll([runtimeType,barcode,source,name,brand,servingDescription,servingGrams,servingVolumeMl,calories,protein,carbs,fat,iron,saturatedFat,transFat,monounsaturatedFat,polyunsaturatedFat,fiber,sugars,addedSugars,sodium,potassium,cholesterol,calcium,vitaminD,vitaminC,existingFoodId,servingBasis,hasNoNutritionData,hasCompleteMacros,completeness]);

@override
String toString() {
  return 'FoodFormSeed(barcode: $barcode, source: $source, name: $name, brand: $brand, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, iron: $iron, saturatedFat: $saturatedFat, transFat: $transFat, monounsaturatedFat: $monounsaturatedFat, polyunsaturatedFat: $polyunsaturatedFat, fiber: $fiber, sugars: $sugars, addedSugars: $addedSugars, sodium: $sodium, potassium: $potassium, cholesterol: $cholesterol, calcium: $calcium, vitaminD: $vitaminD, vitaminC: $vitaminC, existingFoodId: $existingFoodId, servingBasis: $servingBasis, hasNoNutritionData: $hasNoNutritionData, hasCompleteMacros: $hasCompleteMacros, completeness: $completeness)';
}


}

/// @nodoc
abstract mixin class $FoodFormSeedCopyWith<$Res>  {
  factory $FoodFormSeedCopyWith(FoodFormSeed value, $Res Function(FoodFormSeed) _then) = _$FoodFormSeedCopyWithImpl;
@useResult
$Res call({
 String barcode, FoodSource source, String name, String brand, String servingDescription, String servingGrams, String servingVolumeMl, String calories, String protein, String carbs, String fat, String iron, String saturatedFat, String transFat, String monounsaturatedFat, String polyunsaturatedFat, String fiber, String sugars, String addedSugars, String sodium, String potassium, String cholesterol, String calcium, String vitaminD, String vitaminC, String? existingFoodId, ServingBasis? servingBasis, bool hasNoNutritionData, bool hasCompleteMacros, double? completeness
});




}
/// @nodoc
class _$FoodFormSeedCopyWithImpl<$Res>
    implements $FoodFormSeedCopyWith<$Res> {
  _$FoodFormSeedCopyWithImpl(this._self, this._then);

  final FoodFormSeed _self;
  final $Res Function(FoodFormSeed) _then;

/// Create a copy of FoodFormSeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? source = null,Object? name = null,Object? brand = null,Object? servingDescription = null,Object? servingGrams = null,Object? servingVolumeMl = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? iron = null,Object? saturatedFat = null,Object? transFat = null,Object? monounsaturatedFat = null,Object? polyunsaturatedFat = null,Object? fiber = null,Object? sugars = null,Object? addedSugars = null,Object? sodium = null,Object? potassium = null,Object? cholesterol = null,Object? calcium = null,Object? vitaminD = null,Object? vitaminC = null,Object? existingFoodId = freezed,Object? servingBasis = freezed,Object? hasNoNutritionData = null,Object? hasCompleteMacros = null,Object? completeness = freezed,}) {
  return _then(FoodFormSeed(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingGrams: null == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as String,servingVolumeMl: null == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as String,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as String,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as String,iron: null == iron ? _self.iron : iron // ignore: cast_nullable_to_non_nullable
as String,saturatedFat: null == saturatedFat ? _self.saturatedFat : saturatedFat // ignore: cast_nullable_to_non_nullable
as String,transFat: null == transFat ? _self.transFat : transFat // ignore: cast_nullable_to_non_nullable
as String,monounsaturatedFat: null == monounsaturatedFat ? _self.monounsaturatedFat : monounsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,polyunsaturatedFat: null == polyunsaturatedFat ? _self.polyunsaturatedFat : polyunsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as String,sugars: null == sugars ? _self.sugars : sugars // ignore: cast_nullable_to_non_nullable
as String,addedSugars: null == addedSugars ? _self.addedSugars : addedSugars // ignore: cast_nullable_to_non_nullable
as String,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as String,potassium: null == potassium ? _self.potassium : potassium // ignore: cast_nullable_to_non_nullable
as String,cholesterol: null == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as String,calcium: null == calcium ? _self.calcium : calcium // ignore: cast_nullable_to_non_nullable
as String,vitaminD: null == vitaminD ? _self.vitaminD : vitaminD // ignore: cast_nullable_to_non_nullable
as String,vitaminC: null == vitaminC ? _self.vitaminC : vitaminC // ignore: cast_nullable_to_non_nullable
as String,existingFoodId: freezed == existingFoodId ? _self.existingFoodId : existingFoodId // ignore: cast_nullable_to_non_nullable
as String?,servingBasis: freezed == servingBasis ? _self.servingBasis : servingBasis // ignore: cast_nullable_to_non_nullable
as ServingBasis?,hasNoNutritionData: null == hasNoNutritionData ? _self.hasNoNutritionData : hasNoNutritionData // ignore: cast_nullable_to_non_nullable
as bool,hasCompleteMacros: null == hasCompleteMacros ? _self.hasCompleteMacros : hasCompleteMacros // ignore: cast_nullable_to_non_nullable
as bool,completeness: freezed == completeness ? _self.completeness : completeness // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodFormSeed].
extension FoodFormSeedPatterns on FoodFormSeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodFormSeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodFormSeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodFormSeed value)  $default,){
final _that = this;
switch (_that) {
case _FoodFormSeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodFormSeed value)?  $default,){
final _that = this;
switch (_that) {
case _FoodFormSeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  FoodSource source,  String name,  String brand,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String iron,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String calcium,  String vitaminD,  String vitaminC,  String? existingFoodId,  ServingBasis? servingBasis,  bool hasNoNutritionData,  bool hasCompleteMacros,  double? completeness)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodFormSeed() when $default != null:
return $default(_that.barcode,_that.source,_that.name,_that.brand,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.iron,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.calcium,_that.vitaminD,_that.vitaminC,_that.existingFoodId,_that.servingBasis,_that.hasNoNutritionData,_that.hasCompleteMacros,_that.completeness);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  FoodSource source,  String name,  String brand,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String iron,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String calcium,  String vitaminD,  String vitaminC,  String? existingFoodId,  ServingBasis? servingBasis,  bool hasNoNutritionData,  bool hasCompleteMacros,  double? completeness)  $default,) {final _that = this;
switch (_that) {
case _FoodFormSeed():
return $default(_that.barcode,_that.source,_that.name,_that.brand,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.iron,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.calcium,_that.vitaminD,_that.vitaminC,_that.existingFoodId,_that.servingBasis,_that.hasNoNutritionData,_that.hasCompleteMacros,_that.completeness);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  FoodSource source,  String name,  String brand,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String iron,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String calcium,  String vitaminD,  String vitaminC,  String? existingFoodId,  ServingBasis? servingBasis,  bool hasNoNutritionData,  bool hasCompleteMacros,  double? completeness)?  $default,) {final _that = this;
switch (_that) {
case _FoodFormSeed() when $default != null:
return $default(_that.barcode,_that.source,_that.name,_that.brand,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.iron,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.calcium,_that.vitaminD,_that.vitaminC,_that.existingFoodId,_that.servingBasis,_that.hasNoNutritionData,_that.hasCompleteMacros,_that.completeness);case _:
  return null;

}
}

}

/// @nodoc


class _FoodFormSeed extends FoodFormSeed {
  const _FoodFormSeed({required this.barcode, this.source = FoodSource.custom, this.name = '', this.brand = '', this.servingDescription = '', this.servingGrams = '', this.servingVolumeMl = '', this.calories = '', this.protein = '', this.carbs = '', this.fat = '', this.iron = '', this.saturatedFat = '', this.transFat = '', this.monounsaturatedFat = '', this.polyunsaturatedFat = '', this.fiber = '', this.sugars = '', this.addedSugars = '', this.sodium = '', this.potassium = '', this.cholesterol = '', this.calcium = '', this.vitaminD = '', this.vitaminC = '', this.existingFoodId, this.servingBasis, this.hasNoNutritionData = false, this.hasCompleteMacros = false, this.completeness}): super._();
  

/// The provider's **echoed** barcode — see [FoodFormSeed.fromProviderFood].
@override final  String barcode;
/// Where the *data* in this seed came from, which is what the saved
/// [Food] must record (ADR 010: provenance records where data came from,
/// and survives the user editing every number).
///
/// **This is a discriminator, not a decoration.** The form previously
/// inferred provenance from "was there a seed at all", which made
/// [FoodFormSeed.forUnknownBarcode] — the provider had no product and
/// the user typed every figure off the packet themselves — save as
/// `openFoodFacts`. That is a false attribution in both directions: it
/// credits a database with numbers it never supplied, and it would let a
/// future sync backend treat a hand-authored row as ODbL-derived. Only a
/// seed that actually carries provider data says
/// [FoodSource.openFoodFacts].
///
/// The default is [FoodSource.custom] because the plain constructor is
/// used for hand-authored and edit-an-existing-food seeds; callers
/// re-opening an existing food pass that food's own source through, so an
/// edit never rewrites where the data came from.
@override@JsonKey() final  FoodSource source;
@override@JsonKey() final  String name;
@override@JsonKey() final  String brand;
@override@JsonKey() final  String servingDescription;
@override@JsonKey() final  String servingGrams;
@override@JsonKey() final  String servingVolumeMl;
@override@JsonKey() final  String calories;
@override@JsonKey() final  String protein;
@override@JsonKey() final  String carbs;
@override@JsonKey() final  String fat;
@override@JsonKey() final  String iron;
/// The optional nutrients, in the same raw-text form as the four above.
///
/// The provider never supplies these; they exist for
/// [FoodFormSeed.forEditing]. An edit **overwrites the food's own row**,
/// so any nutrient the seed leaves blank is one the save would erase —
/// fibre and sodium a user typed in six months ago have to survive their
/// correcting the calorie figure.
///
/// Today most of them cannot be erased because they are never stored:
/// the `foods` table carries energy, the three macros and iron, and
/// nothing else, so the rest are collected, validated and dropped at the
/// repository boundary. That gap needs a schema change and is not this
/// form's to fix — but seeding them here means the day the columns
/// arrive, the edit path is already correct instead of quietly wiping
/// them.
@override@JsonKey() final  String saturatedFat;
@override@JsonKey() final  String transFat;
@override@JsonKey() final  String monounsaturatedFat;
@override@JsonKey() final  String polyunsaturatedFat;
@override@JsonKey() final  String fiber;
@override@JsonKey() final  String sugars;
@override@JsonKey() final  String addedSugars;
@override@JsonKey() final  String sodium;
@override@JsonKey() final  String potassium;
@override@JsonKey() final  String cholesterol;
@override@JsonKey() final  String calcium;
@override@JsonKey() final  String vitaminD;
@override@JsonKey() final  String vitaminC;
/// The `Food.id` this form is **editing**, or `null` when it will create
/// a new food.
///
/// Present, the save is an in-place update: `NutritionRepository.saveFood`
/// upserts by id and reads `createdAt` back off the existing row, so the
/// food keeps its identity, its creation date and — crucially — every
/// diary entry's link back to it.
///
/// Absent, the controller generates a fresh id. That used to be the only
/// behaviour, which meant "Edit food details & macros" silently wrote a
/// **second catalogue row** every time it was used and left the original
/// sitting beside it.
///
/// It is also what the duplicate-barcode check compares against, so a
/// food's own row can never be mistaken for a collision with itself.
@override final  String? existingFoodId;
/// Where the seeded per-serving numbers came from, or `null` when the
/// provider had no record at all
/// ([FoodFormSeed.forUnknownBarcode]). Surfaced on the
/// review screen so the user knows what they are looking at rather than
/// meeting three different things all labelled "per serving".
@override final  ServingBasis? servingBasis;
/// The provider records that this product carries **no** nutrition
/// information at all — the database asserting there is nothing to
/// have, which is worth saying out loud instead of showing an empty
/// form with no explanation.
@override@JsonKey() final  bool hasNoNutritionData;
/// Whether energy and all three macros arrived. `false` means the user
/// has blanks to fill before they can save.
@override@JsonKey() final  bool hasCompleteMacros;
/// The provider's own 0–1 completeness score for the *record*, when it
/// publishes one. A statement about how many people have filled the
/// product in, never about the food.
@override final  double? completeness;

/// Create a copy of FoodFormSeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodFormSeedCopyWith<_FoodFormSeed> get copyWith => __$FoodFormSeedCopyWithImpl<_FoodFormSeed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodFormSeed&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.iron, iron) || other.iron == iron)&&(identical(other.saturatedFat, saturatedFat) || other.saturatedFat == saturatedFat)&&(identical(other.transFat, transFat) || other.transFat == transFat)&&(identical(other.monounsaturatedFat, monounsaturatedFat) || other.monounsaturatedFat == monounsaturatedFat)&&(identical(other.polyunsaturatedFat, polyunsaturatedFat) || other.polyunsaturatedFat == polyunsaturatedFat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugars, sugars) || other.sugars == sugars)&&(identical(other.addedSugars, addedSugars) || other.addedSugars == addedSugars)&&(identical(other.sodium, sodium) || other.sodium == sodium)&&(identical(other.potassium, potassium) || other.potassium == potassium)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.calcium, calcium) || other.calcium == calcium)&&(identical(other.vitaminD, vitaminD) || other.vitaminD == vitaminD)&&(identical(other.vitaminC, vitaminC) || other.vitaminC == vitaminC)&&(identical(other.existingFoodId, existingFoodId) || other.existingFoodId == existingFoodId)&&(identical(other.servingBasis, servingBasis) || other.servingBasis == servingBasis)&&(identical(other.hasNoNutritionData, hasNoNutritionData) || other.hasNoNutritionData == hasNoNutritionData)&&(identical(other.hasCompleteMacros, hasCompleteMacros) || other.hasCompleteMacros == hasCompleteMacros)&&(identical(other.completeness, completeness) || other.completeness == completeness));
}


@override
int get hashCode => Object.hashAll([runtimeType,barcode,source,name,brand,servingDescription,servingGrams,servingVolumeMl,calories,protein,carbs,fat,iron,saturatedFat,transFat,monounsaturatedFat,polyunsaturatedFat,fiber,sugars,addedSugars,sodium,potassium,cholesterol,calcium,vitaminD,vitaminC,existingFoodId,servingBasis,hasNoNutritionData,hasCompleteMacros,completeness]);

@override
String toString() {
  return 'FoodFormSeed(barcode: $barcode, source: $source, name: $name, brand: $brand, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, iron: $iron, saturatedFat: $saturatedFat, transFat: $transFat, monounsaturatedFat: $monounsaturatedFat, polyunsaturatedFat: $polyunsaturatedFat, fiber: $fiber, sugars: $sugars, addedSugars: $addedSugars, sodium: $sodium, potassium: $potassium, cholesterol: $cholesterol, calcium: $calcium, vitaminD: $vitaminD, vitaminC: $vitaminC, existingFoodId: $existingFoodId, servingBasis: $servingBasis, hasNoNutritionData: $hasNoNutritionData, hasCompleteMacros: $hasCompleteMacros, completeness: $completeness)';
}


}

/// @nodoc
abstract mixin class _$FoodFormSeedCopyWith<$Res> implements $FoodFormSeedCopyWith<$Res> {
  factory _$FoodFormSeedCopyWith(_FoodFormSeed value, $Res Function(_FoodFormSeed) _then) = __$FoodFormSeedCopyWithImpl;
@override @useResult
$Res call({
 String barcode, FoodSource source, String name, String brand, String servingDescription, String servingGrams, String servingVolumeMl, String calories, String protein, String carbs, String fat, String iron, String saturatedFat, String transFat, String monounsaturatedFat, String polyunsaturatedFat, String fiber, String sugars, String addedSugars, String sodium, String potassium, String cholesterol, String calcium, String vitaminD, String vitaminC, String? existingFoodId, ServingBasis? servingBasis, bool hasNoNutritionData, bool hasCompleteMacros, double? completeness
});




}
/// @nodoc
class __$FoodFormSeedCopyWithImpl<$Res>
    implements _$FoodFormSeedCopyWith<$Res> {
  __$FoodFormSeedCopyWithImpl(this._self, this._then);

  final _FoodFormSeed _self;
  final $Res Function(_FoodFormSeed) _then;

/// Create a copy of FoodFormSeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? source = null,Object? name = null,Object? brand = null,Object? servingDescription = null,Object? servingGrams = null,Object? servingVolumeMl = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? iron = null,Object? saturatedFat = null,Object? transFat = null,Object? monounsaturatedFat = null,Object? polyunsaturatedFat = null,Object? fiber = null,Object? sugars = null,Object? addedSugars = null,Object? sodium = null,Object? potassium = null,Object? cholesterol = null,Object? calcium = null,Object? vitaminD = null,Object? vitaminC = null,Object? existingFoodId = freezed,Object? servingBasis = freezed,Object? hasNoNutritionData = null,Object? hasCompleteMacros = null,Object? completeness = freezed,}) {
  return _then(_FoodFormSeed(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingGrams: null == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as String,servingVolumeMl: null == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as String,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as String,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as String,iron: null == iron ? _self.iron : iron // ignore: cast_nullable_to_non_nullable
as String,saturatedFat: null == saturatedFat ? _self.saturatedFat : saturatedFat // ignore: cast_nullable_to_non_nullable
as String,transFat: null == transFat ? _self.transFat : transFat // ignore: cast_nullable_to_non_nullable
as String,monounsaturatedFat: null == monounsaturatedFat ? _self.monounsaturatedFat : monounsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,polyunsaturatedFat: null == polyunsaturatedFat ? _self.polyunsaturatedFat : polyunsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as String,sugars: null == sugars ? _self.sugars : sugars // ignore: cast_nullable_to_non_nullable
as String,addedSugars: null == addedSugars ? _self.addedSugars : addedSugars // ignore: cast_nullable_to_non_nullable
as String,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as String,potassium: null == potassium ? _self.potassium : potassium // ignore: cast_nullable_to_non_nullable
as String,cholesterol: null == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as String,calcium: null == calcium ? _self.calcium : calcium // ignore: cast_nullable_to_non_nullable
as String,vitaminD: null == vitaminD ? _self.vitaminD : vitaminD // ignore: cast_nullable_to_non_nullable
as String,vitaminC: null == vitaminC ? _self.vitaminC : vitaminC // ignore: cast_nullable_to_non_nullable
as String,existingFoodId: freezed == existingFoodId ? _self.existingFoodId : existingFoodId // ignore: cast_nullable_to_non_nullable
as String?,servingBasis: freezed == servingBasis ? _self.servingBasis : servingBasis // ignore: cast_nullable_to_non_nullable
as ServingBasis?,hasNoNutritionData: null == hasNoNutritionData ? _self.hasNoNutritionData : hasNoNutritionData // ignore: cast_nullable_to_non_nullable
as bool,hasCompleteMacros: null == hasCompleteMacros ? _self.hasCompleteMacros : hasCompleteMacros // ignore: cast_nullable_to_non_nullable
as bool,completeness: freezed == completeness ? _self.completeness : completeness // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
