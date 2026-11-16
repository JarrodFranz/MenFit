import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/home/presentation/widgets/macros_today_card.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

NutritionGoals _goals({
  bool hideCalorieNumbers = false,
  double? proteinGrams = 120,
  double? carbGrams = 240,
  double? fatGrams = 70,
}) {
  final now = DateTime.utc(2026, 9, 3);
  return NutritionGoals(
    id: 'goals',
    createdAt: now,
    updatedAt: now,
    proteinTargetGrams: proteinGrams,
    carbTargetGrams: carbGrams,
    fatTargetGrams: fatGrams,
    hideCalorieNumbers: hideCalorieNumbers,
  );
}

DayNutritionTotals _totals() => const DayNutritionTotals(
  total: NutritionTotals(
    facts: NutritionFacts(
      caloriesKcal: 1500,
      proteinGrams: 60,
      carbsGrams: 120,
      fatGrams: 35,
    ),
    entryCount: 4,
  ),
  byMeal: {},
);

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required NutritionGoals? goals,
    DayCalorieTarget target = const DayCalorieTarget(targetKcal: 2000),
    bool goalsPending = false,
  }) async {
    tester.view
      ..physicalSize = const Size(420, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final today = LocalDate.today();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dayNutritionTotalsProvider(
            today,
          ).overrideWith((ref) => Stream.value(_totals())),
          nutritionGoalsProvider.overrideWith(
            (ref) => goalsPending
                ? const Stream<NutritionGoals?>.empty()
                : Stream.value(goals),
          ),
          dayCalorieTargetProvider.overrideWith((ref) => target),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: MacrosTodayCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows energy against the target, and the three macros', (
    tester,
  ) async {
    await pumpCard(tester, goals: _goals());

    expect(find.text('1500 kcal of 2000 kcal'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('60 g of 120 g'), findsOneWidget);
    expect(find.text('120 g of 240 g'), findsOneWidget);
    expect(find.text('35 g of 70 g'), findsOneWidget);
  });

  testWidgets(
    'hideCalorieNumbers removes every energy figure and keeps the macros',
    (tester) async {
      await pumpCard(tester, goals: _goals(hideCalorieNumbers: true));

      // Not blanked, not greyed, not dashed - absent
      // (`knowledge/domain/nutrition.md`).
      expect(find.textContaining('kcal'), findsNothing);
      expect(find.text('No target set'), findsNothing);

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('60 g of 120 g'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
    },
  );

  testWidgets(
    'while the goals row is still loading no energy figure is rendered — '
    'unknown hides, it does not reveal',
    (tester) async {
      await pumpCard(tester, goals: null, goalsPending: true);

      // The card is built; only the energy line is withheld. Sweeping every
      // string rather than one expected label is the point: a flash of a kcal
      // figure is exactly what the preference exists to prevent, and it can
      // come from any line on this card.
      final everyString = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(everyString, isNotEmpty);
      expect(
        everyString.where((s) => s.contains('kcal')),
        isEmpty,
        reason: 'kcal text rendered before the preference was known',
      );
      expect(find.text('No target set'), findsNothing);
      expect(find.text('Protein'), findsOneWidget);
    },
  );

  testWidgets(
    'once the goals row emits with the preference off, the energy figure is '
    'there',
    (tester) async {
      await pumpCard(tester, goals: _goals());

      expect(find.text('1500 kcal of 2000 kcal'), findsOneWidget);
    },
  );

  testWidgets('says so plainly when no target is set', (tester) async {
    await pumpCard(
      tester,
      goals: _goals(proteinGrams: null, carbGrams: null, fatGrams: null),
      target: const DayCalorieTarget(),
    );

    expect(find.text('1500 kcal'), findsOneWidget);
    expect(find.text('No target set'), findsOneWidget);
    // No target means a bare value, never an invented "of 0 g".
    expect(find.text('60 g'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('labels an estimated target as an estimate', (tester) async {
    await pumpCard(
      tester,
      goals: _goals(),
      target: const DayCalorieTarget(targetKcal: 1847, isEstimate: true),
    );

    // Rounded to the nearest 10 and prefixed with "about" - the estimate is
    // never presented as precise.
    expect(find.text('1500 kcal of about 1850 kcal'), findsOneWidget);
  });
}
