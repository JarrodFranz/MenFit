// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderFoodSummary {

/// Which provider produced this specific result.
///
/// Stamped by the mapper that built this summary
/// (`data/open_food_facts_mapper.dart`, `data/fat_secret_mapper.dart`),
/// never defaulted: when a composite provider tries a primary and falls
/// back to a second one (`domain/fallback_food_data_provider.dart`), a
/// missing source here would be a provenance bug, not a detail to paper
/// over with a guess.
 FoodSource get source;/// The provider's product code, as the provider echoed it back (which
/// is not necessarily the string that was searched for).
 String get barcode;/// Best available product name; never blank (falls back to the
/// barcode when the provider has no usable name).
 String get name;/// Brand or maker, when the provider states one.
 String? get brand;/// Energy per 100 g, in kilocalories. `null` means the provider
/// doesn't state it.
 double? get caloriesKcal;/// Protein per 100 g, in grams. `null` means not stated.
 double? get proteinGrams;/// Carbohydrate per 100 g, in grams. `null` means not stated.
 double? get carbsGrams;/// Fat per 100 g, in grams. `null` means not stated.
 double? get fatGrams;/// Stated serving description (e.g. "1 bar (45 g)", "250 ml"), when
/// available.
 String? get servingDescription;/// Serving weight in grams, when available.
 double? get servingGrams;/// Serving volume in millilitres, when available.
 double? get servingVolumeMl;/// Energy per serving in kilocalories, when available.
 double? get servingCaloriesKcal;
/// Create a copy of ProviderFoodSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderFoodSummaryCopyWith<ProviderFoodSummary> get copyWith => _$ProviderFoodSummaryCopyWithImpl<ProviderFoodSummary>(this as ProviderFoodSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderFoodSummary&&(identical(other.source, source) || other.source == source)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.servingCaloriesKcal, servingCaloriesKcal) || other.servingCaloriesKcal == servingCaloriesKcal));
}


@override
int get hashCode => Object.hash(runtimeType,source,barcode,name,brand,caloriesKcal,proteinGrams,carbsGrams,fatGrams,servingDescription,servingGrams,servingVolumeMl,servingCaloriesKcal);

@override
String toString() {
  return 'ProviderFoodSummary(source: $source, barcode: $barcode, name: $name, brand: $brand, caloriesKcal: $caloriesKcal, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, servingCaloriesKcal: $servingCaloriesKcal)';
}


}

