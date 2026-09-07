import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';

part 'nutrition_totals.freezed.dart';

/// A summed slice of the diary — a whole day, or one meal within it.
///
/// [facts] carries the numbers; the two fields beside it carry the honesty:
/// [entryCount] so an empty slice can be told apart from a slice of
/// zero-calorie foods, and [ironIsPartial] so an iron total is never
/// presented as complete when some of the foods in it never stated their
/// iron (see `domain/nutrition_facts.dart` for why unknown iron is `null`
/// rather than `0`).
@freezed
abstract class NutritionTotals with _$NutritionTotals {
  const factory NutritionTotals({
    @Default(NutritionFacts.zero) NutritionFacts facts,

    /// How many diary entries were summed into [facts].
    @Default(0) int entryCount,

    /// Whether at least one summed entry didn't state its iron, making
    /// `facts.ironMg` a floor rather than a complete figure.
    @Default(false) bool ironIsPartial,

    /// Whether at least one summed entry didn't state its calcium.
    @Default(false) bool calciumIsPartial,

    /// Whether at least one summed entry didn't state its vitamin D.
    @Default(false) bool vitaminDIsPartial,

    /// Whether at least one summed entry didn't state its fiber.
    @Default(false) bool fiberIsPartial,

    /// Whether at least one summed entry didn't state its vitamin C.
    @Default(false) bool vitaminCIsPartial,

    /// Whether at least one summed entry didn't state its potassium.
    @Default(false) bool potassiumIsPartial,
  }) = _NutritionTotals;

  const NutritionTotals._();

  /// Nothing logged.
  static const NutritionTotals empty = NutritionTotals();

  /// Energy, in kilocalories.
  double get caloriesKcal => facts.caloriesKcal;

  /// Protein, in grams. A first-class adequacy indicator for this audience
  /// (`knowledge/domain/nutrition.md`).
  double get proteinGrams => facts.proteinGrams;

  /// Carbohydrate, in grams.
  double get carbsGrams => facts.carbsGrams;

  /// Fat, in grams.
  double get fatGrams => facts.fatGrams;

  /// Iron, in milligrams. `null` when *nothing* summed here stated iron;
  /// when non-null, read alongside [ironIsPartial] — a partial total is a
  /// floor, not the day's actual iron.
  double? get ironMg => facts.ironMg;

  /// Calcium, in milligrams.
  double? get calciumMg => facts.calciumMg;

  /// Vitamin D, in micrograms.
  double? get vitaminDMcg => facts.vitaminDMcg;

  /// Dietary fiber, in grams.
  double? get fiberGrams => facts.fiberGrams;

  /// Vitamin C, in milligrams.
  double? get vitaminCMg => facts.vitaminCMg;

  /// Potassium, in milligrams.
  double? get potassiumMg => facts.potassiumMg;

  /// Whether anything at all was logged into this slice.
  bool get isEmpty => entryCount == 0;
}

/// A day's diary, totalled overall and broken down per meal.
///
/// [byMeal] always contains an entry for **every** [MealType], empty ones
/// included, so the UI can lay out a stable set of meal sections without
/// null-checking or inventing placeholders.
@freezed
abstract class DayNutritionTotals with _$DayNutritionTotals {
  const factory DayNutritionTotals({
    required NutritionTotals total,
    required Map<MealType, NutritionTotals> byMeal,
  }) = _DayNutritionTotals;

  const DayNutritionTotals._();

  /// A day with nothing logged: zero totals, and an empty slice for every
  /// meal.
  factory DayNutritionTotals.empty() {
    return DayNutritionTotals(
      total: NutritionTotals.empty,
      byMeal: {for (final meal in MealType.values) meal: NutritionTotals.empty},
    );
  }
}

