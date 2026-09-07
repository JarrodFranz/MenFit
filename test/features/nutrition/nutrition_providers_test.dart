import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';

void main() {
  final today = LocalDate.today();
  final now = DateTime.utc(2026);

  late db.AppDatabase database;
  late ProviderContainer container;

  /// Waits until the subscribed provider emits a value matching [predicate]
  /// (checking the current value immediately, then every subsequent
  /// emission), rather than racing a bare `await ... .future` straight after
  /// a write - Drift's `.watch()` streams notify watchers asynchronously
  /// after a write completes, not synchronously as part of it (same
  /// reasoning as `streaks_providers_test.dart`'s `waitFor`).
  ///
  /// Takes a subscribe *closure* rather than the provider itself because
  /// Riverpod 3 doesn't export `ProviderListenable` from `flutter_riverpod`
  /// (only from `package:riverpod/misc.dart`, which isn't a declared
  /// dependency of this project), so a generic provider parameter has no
  /// nameable type. The thin wrappers below keep the call sites readable.
  Future<T> waitFor<T>(
    ProviderSubscription<AsyncValue<T>> Function(
      void Function(AsyncValue<T> next) onValue,
    )
    subscribe,
    bool Function(T) predicate,
  ) async {
    final completer = Completer<T>();
    final subscription = subscribe((next) {
      final value = next.value;
      if (value != null && predicate(value) && !completer.isCompleted) {
        completer.complete(value);
      }
    });
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      subscription.close();
    }
  }

  Future<DayNutritionTotals> waitForTotals(
    LocalDate day,
    bool Function(DayNutritionTotals) predicate,
  ) {
    return waitFor(
      (onValue) => container.listen(
        dayNutritionTotalsProvider(day),
        (previous, next) => onValue(next),
        fireImmediately: true,
      ),
      predicate,
    );
  }

  Future<NutritionGoals?> waitForGoals(
    bool Function(NutritionGoals?) predicate,
  ) {
    return waitFor(
      (onValue) => container.listen(
        nutritionGoalsProvider,
        (previous, next) => onValue(next),
        fireImmediately: true,
      ),
      predicate,
    );
  }

  Future<EnergyEstimateResult> waitForEstimate(
    bool Function(EnergyEstimateResult) predicate,
  ) {
    return waitFor(
      (onValue) => container.listen(
        energyEstimateProvider,
        (previous, next) => onValue(next),
        fireImmediately: true,
      ),
      predicate,
    );
  }

  Future<CalorieTargetOutcome> waitForTarget(
    bool Function(CalorieTargetOutcome) predicate,
  ) {
    return waitFor(
      (onValue) => container.listen(
        calorieTargetProvider,
        (previous, next) => onValue(next),
        fireImmediately: true,
      ),
      predicate,
    );
  }

  Food food({double caloriesKcal = 300, double proteinGrams = 10}) {
    return Food(
      id: 'food-1',
      name: 'Porridge oats',
      servingDescription: '1 cup (dry)',
      perServing: NutritionFacts(
        caloriesKcal: caloriesKcal,
        proteinGrams: proteinGrams,
        carbsGrams: 54,
        fatGrams: 5,
        ironMg: 3,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> saveProfileWithBodyData() {
    return container
        .read(profileRepositoryProvider)
        .saveProfile(
          UserProfile(
            id: 'profile-1',
            displayName: 'Jordan',
            unitSystem: UnitSystem.metric,
            createdAt: now,
            updatedAt: now,
            dateOfBirth: LocalDate(today.year - 30, 1, 1),
            heightCm: 170,
            weightKg: 65,
          ),
        );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    // These are StreamProviders (default autoDispose): without an active
    // listener they can be torn down mid-flight on their very first pending
    // emission (Riverpod v3 test trap, central testing-pitfalls.md). No-op
    // listens keep them alive for the container's lifetime, the way a
    // watching widget would in the real app.
    container
      ..listen(dayNutritionTotalsProvider(today), (previous, next) {})
      ..listen(nutritionGoalsProvider, (previous, next) {})
      ..listen(energyEstimateProvider, (previous, next) {})
      ..listen(calorieTargetProvider, (previous, next) {});
  });

  group('dayNutritionTotalsProvider', () {
    test('an empty day totals to zero', () async {
      final totals = await container.read(
        dayNutritionTotalsProvider(today).future,
      );
      expect(totals.total.entryCount, 0);
      expect(totals.total.caloriesKcal, 0);
    });

    test('recomputes when an entry is logged for that day', () async {
      final repository = container.read(nutritionRepositoryProvider);
      await repository.saveFood(food());
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: today,
          meal: MealType.breakfast,
          food: food(),
          amount: 2,
          now: now,
        ),
      );

      final totals = await waitForTotals(
        today,
        (value) => value.total.entryCount == 1,
      );
      expect(totals.total.caloriesKcal, 600);
      expect(totals.total.proteinGrams, 20);
      expect(totals.byMeal[MealType.breakfast]!.caloriesKcal, 600);
      expect(totals.byMeal[MealType.dinner]!.entryCount, 0);
    });

    test('an entry on another day does not leak into this day', () async {
      final repository = container.read(nutritionRepositoryProvider);
      await repository.saveFood(food());
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'entry-1',
          day: today.addDays(-1),
          meal: MealType.breakfast,
          food: food(),
          amount: 2,
          now: now,
        ),
      );

      final yesterday = await waitForTotals(
        today.addDays(-1),
        (value) => value.total.entryCount == 1,
      );
      expect(yesterday.total.caloriesKcal, 600);

      final totals = await container.read(
        dayNutritionTotalsProvider(today).future,
      );
      expect(totals.total.entryCount, 0);
    });
  });

  group('nutritionGoalsProvider', () {
    test('emits null until something is saved, then the saved goals', () async {
      expect(await container.read(nutritionGoalsProvider.future), isNull);

      await container
          .read(nutritionGoalsRepositoryProvider)
          .saveGoals(
            NutritionGoals(
              id: 'goals-1',
              createdAt: now,
              updatedAt: now,
              hideCalorieNumbers: true,
            ),
          );

      final goals = await waitForGoals((value) => value != null);
      expect(goals!.hideCalorieNumbers, isTrue);
    });
  });

  group('energyEstimateProvider', () {
    test(
      'with no profile and no activity level, there is no estimate - and it '
      'names what is missing',
      () async {
        final result = await container.read(energyEstimateProvider.future);

        expect(result, isA<NoEnergyEstimate>());
        final gap = result as NoEnergyEstimate;
        expect(gap.missing, EnergyEstimateInput.values.toSet());
        expect(gap.activityLevelMissing, isTrue);
      },
    );

    test(
      'body data without a chosen activity level still yields no estimate',
      () async {
        await saveProfileWithBodyData();

        final gap = await waitForEstimate(
          (value) => value is NoEnergyEstimate && value.missing.isEmpty,
        );
        expect((gap as NoEnergyEstimate).activityLevelMissing, isTrue);
      },
    );

    test('body data plus an activity level yields an estimate', () async {
      await saveProfileWithBodyData();
      await container
          .read(nutritionGoalsRepositoryProvider)
          .saveGoals(
            NutritionGoals(
              id: 'goals-1',
              createdAt: now,
              updatedAt: now,
              activityLevel: ActivityLevel.sedentary,
            ),
          );

      final estimate = await waitForEstimate(
        (value) => value is EnergyEstimate,
      );
      expect(
        (estimate as EnergyEstimate).basalMetabolicRateKcal,
        closeTo(1567.5, 1),
        reason: '65 kg, 170 cm, 30 years, male coefficients',
      );
    });
  });

  group('calorieTargetProvider', () {
    test('no estimate means no target - nothing is invented', () async {
      final outcome = await container.read(calorieTargetProvider.future);
      expect(outcome, isA<NoCalorieTarget>());
    });

    test('an over-aggressive deficit comes back floored, with the '
        'explanation attached', () async {
      await saveProfileWithBodyData();
      await container
          .read(nutritionGoalsRepositoryProvider)
          .saveGoals(
            NutritionGoals(
              id: 'goals-1',
              createdAt: now,
              updatedAt: now,
              activityLevel: ActivityLevel.sedentary,
              weightGoal: WeightGoal.lose,
              dailyDeficitKcal: 1000,
            ),
          );

      final outcome = await waitForTarget(
        (value) => value is FlooredCalorieTarget,
      );
      final floored = outcome as FlooredCalorieTarget;
      // TDEE = 1567.5 x 1.2 = 1881; 1881 - 1000 = 881, well under the 1568
      // BMR floor.
      expect(floored.floorKcal, 1568);
      expect(floored.targetKcal, 1568);
      expect(floored.requestedKcal, 881);
      expect(floored.explanation, floorExplanation);
    });

    test('a modest deficit passes through un-floored', () async {
      await saveProfileWithBodyData();
      await container
          .read(nutritionGoalsRepositoryProvider)
          .saveGoals(
            NutritionGoals(
              id: 'goals-1',
              createdAt: now,
              updatedAt: now,
              activityLevel: ActivityLevel.moderatelyActive,
              weightGoal: WeightGoal.lose,
              dailyDeficitKcal: 250,
            ),
          );

      final outcome = await waitForTarget((value) => value is CalorieTarget);
      expect((outcome as CalorieTarget).appliedAdjustmentKcal, -250);
      expect(outcome.targetKcal, greaterThan(1568));
    });
  });
}
