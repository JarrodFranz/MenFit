import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/keto/presentation/keto_macros_card.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

void main() {
  testWidgets('percentage targets explain their missing energy basis', (
    tester,
  ) async {
    final stamp = DateTime.utc(2026);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nutritionGoalsProvider.overrideWith(
            (ref) => Stream.value(
              NutritionGoals(
                id: 'goals',
                createdAt: stamp,
                updatedAt: stamp,
                macroTargetMode: MacroTargetMode.percent,
                carbTargetPercent: 10,
              ),
            ),
          ),
          dayCalorieTargetProvider.overrideWithValue(const DayCalorieTarget()),
          dayNutritionTotalsProvider.overrideWith(
            (ref, day) => Stream.value(
              const DayNutritionTotals(
                total: NutritionTotals.empty,
                byMeal: {},
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: KetoMacrosCard(day: LocalDate(2026, 1, 1)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('percentage targets in grams'), findsOneWidget);
    expect(find.textContaining('current target'), findsNothing);
  });
}
