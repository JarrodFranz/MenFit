import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_facts.freezed.dart';

/// The nutrition of one unit of something: energy, the three main macros,
/// detailed fat/carb breakdowns, minerals, and vitamins.
///
/// Used in two places that must stay identical in shape — a `Food`'s
/// per-serving definition and the **snapshot** a `NutritionEntry` copies at
/// log time (see `core/db/tables/nutrition_entries.dart` for why that
/// snapshot exists). Keeping one value type for both is what makes
/// "multiply by servings, then add up" a one-liner in
/// `domain/nutrition_totals.dart`.
///
/// Optional nutrients (saturated fat, fiber, sugars, iron, sodium, etc.) are
/// nullable and `null` means **unknown**, never zero: most labels don't state
/// all nutrients, and reporting an unstated value as `0` would turn missing
/// data into a claim about the food.
@freezed
abstract class NutritionFacts with _$NutritionFacts {
  const factory NutritionFacts({
    /// Energy, in kilocalories.
    @Default(0) double caloriesKcal,

    /// Protein, in grams.
    @Default(0) double proteinGrams,

    /// Carbohydrate, in grams.
    @Default(0) double carbsGrams,

    /// Fat, in grams.
    @Default(0) double fatGrams,

    /// Saturated fat, in grams.
    double? saturatedFatGrams,

    /// Trans fat, in grams.
    double? transFatGrams,

    /// Monounsaturated fat, in grams.
    double? monounsaturatedFatGrams,

    /// Polyunsaturated fat, in grams.
    double? polyunsaturatedFatGrams,

    /// Dietary fiber, in grams.
    double? fiberGrams,

    /// Total sugars, in grams.
    double? sugarsGrams,

    /// Added sugars, in grams.
    double? addedSugarsGrams,

    /// Sodium, in milligrams.
    double? sodiumMg,

    /// Potassium, in milligrams.
    double? potassiumMg,

    /// Cholesterol, in milligrams.
    double? cholesterolMg,

    /// Iron, in milligrams. `null` means unknown — see the class doc.
    double? ironMg,

    /// Calcium, in milligrams.
    double? calciumMg,

    /// Vitamin D, in micrograms.
    double? vitaminDMcg,

    /// Vitamin C, in milligrams.
    double? vitaminCMg,
  }) = _NutritionFacts;

  const NutritionFacts._();

  /// All-zero facts with unknown optional nutrients — the identity for [plus]
  /// and the starting accumulator for a day with nothing logged.
  static const NutritionFacts zero = NutritionFacts();

  /// Whether iron is stated at all. Reported up through day totals so the
  /// UI can say "some of today's foods don't list iron" instead of
  /// implying a total is complete when it isn't.
  bool get hasIron => ironMg != null;

  /// These facts multiplied by [factor] — the "two and a half servings"
  /// calculation. Unknown nutrients stay unknown (scaling `null` cannot invent
  /// a value).
  NutritionFacts scaled(double factor) {
    double? scale(double? v) => v == null ? null : v * factor;
    return NutritionFacts(
      caloriesKcal: caloriesKcal * factor,
      proteinGrams: proteinGrams * factor,
      carbsGrams: carbsGrams * factor,
      fatGrams: fatGrams * factor,
      saturatedFatGrams: scale(saturatedFatGrams),
      transFatGrams: scale(transFatGrams),
      monounsaturatedFatGrams: scale(monounsaturatedFatGrams),
      polyunsaturatedFatGrams: scale(polyunsaturatedFatGrams),
      fiberGrams: scale(fiberGrams),
      sugarsGrams: scale(sugarsGrams),
      addedSugarsGrams: scale(addedSugarsGrams),
      sodiumMg: scale(sodiumMg),
      potassiumMg: scale(potassiumMg),
      cholesterolMg: scale(cholesterolMg),
      ironMg: scale(ironMg),
      calciumMg: scale(calciumMg),
      vitaminDMcg: scale(vitaminDMcg),
      vitaminCMg: scale(vitaminCMg),
    );
  }

  /// These facts added to [other].
  ///
  /// Optional nutrients follow "unknown contributes nothing": the result is
  /// `null` only when *neither* side stated the nutrient, so a sum of one known
  /// and one unknown value reports the known part rather than collapsing to
  /// unknown. That makes the sum a floor, not a guess.
  NutritionFacts plus(NutritionFacts other) {
    double? add(double? a, double? b) =>
        (a == null && b == null) ? null : (a ?? 0) + (b ?? 0);
    return NutritionFacts(
      caloriesKcal: caloriesKcal + other.caloriesKcal,
      proteinGrams: proteinGrams + other.proteinGrams,
      carbsGrams: carbsGrams + other.carbsGrams,
      fatGrams: fatGrams + other.fatGrams,
      saturatedFatGrams: add(saturatedFatGrams, other.saturatedFatGrams),
      transFatGrams: add(transFatGrams, other.transFatGrams),
      monounsaturatedFatGrams: add(
        monounsaturatedFatGrams,
        other.monounsaturatedFatGrams,
      ),
      polyunsaturatedFatGrams: add(
        polyunsaturatedFatGrams,
        other.polyunsaturatedFatGrams,
      ),
      fiberGrams: add(fiberGrams, other.fiberGrams),
      sugarsGrams: add(sugarsGrams, other.sugarsGrams),
      addedSugarsGrams: add(addedSugarsGrams, other.addedSugarsGrams),
      sodiumMg: add(sodiumMg, other.sodiumMg),
      potassiumMg: add(potassiumMg, other.potassiumMg),
      cholesterolMg: add(cholesterolMg, other.cholesterolMg),
      ironMg: add(ironMg, other.ironMg),
      calciumMg: add(calciumMg, other.calciumMg),
      vitaminDMcg: add(vitaminDMcg, other.vitaminDMcg),
      vitaminCMg: add(vitaminCMg, other.vitaminCMg),
    );
  }
}
