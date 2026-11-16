import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/presentation/quick_add_dialog.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers;

void main() {
  late db.AppDatabase database;
  final day = LocalDate(2026, 8, 29);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildWidget({required MealType meal}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: QuickAddDialog(day: day, meal: meal),
        ),
      ),
    );
  }

  testWidgets(
    'entering macros automatically calculates calories',
    (tester) async {
      await tester.pumpWidget(buildWidget(meal: MealType.lunch));
      await tester.pumpAndSettle();

      // Enter 20g protein, 30g carbs, 10g fat ->
      // (20*4) + (30*4) + (10*9) = 80 + 120 + 90 = 290 kcal
      await tester.enterText(
        find.byKey(const Key('quickAddProteinField')),
        '20',
      );
      await tester.enterText(
        find.byKey(const Key('quickAddCarbsField')),
        '30',
      );
      await tester.enterText(
        find.byKey(const Key('quickAddFatField')),
        '10',
      );
      await tester.pumpAndSettle();

      final caloriesInput = tester.widget<TextFormField>(
        find.byKey(const Key('quickAddCaloriesField')),
      );
      expect(caloriesInput.controller?.text, equals('290'));

      // Tap Log meal
      await tester.tap(find.byKey(const Key('quickAddSaveButton')));
      await tester.pumpAndSettle();

      // Verify entry in database
      final rows = await database.select(database.nutritionEntries).get();
      expect(rows.length, equals(1));
      expect(rows.first.foodName, equals('Quick add'));
      expect(rows.first.meal, equals('lunch'));
      expect(rows.first.caloriesKcal, equals(290.0));
      expect(rows.first.proteinGrams, equals(20.0));
      expect(rows.first.carbsGrams, equals(30.0));
      expect(rows.first.fatGrams, equals(10.0));
    },
  );

  testWidgets(
    'entering calories directly without macros logs cleanly',
    (tester) async {
      await tester.pumpWidget(buildWidget(meal: MealType.breakfast));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quickAddNameField')),
        'Coffee & Croissant',
      );
      await tester.enterText(
        find.byKey(const Key('quickAddCaloriesField')),
        '420',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quickAddSaveButton')));
      await tester.pumpAndSettle();

      final rows = await database.select(database.nutritionEntries).get();
      expect(rows.length, equals(1));
      expect(rows.first.foodName, equals('Coffee & Croissant'));
      expect(rows.first.meal, equals('breakfast'));
      expect(rows.first.caloriesKcal, equals(420.0));
      expect(rows.first.proteinGrams, equals(0.0));
    },
  );

  testWidgets(
    'empty submit displays error',
    (tester) async {
      await tester.pumpWidget(buildWidget(meal: MealType.dinner));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quickAddSaveButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter calories or at least one macro.'),
        findsOneWidget,
      );
    },
  );

  group('save to my foods', () {
    /// Off is the shipped default and the one that must not drift: a
    /// catalogue that quietly filled up with "Lunch at cafe" would make the
    /// picker worse for everyone who never asked for it.
    testWidgets('off by default: nothing is added to the catalogue', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(meal: MealType.lunch));
      await tester.pumpAndSettle();

      final switchTile = tester.widget<SwitchListTile>(
        find.byKey(const Key('quickAddSaveToFoodsSwitch')),
      );
      expect(switchTile.value, isFalse);

      await tester.enterText(
        find.byKey(const Key('quickAddCaloriesField')),
        '420',
      );
      await tester.tap(find.byKey(const Key('quickAddSaveButton')));
      await tester.pumpAndSettle();

      expect(await database.select(database.foods).get(), isEmpty);
      final entries = await database.select(database.nutritionEntries).get();
      expect(entries.single.foodId, isNull);

      // Containment: this dialog watches no Drift stream, so nothing here
      // schedules drift's stream-cleanup timer today — but these are the
      // first tests in the file to write to `foods`, and an unmount costs
      // one pump against a whole file wedging if that ever changes.
      await flushDriftTimers(tester);
    });

    testWidgets('on: the same numbers become a reusable food', (tester) async {
      await tester.pumpWidget(buildWidget(meal: MealType.dinner));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quickAddNameField')),
        'House curry',
      );
      await tester.enterText(
        find.byKey(const Key('quickAddProteinField')),
        '20',
      );
      await tester.enterText(
        find.byKey(const Key('quickAddCarbsField')),
        '30',
      );
      await tester.enterText(find.byKey(const Key('quickAddFatField')), '10');
      await tester.pumpAndSettle();

      final toggle = find.byKey(const Key('quickAddSaveToFoodsSwitch'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quickAddSaveButton')));
      await tester.pumpAndSettle();

      final foods = await database.select(database.foods).get();
      expect(foods, hasLength(1));
      final food = foods.single;
      expect(food.name, 'House curry');
      // A quick add knows a portion, not a measurable unit of the food.
      expect(food.servingDescription, '1 serving');
      expect(food.servingGrams, isNull);
      expect(FoodSource.fromStorage(food.source), FoodSource.custom);
      expect(food.caloriesKcal, 290.0);
      expect(food.proteinGrams, 20.0);
      expect(food.carbsGrams, 30.0);
      expect(food.fatGrams, 10.0);

      // The entry links to it, which is what puts it in "Recent" next time.
      final entries = await database.select(database.nutritionEntries).get();
      expect(entries.single.foodId, food.id);
      expect(entries.single.caloriesKcal, 290.0);

      await flushDriftTimers(tester);
    });
  });
}
