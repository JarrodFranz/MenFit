import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/meal_section.dart';

/// The action row's `Wrap` — three actions ("Add food", "Quick add", "Copy
/// from yesterday") can appear on one empty meal, and at compact widths they
/// don't all fit on one line (`presentation/widgets/meal_section.dart`'s own
/// comment on the `Wrap`). Without `runSpacing`, a wrapped second line sits
/// flush against the first.
void main() {
  testWidgets(
    'the action row spaces a wrapped second line the same as the first',
    (tester) async {
      // Narrow enough that "Add food", "Quick add" and "Copy from
      // yesterday" cannot all fit on one line, so the `Wrap` actually wraps.
      tester.view
        ..physicalSize = const Size(320, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: MealSection(
              meal: MealType.breakfast,
              entries: const [],
              subtotal: NutritionTotals.empty,
              hideCalorieNumbers: false,
              onAddFood: () {},
              onEditEntry: (_) {},
              onQuickAdd: () {},
              onCopyFromYesterday: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      // Matches `spacing` (both `tokens.spacingXs`) rather than staying at
      // the `Wrap` default of 0, which is the bug this guards against: a
      // wrapped row with horizontal gaps between buttons and none between
      // its lines.
      expect(wrap.runSpacing, wrap.spacing);
      expect(wrap.runSpacing, greaterThan(0));
    },
  );
}
