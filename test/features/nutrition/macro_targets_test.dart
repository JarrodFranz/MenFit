import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';

void main() {
  final now = DateTime.utc(2026, 8, 27, 8);

  // `mode` is required rather than defaulted, so every case below states
  // which representation it is asserting about.
  NutritionGoals goals({
    required MacroTargetMode mode,
    int? calorieTargetKcal,
    double? proteinTargetGrams,
    double? carbTargetGrams,
    double? fatTargetGrams,
    double? proteinTargetPercent,
    double? carbTargetPercent,
    double? fatTargetPercent,
  }) => NutritionGoals(
    id: 'goals-1',
    createdAt: now,
    updatedAt: now,
    macroTargetMode: mode,
    calorieTargetKcal: calorieTargetKcal,
    proteinTargetGrams: proteinTargetGrams,
    carbTargetGrams: carbTargetGrams,
    fatTargetGrams: fatTargetGrams,
    proteinTargetPercent: proteinTargetPercent,
    carbTargetPercent: carbTargetPercent,
    fatTargetPercent: fatTargetPercent,
  );

  const resolved = CalorieTarget(
    targetKcal: 1800,
    maintenanceKcal: 1800,
    appliedAdjustmentKcal: 0,
  );

  group('MacroTargetMode storage', () {
    test('round-trips both values', () {
      for (final mode in MacroTargetMode.values) {
        expect(MacroTargetMode.fromStorage(mode.toStorage()), mode);
      }
    });

    test('null and anything unrecognised read as grams', () {
      expect(MacroTargetMode.fromStorage(null), MacroTargetMode.grams);
      expect(MacroTargetMode.fromStorage(''), MacroTargetMode.grams);
      expect(MacroTargetMode.fromStorage('GRAMS'), MacroTargetMode.grams);
      expect(
        MacroTargetMode.fromStorage('kilojoules'),
        MacroTargetMode.grams,
        reason:
            'grams is what every row written before this column existed '
            'already meant',
      );
    });
  });

  group('deriveMacroTargetGrams', () {
    test('converts each share at its Atwater factor', () {
      final outcome = deriveMacroTargetGrams(
        calorieTargetKcal: 2000,
        resolvedTarget: null,
        proteinTargetPercent: 30,
        carbTargetPercent: 40,
        fatTargetPercent: 30,
      ) as DerivedMacroTargetGrams;

      // 30% of 2000 = 600 kcal / 4 = 150 g.
      expect(outcome.proteinGrams, closeTo(150, 1e-9));
      // 40% of 2000 = 800 kcal / 4 = 200 g.
      expect(outcome.carbGrams, closeTo(200, 1e-9));
      // 30% of 2000 = 600 kcal / 9 = 66.67 g.
      expect(outcome.fatGrams, closeTo(600 / 9, 1e-9));
      expect(outcome.basisKcal, 2000);
      expect(outcome.basisIsEstimated, isFalse);
    });

    test('a share of 0 is zero grams, an unset share is null', () {
      final outcome = deriveMacroTargetGrams(
        calorieTargetKcal: 2000,
        resolvedTarget: null,
        proteinTargetPercent: 0,
      ) as DerivedMacroTargetGrams;

      expect(outcome.proteinGrams, 0);
      expect(
        outcome.carbGrams,
        isNull,
        reason: 'an unset share is unset, not a share of nothing',
      );
      expect(outcome.fatGrams, isNull);
    });

    test(
      "the user's own calorie target wins over the resolved estimate",
      () async {
        final outcome = deriveMacroTargetGrams(
          calorieTargetKcal: 2400,
          resolvedTarget: resolved,
          proteinTargetPercent: 25,
        ) as DerivedMacroTargetGrams;

        expect(outcome.basisKcal, 2400);
        expect(outcome.basisIsEstimated, isFalse);
        expect(outcome.proteinGrams, closeTo(2400 * 0.25 / 4, 1e-9));
      },
    );

    test('with no calorie target the resolved estimate is the basis', () {
      final outcome = deriveMacroTargetGrams(
        calorieTargetKcal: null,
        resolvedTarget: resolved,
        proteinTargetPercent: 20,
      ) as DerivedMacroTargetGrams;

      expect(outcome.basisKcal, 1800);
      expect(outcome.basisIsEstimated, isTrue);
      expect(outcome.proteinGrams, closeTo(1800 * 0.2 / 4, 1e-9));
    });

    test('a floored target is still a basis - it is what she works to', () {
      const floored = FlooredCalorieTarget(
        targetKcal: 1400,
        requestedKcal: 1200,
        floorKcal: 1400,
        maintenanceKcal: 1700,
        requestedAdjustmentKcal: -500,
      );

      final outcome = deriveMacroTargetGrams(
        calorieTargetKcal: null,
        resolvedTarget: floored,
        fatTargetPercent: 30,
      ) as DerivedMacroTargetGrams;

      expect(outcome.basisKcal, 1400);
      expect(outcome.fatGrams, closeTo(1400 * 0.3 / 9, 1e-9));
    });

    test(
      'no calorie target and no estimate is a typed no-basis outcome, never '
      'zeros',
      () {
        const noEstimate = NoCalorieTarget(
          NoEnergyEstimate(
            missing: {EnergyEstimateInput.weightKg},
            activityLevelMissing: true,
          ),
        );

        expect(
          deriveMacroTargetGrams(
            calorieTargetKcal: null,
            resolvedTarget: noEstimate,
            proteinTargetPercent: 30,
            carbTargetPercent: 40,
            fatTargetPercent: 30,
          ),
          isA<NoMacroTargetBasis>(),
        );
        expect(
          deriveMacroTargetGrams(
            calorieTargetKcal: null,
            resolvedTarget: null,
            proteinTargetPercent: 30,
          ),
          isA<NoMacroTargetBasis>(),
        );
      },
    );

    test(
      'an explicit calorie target of zero yields no basis rather than '
      'falling through to the estimate',
      () {
        expect(
          deriveMacroTargetGrams(
            calorieTargetKcal: 0,
            resolvedTarget: resolved,
            proteinTargetPercent: 30,
          ),
          isA<NoMacroTargetBasis>(),
          reason:
              "falling through would silently swap the user's number for a "
              'different one',
        );
      },
    );

    test(
      'a nonsensical share yields null grams rather than a nonsense one',
      () {
        final outcome = deriveMacroTargetGrams(
          calorieTargetKcal: 2000,
          resolvedTarget: null,
          proteinTargetPercent: -10,
          carbTargetPercent: double.nan,
          fatTargetPercent: double.infinity,
        ) as DerivedMacroTargetGrams;

        expect(outcome.proteinGrams, isNull);
        expect(outcome.carbGrams, isNull);
        expect(outcome.fatGrams, isNull);
      },
    );
  });

  group('macroGramsForPercent', () {
    test('is the Atwater conversion and nothing else', () {
      expect(
        macroGramsForPercent(
          basisKcal: 1000,
          percent: 100,
          kcalPerGram: fatKcalPerGram,
        ),
        closeTo(1000 / 9, 1e-9),
      );
      expect(
        macroGramsForPercent(
          basisKcal: 1000,
          percent: 50,
          kcalPerGram: carbKcalPerGram,
        ),
        closeTo(125, 1e-9),
      );
    });
  });

  group('hasAnyTarget', () {
    test('only the authoritative macro set counts', () {
      expect(
        goals(
          mode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
        ).hasAnyTarget,
        isTrue,
      );
      expect(
        goals(
          mode: MacroTargetMode.grams,
          proteinTargetGrams: 110,
        ).hasAnyTarget,
        isTrue,
      );
      expect(
        goals(
          mode: MacroTargetMode.percent,
          proteinTargetGrams: 110,
        ).hasAnyTarget,
        isFalse,
        reason:
            'grams left over from before a mode switch are kept, but they '
            'are not the target while percent is the authoritative mode',
      );
      expect(
        goals(
          mode: MacroTargetMode.grams,
          proteinTargetPercent: 30,
        ).hasAnyTarget,
        isFalse,
      );
    });

    test('a calorie target alone still counts in either mode', () {
      for (final mode in MacroTargetMode.values) {
        expect(
          goals(mode: mode, calorieTargetKcal: 2000).hasAnyTarget,
          isTrue,
        );
      }
    });

    test('nothing set is nothing set', () {
      for (final mode in MacroTargetMode.values) {
        expect(goals(mode: mode).hasAnyTarget, isFalse);
      }
    });
  });
}