/// @nodoc
abstract mixin class $ProviderFoodSummaryCopyWith<$Res>  {
  factory $ProviderFoodSummaryCopyWith(ProviderFoodSummary value, $Res Function(ProviderFoodSummary) _then) = _$ProviderFoodSummaryCopyWithImpl;
@useResult
$Res call({
 FoodSource source, String barcode, String name, String? brand, double? caloriesKcal, double? proteinGrams, double? carbsGrams, double? fatGrams, String? servingDescription, double? servingGrams, double? servingVolumeMl, double? servingCaloriesKcal
});




}
/// @nodoc
class _$ProviderFoodSummaryCopyWithImpl<$Res>
    implements $ProviderFoodSummaryCopyWith<$Res> {
  _$ProviderFoodSummaryCopyWithImpl(this._self, this._then);

  final ProviderFoodSummary _self;
  final $Res Function(ProviderFoodSummary) _then;

/// Create a copy of ProviderFoodSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? barcode = null,Object? name = null,Object? brand = freezed,Object? caloriesKcal = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? servingDescription = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? servingCaloriesKcal = freezed,}) {
  return _then(ProviderFoodSummary(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double?,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,servingCaloriesKcal: freezed == servingCaloriesKcal ? _self.servingCaloriesKcal : servingCaloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderFoodSummary].
extension ProviderFoodSummaryPatterns on ProviderFoodSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderFoodSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderFoodSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderFoodSummary value)  $default,){
final _that = this;
switch (_that) {
case _ProviderFoodSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderFoodSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderFoodSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodSource source,  String barcode,  String name,  String? brand,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? servingCaloriesKcal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderFoodSummary() when $default != null:
return $default(_that.source,_that.barcode,_that.name,_that.brand,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.servingCaloriesKcal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodSource source,  String barcode,  String name,  String? brand,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? servingCaloriesKcal)  $default,) {final _that = this;
switch (_that) {
case _ProviderFoodSummary():
return $default(_that.source,_that.barcode,_that.name,_that.brand,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.servingCaloriesKcal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodSource source,  String barcode,  String name,  String? brand,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  String? servingDescription,  double? servingGrams,  double? servingVolumeMl,  double? servingCaloriesKcal)?  $default,) {final _that = this;
switch (_that) {
case _ProviderFoodSummary() when $default != null:
return $default(_that.source,_that.barcode,_that.name,_that.brand,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.servingCaloriesKcal);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderFoodSummary extends ProviderFoodSummary {
  const _ProviderFoodSummary({required this.source, required this.barcode, required this.name, this.brand, this.caloriesKcal, this.proteinGrams, this.carbsGrams, this.fatGrams, this.servingDescription, this.servingGrams, this.servingVolumeMl, this.servingCaloriesKcal}): super._();
  

/// Which provider produced this specific result.
///
/// Stamped by the mapper that built this summary
/// (`data/open_food_facts_mapper.dart`, `data/fat_secret_mapper.dart`),
/// never defaulted: when a composite provider tries a primary and falls
/// back to a second one (`domain/fallback_food_data_provider.dart`), a
/// missing source here would be a provenance bug, not a detail to paper
/// over with a guess.
@override final  FoodSource source;
/// The provider's product code, as the provider echoed it back (which
/// is not necessarily the string that was searched for).
@override final  String barcode;
/// Best available product name; never blank (falls back to the
/// barcode when the provider has no usable name).
@override final  String name;
/// Brand or maker, when the provider states one.
@override final  String? brand;
/// Energy per 100 g, in kilocalories. `null` means the provider
/// doesn't state it.
@override final  double? caloriesKcal;
/// Protein per 100 g, in grams. `null` means not stated.
@override final  double? proteinGrams;
/// Carbohydrate per 100 g, in grams. `null` means not stated.
@override final  double? carbsGrams;
/// Fat per 100 g, in grams. `null` means not stated.
@override final  double? fatGrams;
/// Stated serving description (e.g. "1 bar (45 g)", "250 ml"), when
/// available.
@override final  String? servingDescription;
/// Serving weight in grams, when available.
@override final  double? servingGrams;
/// Serving volume in millilitres, when available.
@override final  double? servingVolumeMl;
/// Energy per serving in kilocalories, when available.
@override final  double? servingCaloriesKcal;

/// Create a copy of ProviderFoodSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderFoodSummaryCopyWith<_ProviderFoodSummary> get copyWith => __$ProviderFoodSummaryCopyWithImpl<_ProviderFoodSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderFoodSummary&&(identical(other.source, source) || other.source == source)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.servingCaloriesKcal, servingCaloriesKcal) || other.servingCaloriesKcal == servingCaloriesKcal));
}


@override
int get hashCode => Object.hash(runtimeType,source,barcode,name,brand,caloriesKcal,proteinGrams,carbsGrams,fatGrams,servingDescription,servingGrams,servingVolumeMl,servingCaloriesKcal);

@override
String toString() {
  return 'ProviderFoodSummary(source: $source, barcode: $barcode, name: $name, brand: $brand, caloriesKcal: $caloriesKcal, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, servingCaloriesKcal: $servingCaloriesKcal)';
}


}

/// @nodoc
abstract mixin class _$ProviderFoodSummaryCopyWith<$Res> implements $ProviderFoodSummaryCopyWith<$Res> {
  factory _$ProviderFoodSummaryCopyWith(_ProviderFoodSummary value, $Res Function(_ProviderFoodSummary) _then) = __$ProviderFoodSummaryCopyWithImpl;
@override @useResult
$Res call({
 FoodSource source, String barcode, String name, String? brand, double? caloriesKcal, double? proteinGrams, double? carbsGrams, double? fatGrams, String? servingDescription, double? servingGrams, double? servingVolumeMl, double? servingCaloriesKcal
});




}
/// @nodoc
class __$ProviderFoodSummaryCopyWithImpl<$Res>
    implements _$ProviderFoodSummaryCopyWith<$Res> {
  __$ProviderFoodSummaryCopyWithImpl(this._self, this._then);

  final _ProviderFoodSummary _self;
  final $Res Function(_ProviderFoodSummary) _then;

/// Create a copy of ProviderFoodSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? barcode = null,Object? name = null,Object? brand = freezed,Object? caloriesKcal = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? servingDescription = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? servingCaloriesKcal = freezed,}) {
  return _then(_ProviderFoodSummary(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double?,servingDescription: freezed == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,servingCaloriesKcal: freezed == servingCaloriesKcal ? _self.servingCaloriesKcal : servingCaloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$ProviderFood {

/// Which provider produced this result — see
/// [ProviderFoodSummary.source], which carries the same requirement for
/// the same reason.
 FoodSource get source;/// The provider's product code, **as the provider echoed it back**.
///
/// Providers normalise codes server-side (leading zeros, EAN-8 to
/// EAN-13), so this can differ from the scanned string. Anything keyed
/// on a barcode — a cache, a saved `Food.barcode` — keys on this.
 String get barcode;/// Best available product name; never blank (falls back to the
/// barcode when the provider has no usable name for it).
 String get name;/// Free-text description of one serving, exactly as the provider
/// states it (`'3/4 cup (28 g)'`), or `'100 g'` when
/// [servingBasis] is [ServingBasis.per100g].
///
/// Displayed, never parsed: providers do not normalise this field and
/// malformed values are common in practice.
 String get servingDescription;/// Where the per-serving numbers below came from. Shown to the user —
/// see [ServingBasis].
 ServingBasis get servingBasis;/// Brand or maker, when the provider states one.
 String? get brand;/// Mass of one serving in grams, when a usable one is known. `100`
/// when [servingBasis] is [ServingBasis.per100g].
 double? get servingGrams;/// Volume of one serving in millilitres, when a usable one is known.
 double? get servingVolumeMl;/// Energy per serving, in kilocalories. `null` means **not stated** —
/// see the class doc.
 double? get caloriesKcal;/// Protein per serving, in grams. `null` means not stated.
 double? get proteinGrams;/// Carbohydrate per serving, in grams. `null` means not stated.
 double? get carbsGrams;/// Fat per serving, in grams. `null` means not stated.
 double? get fatGrams;/// Iron per serving, in **milligrams**. `null` means not stated.
///
/// Providers commonly express iron in grams; converting to the
/// milligrams this app uses happens at the data layer, so everything
/// above it sees one unit.
 double? get ironMg;/// Calcium per serving, in milligrams. `null` means not stated.
 double? get calciumMg;/// Vitamin D per serving, in micrograms. `null` means not stated.
 double? get vitaminDMcg;/// Vitamin C per serving, in milligrams. `null` means not stated.
 double? get vitaminCMg;/// Dietary fiber per serving, in grams. `null` means not stated.
 double? get fiberGrams;/// Sodium per serving, in milligrams. `null` means not stated.
 double? get sodiumMg;/// Potassium per serving, in milligrams. `null` means not stated.
 double? get potassiumMg;/// Saturated fat per serving, in grams. `null` means not stated.
 double? get saturatedFatGrams;/// The provider's own 0–1 completeness score for the product record,
/// when it publishes one. A signal about the *record*, not about the
/// food — a low score means "few people have filled this in".
 double? get completeness;/// Whether the provider marks this product's nutrition facts as
/// complete. Stronger than [completeness], which counts photos and
/// categories too.
 bool get hasCompleteNutritionFacts;/// Whether the provider records that this product carries **no**
/// nutrition information at all (an unlabelled loose product, say).
///
/// Distinct from "we have no numbers for it": this is the database
/// asserting there is nothing to have, which the review screen can say
/// out loud instead of showing an empty form.
 bool get hasNoNutritionData;
/// Create a copy of ProviderFood
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderFoodCopyWith<ProviderFood> get copyWith => _$ProviderFoodCopyWithImpl<ProviderFood>(this as ProviderFood, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderFood&&(identical(other.source, source) || other.source == source)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingBasis, servingBasis) || other.servingBasis == servingBasis)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.ironMg, ironMg) || other.ironMg == ironMg)&&(identical(other.calciumMg, calciumMg) || other.calciumMg == calciumMg)&&(identical(other.vitaminDMcg, vitaminDMcg) || other.vitaminDMcg == vitaminDMcg)&&(identical(other.vitaminCMg, vitaminCMg) || other.vitaminCMg == vitaminCMg)&&(identical(other.fiberGrams, fiberGrams) || other.fiberGrams == fiberGrams)&&(identical(other.sodiumMg, sodiumMg) || other.sodiumMg == sodiumMg)&&(identical(other.potassiumMg, potassiumMg) || other.potassiumMg == potassiumMg)&&(identical(other.saturatedFatGrams, saturatedFatGrams) || other.saturatedFatGrams == saturatedFatGrams)&&(identical(other.completeness, completeness) || other.completeness == completeness)&&(identical(other.hasCompleteNutritionFacts, hasCompleteNutritionFacts) || other.hasCompleteNutritionFacts == hasCompleteNutritionFacts)&&(identical(other.hasNoNutritionData, hasNoNutritionData) || other.hasNoNutritionData == hasNoNutritionData));
}


@override
int get hashCode => Object.hashAll([runtimeType,source,barcode,name,servingDescription,servingBasis,brand,servingGrams,servingVolumeMl,caloriesKcal,proteinGrams,carbsGrams,fatGrams,ironMg,calciumMg,vitaminDMcg,vitaminCMg,fiberGrams,sodiumMg,potassiumMg,saturatedFatGrams,completeness,hasCompleteNutritionFacts,hasNoNutritionData]);

@override
String toString() {
  return 'ProviderFood(source: $source, barcode: $barcode, name: $name, servingDescription: $servingDescription, servingBasis: $servingBasis, brand: $brand, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, caloriesKcal: $caloriesKcal, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, ironMg: $ironMg, calciumMg: $calciumMg, vitaminDMcg: $vitaminDMcg, vitaminCMg: $vitaminCMg, fiberGrams: $fiberGrams, sodiumMg: $sodiumMg, potassiumMg: $potassiumMg, saturatedFatGrams: $saturatedFatGrams, completeness: $completeness, hasCompleteNutritionFacts: $hasCompleteNutritionFacts, hasNoNutritionData: $hasNoNutritionData)';
}


}

/// @nodoc
abstract mixin class $ProviderFoodCopyWith<$Res>  {
  factory $ProviderFoodCopyWith(ProviderFood value, $Res Function(ProviderFood) _then) = _$ProviderFoodCopyWithImpl;
@useResult
$Res call({
 FoodSource source, String barcode, String name, String servingDescription, ServingBasis servingBasis, String? brand, double? servingGrams, double? servingVolumeMl, double? caloriesKcal, double? proteinGrams, double? carbsGrams, double? fatGrams, double? ironMg, double? calciumMg, double? vitaminDMcg, double? vitaminCMg, double? fiberGrams, double? sodiumMg, double? potassiumMg, double? saturatedFatGrams, double? completeness, bool hasCompleteNutritionFacts, bool hasNoNutritionData
});




}
/// @nodoc
class _$ProviderFoodCopyWithImpl<$Res>
    implements $ProviderFoodCopyWith<$Res> {
  _$ProviderFoodCopyWithImpl(this._self, this._then);

  final ProviderFood _self;
  final $Res Function(ProviderFood) _then;

/// Create a copy of ProviderFood
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? barcode = null,Object? name = null,Object? servingDescription = null,Object? servingBasis = null,Object? brand = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? caloriesKcal = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? ironMg = freezed,Object? calciumMg = freezed,Object? vitaminDMcg = freezed,Object? vitaminCMg = freezed,Object? fiberGrams = freezed,Object? sodiumMg = freezed,Object? potassiumMg = freezed,Object? saturatedFatGrams = freezed,Object? completeness = freezed,Object? hasCompleteNutritionFacts = null,Object? hasNoNutritionData = null,}) {
  return _then(ProviderFood(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingBasis: null == servingBasis ? _self.servingBasis : servingBasis // ignore: cast_nullable_to_non_nullable
as ServingBasis,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double?,ironMg: freezed == ironMg ? _self.ironMg : ironMg // ignore: cast_nullable_to_non_nullable
as double?,calciumMg: freezed == calciumMg ? _self.calciumMg : calciumMg // ignore: cast_nullable_to_non_nullable
as double?,vitaminDMcg: freezed == vitaminDMcg ? _self.vitaminDMcg : vitaminDMcg // ignore: cast_nullable_to_non_nullable
as double?,vitaminCMg: freezed == vitaminCMg ? _self.vitaminCMg : vitaminCMg // ignore: cast_nullable_to_non_nullable
as double?,fiberGrams: freezed == fiberGrams ? _self.fiberGrams : fiberGrams // ignore: cast_nullable_to_non_nullable
as double?,sodiumMg: freezed == sodiumMg ? _self.sodiumMg : sodiumMg // ignore: cast_nullable_to_non_nullable
as double?,potassiumMg: freezed == potassiumMg ? _self.potassiumMg : potassiumMg // ignore: cast_nullable_to_non_nullable
as double?,saturatedFatGrams: freezed == saturatedFatGrams ? _self.saturatedFatGrams : saturatedFatGrams // ignore: cast_nullable_to_non_nullable
as double?,completeness: freezed == completeness ? _self.completeness : completeness // ignore: cast_nullable_to_non_nullable
as double?,hasCompleteNutritionFacts: null == hasCompleteNutritionFacts ? _self.hasCompleteNutritionFacts : hasCompleteNutritionFacts // ignore: cast_nullable_to_non_nullable
as bool,hasNoNutritionData: null == hasNoNutritionData ? _self.hasNoNutritionData : hasNoNutritionData // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderFood].
extension ProviderFoodPatterns on ProviderFood {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderFood value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderFood() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderFood value)  $default,){
final _that = this;
switch (_that) {
case _ProviderFood():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderFood value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderFood() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodSource source,  String barcode,  String name,  String servingDescription,  ServingBasis servingBasis,  String? brand,  double? servingGrams,  double? servingVolumeMl,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  double? ironMg,  double? calciumMg,  double? vitaminDMcg,  double? vitaminCMg,  double? fiberGrams,  double? sodiumMg,  double? potassiumMg,  double? saturatedFatGrams,  double? completeness,  bool hasCompleteNutritionFacts,  bool hasNoNutritionData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderFood() when $default != null:
return $default(_that.source,_that.barcode,_that.name,_that.servingDescription,_that.servingBasis,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.ironMg,_that.calciumMg,_that.vitaminDMcg,_that.vitaminCMg,_that.fiberGrams,_that.sodiumMg,_that.potassiumMg,_that.saturatedFatGrams,_that.completeness,_that.hasCompleteNutritionFacts,_that.hasNoNutritionData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodSource source,  String barcode,  String name,  String servingDescription,  ServingBasis servingBasis,  String? brand,  double? servingGrams,  double? servingVolumeMl,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  double? ironMg,  double? calciumMg,  double? vitaminDMcg,  double? vitaminCMg,  double? fiberGrams,  double? sodiumMg,  double? potassiumMg,  double? saturatedFatGrams,  double? completeness,  bool hasCompleteNutritionFacts,  bool hasNoNutritionData)  $default,) {final _that = this;
switch (_that) {
case _ProviderFood():
return $default(_that.source,_that.barcode,_that.name,_that.servingDescription,_that.servingBasis,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.ironMg,_that.calciumMg,_that.vitaminDMcg,_that.vitaminCMg,_that.fiberGrams,_that.sodiumMg,_that.potassiumMg,_that.saturatedFatGrams,_that.completeness,_that.hasCompleteNutritionFacts,_that.hasNoNutritionData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodSource source,  String barcode,  String name,  String servingDescription,  ServingBasis servingBasis,  String? brand,  double? servingGrams,  double? servingVolumeMl,  double? caloriesKcal,  double? proteinGrams,  double? carbsGrams,  double? fatGrams,  double? ironMg,  double? calciumMg,  double? vitaminDMcg,  double? vitaminCMg,  double? fiberGrams,  double? sodiumMg,  double? potassiumMg,  double? saturatedFatGrams,  double? completeness,  bool hasCompleteNutritionFacts,  bool hasNoNutritionData)?  $default,) {final _that = this;
switch (_that) {
case _ProviderFood() when $default != null:
return $default(_that.source,_that.barcode,_that.name,_that.servingDescription,_that.servingBasis,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.caloriesKcal,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.ironMg,_that.calciumMg,_that.vitaminDMcg,_that.vitaminCMg,_that.fiberGrams,_that.sodiumMg,_that.potassiumMg,_that.saturatedFatGrams,_that.completeness,_that.hasCompleteNutritionFacts,_that.hasNoNutritionData);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderFood extends ProviderFood {
  const _ProviderFood({required this.source, required this.barcode, required this.name, required this.servingDescription, required this.servingBasis, this.brand, this.servingGrams, this.servingVolumeMl, this.caloriesKcal, this.proteinGrams, this.carbsGrams, this.fatGrams, this.ironMg, this.calciumMg, this.vitaminDMcg, this.vitaminCMg, this.fiberGrams, this.sodiumMg, this.potassiumMg, this.saturatedFatGrams, this.completeness, this.hasCompleteNutritionFacts = false, this.hasNoNutritionData = false}): super._();
  

/// Which provider produced this result — see
/// [ProviderFoodSummary.source], which carries the same requirement for
/// the same reason.
@override final  FoodSource source;
/// The provider's product code, **as the provider echoed it back**.
///
/// Providers normalise codes server-side (leading zeros, EAN-8 to
/// EAN-13), so this can differ from the scanned string. Anything keyed
/// on a barcode — a cache, a saved `Food.barcode` — keys on this.
@override final  String barcode;
/// Best available product name; never blank (falls back to the
/// barcode when the provider has no usable name for it).
@override final  String name;
/// Free-text description of one serving, exactly as the provider
/// states it (`'3/4 cup (28 g)'`), or `'100 g'` when
/// [servingBasis] is [ServingBasis.per100g].
///
/// Displayed, never parsed: providers do not normalise this field and
/// malformed values are common in practice.
@override final  String servingDescription;
/// Where the per-serving numbers below came from. Shown to the user —
/// see [ServingBasis].
@override final  ServingBasis servingBasis;
/// Brand or maker, when the provider states one.
@override final  String? brand;
/// Mass of one serving in grams, when a usable one is known. `100`
/// when [servingBasis] is [ServingBasis.per100g].
@override final  double? servingGrams;
/// Volume of one serving in millilitres, when a usable one is known.
@override final  double? servingVolumeMl;
/// Energy per serving, in kilocalories. `null` means **not stated** —
/// see the class doc.
@override final  double? caloriesKcal;
/// Protein per serving, in grams. `null` means not stated.
@override final  double? proteinGrams;
/// Carbohydrate per serving, in grams. `null` means not stated.
@override final  double? carbsGrams;
/// Fat per serving, in grams. `null` means not stated.
@override final  double? fatGrams;
/// Iron per serving, in **milligrams**. `null` means not stated.
///
/// Providers commonly express iron in grams; converting to the
/// milligrams this app uses happens at the data layer, so everything
/// above it sees one unit.
@override final  double? ironMg;
/// Calcium per serving, in milligrams. `null` means not stated.
@override final  double? calciumMg;
/// Vitamin D per serving, in micrograms. `null` means not stated.
@override final  double? vitaminDMcg;
/// Vitamin C per serving, in milligrams. `null` means not stated.
@override final  double? vitaminCMg;
/// Dietary fiber per serving, in grams. `null` means not stated.
@override final  double? fiberGrams;
/// Sodium per serving, in milligrams. `null` means not stated.
@override final  double? sodiumMg;
/// Potassium per serving, in milligrams. `null` means not stated.
@override final  double? potassiumMg;
/// Saturated fat per serving, in grams. `null` means not stated.
@override final  double? saturatedFatGrams;
/// The provider's own 0–1 completeness score for the product record,
/// when it publishes one. A signal about the *record*, not about the
/// food — a low score means "few people have filled this in".
@override final  double? completeness;
/// Whether the provider marks this product's nutrition facts as
/// complete. Stronger than [completeness], which counts photos and
/// categories too.
@override@JsonKey() final  bool hasCompleteNutritionFacts;
/// Whether the provider records that this product carries **no**
/// nutrition information at all (an unlabelled loose product, say).
///
/// Distinct from "we have no numbers for it": this is the database
/// asserting there is nothing to have, which the review screen can say
/// out loud instead of showing an empty form.
@override@JsonKey() final  bool hasNoNutritionData;

/// Create a copy of ProviderFood
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderFoodCopyWith<_ProviderFood> get copyWith => __$ProviderFoodCopyWithImpl<_ProviderFood>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderFood&&(identical(other.source, source) || other.source == source)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingBasis, servingBasis) || other.servingBasis == servingBasis)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.ironMg, ironMg) || other.ironMg == ironMg)&&(identical(other.calciumMg, calciumMg) || other.calciumMg == calciumMg)&&(identical(other.vitaminDMcg, vitaminDMcg) || other.vitaminDMcg == vitaminDMcg)&&(identical(other.vitaminCMg, vitaminCMg) || other.vitaminCMg == vitaminCMg)&&(identical(other.fiberGrams, fiberGrams) || other.fiberGrams == fiberGrams)&&(identical(other.sodiumMg, sodiumMg) || other.sodiumMg == sodiumMg)&&(identical(other.potassiumMg, potassiumMg) || other.potassiumMg == potassiumMg)&&(identical(other.saturatedFatGrams, saturatedFatGrams) || other.saturatedFatGrams == saturatedFatGrams)&&(identical(other.completeness, completeness) || other.completeness == completeness)&&(identical(other.hasCompleteNutritionFacts, hasCompleteNutritionFacts) || other.hasCompleteNutritionFacts == hasCompleteNutritionFacts)&&(identical(other.hasNoNutritionData, hasNoNutritionData) || other.hasNoNutritionData == hasNoNutritionData));
}


@override
int get hashCode => Object.hashAll([runtimeType,source,barcode,name,servingDescription,servingBasis,brand,servingGrams,servingVolumeMl,caloriesKcal,proteinGrams,carbsGrams,fatGrams,ironMg,calciumMg,vitaminDMcg,vitaminCMg,fiberGrams,sodiumMg,potassiumMg,saturatedFatGrams,completeness,hasCompleteNutritionFacts,hasNoNutritionData]);

@override
String toString() {
  return 'ProviderFood(source: $source, barcode: $barcode, name: $name, servingDescription: $servingDescription, servingBasis: $servingBasis, brand: $brand, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, caloriesKcal: $caloriesKcal, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, ironMg: $ironMg, calciumMg: $calciumMg, vitaminDMcg: $vitaminDMcg, vitaminCMg: $vitaminCMg, fiberGrams: $fiberGrams, sodiumMg: $sodiumMg, potassiumMg: $potassiumMg, saturatedFatGrams: $saturatedFatGrams, completeness: $completeness, hasCompleteNutritionFacts: $hasCompleteNutritionFacts, hasNoNutritionData: $hasNoNutritionData)';
}


}