/// Totals [entries] for a single day: the overall figures and the per-meal
/// subtotals.
///
/// Pure — no clock, no I/O, no filtering by day: the caller passes the
/// entries it wants totalled (the repository's day query already scopes
/// them), so this function can equally total a week or a single meal's
/// worth without knowing what it's looking at.
///
/// Each entry contributes `perServing × quantityServings` — the entry's own
/// **snapshot**, never a live lookup of the food it came from (see
/// `domain/nutrition_entry.dart`). An empty list yields
/// [DayNutritionTotals.empty].
DayNutritionTotals computeDayTotals(List<NutritionEntry> entries) {
  var total = NutritionFacts.zero;
  var totalCount = 0;
  var totalIronPartial = false;
  var totalCalciumPartial = false;
  var totalVitaminDPartial = false;
  var totalFiberPartial = false;
  var totalVitaminCPartial = false;
  var totalPotassiumPartial = false;

  final mealFacts = <MealType, NutritionFacts>{
    for (final meal in MealType.values) meal: NutritionFacts.zero,
  };
  final mealCounts = <MealType, int>{
    for (final meal in MealType.values) meal: 0,
  };
  final mealIronPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };
  final mealCalciumPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };
  final mealVitaminDPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };
  final mealFiberPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };
  final mealVitaminCPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };
  final mealPotassiumPartial = <MealType, bool>{
    for (final meal in MealType.values) meal: false,
  };

  for (final entry in entries) {
    final facts = entry.facts;
    total = total.plus(facts);
    totalCount++;
    mealFacts[entry.meal] = mealFacts[entry.meal]!.plus(facts);
    mealCounts[entry.meal] = mealCounts[entry.meal]! + 1;

    if (facts.ironMg == null) {
      totalIronPartial = true;
      mealIronPartial[entry.meal] = true;
    }
    if (facts.calciumMg == null) {
      totalCalciumPartial = true;
      mealCalciumPartial[entry.meal] = true;
    }
    if (facts.vitaminDMcg == null) {
      totalVitaminDPartial = true;
      mealVitaminDPartial[entry.meal] = true;
    }
    if (facts.fiberGrams == null) {
      totalFiberPartial = true;
      mealFiberPartial[entry.meal] = true;
    }
    if (facts.vitaminCMg == null) {
      totalVitaminCPartial = true;
      mealVitaminCPartial[entry.meal] = true;
    }
    if (facts.potassiumMg == null) {
      totalPotassiumPartial = true;
      mealPotassiumPartial[entry.meal] = true;
    }
  }

  return DayNutritionTotals(
    total: NutritionTotals(
      facts: total,
      entryCount: totalCount,
      // An empty slice is not "partial" — there is nothing missing from a
      // total of nothing.
      ironIsPartial: totalCount > 0 && totalIronPartial,
      calciumIsPartial: totalCount > 0 && totalCalciumPartial,
      vitaminDIsPartial: totalCount > 0 && totalVitaminDPartial,
      fiberIsPartial: totalCount > 0 && totalFiberPartial,
      vitaminCIsPartial: totalCount > 0 && totalVitaminCPartial,
      potassiumIsPartial: totalCount > 0 && totalPotassiumPartial,
    ),
    byMeal: {
      for (final meal in MealType.values)
        meal: NutritionTotals(
          facts: mealFacts[meal]!,
          entryCount: mealCounts[meal]!,
          ironIsPartial: mealCounts[meal]! > 0 && mealIronPartial[meal]!,
          calciumIsPartial: mealCounts[meal]! > 0 && mealCalciumPartial[meal]!,
          vitaminDIsPartial:
              mealCounts[meal]! > 0 && mealVitaminDPartial[meal]!,
          fiberIsPartial: mealCounts[meal]! > 0 && mealFiberPartial[meal]!,
          vitaminCIsPartial:
              mealCounts[meal]! > 0 && mealVitaminCPartial[meal]!,
          potassiumIsPartial:
              mealCounts[meal]! > 0 && mealPotassiumPartial[meal]!,
        ),
    },
  );
}

/// Aggregated nutrition totals across a multi-day date range (week, month),
/// including sum totals, daily averages across the range, and per-day totals.
@freezed
abstract class RangeNutritionTotals with _$RangeNutritionTotals {
  const factory RangeNutritionTotals({
    required NutritionTotals total,
    required NutritionTotals dailyAverage,
    required int daysInRange,
    required int daysWithEntries,
    required Map<LocalDate, DayNutritionTotals> byDay,
  }) = _RangeNutritionTotals;

  const RangeNutritionTotals._();

  /// An empty range with no entries logged.
  factory RangeNutritionTotals.empty(int daysInRange) {
    return RangeNutritionTotals(
      total: NutritionTotals.empty,
      dailyAverage: NutritionTotals.empty,
      daysInRange: daysInRange,
      daysWithEntries: 0,
      byDay: const {},
    );
  }
}

