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
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/log_entry_dialog.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers;

/// The quantity picker: an amount plus a unit, and the promise that the
/// nutrition follows the unit rather than the number.
///
/// Nothing here asserts about wrapping, line counts or measured widths —
/// these run with `--use-test-fonts`, whose glyphs are fixed-width and share
/// nothing with the real ones, so any such assertion would be measuring the
/// test font.
void main() {
  final today = LocalDate.today();
  final now = DateTime.utc(2026, 8, 27, 8);

  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// A 30 g serving at 300 kcal, so a gram figure converts to a round
  /// serving count and back.
  Food oats({double? servingGrams = 30}) => Food(
    id: 'food-oats',
    name: 'Porridge oats',
    servingDescription: '1 cup (dry)',
    servingGrams: servingGrams,
    perServing: const NutritionFacts(
      caloriesKcal: 300,
      proteinGrams: 10,
      carbsGrams: 54,
      fatGrams: 5,
      ironMg: 3,
    ),
    createdAt: now,
    updatedAt: now,
  );

  Food milk({double? servingVolumeMl = 250}) => Food(
    id: 'food-milk',
    name: 'Whole Milk',
    servingDescription: '1 glass',
    servingVolumeMl: servingVolumeMl,
    perServing: const NutritionFacts(
      caloriesKcal: 150,
      proteinGrams: 8,
      carbsGrams: 12,
      fatGrams: 8,
    ),
    createdAt: now,
    updatedAt: now,
  );

  ProviderContainer container() {
    final result = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(result.dispose);
    return result;
  }

  Future<void> saveGoals(NutritionGoals goals) async {
    await container().read(nutritionGoalsRepositoryProvider).saveGoals(goals);
  }

  Future<List<NutritionEntry>> loggedEntries() {
    return container().read(nutritionRepositoryProvider).getEntriesFor(today);
  }

  Future<void> pumpDialog(
    WidgetTester tester, {
    Food? food,
    NutritionEntry? existing,
  }) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
      ..devicePixelRatio = 1;
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: LogEntryDialog(
              day: today,
              meal: MealType.breakfast,
              food: food,
              existing: existing,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The text currently in the amount field — read off the EditableText,
  /// since a `TextFormField` seeded with `initialValue` owns its controller
  /// internally.
  String amountFieldText(WidgetTester tester) {
    return tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('quantityField')),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
  }

  /// The unit the picker is actually sitting on.
  QuantityUnit? selectedUnit(WidgetTester tester) {
    return tester
        .widget<DropdownButtonFormField<QuantityUnit>>(
          find.byKey(const Key('quantityUnitField')),
        )
        .initialValue;
  }

  /// Every unit the picker is offering: opens the menu, records which unit
  /// labels it holds, and closes it again by re-selecting the unit already
  /// chosen (a no-op selection).
  Future<List<QuantityUnit>> offeredUnits(
    WidgetTester tester, {
    double? servingGrams = 30,
    double? servingVolumeMl,
  }) async {
    final selected = selectedUnit(tester)!;
    await tester.tap(find.byKey(const Key('quantityUnitField')));
    await tester.pumpAndSettle();

    String labelFor(QuantityUnit unit) {
      if (unit == QuantityUnit.serving) {
        if (servingGrams != null && servingGrams > 0) {
          final g = servingGrams == servingGrams.roundToDouble()
              ? servingGrams.round().toString()
              : servingGrams.toString();
          return 'Serving ($g g)';
        }
        if (servingVolumeMl != null && servingVolumeMl > 0) {
          final ml = servingVolumeMl == servingVolumeMl.roundToDouble()
              ? servingVolumeMl.round().toString()
              : servingVolumeMl.toString();
          return 'Serving ($ml ml)';
        }
        return 'Serving (1 cup (dry))';
      }
      return switch (unit) {
        QuantityUnit.gram => 'gram (g)',
        QuantityUnit.millilitre => 'millilitre (ml)',
        QuantityUnit.ounce => 'ounce (oz)',
        QuantityUnit.fluidOunce => 'fluid ounce (fl oz)',
        QuantityUnit.kilogram => 'kilogram (kg)',
        QuantityUnit.pound => 'pound (lb)',
        _ => unit.label,
      };
    }

    final offered = [
      for (final unit in QuantityUnit.values)
        if (find.text(labelFor(unit)).evaluate().isNotEmpty) unit,
    ];

    await tester.tap(find.text(labelFor(selected)).last);
    await tester.pumpAndSettle();
    return offered;
  }

  Future<void> pickUnit(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(const Key('quantityUnitField')));
    await tester.pumpAndSettle();
    // The label appears both in the closed button and in the open menu.
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a food with a serving weight offers every offerable unit, and says '
    'nothing about missing weights',
    (tester) async {
      await pumpDialog(tester, food: oats());

      final offered = await offeredUnits(tester);
      expect(
        offered,
        QuantityUnit.offerable,
        reason: 'a weighed food can be logged in any unit that is a MASS',
      );
      // Not `QuantityUnit.values`: millilitres and fluid ounces are no
      // longer offered, because a millilitre is not a mass and this app
      // stores no density (`domain/quantity_unit.dart`,
      // `knowledge/domain/nutrition.md`). The enum values survive so
      // entries logged in them still parse and display; `offeredUnits`
      // sweeps every value and would catch either one reappearing here.
      expect(offered.where((unit) => unit.isVolume), isEmpty);
      // Servings stays the default: the food describes itself that way, and
      // switching to weight is the user's move to make.
      expect(selectedUnit(tester), QuantityUnit.serving);
      expect(find.textContaining('gram weight per serving'), findsNothing);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a food with no recorded serving weight offers servings and nothing '
    'else, and says once what would change that',
    (tester) async {
      await pumpDialog(tester, food: oats(servingGrams: null));

      expect(
        await offeredUnits(tester, servingGrams: null),
        [QuantityUnit.serving],
        reason: 'a mass unit here could only fail or guess a weight',
      );
      // The picker is still there rather than hidden, and the explanation
      // is informative rather than corrective.
      expect(find.byKey(const Key('quantityUnitField')), findsOneWidget);
      expect(
        find.textContaining("doesn't have a gram weight or volume per serving"),
        findsOneWidget,
      );
      expect(find.textContaining('should'), findsNothing);

      await flushDriftTimers(tester);
    },
  );

  testWidgets('changing the unit keeps the typed number and moves the '
      'preview with it', (tester) async {
    await pumpDialog(tester, food: oats());

    await tester.enterText(find.byKey(const Key('quantityField')), '60');
    await tester.pumpAndSettle();
    // 60 servings at 300 kcal.
    expect(find.text('18000 kcal'), findsOneWidget);

    await pickUnit(tester, 'gram (g)');

    expect(
      amountFieldText(tester),
      '60',
      reason:
          'retyping the number after switching units is an insult to '
          'someone holding a scale',
    );
    expect(selectedUnit(tester), QuantityUnit.gram);
    // 60 g of a 30 g serving is 2 servings.
    expect(find.text('600 kcal'), findsOneWidget);
    expect(find.text('P 20 g · C 108 g · F 10 g'), findsOneWidget);
    expect(find.text('Iron 6.0 mg'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('logging 60 g of a 30 g-serving food stores two servings, '
      'and remembers it was grams', (tester) async {
    await container().read(nutritionRepositoryProvider).saveFood(oats());
    await pumpDialog(tester, food: oats());

    await tester.enterText(find.byKey(const Key('quantityField')), '60');
    await pickUnit(tester, 'gram (g)');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final entry = (await loggedEntries()).single;
    expect(entry.quantityServings, 2);
    expect(entry.quantityAmount, 60);
    expect(entry.quantityUnit, QuantityUnit.gram);
    expect(entry.servingGrams, 30);
    expect(
      entry.facts.caloriesKcal,
      600,
      reason: 'identical to what two servings would have contributed',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('reopening a gram-logged entry shows grams, not the serving '
      'count it works out to', (tester) async {
    final entry = NutritionEntry.fromFood(
      id: 'entry-1',
      day: today,
      meal: MealType.breakfast,
      food: oats(),
      amount: 47,
      unit: QuantityUnit.gram,
      now: now,
    );
    await container().read(nutritionRepositoryProvider).saveEntry(entry);

    await pumpDialog(tester, existing: entry);

    expect(amountFieldText(tester), '47');
    expect(
      selectedUnit(tester),
      QuantityUnit.gram,
      reason: 'the dialog reopens on the unit it was logged in',
    );
    // Not the 1.5666… servings it works out to.
    expect(find.text('1.57'), findsNothing);
    expect(amountFieldText(tester), isNot(startsWith('1.5')));

    await flushDriftTimers(tester);
  });

  testWidgets(
    'an entry with no serving-weight snapshot degrades to servings rather '
    'than pretending a weight',
    (tester) async {
      // Every pre-v13 row looks like this, as does anything logged from a
      // food nobody weighed.
      final entry = NutritionEntry.fromFood(
        id: 'entry-1',
        day: today,
        meal: MealType.breakfast,
        food: oats(servingGrams: null),
        amount: 1.5,
        now: now,
      );
      await container().read(nutritionRepositoryProvider).saveEntry(entry);

      await pumpDialog(tester, existing: entry);

      expect(amountFieldText(tester), '1.5');
      expect(selectedUnit(tester), QuantityUnit.serving);
      expect(
        find.textContaining("doesn't have a gram weight or volume per serving"),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets('hide calorie numbers still blanks the energy in the preview, '
      'and only the energy', (tester) async {
    await saveGoals(
      NutritionGoals(
        id: 'goals-1',
        createdAt: now,
        updatedAt: now,
        hideCalorieNumbers: true,
      ),
    );
    await pumpDialog(tester, food: oats());

    await tester.enterText(find.byKey(const Key('quantityField')), '60');
    await pickUnit(tester, 'gram (g)');

    expect(find.textContaining('kcal'), findsNothing);
    // The macros the mode leaves standing still track the converted amount.
    expect(find.text('P 20 g · C 108 g · F 10 g'), findsOneWidget);
    expect(find.text('Iron 6.0 mg'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'a pure-volume food offers volume units and logs millilitres',
    (tester) async {
      await container().read(nutritionRepositoryProvider).saveFood(milk());
      await pumpDialog(tester, food: milk());

      final offered = await offeredUnits(
        tester,
        servingGrams: null,
        servingVolumeMl: 250,
      );
      expect(offered, [
        QuantityUnit.serving,
        QuantityUnit.millilitre,
        QuantityUnit.fluidOunce,
      ]);

      await tester.enterText(find.byKey(const Key('quantityField')), '500');
      await pickUnit(tester, 'millilitre (ml)');
      expect(find.text('300 kcal'), findsOneWidget); // 2 servings

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final entry = (await loggedEntries()).single;
      expect(entry.quantityServings, 2);
      expect(entry.quantityAmount, 500);
      expect(entry.quantityUnit, QuantityUnit.millilitre);
      expect(entry.servingVolumeMl, 250);
      expect(entry.servingGrams, isNull);
      expect(entry.facts.caloriesKcal, 300);

      await flushDriftTimers(tester);
    },
  );
}
