import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';

void main() {
  group('calculateMacroTargets', () {
    const basisKcal = 2000;

    test(
      '0 locked macros calculates standard spread (20% P, 50% C, 30% F)',
      () {
        final outcome = calculateMacroTargets(
          locks: MacroLocks.none,
          calorieTargetKcal: basisKcal,
          resolvedTarget: null,
        );

        expect(outcome, isA<CalculatedMacroGrams>());
        final result = outcome as CalculatedMacroGrams;
        // 2000 kcal * 20% = 400 kcal / 4 = 100g protein
        expect(result.proteinGrams, equals(100));
        // 2000 kcal * 50% = 1000 kcal / 4 = 250g carbs
        expect(result.carbGrams, equals(250));
        // 2000 kcal * 30% = 600 kcal / 9 = 66.666...g fat
        expect(result.fatGrams, closeTo(66.67, 0.01));
        expect(result.basisKcal, equals(2000));
      },
    );

    test(
      '1 locked macro (Protein) splits remaining kcal across Carbs and Fat',
      () {
        // Lock protein at 150g = 600 kcal.
        // Remaining = 2000 - 600 = 1400 kcal.
        // Free: Carbs (std 50%) and Fat (std 30%). Total relative std = 80%.
        // Carbs kcal = 1400 * (50/80) = 875 kcal -> 875 / 4 = 218.75g carbs.
        // Fat kcal = 1400 * (30/80) = 525 kcal -> 525 / 9 = 58.333...g fat.
        final outcome = calculateMacroTargets(
          locks: const MacroLocks(protein: true),
          calorieTargetKcal: basisKcal,
          resolvedTarget: null,
          proteinTargetGrams: 150,
        );

        expect(outcome, isA<CalculatedMacroGrams>());
        final result = outcome as CalculatedMacroGrams;
        expect(result.proteinGrams, equals(150));
        expect(result.carbGrams, equals(218.75));
        expect(result.fatGrams, closeTo(58.33, 0.01));
      },
    );

    test(
      '1 locked macro (Carbs) splits remaining kcal across Protein and Fat',
      () {
        // Lock carbs at 200g = 800 kcal.
        // Remaining = 2000 - 800 = 1200 kcal.
        // Free: Protein (std 20%) and Fat (std 30%). Total relative std = 50%.
        // Protein kcal = 1200 * (20/50) = 480 kcal -> 480 / 4 = 120g protein.
        // Fat kcal = 1200 * (30/50) = 720 kcal -> 720 / 9 = 80g fat.
        final outcome = calculateMacroTargets(
          locks: const MacroLocks(carbs: true),
          calorieTargetKcal: basisKcal,
          resolvedTarget: null,
          carbTargetGrams: 200,
        );

        expect(outcome, isA<CalculatedMacroGrams>());
        final result = outcome as CalculatedMacroGrams;
        expect(result.proteinGrams, equals(120));
        expect(result.carbGrams, equals(200));
        expect(result.fatGrams, equals(80));
      },
    );

    test('2 locked macros (Protein & Fat) calculates remaining Carbs', () {
      // Protein = 150g (600 kcal), Fat = 60g (540 kcal). Locked = 1140 kcal.
      // Remaining = 2000 - 1140 = 860 kcal.
      // Carbs = 860 / 4 = 215g carbs.
      final outcome = calculateMacroTargets(
        locks: const MacroLocks(protein: true, fat: true),
        calorieTargetKcal: basisKcal,
        resolvedTarget: null,
        proteinTargetGrams: 150,
        fatTargetGrams: 60,
      );

      expect(outcome, isA<CalculatedMacroGrams>());
      final result = outcome as CalculatedMacroGrams;
      expect(result.proteinGrams, equals(150));
      expect(result.carbGrams, equals(215));
      expect(result.fatGrams, equals(60));
    });

    test('3 locked macros recalculates total daily calories from grams', () {
      // Protein = 150g (600 kcal), Carbs = 200g (800 kcal),
      // Fat = 50g (450 kcal). Total kcal = 600 + 800 + 450 = 1850 kcal.
      final outcome = calculateMacroTargets(
        locks: const MacroLocks(protein: true, carbs: true, fat: true),
        calorieTargetKcal: 2500, // Old calorie figure gets overwritten
        resolvedTarget: null,
        proteinTargetGrams: 150,
        carbTargetGrams: 200,
        fatTargetGrams: 50,
      );

      expect(outcome, isA<CalculatedCalories>());
      final result = outcome as CalculatedCalories;
      expect(result.caloriesKcal, equals(1850));
    });

    test(
      'returns NoCalculateBasis when no calorie basis is available',
      () {
        final outcome = calculateMacroTargets(
          locks: MacroLocks.none,
          calorieTargetKcal: null,
          resolvedTarget: const NoCalorieTarget(
            NoEnergyEstimate(
              missing: {EnergyEstimateInput.weightKg},
              activityLevelMissing: false,
            ),
          ),
        );

        expect(outcome, isA<NoCalculateBasis>());
      },
    );

    test(
      'returns CalculateError when a locked macro has a blank/null value',
      () {
        final outcome = calculateMacroTargets(
          locks: const MacroLocks(protein: true),
          calorieTargetKcal: basisKcal,
          resolvedTarget: null,
        );

        expect(outcome, isA<CalculateError>());
      },
    );

    test(
      'returns CalculateError when locked macros exceed calorie target',
      () {
        // Protein = 600g = 2400 kcal > 2000 kcal basis
        final outcome = calculateMacroTargets(
          locks: const MacroLocks(protein: true),
          calorieTargetKcal: basisKcal,
          resolvedTarget: null,
          proteinTargetGrams: 600,
        );

        expect(outcome, isA<CalculateError>());
      },
    );
  });
}