/// Aggregates [entries] across a [daysInRange] window into
/// [RangeNutritionTotals].
RangeNutritionTotals computeRangeNutritionTotals({
  required List<NutritionEntry> entries,
  required int daysInRange,
}) {
  if (entries.isEmpty || daysInRange <= 0) {
    return RangeNutritionTotals.empty(daysInRange);
  }

  final entriesByDay = <LocalDate, List<NutritionEntry>>{};
  for (final entry in entries) {
    entriesByDay.putIfAbsent(entry.day, () => []).add(entry);
  }

  final byDay = <LocalDate, DayNutritionTotals>{};
  var totalFacts = NutritionFacts.zero;
  var totalCount = 0;
  var totalIronPartial = false;
  var totalCalciumPartial = false;
  var totalVitaminDPartial = false;
  var totalFiberPartial = false;
  var totalVitaminCPartial = false;
  var totalPotassiumPartial = false;

  for (final entry in entries) {
    final facts = entry.facts;
    totalFacts = totalFacts.plus(facts);
    totalCount++;
    if (facts.ironMg == null) totalIronPartial = true;
    if (facts.calciumMg == null) totalCalciumPartial = true;
    if (facts.vitaminDMcg == null) totalVitaminDPartial = true;
    if (facts.fiberGrams == null) totalFiberPartial = true;
    if (facts.vitaminCMg == null) totalVitaminCPartial = true;
    if (facts.potassiumMg == null) totalPotassiumPartial = true;
  }

  for (final mapEntry in entriesByDay.entries) {
    byDay[mapEntry.key] = computeDayTotals(mapEntry.value);
  }

  final total = NutritionTotals(
    facts: totalFacts,
    entryCount: totalCount,
    ironIsPartial: totalCount > 0 && totalIronPartial,
    calciumIsPartial: totalCount > 0 && totalCalciumPartial,
    vitaminDIsPartial: totalCount > 0 && totalVitaminDPartial,
    fiberIsPartial: totalCount > 0 && totalFiberPartial,
    vitaminCIsPartial: totalCount > 0 && totalVitaminCPartial,
    potassiumIsPartial: totalCount > 0 && totalPotassiumPartial,
  );

  final divisor = daysInRange > 0 ? daysInRange.toDouble() : 1.0;
  // An unknown nutrient stays unknown once averaged: dividing "nobody said"
  // by seven does not produce a number (`domain/nutrition_facts.dart`).
  double? perDay(double? value) => value == null ? null : value / divisor;
  final avgFacts = NutritionFacts(
    caloriesKcal: totalFacts.caloriesKcal / divisor,
    proteinGrams: totalFacts.proteinGrams / divisor,
    carbsGrams: totalFacts.carbsGrams / divisor,
    fatGrams: totalFacts.fatGrams / divisor,
    ironMg: perDay(totalFacts.ironMg),
    saturatedFatGrams: perDay(totalFacts.saturatedFatGrams),
    transFatGrams: perDay(totalFacts.transFatGrams),
    monounsaturatedFatGrams: perDay(totalFacts.monounsaturatedFatGrams),
    polyunsaturatedFatGrams: perDay(totalFacts.polyunsaturatedFatGrams),
    fiberGrams: perDay(totalFacts.fiberGrams),
    sugarsGrams: perDay(totalFacts.sugarsGrams),
    addedSugarsGrams: perDay(totalFacts.addedSugarsGrams),
    sodiumMg: perDay(totalFacts.sodiumMg),
    potassiumMg: perDay(totalFacts.potassiumMg),
    cholesterolMg: perDay(totalFacts.cholesterolMg),
    calciumMg: perDay(totalFacts.calciumMg),
    vitaminDMcg: perDay(totalFacts.vitaminDMcg),
    vitaminCMg: perDay(totalFacts.vitaminCMg),
  );

  final dailyAverage = NutritionTotals(
    facts: avgFacts,
    entryCount: (totalCount / divisor).round(),
    ironIsPartial: total.ironIsPartial,
    calciumIsPartial: total.calciumIsPartial,
    vitaminDIsPartial: total.vitaminDIsPartial,
    fiberIsPartial: total.fiberIsPartial,
    vitaminCIsPartial: total.vitaminCIsPartial,
    potassiumIsPartial: total.potassiumIsPartial,
  );

  return RangeNutritionTotals(
    total: total,
    dailyAverage: dailyAverage,
    daysInRange: daysInRange,
    daysWithEntries: entriesByDay.keys.length,
    byDay: byDay,
  );
}
