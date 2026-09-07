import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

/// `Food.source` is not a label, it is a claim about **where the numbers came
/// from** — and ADR 010 leans on it twice: attribution (ODbL obliges naming
/// Open Food Facts for data that came from it) and separability (a future
/// sync backend must be able to tell provider-derived rows from
/// user-authored ones before share-alike bites).
///
/// The form used to decide it by asking "was there a seed at all", which got
/// the commonest barcode case exactly backwards: a scan the database has
/// never heard of seeds the form with **nothing but the barcode**, the user
/// types every figure off the packet herself, and the row was still saved as
/// `open_food_facts`.
void main() {
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

  /// Fills in whatever the seed left blank and saves.
  Future<Food?> save(FoodFormSeed? seed) async {
    final controller = container.read(foodFormControllerProvider(seed).notifier)
      ..updateName('Shop-brand oats')
      ..updateCalories('150')
      ..updateProtein('5')
      ..updateCarbs('27')
      ..updateFat('3');
    return controller.save();
  }

  /// A record the provider actually had — the only case that may claim the
  /// provider as its source.
  const providerFood = ProviderFood(
    source: FoodSource.openFoodFacts,
    barcode: '5000112637922',
    name: 'Porridge oats',
    servingDescription: '40 g',
    servingBasis: ServingBasis.derivedFromPer100g,
    brand: 'Quaker',
    servingGrams: 40,
    caloriesKcal: 372,
    proteinGrams: 11.2,
    carbsGrams: 60,
    fatGrams: 8,
  );

  test('a blank form saves a custom food', () async {
    final food = await save(null);

    expect(food?.source, FoodSource.custom);
  });

  test(
    'a barcode the provider had never heard of saves a CUSTOM food',
    () async {
      // The regression. `forUnknownBarcode` means the provider answered
      // "no such product" and supplied not one number; every figure on this
      // food is the user's own reading of the packet.
      final food = await save(
        FoodFormSeed.forUnknownBarcode('5000112637922'),
      );

      expect(food?.source, FoodSource.custom);
      expect(food?.source, isNot(FoodSource.openFoodFacts));

      final rows = await database.select(database.foods).get();
      expect(rows.single.source, 'custom');
    },
  );

  test('a record the provider DID have saves as openFoodFacts', () async {
    final food = await save(FoodFormSeed.fromProviderFood(providerFood));

    expect(food?.source, FoodSource.openFoodFacts);

    final rows = await database.select(database.foods).get();
    expect(rows.single.source, 'open_food_facts');
  });

  test(
    'editing a provider-sourced food keeps openFoodFacts, even after every '
    'number is retyped',
    () async {
      // ADR 010: provenance records where the data *came from*, and editing
      // it does not make it hers.
      final food = await save(
        const FoodFormSeed(
          barcode: '5000112637922',
          source: FoodSource.openFoodFacts,
          name: 'Porridge oats',
          calories: '372',
          protein: '11.2',
          carbs: '60',
          fat: '8',
          hasCompleteMacros: true,
        ),
      );

      expect(food?.source, FoodSource.openFoodFacts);
    },
  );

  test('editing a hand-entered food keeps custom', () async {
    // The other direction of the same bug: "Edit food details" on a food the
    // user typed in herself used to relabel it as provider-derived, because
    // the edit route passes a seed.
    final food = await save(
      const FoodFormSeed(
        barcode: '',
        name: 'Nan bread',
        calories: '310',
        protein: '8',
        carbs: '50',
        fat: '7',
        hasCompleteMacros: true,
      ),
    );

    expect(food?.source, FoodSource.custom);
  });

  test('the seed default is custom, so a new call site cannot over-claim', () {
    expect(const FoodFormSeed(barcode: '').source, FoodSource.custom);
    expect(
      FoodFormSeed.forUnknownBarcode('5000112637922').source,
      FoodSource.custom,
    );
    expect(
      FoodFormSeed.fromProviderFood(providerFood).source,
      FoodSource.openFoodFacts,
    );
  });
}
