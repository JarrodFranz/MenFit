/// Drift row -> freezed entity mapping for the `foods` and
/// `nutrition_entries` tables.
///
/// Split out of `drift_nutrition_repository.dart` purely for size
/// (coding_standards.md's ~300-line rule). This is still `data/`: Drift
/// types are named here and nowhere above this layer. The generated row
/// classes share names with the domain entities, so the `db` prefix is used
/// throughout, same as the repository.
library;

import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

/// Builds the per-serving facts shared by both row shapes — the two tables
/// deliberately carry the same eighteen nutrition columns,
/// `nutrition_entries`' being the log-time snapshot of `foods`' current
/// values (see `core/db/tables/nutrition_entries.dart`).
///
/// Every optional nutrient passes through as-is, `null` included: an
/// unstated nutrient is never flattened to zero, because `0` would be a
/// claim about the food rather than an admission that the label was silent
/// (see `domain/nutrition_facts.dart`).
///
/// The parameter list is deliberately exhaustive and required rather than
/// defaulted: adding a nutrient to `NutritionFacts` without adding it here
/// should break the build, not silently drop the value — which is exactly
/// how the thirteen optional nutrients were lost between S1-5 and schema
/// v21.
NutritionFacts factsFrom({
  required double caloriesKcal,
  required double proteinGrams,
  required double carbsGrams,
  required double fatGrams,
  required double? ironMg,
  required double? saturatedFatGrams,
  required double? transFatGrams,
  required double? monounsaturatedFatGrams,
  required double? polyunsaturatedFatGrams,
  required double? fiberGrams,
  required double? sugarsGrams,
  required double? addedSugarsGrams,
  required double? sodiumMg,
  required double? potassiumMg,
  required double? cholesterolMg,
  required double? calciumMg,
  required double? vitaminDMcg,
  required double? vitaminCMg,
}) {
  return NutritionFacts(
    caloriesKcal: caloriesKcal,
    proteinGrams: proteinGrams,
    carbsGrams: carbsGrams,
    fatGrams: fatGrams,
    ironMg: ironMg,
    saturatedFatGrams: saturatedFatGrams,
    transFatGrams: transFatGrams,
    monounsaturatedFatGrams: monounsaturatedFatGrams,
    polyunsaturatedFatGrams: polyunsaturatedFatGrams,
    fiberGrams: fiberGrams,
    sugarsGrams: sugarsGrams,
    addedSugarsGrams: addedSugarsGrams,
    sodiumMg: sodiumMg,
    potassiumMg: potassiumMg,
    cholesterolMg: cholesterolMg,
    calciumMg: calciumMg,
    vitaminDMcg: vitaminDMcg,
    vitaminCMg: vitaminCMg,
  );
}

DateTime _utcFromMillis(int millis) {
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

/// Maps a `foods` row to its domain entity.
Food foodToEntity(db.Food row) {
  return Food(
    id: row.id,
    name: row.name,
    brand: row.brand,
    servingDescription: row.servingDescription,
    servingGrams: row.servingGrams,
    servingVolumeMl: row.servingVolumeMl,
    perServing: factsFrom(
      caloriesKcal: row.caloriesKcal,
      proteinGrams: row.proteinGrams,
      carbsGrams: row.carbsGrams,
      fatGrams: row.fatGrams,
      ironMg: row.ironMg,
      saturatedFatGrams: row.saturatedFatGrams,
      transFatGrams: row.transFatGrams,
      monounsaturatedFatGrams: row.monounsaturatedFatGrams,
      polyunsaturatedFatGrams: row.polyunsaturatedFatGrams,
      fiberGrams: row.fiberGrams,
      sugarsGrams: row.sugarsGrams,
      addedSugarsGrams: row.addedSugarsGrams,
      sodiumMg: row.sodiumMg,
      potassiumMg: row.potassiumMg,
      cholesterolMg: row.cholesterolMg,
      calciumMg: row.calciumMg,
      vitaminDMcg: row.vitaminDMcg,
      vitaminCMg: row.vitaminCMg,
    ),
    barcode: row.barcode,
    source: FoodSource.fromStorage(row.source),
    providerFoodId: row.providerFoodId,
    createdAt: _utcFromMillis(row.createdAt),
    updatedAt: _utcFromMillis(row.updatedAt),
  );
}

/// Maps a `nutrition_entries` row to its domain entity, snapshot included.
NutritionEntry entryToEntity(db.NutritionEntry row) {
  return NutritionEntry(
    id: row.id,
    day: LocalDate.parse(row.day),
    meal: MealType.fromStorage(row.meal),
    foodId: row.foodId,
    foodName: row.foodName,
    foodBrand: row.foodBrand,
    servingDescription: row.servingDescription,
    quantityServings: row.quantityServings,
    quantityAmount: row.quantityAmount,
    // An unrecognised key reads as servings, which is the correct reading
    // of every row written before units existed (`domain/quantity_unit.dart`).
    quantityUnit: QuantityUnit.fromStorage(row.quantityUnit),
    servingGrams: row.servingGrams,
    servingVolumeMl: row.servingVolumeMl,
    perServing: factsFrom(
      caloriesKcal: row.caloriesKcal,
      proteinGrams: row.proteinGrams,
      carbsGrams: row.carbsGrams,
      fatGrams: row.fatGrams,
      ironMg: row.ironMg,
      saturatedFatGrams: row.saturatedFatGrams,
      transFatGrams: row.transFatGrams,
      monounsaturatedFatGrams: row.monounsaturatedFatGrams,
      polyunsaturatedFatGrams: row.polyunsaturatedFatGrams,
      fiberGrams: row.fiberGrams,
      sugarsGrams: row.sugarsGrams,
      addedSugarsGrams: row.addedSugarsGrams,
      sodiumMg: row.sodiumMg,
      potassiumMg: row.potassiumMg,
      cholesterolMg: row.cholesterolMg,
      calciumMg: row.calciumMg,
      vitaminDMcg: row.vitaminDMcg,
      vitaminCMg: row.vitaminCMg,
    ),
    createdAt: _utcFromMillis(row.createdAt),
    updatedAt: _utcFromMillis(row.updatedAt),
  );
}
