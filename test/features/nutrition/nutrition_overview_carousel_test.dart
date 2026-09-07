import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/nutrition_overview_carousel.dart';

void main() {
  final now = DateTime.utc(2026, 8, 28);

  Widget buildSubject({
    required NutritionTotals totals,
    DayCalorieTarget? target,
    NutritionGoals? goals,
    bool hideCalorieNumbers = false,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: NutritionOverviewCarousel(
            totals: totals,
            target: target ?? const DayCalorieTarget(targetKcal: 2000),
            goals: goals,
            hideCalorieNumbers: hideCalorieNumbers,
          ),
        ),
      ),
    );
  }

  testWidgets('renders Calories card by default with goal and food stats', (
    tester,
  ) async {
    const totals = NutritionTotals(
      facts: NutritionFacts(
        caloriesKcal: 600,
        proteinGrams: 40,
        carbsGrams: 70,
        fatGrams: 15,
      ),
      entryCount: 2,
    );

    await tester.pumpWidget(buildSubject(totals: totals));

    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('1400 kcal'), findsOneWidget); // 2000 - 600 remaining
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('Base Goal'), findsOneWidget);
    expect(find.text('2000 kcal'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('600 kcal'), findsOneWidget);
  });

  testWidgets(
    'when calories exceed target, shows Goal met and non-negative remaining',
    (tester) async {
      const totals = NutritionTotals(
        facts: NutritionFacts(
          caloriesKcal: 2200,
          proteinGrams: 100,
          carbsGrams: 250,
          fatGrams: 80,
        ),
        entryCount: 4,
      );

      await tester.pumpWidget(buildSubject(totals: totals));

      expect(
        find.text('0 kcal'),
        findsOneWidget,
      ); // 0 remaining, never negative
      expect(find.text('Goal met'), findsOneWidget);
    },
  );

  testWidgets(
    'when hideCalorieNumbers is true, Calories card is omitted completely',
    (tester) async {
      const totals = NutritionTotals(
        facts: NutritionFacts(
          caloriesKcal: 600,
          proteinGrams: 40,
          carbsGrams: 70,
          fatGrams: 15,
        ),
        entryCount: 2,
      );

      final goals = NutritionGoals(
        id: 'g1',
        createdAt: now,
        updatedAt: now,
        calorieTargetKcal: 2000,
        proteinTargetGrams: 120,
        carbTargetGrams: 200,
        fatTargetGrams: 60,
        hideCalorieNumbers: true,
      );

      await tester.pumpWidget(
        buildSubject(
          totals: totals,
          goals: goals,
          hideCalorieNumbers: true,
        ),
      );

      // No calories text or numbers visible anywhere
      expect(find.text('Calories'), findsNothing);
      expect(find.text('Remaining'), findsNothing);
      expect(find.textContaining('kcal'), findsNothing);

      // First page is Macros
      expect(find.text('Macros'), findsOneWidget);
      expect(find.text('Carbohydrates'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
    },
  );
}
