import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

/// Editing a food used to write a **second catalogue row** and leave the
/// original beside it: the form generated a fresh id every time, so "Edit
/// food details & macros" quietly grew the catalogue by one per edit and the
/// diary's food links kept pointing at the row nobody had corrected.
///
/// [FoodFormSeed.forEditing] is now the single way in, and it carries the
/// three things hand-built seeds kept getting wrong — the id, the source,
/// and every optional nutrient.
void main() {
  final created = DateTime.utc(2026, 1, 1, 9);

  late db.AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// A food with its optional nutrients filled in. Since schema v21 all of
  /// them reach the `foods` table, so the keeps-everything-else test below
  /// asserts the whole set rather than the subset that used to survive.
  Food fullFood({
    String id = 'food-oats',
    String? barcode = '5000112637922',
    FoodSource source = FoodSource.custom,
  }) {
    return Food(
      id: id,
      name: 'Porridge oats',
      brand: 'Quaker',
      servingDescription: '1 cup (dry)',
      servingGrams: 40,
      perServing: const NutritionFacts(
        caloriesKcal: 150,
        proteinGrams: 5,
        carbsGrams: 27,
        fatGrams: 3,
        saturatedFatGrams: 0.6,
        fiberGrams: 4.2,
        sugarsGrams: 0.5,
        sodiumMg: 11,
        ironMg: 1.8,
        calciumMg: 21,
      ),
      barcode: barcode,
      source: source,
      createdAt: created,
      updatedAt: created,
    );
  }

  Future<void> putInCatalogue(Food food) =>
      container.read(nutritionRepositoryProvider).saveFood(food);

  Future<Food?> saveForm(
    FoodFormSeed? seed,
    void Function(FoodFormController) edit,
  ) {
    final controller = container.read(
      foodFormControllerProvider(seed).notifier,
    );
    edit(controller);
    return controller.save();
  }

  group('editing an existing food', () {
    test('updates the same row instead of adding a second one', () async {
      final original = fullFood();
      await putInCatalogue(original);

      final saved = await saveForm(
        FoodFormSeed.forEditing(original),
        (controller) => controller.updateCalories('162'),
      );

      expect(saved?.id, original.id);
      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1), reason: 'an edit must not grow the catalogue');
      expect(rows.single.id, original.id);
      expect(rows.single.caloriesKcal, 162);
    });

    test('preserves createdAt and moves updatedAt', () async {
      final original = fullFood();
      await putInCatalogue(original);

      await saveForm(
        FoodFormSeed.forEditing(original),
        (controller) => controller.updateCalories('162'),
      );

      final row = (await database.select(database.foods).get()).single;
      expect(row.createdAt, created.millisecondsSinceEpoch);
      expect(row.updatedAt, greaterThan(row.createdAt));
    });

    test(
      'an edit that touches only the calories keeps everything else',
      () async {
        // The failure mode an in-place update could introduce: `saveFood`
        // writes the whole row, so anything the seed forgot is erased.
        //
        // Schema v21 gave `foods` columns for all thirteen optional
        // nutrients, so this now asserts the full set. Before v21 saturated
        // fat, fibre, sodium and the rest were collected by the form,
        // validated, and then discarded at the repository boundary with no
        // warning to the user — `forEditing` already carried them, so
        // closing the gap was a schema change and nothing more.
        final original = fullFood();
        await putInCatalogue(original);

        await saveForm(
          FoodFormSeed.forEditing(original),
          (controller) => controller.updateCalories('162'),
        );

        final row = (await database.select(database.foods).get()).single;
        expect(row.caloriesKcal, 162);
        expect(row.proteinGrams, 5);
        expect(row.carbsGrams, 27);
        expect(row.fatGrams, 3);
        expect(row.ironMg, 1.8);
        expect(row.saturatedFatGrams, 0.6);
        expect(row.fiberGrams, 4.2);
        expect(row.sugarsGrams, 0.5);
        expect(row.sodiumMg, 11);
        expect(row.calciumMg, 21);
        // The ones `fullFood` leaves unstated stay unstated: a blank field
        // is missing data, never a 0 the user never typed.
        expect(row.transFatGrams, isNull);
        expect(row.monounsaturatedFatGrams, isNull);
        expect(row.polyunsaturatedFatGrams, isNull);
        expect(row.addedSugarsGrams, isNull);
        expect(row.potassiumMg, isNull);
        expect(row.cholesterolMg, isNull);
        expect(row.vitaminDMcg, isNull);
        expect(row.vitaminCMg, isNull);
        expect(row.name, 'Porridge oats');
        expect(row.brand, 'Quaker');
        expect(row.barcode, '5000112637922');
      },
    );

    test('optional nutrients typed into the form reach the row', () async {
      // The defect schema v21 closed: the form collected and validated all
      // thirteen, `Food.perServing` carried them, and `saveFood` dropped
      // them because `foods` had no columns.
      final original = fullFood();
      await putInCatalogue(original);

      await saveForm(FoodFormSeed.forEditing(original), (controller) {
        controller
          ..updateTransFat('0.1')
          ..updateMonounsaturatedFat('1.2')
          ..updatePolyunsaturatedFat('1.3')
          ..updateAddedSugars('0.4')
          ..updatePotassium('350')
          ..updateCholesterol('0.2')
          ..updateVitaminD('1.1')
          ..updateVitaminC('0.9');
      });

      final row = (await database.select(database.foods).get()).single;
      expect(row.transFatGrams, 0.1);
      expect(row.monounsaturatedFatGrams, 1.2);
      expect(row.polyunsaturatedFatGrams, 1.3);
      expect(row.addedSugarsGrams, 0.4);
      expect(row.potassiumMg, 350);
      expect(row.cholesterolMg, 0.2);
      expect(row.vitaminDMcg, 1.1);
      expect(row.vitaminCMg, 0.9);
      // And the ones the seed brought in are still there beside them.
      expect(row.saturatedFatGrams, 0.6);
      expect(row.fiberGrams, 4.2);
    });

    test('clearing an optional nutrient clears the column', () async {
      final original = fullFood();
      await putInCatalogue(original);

      await saveForm(
        FoodFormSeed.forEditing(original),
        (controller) => controller.updateFiber(''),
      );

      final row = (await database.select(database.foods).get()).single;
      expect(row.fiberGrams, isNull, reason: 'blanked means unknown again');
      expect(row.sodiumMg, 11, reason: 'the others are untouched');
    });

    test('keeps the serving description the user wrote', () async {
      // A gram basis would rewrite '1 cup (dry)' as '1 serving (40 g)'.
      // Tolerable when an edit produced a new row; data loss now that it
      // updates the food itself.
      final original = fullFood();
      await putInCatalogue(original);

      await saveForm(
        FoodFormSeed.forEditing(original),
        (controller) => controller.updateCalories('162'),
      );

      final row = (await database.select(database.foods).get()).single;
      expect(row.servingDescription, '1 cup (dry)');
      expect(row.servingGrams, 40);
    });

    test('keeps the provenance of a provider-sourced food', () async {
      final original = fullFood(source: FoodSource.openFoodFacts);
      await putInCatalogue(original);

      final saved = await saveForm(
        FoodFormSeed.forEditing(original),
        (controller) => controller.updateCalories('162'),
      );

      expect(saved?.source, FoodSource.openFoodFacts);
      final row = (await database.select(database.foods).get()).single;
      expect(row.source, 'open_food_facts');
    });
  });

  group('creating a food', () {
    test('still generates a fresh id and adds a row', () async {
      await putInCatalogue(fullFood());

      final saved = await saveForm(null, (controller) {
        controller
          ..updateName('Shop-brand oats')
          ..updateCalories('150')
          ..updateProtein('5')
          ..updateCarbs('27')
          ..updateFat('3');
      });

      expect(saved?.id, isNotEmpty);
      expect(saved?.id, isNot('food-oats'));
      expect(await database.select(database.foods).get(), hasLength(2));
    });
  });

  group('the duplicate-barcode check, now that there is an id', () {
    test('ignores the edited food own row', () async {
      final original = fullFood();
      await putInCatalogue(original);
      final seed = FoodFormSeed.forEditing(original);

      final saved = await saveForm(
        seed,
        (controller) => controller.updateCalories('162'),
      );

      // Its own barcode found its own row, which is not a collision.
      expect(saved, isNotNull);
      expect(
        container.read(foodFormControllerProvider(seed)).duplicateBarcodeMatch,
        isNull,
      );
    });

    test('still catches another food barcode typed onto this one', () async {
      // The case a barcode-based exemption would have waved through: she
      // opens food A and types food B's code onto it.
      final original = fullFood(barcode: null);
      final other = fullFood(id: 'food-milk');
      await putInCatalogue(original);
      await putInCatalogue(other);
      final seed = FoodFormSeed.forEditing(original);

      final saved = await saveForm(
        seed,
        (controller) => controller.updateBarcode('5000112637922'),
      );

      expect(saved, isNull);
      expect(
        container
            .read(foodFormControllerProvider(seed))
            .duplicateBarcodeMatch
            ?.id,
        'food-milk',
      );
      // Nothing was written while the question stands.
      expect(await database.select(database.foods).get(), hasLength(2));
    });

    test('a create-a-food seed has no id, so any match counts', () async {
      // `forUnknownBarcode` carries a barcode but no food, so there is
      // nothing for a match to be the same as — every live row on that code
      // is a real collision.
      await putInCatalogue(fullFood());

      final seed = FoodFormSeed.forUnknownBarcode('5000112637922');
      final saved = await saveForm(seed, (controller) {
        controller
          ..updateName('Shop-brand oats')
          ..updateCalories('150')
          ..updateProtein('5')
          ..updateCarbs('27')
          ..updateFat('3');
      });

      expect(saved, isNull);
      expect(
        container.read(foodFormControllerProvider(seed)).duplicateBarcodeMatch,
        isNotNull,
      );
    });
  });

  test('only forEditing reports an existing food', () {
    expect(FoodFormSeed.forEditing(fullFood()).isEditingExistingFood, isTrue);
    expect(FoodFormSeed.forEditing(fullFood()).existingFoodId, 'food-oats');
    expect(
      FoodFormSeed.forUnknownBarcode('5000112637922').isEditingExistingFood,
      isFalse,
    );
    expect(const FoodFormSeed(barcode: '').isEditingExistingFood, isFalse);
  });

  test('forEditing carries every optional nutrient into the form', () {
    // Asserted on the seed itself as well as through a save, because this is
    // the list that will be forgotten when a nutrient is added to `Food`.
    final seed = FoodFormSeed.forEditing(fullFood());

    expect(seed.saturatedFat, '0.6');
    expect(seed.fiber, '4.2');
    expect(seed.sugars, '0.5');
    expect(seed.sodium, '11');
    expect(seed.iron, '1.8');
    expect(seed.calcium, '21');
    // Unset ones stay blank, never '0' — the same rule the provider seed
    // follows, for the same reason.
    expect(seed.transFat, '');
    expect(seed.potassium, '');
    expect(seed.vitaminC, '');
  });
}
