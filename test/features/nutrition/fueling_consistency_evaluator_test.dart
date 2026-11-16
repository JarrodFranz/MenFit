import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/fueling_consistency_evaluator.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';

void main() {
  const evaluator = FuelingConsistencyEvaluator();
  final today = LocalDate(2026, 8, 31);

  NutritionEntry createEntry(LocalDate day, double proteinGrams) {
    return NutritionEntry(
      id: 'entry-${day.toIso()}-$proteinGrams',
      day: day,
      meal: MealType.lunch,
      foodName: 'High Protein Meal',
      quantityServings: 1,
      quantityAmount: 1,
      perServing: NutritionFacts(
        caloriesKcal: 500,
        proteinGrams: proteinGrams,
        carbsGrams: 40,
        fatGrams: 15,
      ),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  test(
    'returns milestone achieved when protein goal is met on 4 of 7 days',
    () {
      final goals = NutritionGoals(
        id: 'goals-1',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        proteinTargetGrams: 80,
        carbTargetGrams: 200,
        fatTargetGrams: 60,
      );

      final entries = [
        createEntry(today.addDays(0), 85),
        createEntry(today.addDays(-1), 75), // 75 >= 80 * 0.85 (68) -> met
        createEntry(today.addDays(-2), 90),
        createEntry(today.addDays(-3), 70), // 70 >= 68 -> met
        createEntry(today.addDays(-4), 30), // not met
      ];

      final result = evaluator.evaluate(
        entries: entries,
        goals: goals,
        today: today,
        basisKcal: null,
      );

      expect(result.isMilestoneAchieved, isTrue);
      expect(result.proteinGoalsMetCount, 4);
      expect(result.daysLoggedCount, 5);
      expect(result.milestoneTitle, contains('Protein & Fueling Champion'));
      expect(result.badgeLabel, '4/7 Protein');
    },
  );

  test(
    'returns milestone when 5 days are logged even without protein target',
    () {
      final goals = NutritionGoals(
        id: 'goals-1',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        proteinTargetGrams: 150,
        carbTargetGrams: 200,
        fatTargetGrams: 60,
      );

      final entries = [
        createEntry(today.addDays(0), 40),
        createEntry(today.addDays(-1), 40),
        createEntry(today.addDays(-2), 40),
        createEntry(today.addDays(-3), 40),
        createEntry(today.addDays(-4), 40),
      ];

      final result = evaluator.evaluate(
        entries: entries,
        goals: goals,
        today: today,
        basisKcal: null,
      );

      expect(result.isMilestoneAchieved, isTrue);
      expect(result.proteinGoalsMetCount, 0);
      expect(result.daysLoggedCount, 5);
      expect(result.milestoneTitle, contains('Consistent Fueling Milestone'));
      expect(result.badgeLabel, '5/7 Fueling');
    },
  );

  test('returns false when fewer than 4 days logged', () {
    final goals = NutritionGoals(
      id: 'goals-1',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      proteinTargetGrams: 100,
      carbTargetGrams: 200,
      fatTargetGrams: 60,
    );

    final entries = [
      createEntry(today.addDays(0), 100),
      createEntry(today.addDays(-1), 100),
    ];

    final result = evaluator.evaluate(
      entries: entries,
      goals: goals,
      today: today,
      basisKcal: null,
    );

    expect(result.isMilestoneAchieved, isFalse);
    expect(result.proteinGoalsMetCount, 2);
    expect(result.daysLoggedCount, 2);
  });

  group('percent-mode protein target', () {
    NutritionGoals percentGoals({
      required double proteinPercent,
    }) => NutritionGoals(
      id: 'goals-percent',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      macroTargetMode: MacroTargetMode.percent,
      proteinTargetPercent: proteinPercent,
      carbTargetPercent: 40,
      fatTargetPercent: 100 - proteinPercent - 40,
    );

    test(
      'derives 135 g from 30% of an 1800 kcal basis for the 85% threshold '
      '(114.75 g)',
      () {
        final goals = percentGoals(proteinPercent: 30);

        final entries = [
          // 30% of 1800 kcal is 135 g protein; 85% of that is 114.75 g.
          createEntry(today.addDays(0), 114.75), // exactly at threshold -> met
          createEntry(today.addDays(-1), 114.75),
          createEntry(today.addDays(-2), 114.75),
          createEntry(today.addDays(-3), 114.75),
          createEntry(today.addDays(-4), 100), // below threshold -> not met
        ];

        final result = evaluator.evaluate(
          entries: entries,
          goals: goals,
          today: today,
          basisKcal: 1800,
        );

        expect(result.proteinGoalsMetCount, 4);
        expect(result.isMilestoneAchieved, isTrue);
        expect(
          result.milestoneTitle,
          contains('Protein & Fueling Champion'),
        );
      },
    );

    test(
      'meets the same 120 g/day fixture on every day when the derived '
      'target is low enough',
      () {
        // 44% of 1000 kcal is 110 g protein; 85% of that is 93.5 g, well
        // under the 120 g logged every day.
        final goals = percentGoals(proteinPercent: 44);
        final entries = [
          for (var i = 0; i >= -6; i--) createEntry(today.addDays(i), 120),
        ];

        final result = evaluator.evaluate(
          entries: entries,
          goals: goals,
          today: today,
          basisKcal: 1000,
        );

        expect(result.daysLoggedCount, 7);
        expect(result.proteinGoalsMetCount, 7);
        expect(result.badgeLabel, '7/7 Protein');
      },
    );

    test(
      'meets the same 120 g/day fixture on no day when the derived target '
      'is high enough',
      () {
        // 40% of 2000 kcal is 200 g protein; 85% of that is 170 g, above
        // the 120 g logged every day.
        final goals = percentGoals(proteinPercent: 40);
        final entries = [
          for (var i = 0; i >= -6; i--) createEntry(today.addDays(i), 120),
        ];

        final result = evaluator.evaluate(
          entries: entries,
          goals: goals,
          today: today,
          basisKcal: 2000,
        );

        expect(result.daysLoggedCount, 7);
        expect(result.proteinGoalsMetCount, 0);
        // The days-logged milestone still fires -- only the protein axis
        // is gated by the (unreachable) target.
        expect(result.isMilestoneAchieved, isTrue);
        expect(
          result.milestoneTitle,
          contains('Consistent Fueling Milestone'),
        );
      },
    );

    test(
      'never counts a percent-mode target as met when there is no calorie '
      'basis to derive it from',
      () {
        final goals = percentGoals(proteinPercent: 30);
        final entries = [
          for (var i = 0; i >= -4; i--) createEntry(today.addDays(i), 200),
        ];

        final result = evaluator.evaluate(
          entries: entries,
          goals: goals,
          today: today,
          basisKcal: null,
        );

        expect(result.daysLoggedCount, 5);
        expect(result.proteinGoalsMetCount, 0);
        // Still earns the milestone through the days-logged path.
        expect(result.isMilestoneAchieved, isTrue);
        expect(
          result.milestoneTitle,
          contains('Consistent Fueling Milestone'),
        );
      },
    );
  });
}
