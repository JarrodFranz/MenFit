import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const FoodFormScreen(),
      ),
    );
  }

  /// The food form is taller than the 800x600 default test view, and its
  /// fields are built by a lazy `ListView` — so a row below the fold is not
  /// merely off-screen, it does not exist, and `ensureVisible` cannot find
  /// what was never built. This test predates two sections that have since
  /// been added above the basis picker (the barcode field, and the
  /// "Scan nutrition label" section from ADR 012), each of which pushed the
  /// amount/unit row further down. Same fix, same reason, as
  /// `food_form_barcode_test.dart`.
  void useTallView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> enter(WidgetTester tester, String key, String value) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'defines food with Per Reference 100g basis and saves to database',
    (tester) async {
      useTallView(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Enter food name
      await enter(tester, 'foodNameField', 'Greek Yogurt 0%');

      // Select Per Reference basis
      final perReference = find.text('Per Reference (e.g. 100g)');
      await tester.ensureVisible(perReference);
      await tester.pumpAndSettle();
      await tester.tap(perReference);
      await tester.pumpAndSettle();

      // Amount should default to 100
      expect(find.text('100'), findsOneWidget);

      // Enter primary macros
      await enter(tester, 'caloriesField', '59');
      await enter(tester, 'proteinField', '10.3');
      await enter(tester, 'carbsField', '3.6');
      await enter(tester, 'fatField', '0.4');

      // Expand additional nutrients
      final expansionTile = find.byKey(const Key('additionalNutrientsTile'));
      await tester.ensureVisible(expansionTile);
      await tester.pumpAndSettle();
      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Enter calcium and sugars
      await enter(tester, 'sugarsField', '3.6');
      await enter(tester, 'calciumField', '110');

      // Save food
      final saveButton = find.text('Save food');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final rows = await database.select(database.foods).get();
      expect(rows.length, equals(1));
      expect(rows.first.name, equals('Greek Yogurt 0%'));
      expect(rows.first.servingDescription, equals('Per 100 g'));
      expect(rows.first.servingGrams, equals(100.0));
      expect(rows.first.caloriesKcal, equals(59.0));
      expect(rows.first.proteinGrams, equals(10.3));
    },
  );

  testWidgets(
    'defines food with Serving mode in grams and computes serving description',
    (tester) async {
      useTallView(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await enter(tester, 'foodNameField', 'Protein Bar');

      // Select unit 'g'
      final dropdown = find.byKey(const Key('basisUnitField'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('g').last);
      await tester.pumpAndSettle();

      // Enter amount 60g
      await enter(tester, 'basisAmountField', '60');

      // Enter macros
      await enter(tester, 'caloriesField', '210');
      await enter(tester, 'proteinField', '20');
      await enter(tester, 'carbsField', '15');
      await enter(tester, 'fatField', '7');

      // Save food
      final saveButton = find.text('Save food');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final rows = await database.select(database.foods).get();
      expect(rows.length, equals(1));
      expect(rows.first.name, equals('Protein Bar'));
      expect(rows.first.servingDescription, equals('1 serving (60 g)'));
      expect(rows.first.servingGrams, equals(60.0));
      expect(rows.first.caloriesKcal, equals(210.0));
    },
  );

  testWidgets(
    'the basis-unit picker offers both mass and volume units',
    (tester) async {
      useTallView(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final dropdown = find.byKey(const Key('basisUnitField'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('ml'), findsWidgets);
      expect(find.text('fl oz'), findsWidgets);
      expect(find.text('g'), findsWidgets);
      expect(find.text('oz'), findsWidgets);
      expect(find.text('serving'), findsWidgets);
    },
  );

  testWidgets(
    'defines food with Per Reference 100ml basis and saves to database',
    (tester) async {
      useTallView(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await enter(tester, 'foodNameField', 'Oat Milk');

      // Select Per Reference basis
      final perReference = find.text('Per Reference (e.g. 100g)');
      await tester.ensureVisible(perReference);
      await tester.pumpAndSettle();
      await tester.tap(perReference);
      await tester.pumpAndSettle();

      // Change unit to ml
      final dropdown = find.byKey(const Key('basisUnitField'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ml').last);
      await tester.pumpAndSettle();

      // Enter macros
      await enter(tester, 'caloriesField', '45');
      await enter(tester, 'proteinField', '1.0');
      await enter(tester, 'carbsField', '6.5');
      await enter(tester, 'fatField', '1.5');

      // Save food
      final saveButton = find.text('Save food');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final rows = await database.select(database.foods).get();
      expect(rows.length, equals(1));
      expect(rows.first.name, equals('Oat Milk'));
      expect(rows.first.servingDescription, equals('Per 100 ml'));
      expect(rows.first.servingVolumeMl, equals(100.0));
      expect(rows.first.servingGrams, isNull);
      expect(rows.first.caloriesKcal, equals(45.0));
    },
  );

  testWidgets(
    'defines food with Serving mode in ml and saves servingVolumeMl',
    (tester) async {
      useTallView(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await enter(tester, 'foodNameField', 'Orange Juice');

      // Select unit 'ml'
      final dropdown = find.byKey(const Key('basisUnitField'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ml').last);
      await tester.pumpAndSettle();

      // Enter amount 250ml
      await enter(tester, 'basisAmountField', '250');

      // Enter macros
      await enter(tester, 'caloriesField', '110');
      await enter(tester, 'proteinField', '2');
      await enter(tester, 'carbsField', '26');
      await enter(tester, 'fatField', '0');

      // Save food
      final saveButton = find.text('Save food');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final rows = await database.select(database.foods).get();
      expect(rows.length, equals(1));
      expect(rows.first.name, equals('Orange Juice'));
      expect(rows.first.servingDescription, equals('1 serving (250 ml)'));
      expect(rows.first.servingVolumeMl, equals(250.0));
      expect(rows.first.servingGrams, isNull);
      expect(rows.first.caloriesKcal, equals(110.0));
    },
  );
}
