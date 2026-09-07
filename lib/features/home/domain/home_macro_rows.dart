/// The home dashboard's three-macro read of today's diary.
///
/// Pure Dart, no Flutter: the card above it only draws what this decides.
///
/// Two rules from `knowledge/domain/nutrition.md` live here rather than in
/// the widget, because they are the kind of thing a redesign quietly loses:
///
/// * a macro with **no target** is a value and nothing else - there is no
///   implied zero target and no bar, because a share of nothing is not a
///   target of nothing (`domain/nutrition_goals.dart`);
/// * [HomeMacroRow.fraction] **clamps at 1** and is never inverted past the
///   target. Nothing on this dashboard turns red for eating; an amount
///   eaten is not a score.
library;

import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

/// Which macro a [HomeMacroRow] carries.
enum HomeMacro {
  protein('Protein'),
  carbs('Carbs'),
  fat('Fat');

  const HomeMacro(this.label);

  /// Display name, shared by the bar's label and its spoken description so
  /// the two can't drift.
  final String label;
}

/// One macro's logged grams for today, and the target it is read against
/// when there is one.
class HomeMacroRow {
  const HomeMacroRow({
    required this.macro,
    required this.grams,
    this.targetGrams,
  });

  final HomeMacro macro;

  /// Grams logged today.
  final double grams;

  /// The day's target in grams, or `null` when none is set - a normal,
  /// permanent state, not a missing value to fill in.
  final double? targetGrams;

  /// How far through the target today's total is, `0.0`-`1.0`, or `null`
  /// when there is no target to be a fraction of.
  ///
  /// Clamped at the top on purpose (see this library's dartdoc). A
  /// non-positive target yields `null` rather than a division blow-up: a
  /// target of zero grams is not a target.
  double? get fraction {
    final target = targetGrams;
    if (target == null || target <= 0) return null;
    return (grams / target).clamp(0.0, 1.0);
  }
}

/// Today's protein, carbs and fat, in that order, each against its target.
///
/// [basisKcal] is the day's energy target, which is what a percentage-mode
/// macro split is a percentage *of*. Pass the same figure the diary shows;
/// `null` when there is none, in which case a percent-mode goal honestly
/// reports no gram targets at all rather than inventing them.
List<HomeMacroRow> homeMacroRows({
  required NutritionTotals totals,
  required NutritionGoals? goals,
  required int? basisKcal,
}) {
  // Never `goals?.proteinTargetGrams` and friends directly: those hold a
  // value only when the user stated her targets in grams, so a percent-mode
  // goal read that way would show no macro target at all.
  final targets = goals?.macroTargetGramsFor(basisKcal);
  return [
    HomeMacroRow(
      macro: HomeMacro.protein,
      grams: totals.proteinGrams,
      targetGrams: targets?.protein,
    ),
    HomeMacroRow(
      macro: HomeMacro.carbs,
      grams: totals.carbsGrams,
      targetGrams: targets?.carbs,
    ),
    HomeMacroRow(
      macro: HomeMacro.fat,
      grams: totals.fatGrams,
      targetGrams: targets?.fat,
    ),
  ];
}