/// @nodoc
abstract mixin class _$ProviderFoodCopyWith<$Res> implements $ProviderFoodCopyWith<$Res> {
  factory _$ProviderFoodCopyWith(_ProviderFood value, $Res Function(_ProviderFood) _then) = __$ProviderFoodCopyWithImpl;
@override @useResult
$Res call({
 FoodSource source, String barcode, String name, String servingDescription, ServingBasis servingBasis, String? brand, double? servingGrams, double? servingVolumeMl, double? caloriesKcal, double? proteinGrams, double? carbsGrams, double? fatGrams, double? ironMg, double? calciumMg, double? vitaminDMcg, double? vitaminCMg, double? fiberGrams, double? sodiumMg, double? potassiumMg, double? saturatedFatGrams, double? completeness, bool hasCompleteNutritionFacts, bool hasNoNutritionData
});




}
/// @nodoc
class __$ProviderFoodCopyWithImpl<$Res>
    implements _$ProviderFoodCopyWith<$Res> {
  __$ProviderFoodCopyWithImpl(this._self, this._then);

  final _ProviderFood _self;
  final $Res Function(_ProviderFood) _then;

/// Create a copy of ProviderFood
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? barcode = null,Object? name = null,Object? servingDescription = null,Object? servingBasis = null,Object? brand = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? caloriesKcal = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? ironMg = freezed,Object? calciumMg = freezed,Object? vitaminDMcg = freezed,Object? vitaminCMg = freezed,Object? fiberGrams = freezed,Object? sodiumMg = freezed,Object? potassiumMg = freezed,Object? saturatedFatGrams = freezed,Object? completeness = freezed,Object? hasCompleteNutritionFacts = null,Object? hasNoNutritionData = null,}) {
  return _then(_ProviderFood(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingBasis: null == servingBasis ? _self.servingBasis : servingBasis // ignore: cast_nullable_to_non_nullable
as ServingBasis,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as double?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as double?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as double?,ironMg: freezed == ironMg ? _self.ironMg : ironMg // ignore: cast_nullable_to_non_nullable
as double?,calciumMg: freezed == calciumMg ? _self.calciumMg : calciumMg // ignore: cast_nullable_to_non_nullable
as double?,vitaminDMcg: freezed == vitaminDMcg ? _self.vitaminDMcg : vitaminDMcg // ignore: cast_nullable_to_non_nullable
as double?,vitaminCMg: freezed == vitaminCMg ? _self.vitaminCMg : vitaminCMg // ignore: cast_nullable_to_non_nullable
as double?,fiberGrams: freezed == fiberGrams ? _self.fiberGrams : fiberGrams // ignore: cast_nullable_to_non_nullable
as double?,sodiumMg: freezed == sodiumMg ? _self.sodiumMg : sodiumMg // ignore: cast_nullable_to_non_nullable
as double?,potassiumMg: freezed == potassiumMg ? _self.potassiumMg : potassiumMg // ignore: cast_nullable_to_non_nullable
as double?,saturatedFatGrams: freezed == saturatedFatGrams ? _self.saturatedFatGrams : saturatedFatGrams // ignore: cast_nullable_to_non_nullable
as double?,completeness: freezed == completeness ? _self.completeness : completeness // ignore: cast_nullable_to_non_nullable
as double?,hasCompleteNutritionFacts: null == hasCompleteNutritionFacts ? _self.hasCompleteNutritionFacts : hasCompleteNutritionFacts // ignore: cast_nullable_to_non_nullable
as bool,hasNoNutritionData: null == hasNoNutritionData ? _self.hasNoNutritionData : hasNoNutritionData // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
