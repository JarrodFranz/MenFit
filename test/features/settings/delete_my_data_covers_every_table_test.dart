import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/settings/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A generic guard against the exact bug this file was written for
/// (`StrengthRoutines`/`StrengthCycles` and `WaterLogs` had no
/// `deleteAllData` at all, and nothing caught it): every table declared in
/// `AppDatabase`'s `@DriftDatabase(tables: [...])` list gets one row seeded
/// directly (bypassing repositories, so a repository bug can't hide a
/// table from its own guard), `DeleteMyDataService.run()` — the same
/// service `features/settings/presentation/settings_screen.dart` calls —
/// runs once, and every one of those tables must come back empty.
///
/// **The seed map is the enforcement mechanism, not just test data.** A
/// table added to `app_database.dart` tomorrow with no matching entry
/// below fails the first assertion immediately, by name, rather than this
/// test silently proving nothing about a table nobody seeded.
void main() {
  test(
    'Delete my data empties every table declared in AppDatabase',
    () async {
      SharedPreferences.setMockInitialValues({
        'saved_custom_wellbeing_events': ['Personal event'],
      });
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026).millisecondsSinceEpoch;
      final nowDt = DateTime.utc(2026);

      // One seed function per table, keyed by the table's own
      // `actualTableName` rather than a hand-typed string, so a rename
      // can't silently drift this map out of sync with the schema.
      final seeds = <String, Future<void> Function()>{
        database.ketoneReadings.actualTableName: () => database
            .into(database.ketoneReadings)
            .insert(
              db.KetoneReadingsCompanion.insert(
                id: 'ketone-1',
                day: '2026-01-01',
                type: 'blood',
                result: '0.5',
                measuredAt: now,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.userProfiles.actualTableName: () => database
            .into(database.userProfiles)
            .insert(
              db.UserProfilesCompanion.insert(
                id: 'profile-1',
                displayName: 'Jordan',
                unitSystem: 'metric',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.activities.actualTableName: () => database
            .into(database.activities)
            .insert(
              db.ActivitiesCompanion.insert(
                id: 'activity-1',
                activityType: 'run',
                title: 'Morning run',
                startedAt: now,
                movingTimeMs: 600000,
                elapsedTimeMs: 600000,
                distanceMeters: 4000,
                source: 'manual',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        // Depends on `activity-1` above existing first (foreign key).
        database.activitySamples.actualTableName: () => database
            .into(database.activitySamples)
            .insert(
              db.ActivitySamplesCompanion.insert(
                id: 'sample-1',
                activityId: 'activity-1',
                timestampMs: now,
                latitude: 51.5,
                longitude: -0.1,
              ),
            ),
        database.dailyCheckins.actualTableName: () => database
            .into(database.dailyCheckins)
            .insert(
              db.DailyCheckinsCompanion.insert(
                id: 'checkin-1',
                day: '2026-01-02',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.flareEvents.actualTableName: () => database
            .into(database.flareEvents)
            .insert(
              db.FlareEventsCompanion.insert(
                id: 'flare-1',
                day: '2026-01-02',
                severity: 'moderate',
                impact: 'reducedTraining',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.recoveryDays.actualTableName: () => database
            .into(database.recoveryDays)
            .insert(
              db.RecoveryDaysCompanion.insert(
                id: 'recovery-1',
                day: '2026-01-02',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.routes.actualTableName: () => database
            .into(database.routes)
            .insert(
              db.RoutesCompanion.insert(
                id: 'route-1',
                name: 'River loop',
                distanceMeters: 5000,
                geometry: 'a~l~Fjk~uO',
                activityType: 'run',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.foods.actualTableName: () => database
            .into(database.foods)
            .insert(
              db.FoodsCompanion.insert(
                id: 'food-1',
                name: 'Porridge oats',
                servingDescription: '1 cup (dry)',
                caloriesKcal: 300,
                proteinGrams: 10,
                carbsGrams: 54,
                fatGrams: 5,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.nutritionEntries.actualTableName: () => database
            .into(database.nutritionEntries)
            .insert(
              db.NutritionEntriesCompanion.insert(
                id: 'entry-1',
                day: '2026-01-02',
                meal: 'breakfast',
                foodName: 'Porridge oats',
                quantityServings: 1.5,
                caloriesKcal: 300,
                proteinGrams: 10,
                carbsGrams: 54,
                fatGrams: 5,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.nutritionGoals.actualTableName: () => database
            .into(database.nutritionGoals)
            .insert(
              db.NutritionGoalsCompanion.insert(
                id: 'goals-1',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.waterLogs.actualTableName: () => database
            .into(database.waterLogs)
            .insert(
              db.WaterLogsCompanion.insert(
                id: 'water-1',
                day: '2026-01-02',
                milliliters: 250,
                createdAt: nowDt,
              ),
            ),
        database.strengthRoutines.actualTableName: () => database
            .into(database.strengthRoutines)
            .insert(
              db.StrengthRoutinesCompanion.insert(
                id: 'strength-routine-1',
                name: 'Push day',
                exercisesJson: '[]',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.strengthCycles.actualTableName: () => database
            .into(database.strengthCycles)
            .insert(
              db.StrengthCyclesCompanion.insert(
                id: 'strength-cycle-1',
                name: 'Hypertrophy block',
                routinesJson: '[]',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.weightLogs.actualTableName: () => database
            .into(database.weightLogs)
            .insert(
              db.WeightLogsCompanion.insert(
                id: 'weight-1',
                day: '2026-01-02',
                weightKg: 63.2,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.badgeAwards.actualTableName: () => database
            .into(database.badgeAwards)
            .insert(
              db.BadgeAwardsCompanion.insert(
                id: 'award-1',
                badgeId: 'first_activity',
                tierKey: 'once',
                awardedAt: now,
              ),
            ),
        database.challenges.actualTableName: () => database
            .into(database.challenges)
            .insert(
              db.ChallengesCompanion.insert(
                id: 'challenge-1',
                kind: 'total_distance',
                activityTypes: 'run',
                targetUnits: 1000,
                windowStart: '2026-09-01',
                windowEnd: '2026-09-30',
                salt: 12345,
                selfDisplayName: 'Jordan',
                origin: 'created',
                authorTag: 0x11223344,
                createdAt: now,
              ),
            ),
        database.dailyStepTotals.actualTableName: () => database
            .into(database.dailyStepTotals)
            .insert(
              db.DailyStepTotalsCompanion.insert(
                day: '2026-01-02',
                steps: 8123,
                syncedAt: now,
              ),
            ),
        database.yogaSequences.actualTableName: () => database
            .into(database.yogaSequences)
            .insert(
              db.YogaSequencesCompanion.insert(
                id: 'yoga-1',
                name: 'Morning flow',
                posesJson: '[]',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        database.wellbeingEvents.actualTableName: () => database
            .into(database.wellbeingEvents)
            .insert(
              db.WellbeingEventsCompanion.insert(
                id: 'event-1',
                day: '2026-01-02',
                type: 'intimacy',
                title: 'Intimacy',
                createdAt: now,
                updatedAt: now,
              ),
            ),
      };

      // sqlite_sequence and other SQLite-internal tables are not user
      // data and are excluded here explicitly - in practice
      // `AppDatabase.allTables` only ever lists the tables declared in
      // `@DriftDatabase(tables: [...])`, but the filter costs nothing and
      // documents the exclusion.
      final allTableNames = database.allTables
          .map((t) => t.actualTableName)
          .where((name) => !name.startsWith('sqlite_'))
          .toSet();
      final missingSeeds = allTableNames.difference(seeds.keys.toSet());
      expect(
        missingSeeds,
        isEmpty,
        reason:
            'These tables in AppDatabase.allTables have no seed entry in '
            'this test, so this guard cannot prove "Delete my data" wipes '
            'them: $missingSeeds. Add a seed function above for each, and '
            'a matching deleteAllData() wired into DeleteMyDataService if '
            'one is missing.',
      );

      for (final seed in seeds.values) {
        await seed();
      }

      // Sanity check on the seeding itself: every seed must have actually
      // landed a row, or the "now empty" assertion below would be
      // meaningless for that table.
      for (final tableName in seeds.keys) {
        final row = await database
            .customSelect('SELECT COUNT(*) AS c FROM "$tableName"')
            .getSingle();
        expect(
          row.read<int>('c'),
          greaterThan(0),
          reason: 'Seed for "$tableName" inserted no row',
        );
      }

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // The same call `settings_screen.dart`'s "Delete my data" button
      // makes.
      await container.read(deleteMyDataServiceProvider).run();
      expect(prefs.containsKey('saved_custom_wellbeing_events'), isFalse);

      final stillPopulated = <String>[];
      for (final tableName in seeds.keys) {
        final row = await database
            .customSelect('SELECT COUNT(*) AS c FROM "$tableName"')
            .getSingle();
        if (row.read<int>('c') > 0) stillPopulated.add(tableName);
      }
      expect(
        stillPopulated,
        isEmpty,
        reason:
            'Delete my data left rows behind in: $stillPopulated - add or '
            "fix that repository's deleteAllData() and wire it into "
            'DeleteMyDataService.run().',
      );
    },
  );
}
