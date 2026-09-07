import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/home/domain/home_macro_rows.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

NutritionGoals _goals({
  MacroTargetMode mode = MacroTargetMode.grams,
  double? proteinGrams,
  double? carbGrams,
  double? fatGrams,
  double? proteinPercent,
  double? carbPercent,
  double? fatPercent,
}) {
  final now = DateTime.utc(2026, 9, 3);
  return NutritionGoals(
    id: 'goals',
    createdAt: now,
    updatedAt: now,
    macroTargetMode: mode,
    proteinTargetGrams: proteinGrams,
    carbTargetGrams: carbGrams,
    fatTargetGrams: fatGrams,
    proteinTargetPercent: proteinPercent,
    carbTargetPercent: carbPercent,
    fatTargetPercent: fatPercent,
  );
}

NutritionTotals _totals({
  double protein = 0,
  double carbs = 0,
  double fat = 0,
  int entryCount = 1,
}) => NutritionTotals(
  facts: NutritionFacts(
    proteinGrams: protein,
    carbsGrams: carbs,
    fatGrams: fat,
  ),
  entryCount: entryCount,
);

void main() {
  group('homeMacroRows', () {
    test('returns protein, carbs and fat in that order', () {
      final rows = homeMacroRows(
        totals: _totals(protein: 80, carbs: 210, fat: 60),
        goals: null,
        basisKcal: null,
      );

      expect(
        rows.map((row) => row.macro),
        [HomeMacro.protein, HomeMacro.carbs, HomeMacro.fat],
      );
      expect(rows.map((row) => row.grams), [80, 210, 60]);
    });

    test('carries no target, and no fraction, when no goals are set', () {
      final rows = homeMacroRows(
        totals: _totals(protein: 80),
        goals: null,
        basisKcal: 2000,
      );

      expect(rows.every((row) => row.targetGrams == null), isTrue);
      expect(rows.every((row) => row.fraction == null), isTrue);
    });

    test('reads gram-mode targets straight off the goals', () {
      final rows = homeMacroRows(
        totals: _totals(protein: 60, carbs: 100, fat: 40),
        goals: _goals(proteinGrams: 120, carbGrams: 200, fatGrams: 80),
        basisKcal: null,
      );

      expect(rows.map((row) => row.targetGrams), [120, 200, 80]);
      expect(rows.map((row) => row.fraction), [0.5, 0.5, 0.5]);
    });

    test(
      'derives percent-mode targets from the energy basis, and reports none '
      'at all when there is no basis to take a share of',
      () {
        final goals = _goals(
          mode: MacroTargetMode.percent,
          // Grams left over from a previous mode must not be read while
          // percent is the authoritative mode.
          proteinGrams: 999,
          proteinPercent: 30,
          carbPercent: 40,
          fatPercent: 30,
        );

        final withBasis = homeMacroRows(
          totals: _totals(protein: 75),
          goals: goals,
          basisKcal: 2000,
        );
        // 30% of 2000 kcal at 4 kcal/g = 150 g.
        expect(withBasis.first.targetGrams, closeTo(150, 0.001));
        expect(withBasis.first.fraction, closeTo(0.5, 0.001));

        final withoutBasis = homeMacroRows(
          totals: _totals(protein: 75),
          goals: goals,
          basisKcal: null,
        );
        expect(withoutBasis.every((row) => row.targetGrams == null), isTrue);
      },
    );

    test('clamps the fraction at full past the target — never over, never '
        'inverted', () {
      final rows = homeMacroRows(
        totals: _totals(protein: 300),
        goals: _goals(proteinGrams: 120),
        basisKcal: null,
      );

      expect(rows.first.fraction, 1.0);
      // The grams themselves are untouched: the bar caps, the number does
      // not lie about what was logged.
      expect(rows.first.grams, 300);
    });

    test('a zero or negative target is no target, not a division blow-up', () {
      final rows = homeMacroRows(
        totals: _totals(protein: 40),
        goals: _goals(proteinGrams: 0),
        basisKcal: null,
      );

      expect(rows.first.fraction, isNull);
    });
  });
}
