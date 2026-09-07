import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/achievements/data/drift_award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/data/drift_strength_routine_repository.dart';
import 'package:menfit_app/features/activity/data/drift_yoga_sequence_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_goals_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/data/drift_water_repository.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/steps/data/drift_steps_repository.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'Settings > Delete my data, confirmed: wipes the profile, the theme '
    'preference, and the onboarding flag, and lands back on onboarding',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'theme_mode': 'dark',
        // Residue of the user's data rather than device configuration, and
        // so wiped: a recap marker records which date ranges the app has
        // already recapped, outliving the rows it was derived from.
        'recaps_last_shown_month_key': 'month:2026-08',
        // A consent belongs to the person who gave it, not to the handset:
        // a wiped app going back to onboarding shows the notice again.
        'nutrition_online_lookup_notice_seen': true,
        // The other side of that line, seeded so this test pins the
        // decision rather than leaving it to chance: these describe *this
        // device* and how it is comfortable to use, and survive.
        'accessibility_high_contrast': true,
        'nutrition_food_search_region': 'uk',
        'screen_awake_run': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      // Seed an existing profile, as if onboarding had already run.
      final now = DateTime.utc(2026);
      await DriftProfileRepository(database).saveProfile(
        UserProfile(
          id: EntityId.generate(),
          displayName: 'Jordan',
          unitSystem: UnitSystem.metric,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed a check-in and a flare - S3-tier data that "Delete my data"
      // must wipe first (knowledge/engineering/security_and_privacy.md:
      // "Full export and deletion must work for this data category
      // first").
      final wellbeingRepository = DriftWellbeingRepository(database);
      await wellbeingRepository.saveCheckin(
        DailyCheckin(
          id: EntityId.generate(),
          day: LocalDate(2026, 1, 2),
          energy: 3,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await wellbeingRepository.saveFlare(
        FlareEvent(
          id: EntityId.generate(),
          day: LocalDate(2026, 1, 2),
          severity: FlareSeverity.moderate,
          impact: FlareImpact.reducedTraining,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed a marked recovery day - health-adjacent, also wiped first.
      await DriftRecoveryRepository(database).markRecoveryDay(
        LocalDate(2026, 1, 2),
      );

      // Seed a recorded activity with GPS samples (B1: previously missed
      // by this flow entirely).
      final activityRepository = DriftActivityRepository(database);
      const activityId = 'activity-1';
      await activityRepository.saveActivity(
        Activity(
          id: activityId,
          activityType: ActivityType.run,
          title: 'Morning run',
          startedAt: now,
          movingTime: const Duration(minutes: 20),
          elapsedTime: const Duration(minutes: 20),
          distanceMeters: 4000,
          source: ActivitySource.recorded,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await activityRepository.insertSamples([
        ActivitySample(
          id: EntityId.generate(),
          activityId: activityId,
          timestamp: now,
          latitude: 51.5,
          longitude: -0.1,
        ),
      ]);

      // Seed a saved route - S2-tier location data (start points are
      // typically home-adjacent) that "Delete my data" must also wipe.
      await DriftRouteRepository(database).saveRoute(
        SavedRoute(
          id: EntityId.generate(),
          name: 'River loop',
          activityType: ActivityType.run,
          distanceMeters: 5000,
          points: const [GeoPoint(latitude: 51.5, longitude: -0.1)],
          source: RouteSource.suggested,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed two yoga sequences, one of them soft-deleted: self-authored
      // training content (S1), still hers, and a hidden row is not a
      // deleted one.
      final yogaRepository = DriftYogaSequenceRepository(database);
      await yogaRepository.saveSequence(
        YogaSequence(
          id: 'yoga-live',
          name: 'Morning flow',
          createdAt: now,
          updatedAt: now,
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 30)],
        ),
      );
      await yogaRepository.saveSequence(
        YogaSequence(
          id: 'yoga-hidden',
          name: 'Wind down',
          createdAt: now,
          updatedAt: now,
          poses: const [YogaPose(name: "Child's Pose", holdSeconds: 45)],
        ),
      );
      await yogaRepository.deleteSequence('yoga-hidden');

      // Seed a strength day routine and a strength training cycle, the
      // cycle soft-deleted: self-authored training content (S1), same
      // reasoning as the yoga sequences above, and previously missed by
      // this flow entirely (`StrengthRoutineRepository` had no
      // `deleteAllData` at all).
      final strengthRepository = DriftStrengthRoutineRepository(database);
      await strengthRepository.saveRoutine(
        StrengthDayRoutine(
          id: 'strength-routine-1',
          name: 'Push day',
          createdAt: now,
          updatedAt: now,
          exercises: const [StrengthExerciseTemplate(name: 'Bench press')],
        ),
      );
      await strengthRepository.saveCycle(
        StrengthCycle(
          id: 'strength-cycle-1',
          name: '8-week hypertrophy block',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await strengthRepository.deleteCycle('strength-cycle-1');

      // Seed the food diary - S2-tier nutrition data (S1-4). A saved food,
      // a soft-deleted food (which must not survive as a hidden row), a
      // logged entry, and the nutrition targets, which live in their own
      // single-row table and would otherwise be missed entirely.
      final nutritionRepository = DriftNutritionRepository(database);
      final food = Food(
        id: 'food-1',
        name: 'Porridge oats',
        servingDescription: '1 cup (dry)',
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
      await nutritionRepository.saveFood(food);
      await nutritionRepository.saveFood(
        food.copyWith(id: 'food-2', name: 'Banana'),
      );
      await nutritionRepository.deleteFood('food-2');
      await nutritionRepository.saveEntry(
        NutritionEntry.fromFood(
          id: EntityId.generate(),
          day: LocalDate(2026, 1, 2),
          meal: MealType.breakfast,
          food: food,
          amount: 1.5,
          now: now,
        ),
      );
      await DriftNutritionGoalsRepository(database).saveGoals(
        NutritionGoals(
          id: EntityId.generate(),
          createdAt: now,
          updatedAt: now,
          calorieTargetKcal: 2100,
          hideCalorieNumbers: true,
        ),
      );

      // Seed a logged water entry - S2-tier hydration data, previously
      // missed by this flow entirely (`WaterRepository` had no
      // `deleteAllData` at all).
      await DriftWaterRepository(database).logWater(
        day: LocalDate(2026, 1, 2),
        milliliters: 250,
      );

      // Seed the weight history - S2-tier body metrics, and ED-sensitive
      // besides: a number she asked to have deleted must be gone, notes
      // included, with no soft-deleted row left hiding.
      await DriftWeightRepository(database).saveLog(
        WeightLog(
          id: EntityId.generate(),
          day: LocalDate(2026, 1, 2),
          weightKg: 63.2,
          notes: 'a private note',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed synced step history - S2-tier health-platform data. Note what
      // this delete can and cannot promise: the health platform keeps its
      // own copy, which only she can remove there.
      await DriftStepsRepository(database).upsertMany([
        DailySteps(
          day: LocalDate(2026, 1, 2),
          steps: 8123,
          source: 'Health Connect',
          syncedAt: now,
        ),
        DailySteps(day: LocalDate(2026, 1, 3), steps: 4200, syncedAt: now),
      ]);

      // Seed earned badges - one tiered, one one-off. Individually S1, but
      // the set of them is a fingerprint of everything above, so they go
      // with the rest (see achievements_providers.dart).
      await DriftAwardRepository(database).recordAwards([
        BadgeAward(
          id: EntityId.generate(),
          badgeId: 'run_distance',
          awardedAt: now,
          tier: BadgeTier.bronze,
        ),
        BadgeAward(
          id: EntityId.generate(),
          badgeId: 'first_activity',
          awardedAt: now,
        ),
      ]);

      // Seed a buddy challenge with an imported buddy snapshot - S1
      // personal data (two self-chosen display names) and a record of who
      // she trains with, hard-deleted with the rest.
      await DriftChallengeRepository(database).saveChallenge(
        Challenge(
          blueprint: challengeBlueprintFrom(
            kind: ChallengeKind.totalDistance,
            activityTypes: const {ActivityType.run},
            targetUnits: 1000,
            windowStart: LocalDate(2026, 9, 1),
            windowEnd: LocalDate(2026, 9, 30),
            salt: 12345,
          ),
          selfDisplayName: 'Jordan',
          origin: ChallengeOrigin.created,
          authorTag: 0x11223344,
          createdAt: now,
          buddy: ChallengeBuddySnapshot(
            displayName: 'Sam',
            progressPercent: 62.5,
            asOf: LocalDate(2026, 9, 18),
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Starts on home - onboarding is already complete.
      expect(find.textContaining('Welcome back'), findsOneWidget);

      // Navigate to Settings.
      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Settings')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Delete my data'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete my data'), findsOneWidget);
      // Rule 7 pairs export with deletion: the export entry point sits in
      // the same card, directly above (ADR 015).
      expect(find.text('Export my data'), findsOneWidget);
      await tester.tap(find.text('Delete my data'));
      await tester.pumpAndSettle();

      // Confirmation dialog states what's deleted.
      expect(find.text('Delete my data?'), findsOneWidget);
      expect(
        find.textContaining('profile'),
        findsWidgets,
        reason: 'the dialog body should say what is being deleted',
      );
      expect(
        find.textContaining('check-ins'),
        findsWidgets,
        reason:
            'the dialog body should mention check-ins/symptoms/flare-ups too',
      );
      expect(
        find.textContaining('recovery days'),
        findsWidgets,
        reason: 'the dialog body should mention recovery days too',
      );
      expect(
        find.textContaining('activities'),
        findsWidgets,
        reason: 'the dialog body should mention activities/GPS routes too',
      );
      expect(
        find.textContaining('saved routes'),
        findsWidgets,
        reason: 'the dialog body should mention saved routes too',
      );
      expect(
        find.textContaining('food diary'),
        findsWidgets,
        reason: 'the dialog body should mention the food diary too',
      );
      expect(
        find.textContaining('weight history'),
        findsWidgets,
        reason: 'the dialog body should mention the weight history too',
      );
      expect(
        find.textContaining('step history'),
        findsWidgets,
        reason: 'the dialog body should mention the synced step history too',
      );
      expect(
        find.textContaining('achievements'),
        findsWidgets,
        reason: 'the dialog body should mention earned achievements too',
      );
      expect(
        find.textContaining('buddy challenges'),
        findsWidgets,
        reason: 'the dialog body should mention buddy challenges too',
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // The redirect fires once onboarding is marked incomplete.
      expect(find.text('Welcome to MenFit'), findsOneWidget);
      expect(find.textContaining('Welcome back'), findsNothing);

      final rows = await database.select(database.userProfiles).get();
      expect(rows, isEmpty);
      expect(prefs.getBool('onboarding_complete'), isNot(true));
      expect(prefs.getString('theme_mode'), isNull);
      // The recap markers and the online-lookup acknowledgement go with
      // the rows they are residue of.
      expect(prefs.containsKey('recaps_last_shown_month_key'), isFalse);
      expect(
        prefs.containsKey('nutrition_online_lookup_notice_seen'),
        isFalse,
        reason:
            'a wiped app returning to onboarding must ask before its first '
            'outbound lookup again',
      );
      // Device configuration stays - resetting high contrast or larger text
      // because someone deleted their diary would be a small act of
      // hostility towards the person most likely to need them.
      expect(prefs.getBool('accessibility_high_contrast'), isTrue);
      expect(prefs.getString('nutrition_food_search_region'), 'uk');
      expect(prefs.getBool('screen_awake_run'), isFalse);
      final checkinRows = await database.select(database.dailyCheckins).get();
      expect(checkinRows, isEmpty);
      final flareRows = await database.select(database.flareEvents).get();
      expect(flareRows, isEmpty);
      final recoveryRows = await database.select(database.recoveryDays).get();
      expect(recoveryRows, isEmpty);

      // B1: activities and their GPS samples must be gone too - previously
      // missed by this flow entirely.
      final activityRows = await database.select(database.activities).get();
      expect(activityRows, isEmpty);
      final sampleRows = await database.select(database.activitySamples).get();
      expect(sampleRows, isEmpty);

      // Saved routes must be gone too - hard-deleted, not soft-deleted.
      final routeRows = await database.select(database.routes).get();
      expect(routeRows, isEmpty);

      // S1-4: the whole food diary, including the soft-deleted food (a
      // hidden row is not a deleted one) and the single-row nutrition
      // targets.
      final entryRows = await database.select(database.nutritionEntries).get();
      expect(entryRows, isEmpty);
      final foodRows = await database.select(database.foods).get();
      expect(
        foodRows,
        isEmpty,
        reason:
            'soft-deleted foods must be purged by this flow too, not left '
            'behind as hidden rows',
      );
      final goalsRows = await database.select(database.nutritionGoals).get();
      expect(goalsRows, isEmpty);

      // Logged water - previously missed by this flow entirely
      // (`WaterRepository` had no `deleteAllData` at all).
      final waterRows = await database.select(database.waterLogs).get();
      expect(waterRows, isEmpty);

      // Task 2.1: the weight history, notes and all - a hard delete, so
      // there is nothing left to find at all.
      final weightRows = await database.select(database.weightLogs).get();
      expect(weightRows, isEmpty);

      // Step history synced from the health platform - a hard delete, no
      // soft-delete column to leave rows hiding in.
      final stepRows = await database.select(database.dailyStepTotals).get();
      expect(stepRows, isEmpty);

      // Yoga sequences, the soft-deleted one included - a hidden row is
      // not a deleted one.
      final yogaRows = await database.select(database.yogaSequences).get();
      expect(
        yogaRows,
        isEmpty,
        reason:
            'soft-deleted sequences must be purged by this flow too, not '
            'left behind as hidden rows',
      );

      // Strength routines and cycles, the soft-deleted cycle included -
      // previously missed by this flow entirely (`StrengthRoutineRepository`
      // had no `deleteAllData` at all).
      final strengthRoutineRows = await database
          .select(database.strengthRoutines)
          .get();
      expect(strengthRoutineRows, isEmpty);
      final strengthCycleRows = await database
          .select(database.strengthCycles)
          .get();
      expect(
        strengthCycleRows,
        isEmpty,
        reason:
            'soft-deleted cycles must be purged by this flow too, not left '
            'behind as hidden rows',
      );

      // Task 1.8: earned badges go with the data they were derived from.
      final awardRows = await database.select(database.badgeAwards).get();
      expect(awardRows, isEmpty);

      // Task 1.7: buddy challenges, buddy's display name and all - a hard
      // delete, so there is nothing left to find at all.
      final challengeRows = await database.select(database.challenges).get();
      expect(challengeRows, isEmpty);

      // Flush Drift's stream-cleanup timers under a pump we control before
      // the framework's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
