import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

/// A valid EAN-13 (check digit verified).
const String _ean13 = '5000112637922';

/// The same string with its last digit changed, so the check digit fails.
const String _badCheckDigit = '5000112637923';

/// A real UPC-A as printed on a US packet — twelve digits...
const String _upcA = '016000275270';

/// ...and the thirteen-digit GTIN it is stored as. The canonicalisation is
/// what stops one tin of tomatoes becoming two catalogue rows
/// (`domain/barcode.dart`), and this pair is the case that actually happens.
const String _upcAEchoed = '0016000275270';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  /// The food popped back by the form, or `null` when it popped nothing.
  Food? popped;

  Widget host({FoodFormSeed? seed}) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.light(),
        // Pushed rather than used as `home`, so what the form pops is
        // observable — "use the food you already have" is a pop, and a
        // route with nothing under it would swallow the difference.
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popped = await Navigator.of(context).push<Food>(
                    MaterialPageRoute(
                      builder: (_) => FoodFormScreen(seed: seed),
                    ),
                  );
                },
                child: const Text('open the form'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openForm(WidgetTester tester, {FoodFormSeed? seed}) async {
    popped = null;
    // Tall enough that the whole form lays out; the barcode section sits
    // between the brand field and the nutrition basis.
    tester.view
      ..physicalSize = const Size(700, 2600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(seed: seed));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open the form'));
    await tester.pumpAndSettle();
  }

  /// Lets the real (unmocked) Drift futures inside `save` complete before
  /// pumping — the duplicate check reads the catalogue before anything is
  /// written, so a bare `pumpAndSettle` would land mid-save.
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String value) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  /// Fills in everything `validateFood` requires, leaving the barcode alone.
  Future<void> fillRequiredFields(WidgetTester tester) async {
    await enter(tester, 'foodNameField', 'Shop-brand oats');
    await enter(tester, 'caloriesField', '150');
    await enter(tester, 'proteinField', '5');
    await enter(tester, 'carbsField', '27');
    await enter(tester, 'fatField', '3');
  }

  Future<void> tapSave(WidgetTester tester) async {
    final save = find.text('Save food');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await settleRealAsync(tester);
  }

  String fieldText(WidgetTester tester, String key) {
    return tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
  }

  /// Puts a food in the catalogue the way the app does, through the
  /// repository, so the row is shaped exactly as a saved one.
  Future<Food> seedCatalogueFood({
    required String name,
    required String? barcode,
  }) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final now = DateTime.now().toUtc();
    final food = Food(
      id: EntityId.generate(),
      name: name,
      servingDescription: '40 g',
      servingGrams: 40,
      perServing: const NutritionFacts(
        caloriesKcal: 150,
        proteinGrams: 5,
        carbsGrams: 27,
        fatGrams: 3,
      ),
      barcode: barcode,
      createdAt: now,
      updatedAt: now,
    );
    await container.read(nutritionRepositoryProvider).saveFood(food);
    return food;
  }

  /// Runs [body] with the platform overridden, clearing it **inside the test
  /// body** — `flutter_test` asserts every foundation debug variable is unset
  /// at the end of the body, which runs before any tear-down, so a tear-down
  /// reset always arrives too late. Same pattern as
  /// `barcode_scan_screen_test.dart`.
  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  group('the barcode section', () {
    testWidgets('is on the blank form, with the field empty', (tester) async {
      await openForm(tester);

      expect(find.text('Barcode'), findsOneWidget);
      expect(find.byKey(const Key('foodBarcodeField')), findsOneWidget);
      expect(fieldText(tester, 'foodBarcodeField'), '');
    });

    testWidgets('is prefilled from a seed, and the other seeded fields '
        'still arrive', (tester) async {
      await openForm(
        tester,
        seed: const FoodFormSeed(
          barcode: _ean13,
          name: 'Porridge oats',
          brand: 'Quaker',
          calories: '372',
        ),
      );

      expect(fieldText(tester, 'foodBarcodeField'), _ean13);
      // The seeding this section could plausibly have broken.
      expect(fieldText(tester, 'foodNameField'), 'Porridge oats');
      expect(fieldText(tester, 'foodBrandField'), 'Quaker');
      expect(fieldText(tester, 'caloriesField'), '372');
    });

    testWidgets('offers Scan where there is a camera', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester);

        expect(find.byKey(const Key('foodBarcodeScanButton')), findsOneWidget);
      });
    });

    testWidgets(
      'hides Scan on a platform with no scanner, but keeps the field',
      (tester) async {
        // Manual entry is the documented path on Windows and Web, not a
        // fallback — gating the field on a camera would take the barcode
        // away from two of the four targets
        // (`core/platform/barcode_scanning.dart`).
        await onPlatform(TargetPlatform.windows, () async {
          await openForm(tester);

          expect(find.byKey(const Key('foodBarcodeScanButton')), findsNothing);
          expect(find.byKey(const Key('foodBarcodeField')), findsOneWidget);
        });
      },
    );

    testWidgets('clears back to empty, and saves no barcode', (tester) async {
      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _ean13);

      await tester.tap(find.byKey(const Key('foodBarcodeClearButton')));
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'foodBarcodeField'), '');

      await tapSave(tester);

      final rows = await database.select(database.foods).get();
      expect(rows.single.barcode, isNull);
    });
  });

  group('saving a typed barcode', () {
    testWidgets('stores the canonical digits, not what was typed', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _upcA);
      await tapSave(tester);

      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1));
      // A UPC-A and its EAN-13 spelling are the same product; storing what
      // was typed would make the next scan miss.
      expect(rows.single.barcode, _upcAEchoed);
      expect(rows.single.barcode, isNot(_upcA));
      expect(popped?.barcode, _upcAEchoed);
    });

    testWidgets(
      'a bad check digit blocks the save and never repeats the digits',
      (tester) async {
        await openForm(tester);
        await fillRequiredFields(tester);
        await enter(tester, 'foodBarcodeField', _badCheckDigit);
        await tapSave(tester);

        expect(
          find.text(
            "That doesn't look like a product barcode — check the digits?",
          ),
          findsOneWidget,
        );
        // Nothing written, and the form is still open to fix it.
        expect(await database.select(database.foods).get(), isEmpty);
        expect(popped, isNull);

        // S2: no message on screen repeats what was typed. (The field
        // itself holds it, which is why this looks at Text widgets only.)
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? '')
            .toList();
        expect(texts.where((text) => text.contains(_badCheckDigit)), isEmpty);
      },
    );

    testWidgets('a corrected barcode saves on the next attempt', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _badCheckDigit);
      await tapSave(tester);
      expect(await database.select(database.foods).get(), isEmpty);

      await enter(tester, 'foodBarcodeField', _ean13);
      await tapSave(tester);

      final rows = await database.select(database.foods).get();
      expect(rows.single.barcode, _ean13);
    });
  });

  group('a barcode already in the catalogue', () {
    testWidgets('offers the food she already has instead of a second row', (
      tester,
    ) async {
      final existing = await seedCatalogueFood(
        name: 'Porridge oats',
        barcode: _ean13,
      );

      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _ean13);
      await tapSave(tester);

      // The choice, named by the food rather than by the digits.
      expect(find.text('You already have this one'), findsOneWidget);
      expect(find.textContaining('Porridge oats'), findsWidgets);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .toList();
      expect(texts.where((text) => text.contains(_ean13)), isEmpty);

      // Nothing has been written while the question is open.
      expect(await database.select(database.foods).get(), hasLength(1));

      await tester.tap(find.byKey(const Key('duplicateBarcodeUseExisting')));
      await settleRealAsync(tester);

      // Still one row, and the form handed back the food she already had —
      // which is what every caller does with a saved food anyway.
      expect(await database.select(database.foods).get(), hasLength(1));
      expect(popped?.id, existing.id);
      expect(find.byType(FoodFormScreen), findsNothing);
    });

    testWidgets('still lets her save a separate food when she means to', (
      tester,
    ) async {
      // Two rows for one code is usually accidental, but it is legitimately
      // what someone wants when a shop re-uses a code or a recipe changed —
      // so this is a plain choice, not a warning to click through.
      await seedCatalogueFood(name: 'Porridge oats', barcode: _ean13);

      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _ean13);
      await tapSave(tester);

      await tester.tap(find.byKey(const Key('duplicateBarcodeSaveAnyway')));
      await settleRealAsync(tester);

      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(2));
      expect(rows.where((row) => row.barcode == _ean13), hasLength(2));
      expect(popped?.name, 'Shop-brand oats');
    });

    testWidgets('keeping editing writes nothing and leaves the form open', (
      tester,
    ) async {
      await seedCatalogueFood(name: 'Porridge oats', barcode: _ean13);

      await openForm(tester);
      await fillRequiredFields(tester);
      await enter(tester, 'foodBarcodeField', _ean13);
      await tapSave(tester);

      await tester.tap(find.byKey(const Key('duplicateBarcodeKeepEditing')));
      await settleRealAsync(tester);

      expect(await database.select(database.foods).get(), hasLength(1));
      expect(find.byType(FoodFormScreen), findsOneWidget);
      expect(popped, isNull);
    });

    testWidgets(
      'is not raised when the form is editing the very food that holds it',
      (tester) async {
        // A food's own row can never be a duplicate of itself, however many
        // times it is re-saved. The check compares ids, so this holds even
        // though the barcode matches exactly.
        final existing = await seedCatalogueFood(
          name: 'Porridge oats',
          barcode: _ean13,
        );

        await openForm(tester, seed: FoodFormSeed.forEditing(existing));
        await enter(tester, 'caloriesField', '162');
        await tapSave(tester);

        expect(find.text('You already have this one'), findsNothing);
        // Updated in place, not duplicated.
        final rows = await database.select(database.foods).get();
        expect(rows, hasLength(1));
        expect(rows.single.id, existing.id);
        expect(rows.single.caloriesKcal, 162);
      },
    );

    testWidgets(
      'IS raised when a different food already holds the typed barcode, and '
      'the edit-path dialog offers no "use existing" — only saving on this '
      'food in place',
      (tester) async {
        // The case a "the seed already had this barcode" exemption would
        // have waved straight through.
        final other = await seedCatalogueFood(
          name: 'Semi-skimmed milk',
          barcode: _ean13,
        );
        final editing = await seedCatalogueFood(
          name: 'Porridge oats',
          barcode: null,
        );

        await openForm(tester, seed: FoodFormSeed.forEditing(editing));
        await enter(tester, 'foodBarcodeField', _ean13);
        await tapSave(tester);

        // Named by the OTHER food that holds the barcode, and phrased for
        // the edit path — never the create-path copy or its "use existing"
        // choice, which would pop the other food and silently discard the
        // edits made to this one.
        expect(
          find.text('Another food already has this barcode'),
          findsOneWidget,
        );
        expect(find.text('You already have this one'), findsNothing);
        expect(find.textContaining('Semi-skimmed milk'), findsWidgets);
        expect(
          find.byKey(const Key('duplicateBarcodeUseExisting')),
          findsNothing,
        );

        await tester.tap(find.byKey(const Key('duplicateBarcodeSaveAnyway')));
        await settleRealAsync(tester);

        // In place, not a new row: still the same two rows, and the one
        // being edited now carries the barcode.
        final rows = await database.select(database.foods).get();
        expect(rows, hasLength(2));
        expect(popped?.id, editing.id);
        // Never the OTHER food — that would be the "use existing" outcome,
        // and it isn't offered here.
        expect(popped?.id, isNot(other.id));
        expect(popped?.barcode, _ean13);
        final updated = rows.firstWhere((row) => row.id == editing.id);
        expect(updated.barcode, _ean13);
        expect(await database.select(database.foods).get(), hasLength(2));
      },
    );
  });

  group('a legacy barcode that predates check-digit validation', () {
    testWidgets(
      'unchanged, it does not block saving an unrelated edit',
      (tester) async {
        final legacy = await seedCatalogueFood(
          name: 'Porridge oats',
          barcode: _badCheckDigit,
        );

        await openForm(tester, seed: FoodFormSeed.forEditing(legacy));
        await enter(tester, 'foodNameField', 'Porridge oats (own brand)');
        await tapSave(tester);

        // Saved, not blocked by a barcode nobody touched — and the field's
        // own error never fired.
        expect(
          find.text(
            "That doesn't look like a product barcode — check the digits?",
          ),
          findsNothing,
        );
        final rows = await database.select(database.foods).get();
        expect(rows, hasLength(1));
        expect(rows.single.name, 'Porridge oats (own brand)');
        // Preserved exactly as it already was — not re-derived through the
        // barcode parser, which would fail it and drop it.
        expect(rows.single.barcode, _badCheckDigit);
        expect(popped?.name, 'Porridge oats (own brand)');
      },
    );

    testWidgets(
      'edited to a different invalid code, the save is still refused',
      (tester) async {
        final legacy = await seedCatalogueFood(
          name: 'Porridge oats',
          barcode: _badCheckDigit,
        );
        // A second, different bad check digit — proves this isn't a
        // "barcode field is non-empty" exemption but a byte-identical one.
        const anotherBadCode = '5000112637924';

        await openForm(tester, seed: FoodFormSeed.forEditing(legacy));
        await enter(tester, 'foodBarcodeField', anotherBadCode);
        await tapSave(tester);

        expect(
          find.text(
            "That doesn't look like a product barcode — check the digits?",
          ),
          findsOneWidget,
        );
        final rows = await database.select(database.foods).get();
        expect(rows.single.barcode, _badCheckDigit);
        expect(popped, isNull);
      },
    );
  });
}
