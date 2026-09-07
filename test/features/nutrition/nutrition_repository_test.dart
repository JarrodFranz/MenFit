import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_goals_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

final DateTime _now = DateTime.utc(2026, 8, 20, 9);
final LocalDate _day = LocalDate(2026, 8, 20);

Food _food({
  String id = 'food-1',
  String name = 'Porridge oats',
  String? brand,
  double caloriesKcal = 300,
  double proteinGrams = 10,
  double carbsGrams = 54,
  double fatGrams = 5,
  double? ironMg = 3,
}) {
  return Food(
    id: id,
    name: name,
    brand: brand,
    servingDescription: '1 cup (dry)',
    servingGrams: 80,
    perServing: NutritionFacts(
      caloriesKcal: caloriesKcal,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      ironMg: ironMg,
    ),
    createdAt: _now,
    updatedAt: _now,
  );
}

void main() {
  late db.AppDatabase database;
  late DriftNutritionRepository repository;
  late DriftNutritionGoalsRepository goalsRepository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftNutritionRepository(database);
    goalsRepository = DriftNutritionGoalsRepository(database);
    addTearDown(database.close);
  });

  group('foods', () {
    test('save then read round-trips every field', () async {
      final food = _food(brand: 'Quaker');
      await repository.saveFood(food);

      final loaded = await repository.getFood(food.id);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Porridge oats');
      expect(loaded.brand, 'Quaker');
      expect(loaded.servingDescription, '1 cup (dry)');
      expect(loaded.servingGrams, 80);
      expect(loaded.perServing.caloriesKcal, 300);
      expect(loaded.perServing.proteinGrams, 10);
      expect(loaded.perServing.carbsGrams, 54);
      expect(loaded.perServing.fatGrams, 5);
      expect(loaded.perServing.ironMg, 3);
      expect(loaded.source, FoodSource.custom);
      expect(loaded.displayName, 'Porridge oats · Quaker');
    });

    test('unknown iron round-trips as null, never as zero', () async {
      await repository.saveFood(_food(ironMg: null));

      final loaded = await repository.getFood('food-1');
      expect(loaded!.perServing.ironMg, isNull);
      expect(loaded.perServing.hasIron, isFalse);
    });

    test('saving preserves the original createdAt across an edit', () async {
      await repository.saveFood(_food());
      final first = await database.select(database.foods).getSingle();

      await repository.saveFood(
        _food(name: 'Rolled oats').copyWith(
          createdAt: DateTime.utc(2030),
        ),
      );
      final second = await database.select(database.foods).getSingle();

      expect(second.name, 'Rolled oats');
      expect(second.createdAt, first.createdAt);
    });

    test('clearing an optional field back to null actually persists', () async {
      await repository.saveFood(_food(brand: 'Quaker'));
      await repository.saveFood(_food());

      final loaded = await repository.getFood('food-1');
      expect(loaded!.brand, isNull);
    });

    test('deleteFood soft-deletes: gone from reads, row still there', () async {
      await repository.saveFood(_food());
      await repository.deleteFood('food-1');

      expect(await repository.getFood('food-1'), isNull);
      expect(await repository.watchFoods().first, isEmpty);
      expect(await repository.searchFoods('oats'), isEmpty);
      expect(
        await database.select(database.foods).get(),
        hasLength(1),
        reason: 'soft delete keeps the row (ADR 004)',
      );
    });

    test('re-saving a deleted food restores it', () async {
      await repository.saveFood(_food());
      await repository.deleteFood('food-1');
      await repository.saveFood(_food());

      expect(await repository.getFood('food-1'), isNotNull);
    });

    test('watchFoods emits name-ascending and updates on change', () async {
      await repository.saveFood(_food(id: 'b', name: 'Banana'));
      await repository.saveFood(_food(id: 'a', name: 'Almonds'));

      expect(
        (await repository.watchFoods().first).map((f) => f.name).toList(),
        ['Almonds', 'Banana'],
      );

      final expectation = expectLater(
        repository.watchFoods(),
        emitsThrough(
          predicate<List<Food>>((foods) => foods.length == 3),
        ),
      );
      await repository.saveFood(_food(id: 'c', name: 'Cashews'));
      await expectation;
    });

    group('searchFoods', () {
      setUp(() async {
        await repository.saveFood(_food(id: 'a', brand: 'Quaker'));
        await repository.saveFood(_food(id: 'b', name: 'Banana'));
        await repository.saveFood(_food(id: 'c', name: '70% dark chocolate'));
      });

      test('matches on name, case-insensitively', () async {
        final results = await repository.searchFoods('PORRIDGE');
        expect(results.map((f) => f.id), ['a']);
      });

      test('matches on brand too', () async {
        final results = await repository.searchFoods('quaker');
        expect(results.map((f) => f.id), ['a']);
      });

      test('a blank query returns the catalogue, not an empty list', () async {
        expect(await repository.searchFoods(''), hasLength(3));
        expect(await repository.searchFoods('   '), hasLength(3));
      });

      test('limit caps the results', () async {
        expect(await repository.searchFoods('', limit: 2), hasLength(2));
      });

      test(
        'a % in the query is a literal, not a wildcard - "70%" finds the '
        'chocolate and nothing else',
        () async {
          final results = await repository.searchFoods('70%');
          expect(results.map((f) => f.id), ['c']);
        },
      );

      test('a query matching nothing returns empty', () async {
        expect(await repository.searchFoods('kumquat'), isEmpty);
      });
    });

    group('getFoodByBarcode', () {
      Food coded(String id, String barcode, {DateTime? updatedAt}) => _food(
        id: id,
      ).copyWith(barcode: barcode, updatedAt: updatedAt ?? _now);

      test('finds a saved product by its exact code', () async {
        await repository.saveFood(coded('a', '5000112637922'));
        final found = await repository.getFoodByBarcode('5000112637922');
        expect(found?.id, 'a');
      });

      test(
        'returns null for a code nothing carries, and for a blank',
        () async {
          await repository.saveFood(coded('a', '5000112637922'));
          expect(await repository.getFoodByBarcode('96385074'), isNull);
          expect(await repository.getFoodByBarcode('  '), isNull);
        },
      );

      test('never returns a soft-deleted row', () async {
        await repository.saveFood(coded('a', '5000112637922'));
        await repository.deleteFood('a');
        expect(await repository.getFoodByBarcode('5000112637922'), isNull);
      });

      test(
        'with several live rows on the same (deliberately non-unique) code, '
        'the most recently updated one wins',
        () async {
          // Written straight to the table so `updatedAt` is explicit:
          // `saveFood` stamps it to now, and two saves inside the same
          // millisecond would leave the ordering to chance.
          Future<void> insert(String id, int updatedAt) {
            return database
                .into(database.foods)
                .insert(
                  db.FoodsCompanion.insert(
                    id: id,
                    name: 'Porridge oats',
                    servingDescription: '1 cup (dry)',
                    caloriesKcal: 300,
                    proteinGrams: 10,
                    carbsGrams: 54,
                    fatGrams: 5,
                    barcode: const Value('5000112637922'),
                    createdAt: 0,
                    updatedAt: updatedAt,
                  ),
                );
          }

          await insert('older', 1000);
          await insert('newer', 2000);

          final found = await repository.getFoodByBarcode('5000112637922');
          expect(found?.id, 'newer');
        },
      );
    });
  });

  group('entries', () {
    test('save then read round-trips every field, snapshot included', () async {
      final food = _food(brand: 'Quaker');
      await repository.saveFood(food);
      final entry = NutritionEntry.fromFood(
        id: 'entry-1',
        day: _day,
        meal: MealType.breakfast,
        food: food,
        amount: 1.5,
        now: _now,
      );
      await repository.saveEntry(entry);

      final loaded = (await repository.getEntriesFor(_day)).single;
      expect(loaded.id, 'entry-1');
      expect(loaded.day, _day);
      expect(loaded.meal, MealType.breakfast);
      expect(loaded.foodId, 'food-1');
      expect(loaded.foodName, 'Porridge oats');
      expect(loaded.foodBrand, 'Quaker');
      expect(loaded.servingDescription, '1 cup (dry)');
      expect(loaded.quantityServings, 1.5);
      expect(loaded.quantityAmount, 1.5);
      expect(loaded.quantityUnit, QuantityUnit.serving);
      expect(
        loaded.servingGrams,
        80,
        reason: "the food's serving weight is snapshotted at log time",
      );
      expect(loaded.perServing.caloriesKcal, 300);
      expect(loaded.perServing.ironMg, 3);
      expect(loaded.facts.caloriesKcal, 450);
    });

    test('an entry logged in grams reads back in grams', () async {
      final food = _food();
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.lunch,
          food: food,
          amount: 120,
          unit: QuantityUnit.gram,
          now: _now,
        ),
      );

      final loaded = (await repository.getEntriesFor(_day)).single;
      expect(loaded.quantityAmount, 120);
      expect(loaded.quantityUnit, QuantityUnit.gram);
      expect(loaded.servingGrams, 80);
      expect(
        loaded.quantityServings,
        closeTo(1.5, 1e-9),
        reason: '120 g of an 80 g serving',
      );
      expect(loaded.facts.caloriesKcal, closeTo(450, 1e-9));
      expect(loaded.quantityLabel, '120 g');
    });

    test(
      'an entry whose food had no serving weight stores a null snapshot, '
      'which is what makes weight units unavailable for it later',
      () async {
        final food = _food().copyWith(servingGrams: null);
        await repository.saveFood(food);
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'entry-1',
            day: _day,
            meal: MealType.dinner,
            food: food,
            amount: 2,
            now: _now,
          ),
        );

        final loaded = (await repository.getEntriesFor(_day)).single;
        expect(loaded.servingGrams, isNull);
        expect(loaded.quantityUnit, QuantityUnit.serving);
        expect(loaded.quantityAmount, 2);
      },
    );

    test(
      'editing the serving weight on a food does not re-interpret what an '
      'already-logged gram amount meant',
      () async {
        final food = _food();
        await repository.saveFood(food);
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'entry-1',
            day: _day,
            meal: MealType.breakfast,
            food: food,
            amount: 160,
            unit: QuantityUnit.gram,
            now: _now,
          ),
        );

        // The user corrects the packet weight months later.
        await repository.saveFood(food.copyWith(servingGrams: 40));

        final loaded = (await repository.getEntriesFor(_day)).single;
        expect(
          loaded.servingGrams,
          80,
          reason: 'the entry keeps the weight it was logged against',
        );
        expect(loaded.quantityServings, 2);
        expect(
          loaded.facts.caloriesKcal,
          600,
          reason: '160 g still means what it meant on the day',
        );
      },
    );

    test('a day query returns only that day', () async {
      final food = _food();
      await repository.saveFood(food);
      for (final offset in [-1, 0, 0, 1]) {
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'entry-$offset-${EntityId.generate()}',
            day: _day.addDays(offset),
            meal: MealType.lunch,
            food: food,
            amount: 1,
            now: _now,
          ),
        );
      }

      expect(await repository.getEntriesFor(_day), hasLength(2));
      expect(await repository.getEntriesFor(_day.addDays(-1)), hasLength(1));
      expect(await repository.getEntriesFor(_day.addDays(5)), isEmpty);
    });

    test(
      'entries come back grouped in meal order, preserving logging order '
      'within each meal',
      () async {
        final food = _food();
        await repository.saveFood(food);
        // Logged in a deliberately jumbled meal order.
        for (final (id, meal) in <(String, MealType)>[
          ('s1', MealType.snack),
          ('d1', MealType.dinner),
          ('b1', MealType.breakfast),
          ('s2', MealType.snack),
          ('b2', MealType.breakfast),
        ]) {
          await repository.saveEntry(
            NutritionEntry.fromFood(
              id: id,
              day: _day,
              meal: meal,
              food: food,
              amount: 1,
              now: _now,
            ),
          );
        }

        final ids = (await repository.getEntriesFor(
          _day,
        )).map((e) => e.id).toList();
        expect(ids, ['b1', 'b2', 'd1', 's1', 's2']);
      },
    );

    test('watchEntriesFor re-emits when an entry is added', () async {
      final food = _food();
      await repository.saveFood(food);

      final expectation = expectLater(
        repository.watchEntriesFor(_day),
        emitsThrough(
          predicate<List<NutritionEntry>>((entries) => entries.length == 1),
        ),
      );
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.dinner,
          food: food,
          amount: 1,
          now: _now,
        ),
      );
      await expectation;
    });

    test('deleteEntry hard-deletes: no row is left behind', () async {
      final food = _food();
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.dinner,
          food: food,
          amount: 1,
          now: _now,
        ),
      );

      await repository.deleteEntry('entry-1');

      expect(await repository.getEntriesFor(_day), isEmpty);
      expect(
        await database.select(database.nutritionEntries).get(),
        isEmpty,
        reason: 'a deleted diary entry must actually be gone, not soft-deleted',
      );
    });
  });

  group('the snapshot rule', () {
    test(
      'editing a food does NOT rewrite what was already logged - the old '
      'entry keeps its own numbers, and a new entry picks up the new ones',
      () async {
        // Default numbers: 300 kcal / 10 g protein / 3 mg iron per serving.
        final original = _food();
        await repository.saveFood(original);
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'before-edit',
            day: _day,
            meal: MealType.breakfast,
            food: original,
            amount: 1,
            now: _now,
          ),
        );

        // The user corrects the food: different name, very different
        // numbers, same id.
        final corrected = _food(
          name: 'Porridge oats (corrected)',
          caloriesKcal: 900,
          proteinGrams: 40,
          ironMg: 12,
        );
        await repository.saveFood(corrected);

        final untouched = (await repository.getEntriesFor(
          _day,
        )).firstWhere((e) => e.id == 'before-edit');
        expect(
          untouched.perServing.caloriesKcal,
          300,
          reason: 'the snapshot is what makes the diary trustworthy',
        );
        expect(untouched.perServing.proteinGrams, 10);
        expect(untouched.perServing.ironMg, 3);
        expect(untouched.foodName, 'Porridge oats');

        // Logging again after the edit uses the corrected numbers.
        final reloaded = (await repository.getFood('food-1'))!;
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'after-edit',
            day: _day,
            meal: MealType.dinner,
            food: reloaded,
            amount: 1,
            now: _now,
          ),
        );
        final fresh = (await repository.getEntriesFor(
          _day,
        )).firstWhere((e) => e.id == 'after-edit');
        expect(fresh.perServing.caloriesKcal, 900);
        expect(fresh.foodName, 'Porridge oats (corrected)');

        // And the day's totals reflect both, un-rewritten.
        final totals = computeDayTotals(await repository.getEntriesFor(_day));
        expect(totals.total.caloriesKcal, 1200);
      },
    );

    test(
      'deleting a food leaves earlier entries complete and displayable',
      () async {
        final food = _food(brand: 'Quaker');
        await repository.saveFood(food);
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'entry-1',
            day: _day,
            meal: MealType.lunch,
            food: food,
            amount: 2,
            now: _now,
          ),
        );

        await repository.deleteFood('food-1');

        final entry = (await repository.getEntriesFor(_day)).single;
        expect(entry.foodName, 'Porridge oats');
        expect(entry.displayName, 'Porridge oats · Quaker');
        expect(entry.perServing.caloriesKcal, 300);
        expect(entry.facts.caloriesKcal, 600);
      },
    );

    test(
      'saveEntry persists the snapshot exactly as given, never re-reading '
      'the referenced food',
      () async {
        await repository.saveFood(_food());
        // An entry that points at food-1 but carries different numbers -
        // the repository must not "helpfully" resync it.
        await repository.saveEntry(
          NutritionEntry(
            id: 'entry-1',
            day: _day,
            meal: MealType.snack,
            foodId: 'food-1',
            foodName: 'Something else entirely',
            quantityServings: 1,
            quantityAmount: 1,
            perServing: const NutritionFacts(caloriesKcal: 42),
            createdAt: _now,
            updatedAt: _now,
          ),
        );

        final entry = (await repository.getEntriesFor(_day)).single;
        expect(entry.perServing.caloriesKcal, 42);
        expect(entry.foodName, 'Something else entirely');
      },
    );
  });

  group('nutrition goals', () {
    test('watchGoals emits null before anything is saved', () async {
      expect(await goalsRepository.watchGoals().first, isNull);
      expect(await goalsRepository.getGoals(), isNull);
    });

    test('save then read round-trips every field', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          calorieTargetKcal: 2100,
          proteinTargetGrams: 110,
          carbTargetGrams: 240,
          fatTargetGrams: 70,
          activityLevel: ActivityLevel.moderatelyActive,
          hideCalorieNumbers: true,
          weightGoal: WeightGoal.lose,
          dailyDeficitKcal: 300,
        ),
      );

      final loaded = (await goalsRepository.getGoals())!;
      expect(loaded.calorieTargetKcal, 2100);
      expect(loaded.proteinTargetGrams, 110);
      expect(loaded.carbTargetGrams, 240);
      expect(loaded.fatTargetGrams, 70);
      expect(loaded.activityLevel, ActivityLevel.moderatelyActive);
      expect(loaded.hideCalorieNumbers, isTrue);
      expect(loaded.weightGoal, WeightGoal.lose);
      expect(loaded.dailyDeficitKcal, 300);
      expect(loaded.hasAnyTarget, isTrue);
      expect(
        loaded.macroTargetMode,
        MacroTargetMode.grams,
        reason: 'grams unless the row says otherwise',
      );
    });

    test('a percent-mode row reads back as percent, split intact', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          calorieTargetKcal: 2000,
          macroTargetMode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
          carbTargetPercent: 40,
          fatTargetPercent: 30,
        ),
      );

      final loaded = (await goalsRepository.getGoals())!;
      expect(loaded.macroTargetMode, MacroTargetMode.percent);
      expect(loaded.proteinTargetPercent, 30);
      expect(loaded.carbTargetPercent, 40);
      expect(loaded.fatTargetPercent, 30);
      expect(loaded.hasAnyTarget, isTrue);
    });

    test(
      'both representations persist side by side - neither mode wipes the '
      "other's numbers",
      () async {
        await goalsRepository.saveGoals(
          NutritionGoals(
            id: 'goals-1',
            createdAt: _now,
            updatedAt: _now,
            macroTargetMode: MacroTargetMode.percent,
            proteinTargetGrams: 110,
            carbTargetGrams: 240,
            fatTargetGrams: 70,
            proteinTargetPercent: 25,
            carbTargetPercent: 50,
            fatTargetPercent: 25,
          ),
        );

        final loaded = (await goalsRepository.getGoals())!;
        expect(loaded.proteinTargetGrams, 110);
        expect(loaded.proteinTargetPercent, 25);
        expect(
          loaded.macroTargetMode,
          MacroTargetMode.percent,
          reason: 'the mode, not the presence of numbers, decides which wins',
        );
      },
    );

    test('clearing a percentage back to null actually persists', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          macroTargetMode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
        ),
      );
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          macroTargetMode: MacroTargetMode.percent,
        ),
      );

      expect((await goalsRepository.getGoals())!.proteinTargetPercent, isNull);
    });

    test('a lock set survives the round trip', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          calorieTargetKcal: 2000,
          proteinTargetGrams: 150,
          fatTargetGrams: 67,
          macroLocks: const MacroLocks(protein: true, fat: true),
        ),
      );

      final loaded = (await goalsRepository.getGoals())!;
      expect(loaded.macroLocks, const MacroLocks(protein: true, fat: true));
      expect(loaded.macroLocks.locked, [
        MacroNutrient.protein,
        MacroNutrient.fat,
      ]);
      expect(
        loaded.proteinTargetGrams,
        150,
        reason: 'a lock pins a target, it does not replace one',
      );
    });

    test('unlocking everything again actually persists', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          macroLocks: const MacroLocks(protein: true, carbs: true),
        ),
      );
      await goalsRepository.saveGoals(
        NutritionGoals(id: 'goals-1', createdAt: _now, updatedAt: _now),
      );

      final loaded = (await goalsRepository.getGoals())!;
      expect(
        loaded.macroLocks,
        MacroLocks.none,
        reason: 'the empty set has to overwrite, not be read as "unchanged"',
      );
      expect(loaded.macroLocks.isEmpty, isTrue);
    });

    test('defaults are the neutral, non-assuming ones', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(id: 'goals-1', createdAt: _now, updatedAt: _now),
      );

      final loaded = (await goalsRepository.getGoals())!;
      expect(
        loaded.macroLocks,
        MacroLocks.none,
        reason: 'nothing is locked until the user locks it',
      );
      expect(loaded.hideCalorieNumbers, isFalse);
      expect(
        loaded.weightGoal,
        WeightGoal.maintain,
        reason: 'the app never assumes a user wants to lose weight',
      );
      expect(loaded.dailyDeficitKcal, 0);
      expect(loaded.activityLevel, isNull);
      expect(loaded.hasAnyTarget, isFalse);
    });

    test('clearing a target back to null actually persists', () async {
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          calorieTargetKcal: 2100,
        ),
      );
      await goalsRepository.saveGoals(
        NutritionGoals(id: 'goals-1', createdAt: _now, updatedAt: _now),
      );

      expect((await goalsRepository.getGoals())!.calorieTargetKcal, isNull);
    });

    test('stays a single row across repeated saves', () async {
      for (var i = 0; i < 3; i++) {
        await goalsRepository.saveGoals(
          NutritionGoals(
            id: 'goals-1',
            createdAt: _now,
            updatedAt: _now,
            calorieTargetKcal: 2000 + i,
          ),
        );
      }

      expect(
        await database.select(database.nutritionGoals).get(),
        hasLength(1),
      );
      expect((await goalsRepository.getGoals())!.calorieTargetKcal, 2002);
    });
  });

  group('deleteAllData', () {
    test('leaves nothing behind in any nutrition table', () async {
      final food = _food();
      await repository.saveFood(food);
      await repository.saveFood(_food(id: 'food-2', name: 'Banana'));
      await repository.deleteFood('food-2');
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.breakfast,
          food: food,
          amount: 1,
          now: _now,
        ),
      );
      await goalsRepository.saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: _now,
          updatedAt: _now,
          calorieTargetKcal: 2100,
        ),
      );

      await repository.deleteAllData();
      await goalsRepository.deleteAllData();

      expect(await database.select(database.nutritionEntries).get(), isEmpty);
      expect(
        await database.select(database.foods).get(),
        isEmpty,
        reason:
            'including the soft-deleted food - "Delete my data" must leave '
            'no row behind, not merely hide them',
      );
      expect(await database.select(database.nutritionGoals).get(), isEmpty);
    });
  });

  group('optional nutrients (schema v21)', () {
    // Every one of the thirteen set to a distinct value, so a mapper that
    // crossed two of them over would be caught rather than pass.
    const allStated = NutritionFacts(
      caloriesKcal: 300,
      proteinGrams: 10,
      carbsGrams: 54,
      fatGrams: 5,
      saturatedFatGrams: 1.1,
      transFatGrams: 0.2,
      monounsaturatedFatGrams: 1.3,
      polyunsaturatedFatGrams: 1.4,
      fiberGrams: 8.5,
      sugarsGrams: 1.6,
      addedSugarsGrams: 0.7,
      sodiumMg: 18,
      potassiumMg: 350,
      cholesterolMg: 0.9,
      ironMg: 3,
      calciumMg: 52,
      vitaminDMcg: 1.2,
      vitaminCMg: 0.4,
    );

    Food foodWith(NutritionFacts facts, {String id = 'food-1'}) {
      return Food(
        id: id,
        name: 'Porridge oats',
        servingDescription: '1 cup (dry)',
        servingGrams: 80,
        perServing: facts,
        createdAt: _now,
        updatedAt: _now,
      );
    }

    void expectAllStated(NutritionFacts facts) {
      expect(facts.saturatedFatGrams, 1.1);
      expect(facts.transFatGrams, 0.2);
      expect(facts.monounsaturatedFatGrams, 1.3);
      expect(facts.polyunsaturatedFatGrams, 1.4);
      expect(facts.fiberGrams, 8.5);
      expect(facts.sugarsGrams, 1.6);
      expect(facts.addedSugarsGrams, 0.7);
      expect(facts.sodiumMg, 18);
      expect(facts.potassiumMg, 350);
      expect(facts.cholesterolMg, 0.9);
      expect(facts.ironMg, 3);
      expect(facts.calciumMg, 52);
      expect(facts.vitaminDMcg, 1.2);
      expect(facts.vitaminCMg, 0.4);
    }

    test('a food round-trips all thirteen optional nutrients', () async {
      await repository.saveFood(foodWith(allStated));

      final loaded = await repository.getFood('food-1');
      expectAllStated(loaded!.perServing);
    });

    test('an all-unstated food round-trips as all-null, never zero', () async {
      // The rule the whole nullable design exists for: an unstated nutrient
      // is missing data, not a claim that the food contains none of it.
      await repository.saveFood(
        foodWith(
          const NutritionFacts(
            caloriesKcal: 300,
            proteinGrams: 10,
            carbsGrams: 54,
            fatGrams: 5,
          ),
        ),
      );

      final facts = (await repository.getFood('food-1'))!.perServing;
      for (final value in <double?>[
        facts.saturatedFatGrams,
        facts.transFatGrams,
        facts.monounsaturatedFatGrams,
        facts.polyunsaturatedFatGrams,
        facts.fiberGrams,
        facts.sugarsGrams,
        facts.addedSugarsGrams,
        facts.sodiumMg,
        facts.potassiumMg,
        facts.cholesterolMg,
        facts.ironMg,
        facts.calciumMg,
        facts.vitaminDMcg,
        facts.vitaminCMg,
      ]) {
        expect(value, isNull);
      }
    });

    test('a partly stated food keeps the gaps as gaps', () async {
      await repository.saveFood(
        foodWith(
          const NutritionFacts(
            caloriesKcal: 300,
            proteinGrams: 10,
            carbsGrams: 54,
            fatGrams: 5,
            fiberGrams: 8.5,
            sodiumMg: 18,
          ),
        ),
      );

      final facts = (await repository.getFood('food-1'))!.perServing;
      expect(facts.fiberGrams, 8.5);
      expect(facts.sodiumMg, 18);
      expect(facts.saturatedFatGrams, isNull);
      expect(facts.potassiumMg, isNull);
      expect(facts.vitaminCMg, isNull);
    });

    test('clearing a nutrient on an edit actually clears it', () async {
      // `insertOnConflictUpdate` only writes the columns the companion
      // names, so every nutrient is passed as an explicit `Value(...)`.
      await repository.saveFood(foodWith(allStated));

      await repository.saveFood(
        foodWith(allStated.copyWith(fiberGrams: null, sodiumMg: null)),
      );

      final facts = (await repository.getFood('food-1'))!.perServing;
      expect(facts.fiberGrams, isNull);
      expect(facts.sodiumMg, isNull);
      expect(facts.potassiumMg, 350, reason: 'the untouched ones survive');
    });

    test('an entry snapshots all thirteen optional nutrients', () async {
      final food = foodWith(allStated);
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.breakfast,
          food: food,
          amount: 2,
          now: _now,
        ),
      );

      final loaded = (await repository.getEntriesFor(_day)).single;
      expectAllStated(loaded.perServing);
      // And the multiplier applies to them like everything else.
      expect(loaded.facts.fiberGrams, 17);
      expect(loaded.facts.vitaminCMg, closeTo(0.8, 1e-9));
    });

    test(
      'saveEntry writes distinct optional-nutrient values to their own '
      'raw columns',
      () async {
        // Two distinguishable non-null values plus one null, read back via
        // the raw table rather than through the repository/mapper, so a
        // matching cross in saveEntry and entryToEntity (e.g. sodium and
        // potassium swapped both ways) cannot cancel out and pass anyway.
        // Mirrors the foods-side guard in food_form_edit_test.dart.
        final food = foodWith(
          allStated.copyWith(
            sodiumMg: 11,
            potassiumMg: 22,
            fiberGrams: null,
          ),
        );
        await repository.saveFood(food);
        await repository.saveEntry(
          NutritionEntry.fromFood(
            id: 'entry-1',
            day: _day,
            meal: MealType.breakfast,
            food: food,
            amount: 1,
            now: _now,
          ),
        );

        final row =
            (await database.select(database.nutritionEntries).get()).single;
        expect(row.sodiumMg, 11);
        expect(row.potassiumMg, 22);
        expect(row.fiberGrams, isNull);
      },
    );

    test('an entry with unstated nutrients keeps them null', () async {
      final food = foodWith(
        const NutritionFacts(
          caloriesKcal: 300,
          proteinGrams: 10,
          carbsGrams: 54,
          fatGrams: 5,
          fiberGrams: 8.5,
        ),
      );
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.lunch,
          food: food,
          amount: 1,
          now: _now,
        ),
      );

      final loaded = (await repository.getEntriesFor(_day)).single;
      expect(loaded.perServing.fiberGrams, 8.5);
      expect(loaded.perServing.sodiumMg, isNull);
      expect(loaded.facts.sodiumMg, isNull, reason: 'scaling null is null');
    });

    test('deleteAllData takes the new columns with the row', () async {
      // Row-level deletes, so no column list to keep in step - asserted so
      // that stays true (`security_and_privacy.md`: nutrition is wiped).
      final food = foodWith(allStated);
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: _day,
          meal: MealType.breakfast,
          food: food,
          amount: 1,
          now: _now,
        ),
      );

      await repository.deleteAllData();

      expect(await database.select(database.foods).get(), isEmpty);
      expect(await database.select(database.nutritionEntries).get(), isEmpty);
    });
  });
}
