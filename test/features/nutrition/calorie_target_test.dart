import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';

/// A fixed estimate to resolve targets against: BMR 1400, TDEE 1960
/// (moderately active, 1400 x 1.4 exactly, so the arithmetic below stays
/// readable).
const EnergyEstimate _estimate = EnergyEstimate(
  basalMetabolicRateKcal: 1400,
  totalDailyEnergyKcal: 1960,
  activityLevel: ActivityLevel.moderatelyActive,
);

void main() {
  group('resolveCalorieTarget', () {
    test('maintaining targets maintenance, ignoring any requested gap', () {
      final outcome = resolveCalorieTarget(
        estimate: _estimate,
        dailyDeficitKcal: 500,
      );

      expect(outcome, isA<CalorieTarget>());
      final target = outcome as CalorieTarget;
      expect(target.targetKcal, 1960);
      expect(target.maintenanceKcal, 1960);
      expect(
        target.appliedAdjustmentKcal,
        0,
        reason:
            'a stored deficit must not quietly apply while the goal is '
            '"stay where I am"',
      );
    });

    test('a modest deficit is applied as requested', () {
      final outcome = resolveCalorieTarget(
        estimate: _estimate,
        weightGoal: WeightGoal.lose,
        dailyDeficitKcal: 400,
      ) as CalorieTarget;

      expect(outcome.targetKcal, 1560);
      expect(outcome.maintenanceKcal, 1960);
      expect(outcome.appliedAdjustmentKcal, -400);
    });

    test('a surplus is applied as requested, and is never floored', () {
      final outcome = resolveCalorieTarget(
        estimate: _estimate,
        weightGoal: WeightGoal.gain,
        dailyDeficitKcal: 300,
      ) as CalorieTarget;

      expect(outcome.targetKcal, 2260);
      expect(outcome.appliedAdjustmentKcal, 300);
    });

    test(
      'a deficit landing exactly ON the BMR floor is allowed through '
      'un-floored (the floor is a lower bound, not an exclusive one)',
      () {
        final outcome = resolveCalorieTarget(
          estimate: _estimate,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 560,
        );

        expect(outcome, isA<CalorieTarget>());
        expect((outcome as CalorieTarget).targetKcal, 1400);
      },
    );
  });

  group('the BMR floor', () {
    test(
      'an over-aggressive deficit is floored at estimated BMR, and reports '
      'everything the UI needs to explain why',
      () {
        final outcome = resolveCalorieTarget(
          estimate: _estimate,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 900,
        );

        expect(
          outcome,
          isA<FlooredCalorieTarget>(),
          reason:
              '1960 - 900 = 1060, below the 1400 BMR floor - product '
              'decision 2 says this must not be produced silently',
        );
        final floored = outcome as FlooredCalorieTarget;
        expect(floored.targetKcal, 1400);
        expect(floored.floorKcal, 1400);
        expect(floored.targetKcal, floored.floorKcal);
        expect(
          floored.requestedKcal,
          1060,
          reason: 'what the request would have produced, kept for the copy',
        );
        expect(floored.maintenanceKcal, 1960);
        expect(floored.requestedAdjustmentKcal, -900);
        expect(
          floored.effectiveAdjustmentKcal,
          -560,
          reason: 'how much of the requested gap survived the floor',
        );
      },
    );

    test('the floored outcome carries a non-empty, non-clinical reason', () {
      final floored = resolveCalorieTarget(
        estimate: _estimate,
        weightGoal: WeightGoal.lose,
        dailyDeficitKcal: 1200,
      ) as FlooredCalorieTarget;

      expect(floored.explanation, isNotEmpty);
      expect(floored.explanation, floorExplanation);
      expect(
        floored.explanation.toLowerCase(),
        contains('estimate'),
        reason: 'the copy must say this is an estimate, not medical advice',
      );
      for (final banned in <String>[
        'should',
        'unhealthy',
        'dangerous',
        'too much',
        'too little',
        'failed',
      ]) {
        expect(
          floored.explanation.toLowerCase(),
          isNot(contains(banned)),
          reason: 'ED-safe copy: no shaming, no clinical framing ($banned)',
        );
      }
    });

    test(
      "the floor is the estimate's own BMR, not a hardcoded number - "
      'a different estimate floors at a different value',
      () {
        const leaner = EnergyEstimate(
          basalMetabolicRateKcal: 1180,
          totalDailyEnergyKcal: 1652,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        final floored = resolveCalorieTarget(
          estimate: leaner,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 900,
        ) as FlooredCalorieTarget;

        expect(floored.floorKcal, 1180);
        expect(
          floored.floorKcal,
          isNot(1200),
          reason:
              'a flat 1200 kcal floor is exactly the unsourced, '
              'medical-flavoured claim this design refuses to ship',
        );
      },
    );

    test('a negative requested gap is clamped to zero, never sign-flipped', () {
      final outcome = resolveCalorieTarget(
        estimate: _estimate,
        weightGoal: WeightGoal.lose,
        dailyDeficitKcal: -500,
      ) as CalorieTarget;

      expect(outcome.targetKcal, 1960);
      expect(outcome.appliedAdjustmentKcal, 0);
    });
  });

  group('no estimate', () {
    test(
      'without an energy estimate there is no target at all - no default '
      'number is invented',
      () {
        const gap = NoEnergyEstimate(
          missing: {EnergyEstimateInput.weightKg},
          activityLevelMissing: false,
        );

        final outcome = resolveCalorieTarget(
          estimate: gap,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 500,
        );

        expect(outcome, isA<NoCalorieTarget>());
        expect(
          (outcome as NoCalorieTarget).estimateGap.missing,
          {EnergyEstimateInput.weightKg},
          reason: 'the UI needs to say which input is still needed',
        );
      },
    );
  });

  group('WeightGoal storage', () {
    test('every value round-trips through storage', () {
      for (final goal in WeightGoal.values) {
        expect(WeightGoal.fromStorage(goal.toStorage()), goal);
      }
    });

    test('null and unknown storage values default to maintain', () {
      expect(WeightGoal.fromStorage(null), WeightGoal.maintain);
      expect(WeightGoal.fromStorage('shrink'), WeightGoal.maintain);
    });
  });
}
