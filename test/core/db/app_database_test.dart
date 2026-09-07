import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';

/// Reshapes `activities` back to its pre-v8 form (no `route_id`), the same
/// drop-and-recreate technique used for `activity_samples`/`user_profiles`
/// throughout this file. Needed by every migration test whose `from` is in
/// [2, 7]: those trigger the v8 step's `from >= 2` guarded
/// `addColumn(route_id)`, which would fail with a duplicate-column error
/// against the current-shape table `AppDatabase.forTesting`'s `onCreate`
/// built (route_id already baked in).
Future<void> reshapeActivitiesToPreV8(AppDatabase database) async {
  await database.customStatement('DROP TABLE activities');
  await database.customStatement('''
    CREATE TABLE activities (
      id TEXT NOT NULL PRIMARY KEY,
      activity_type TEXT NOT NULL,
      title TEXT NOT NULL,
      notes TEXT,
      started_at INTEGER NOT NULL,
      moving_time_ms INTEGER NOT NULL,
      elapsed_time_ms INTEGER NOT NULL,
      distance_meters REAL NOT NULL,
      elevation_gain_meters REAL,
      avg_heart_rate INTEGER,
      source TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
  await database.customStatement(
    'CREATE INDEX idx_activities_started_at ON activities (started_at)',
  );
}

/// Reshapes `activities` back to its pre-v15 form (with `route_id` but no
/// `metadata_json`), so the real v14->v15 migration step can be exercised.
///
/// Also drops `water_logs`/`weight_logs` for the reason spelled out on
/// [dropNutritionTablesToPreV11]: a pre-v15 fixture runs v16's and v18's
/// steps too, whose `createIndex` calls have no `IF NOT EXISTS`.
Future<void> reshapeActivitiesToPreV15(AppDatabase database) async {
  await database.customStatement('DROP TABLE activities');
  await database.customStatement('DROP TABLE IF EXISTS water_logs');
  await database.customStatement('DROP TABLE IF EXISTS weight_logs');
  await database.customStatement('''
    CREATE TABLE activities (
      id TEXT NOT NULL PRIMARY KEY,
      activity_type TEXT NOT NULL,
      title TEXT NOT NULL,
      notes TEXT,
      started_at INTEGER NOT NULL,
      moving_time_ms INTEGER NOT NULL,
      elapsed_time_ms INTEGER NOT NULL,
      distance_meters REAL NOT NULL,
      elevation_gain_meters REAL,
      avg_heart_rate INTEGER,
      source TEXT NOT NULL,
      route_id TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
  await database.customStatement(
    'CREATE INDEX idx_activities_started_at ON activities (started_at)',
  );
}

/// Drops all post-v1 tables and reshapes `user_profiles` to v1, so tests
/// running migration from v1 exercise the clean initial state.
Future<void> dropAllTablesToPreV2(AppDatabase database) async {
  await database.customStatement('DROP TABLE activities');
  await database.customStatement('DROP TABLE activity_samples');
  await database.customStatement('DROP TABLE cycle_records');
  await database.customStatement('DROP TABLE daily_checkins');
  await database.customStatement('DROP TABLE flare_events');
  await database.customStatement('DROP TABLE recovery_days');
  await database.customStatement('DROP TABLE routes');
  await database.customStatement('DROP TABLE foods');
  await database.customStatement('DROP TABLE nutrition_entries');
  await database.customStatement('DROP TABLE nutrition_goals');
  await database.customStatement('DROP TABLE IF EXISTS water_logs');
  await database.customStatement('DROP TABLE IF EXISTS weight_logs');
  await database.customStatement('DROP TABLE IF EXISTS strength_routines');
  await database.customStatement('DROP TABLE IF EXISTS strength_cycles');
  await database.customStatement('DROP TABLE IF EXISTS wellbeing_events');
  await database.customStatement('DROP TABLE user_profiles');
  await database.customStatement('''
    CREATE TABLE user_profiles (
      id TEXT NOT NULL PRIMARY KEY,
      display_name TEXT NOT NULL,
      unit_system TEXT NOT NULL,
      weekly_activity_goal INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
}

/// Reshapes `flare_events` back to its pre-v9 form (no `end_day`), the same
/// drop-and-recreate technique used above for `activities`.
///
/// Needed by every migration test whose `from` is in [5, 8]: those trigger
/// the v9 step's `from >= 5` guarded `addColumn(end_day)`, which would fail
/// with a duplicate-column error against the current-shape table
/// `AppDatabase.forTesting`'s `onCreate` built (end_day already baked in).
/// A `from` below 5 doesn't need it — `flare_events` doesn't exist at all on
/// a real pre-v5 install, so those tests drop the table outright and the
/// `from < 5` branch recreates it at its current shape.
Future<void> reshapeFlareEventsToPreV9(AppDatabase database) async {
  await database.customStatement('DROP TABLE flare_events');
  await database.customStatement('''
    CREATE TABLE flare_events (
      id TEXT NOT NULL PRIMARY KEY,
      day TEXT NOT NULL,
      severity TEXT NOT NULL,
      symptoms TEXT NOT NULL DEFAULT '',
      impact TEXT NOT NULL,
      category TEXT,
      notes TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
  await database.customStatement(
    'CREATE INDEX idx_flare_events_day ON flare_events (day)',
  );
}

/// Drops the three v11 nutrition tables, plus `water_logs` and
/// `weight_logs`, so a fixture is shaped like a real pre-v11 install.
///
/// The two later tables come along because `onUpgrade` ignores its `to`
/// argument and runs every step whose `from` guard matches: a fixture at
/// any `from` below 11 will also run v16's and v18's steps, and those
/// steps' `createIndex` calls (unlike `createTable`, which is
/// `IF NOT EXISTS`) collide with the indices `onCreate` already built.
/// Dropping each table takes its index with it.
Future<void> dropNutritionTablesToPreV11(AppDatabase database) async {
  await database.customStatement('DROP TABLE foods');
  await database.customStatement('DROP TABLE nutrition_entries');
  await database.customStatement('DROP TABLE nutrition_goals');
  await database.customStatement('DROP TABLE IF EXISTS water_logs');
  await database.customStatement('DROP TABLE IF EXISTS weight_logs');
}

/// Reshapes `nutrition_goals` back to its pre-v12 form (no
/// `macro_target_mode` and no percent columns), so the real v11->v12
/// migration step can be exercised against it.
///
/// Only a fixture whose `from` is exactly 11 needs this: below that, the
/// `from < 11` branch creates the table fresh at its current (v12) shape and
/// the v12 step's `from >= 11` guard skips — which is the behaviour the
/// guard test below pins down.
Future<void> reshapeNutritionGoalsToPreV12(AppDatabase database) async {
  await database.customStatement('DROP TABLE nutrition_goals');
  await database.customStatement('''
    CREATE TABLE nutrition_goals (
      id TEXT NOT NULL PRIMARY KEY,
      calorie_target_kcal INTEGER,
      protein_target_grams REAL,
      carb_target_grams REAL,
      fat_target_grams REAL,
      hide_calorie_numbers INTEGER NOT NULL DEFAULT 0,
      activity_level TEXT,
      weight_goal TEXT NOT NULL DEFAULT 'maintain',
      daily_deficit_kcal INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
}

/// Reshapes `nutrition_goals` back to its pre-v14 form (everything the v12
/// step added, but no `macro_locks`), so the real v13->v14 migration step can
/// be exercised against it.
///
/// Needed by every fixture whose `from` is 11, 12 or 13 and that isn't
/// already reshaping this table further back: those fall inside the v14
/// step's `from < 14 && from >= 11` window, and `AppDatabase.forTesting`
/// built the table at its current (v14) shape, so the step's `addColumn`
/// would fail with a duplicate-column error. [reshapeNutritionGoalsToPreV12]
/// covers a `from` of exactly 11 on its own — a pre-v12 table has no
/// `macro_locks` either. Below 11 the `from < 11` branch creates the table
/// fresh with the column already in it and the guard skips, which is what
/// the guard test below pins down.
Future<void> reshapeNutritionGoalsToPreV14(AppDatabase database) async {
  await database.customStatement('DROP TABLE nutrition_goals');
  await database.customStatement('''
    CREATE TABLE nutrition_goals (
      id TEXT NOT NULL PRIMARY KEY,
      calorie_target_kcal INTEGER,
      protein_target_grams REAL,
      carb_target_grams REAL,
      fat_target_grams REAL,
      macro_target_mode TEXT NOT NULL DEFAULT 'grams',
      protein_target_percent REAL,
      carb_target_percent REAL,
      fat_target_percent REAL,
      hide_calorie_numbers INTEGER NOT NULL DEFAULT 0,
      activity_level TEXT,
      weight_goal TEXT NOT NULL DEFAULT 'maintain',
      daily_deficit_kcal INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
}

/// Reshapes `nutrition_entries` back to its pre-v13 form (no
/// `quantity_amount`, `quantity_unit` or `serving_grams`), so the real
/// v12->v13 migration step — and its backfill — can be exercised against it.
///
/// Needed by every fixture whose `from` is 11 or 12: those fall inside the
/// v13 step's `from < 13 && from >= 11` window, and `AppDatabase.forTesting`
/// built the table at its current (v13) shape, so the step's `addColumn`s
/// would fail with a duplicate-column error against it. Below 11 the
/// `from < 11` branch creates the table fresh (already including the three
/// columns) and the guard skips — which is the behaviour the guard test
/// below pins down.
///
/// The day index is recreated with the table: a real v12 install has it, and
/// no step at these `from` values would rebuild it.
Future<void> reshapeNutritionEntriesToPreV13(AppDatabase database) async {
  await database.customStatement('DROP TABLE nutrition_entries');
  await database.customStatement('''
    CREATE TABLE nutrition_entries (
      id TEXT NOT NULL PRIMARY KEY,
      day TEXT NOT NULL,
      meal TEXT NOT NULL,
      food_id TEXT,
      food_name TEXT NOT NULL,
      food_brand TEXT,
      serving_description TEXT,
      quantity_servings REAL NOT NULL,
      calories_kcal REAL NOT NULL,
      protein_grams REAL NOT NULL,
      carbs_grams REAL NOT NULL,
      fat_grams REAL NOT NULL,
      iron_mg REAL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
  await database.customStatement(
    'CREATE INDEX idx_nutrition_entries_day ON nutrition_entries (day)',
  );
}

/// Reshapes `routes` back to its pre-v10 form (no `descent_meters`), so the
/// real v9->v10 migration step can be exercised against it.
Future<void> reshapeRoutesToPreV10(AppDatabase database) async {
  await database.customStatement('DROP TABLE routes');
  await database.customStatement('''
    CREATE TABLE routes (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      distance_meters REAL NOT NULL,
      estimated_duration_seconds INTEGER,
      ascent_meters REAL,
      geometry TEXT NOT NULL,
      activity_type TEXT NOT NULL,
      source TEXT NOT NULL DEFAULT 'suggested',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
  ''');
}

/// Reshapes `foods` back to its pre-v21 form (no optional-nutrient columns
/// beyond `iron_mg`), so the real v20->v21 migration step can be exercised
/// against it.
///
/// Only needed by a test that wants to *watch* the columns being added: the
/// step guards every `addColumn` behind a `PRAGMA table_info` check, so a
/// fixture left at its current shape simply skips them (which is what the
/// re-entrancy test below asserts, and why the nineteen other `onUpgrade`
/// call sites at `from >= 11` needed no change at all when v21 landed).
Future<void> reshapeFoodsToPreV21(AppDatabase database) async {
  await database.customStatement('DROP TABLE foods');
  await database.customStatement(_preV21Foods);
  await database.customStatement(
    'CREATE INDEX idx_foods_name ON foods (name)',
  );
  await database.customStatement(
    'CREATE INDEX idx_foods_barcode ON foods (barcode)',
  );
}

const _preV21Foods = '''
    CREATE TABLE foods (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      brand TEXT,
      serving_description TEXT NOT NULL,
      serving_grams REAL,
      calories_kcal REAL NOT NULL,
      protein_grams REAL NOT NULL,
      carbs_grams REAL NOT NULL,
      fat_grams REAL NOT NULL,
      iron_mg REAL,
      barcode TEXT,
      source TEXT NOT NULL DEFAULT 'custom',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
''';

/// Reshapes `nutrition_entries` back to its pre-v21 form: everything v13
/// added, but none of the thirteen optional nutrients. Companion to
/// [reshapeFoodsToPreV21] — the two tables carry the same nutrition shape
/// and v21 moves them together.
Future<void> reshapeNutritionEntriesToPreV21(AppDatabase database) async {
  await database.customStatement('DROP TABLE nutrition_entries');
  await database.customStatement(_preV21NutritionEntries);
  await database.customStatement(
    'CREATE INDEX idx_nutrition_entries_day ON nutrition_entries (day)',
  );
}

const _preV21NutritionEntries = '''
    CREATE TABLE nutrition_entries (
      id TEXT NOT NULL PRIMARY KEY,
      day TEXT NOT NULL,
      meal TEXT NOT NULL,
      food_id TEXT,
      food_name TEXT NOT NULL,
      food_brand TEXT,
      serving_description TEXT,
      quantity_servings REAL NOT NULL,
      quantity_amount REAL NOT NULL DEFAULT 1,
      quantity_unit TEXT NOT NULL DEFAULT 'serving',
      serving_grams REAL,
      calories_kcal REAL NOT NULL,
      protein_grams REAL NOT NULL,
      carbs_grams REAL NOT NULL,
      fat_grams REAL NOT NULL,
      iron_mg REAL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
''';

/// Reshapes `foods` back to its pre-v25 form (no `serving_volume_ml`), so the
/// real v24->v25 migration step can be exercised against it.
Future<void> reshapeFoodsToPreV25(AppDatabase database) async {
  await database.customStatement('DROP TABLE foods');
  await database.customStatement(_preV25Foods);
  await database.customStatement(
    'CREATE INDEX idx_foods_name ON foods (name)',
  );
  await database.customStatement(
    'CREATE INDEX idx_foods_barcode ON foods (barcode)',
  );
}

const _preV25Foods = '''
    CREATE TABLE foods (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      brand TEXT,
      serving_description TEXT NOT NULL,
      serving_grams REAL,
      calories_kcal REAL NOT NULL,
      protein_grams REAL NOT NULL,
      carbs_grams REAL NOT NULL,
      fat_grams REAL NOT NULL,
      iron_mg REAL,
      saturated_fat_grams REAL,
      trans_fat_grams REAL,
      monounsaturated_fat_grams REAL,
      polyunsaturated_fat_grams REAL,
      fiber_grams REAL,
      sugars_grams REAL,
      added_sugars_grams REAL,
      sodium_mg REAL,
      potassium_mg REAL,
      cholesterol_mg REAL,
      calcium_mg REAL,
      vitamin_d_mcg REAL,
      vitamin_c_mg REAL,
      barcode TEXT,
      source TEXT NOT NULL DEFAULT 'custom',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
''';

/// Reshapes `nutrition_entries` back to its pre-v25 form (no
/// `serving_volume_ml`).
Future<void> reshapeNutritionEntriesToPreV25(AppDatabase database) async {
  await database.customStatement('DROP TABLE nutrition_entries');
  await database.customStatement(_preV25NutritionEntries);
  await database.customStatement(
    'CREATE INDEX idx_nutrition_entries_day ON nutrition_entries (day)',
  );
}

const _preV25NutritionEntries = '''
    CREATE TABLE nutrition_entries (
      id TEXT NOT NULL PRIMARY KEY,
      day TEXT NOT NULL,
      meal TEXT NOT NULL,
      food_id TEXT,
      food_name TEXT NOT NULL,
      food_brand TEXT,
      serving_description TEXT,
      quantity_servings REAL NOT NULL,
      quantity_amount REAL NOT NULL DEFAULT 1,
      quantity_unit TEXT NOT NULL DEFAULT 'serving',
      serving_grams REAL,
      calories_kcal REAL NOT NULL,
      protein_grams REAL NOT NULL,
      carbs_grams REAL NOT NULL,
      fat_grams REAL NOT NULL,
      iron_mg REAL,
      saturated_fat_grams REAL,
      trans_fat_grams REAL,
      monounsaturated_fat_grams REAL,
      polyunsaturated_fat_grams REAL,
      fiber_grams REAL,
      sugars_grams REAL,
      added_sugars_grams REAL,
      sodium_mg REAL,
      potassium_mg REAL,
      cholesterol_mg REAL,
      calcium_mg REAL,
      vitamin_d_mcg REAL,
      vitamin_c_mg REAL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'local'
    )
''';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('schema creates successfully', () async {
    // Any query succeeding proves the schema (including UserProfiles) was
    // created without error.
    final rows = await database.select(database.userProfiles).get();
    expect(rows, isEmpty);
  });

  group('v2 schema (Activities, ActivitySamples)', () {
    test(
      'a fresh database opens at the current schema with both tables '
      'usable',
      () async {
        expect(database.schemaVersion, 25);
        // Any query succeeding proves the tables (created via `onCreate` ->
        // `createAll()` on a fresh database) exist and are queryable.
        expect(await database.select(database.activities).get(), isEmpty);
        expect(
          await database.select(database.activitySamples).get(),
          isEmpty,
        );
      },
    );

    test('inserting and reading an Activities row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: id,
              activityType: 'run',
              title: 'Morning Run',
              startedAt: now,
              movingTimeMs: 1800000,
              elapsedTimeMs: 1800000,
              distanceMeters: 5000,
              source: 'manual',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.activities).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, id);
      expect(row.activityType, 'run');
      expect(row.title, 'Morning Run');
      expect(row.notes, isNull);
      expect(row.distanceMeters, 5000);
      expect(row.elevationGainMeters, isNull);
      expect(row.avgHeartRate, isNull);
      expect(row.source, 'manual');
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test(
      'inserting and reading an ActivitySamples row round-trips',
      () async {
        final activityId = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: activityId,
                activityType: 'run',
                title: 'Morning Run',
                startedAt: now,
                movingTimeMs: 1800000,
                elapsedTimeMs: 1800000,
                distanceMeters: 5000,
                source: 'recorded',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final sampleId = EntityId.generate();
        await database
            .into(database.activitySamples)
            .insert(
              ActivitySamplesCompanion.insert(
                id: sampleId,
                activityId: activityId,
                timestampMs: now,
                latitude: 51.5,
                longitude: -0.12,
              ),
            );

        final rows = await database.select(database.activitySamples).get();
        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.id, sampleId);
        expect(row.activityId, activityId);
        expect(row.latitude, 51.5);
        expect(row.longitude, -0.12);
        expect(row.elevationMeters, isNull);
        expect(row.heartRate, isNull);
      },
    );

    test(
      'a v1-shaped database (activities/activity_samples missing) is '
      'upgraded by the real v1->v8 migration step: both tables and their '
      'indices exist afterwards, with activity_samples already including '
      'is_paused',
      () async {
        // `AppDatabase.forTesting` above already opened at the *current*
        // schemaVersion (7), which ran `onCreate` -> `createAll()` and
        // created every table up front - a fresh install never exercises
        // `onUpgrade` at all. To exercise the migration path itself for a
        // device genuinely upgrading from v1, drop every table added since
        // v1 (activities/activity_samples from v2, cycle_records from v3,
        // daily_checkins/flare_events from v5, recovery_days from v6 - a
        // real v1 install has none of them) so the database is shaped like
        // a real v1 install, then invoke the production
        // `migration.onUpgrade` callback directly with the real target
        // version (7) - drift always upgrades a device straight to the
        // current schemaVersion in one call, never stepwise, so `to` here
        // must match, or the `if (from < 3)` branch would otherwise try to
        // recreate a `cycle_records` table this test never dropped.
        //
        // (A full "open at v1, then reopen the same connection at v7"
        // lifecycle test would additionally prove drift's version
        // detection triggers this callback automatically; that requires
        // either a second `@DriftDatabase`-annotated v1-shaped class or
        // drift_dev's schema-snapshot verification tooling, which felt like
        // more machinery than this migration's size warrants. This test
        // instead directly proves the callback's SQL is correct, which is
        // the part actually at risk of being wrong.)
        await database.customStatement('DROP TABLE activities');
        await database.customStatement('DROP TABLE activity_samples');
        await database.customStatement('DROP TABLE cycle_records');
        await database.customStatement('DROP TABLE daily_checkins');
        await database.customStatement('DROP TABLE flare_events');
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        // `user_profiles` is part of the v1 baseline itself, so (unlike the
        // tables above) it isn't dropped - but `forTesting`'s `onCreate`
        // built it at the *current* (v7) shape, already including the new
        // S1-3 columns. A real v1 device wouldn't have them yet, so it must
        // be reshaped back to its v1 form here, the same technique used for
        // `activity_samples` in the v2-/v3-shaped tests below - otherwise
        // the `from < 7` branch's `addColumn` calls would fail with a
        // duplicate-column error.
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 1, 10);

        expect(await database.select(database.activities).get(), isEmpty);
        expect(
          await database.select(database.activitySamples).get(),
          isEmpty,
        );
        expect(await database.select(database.recoveryDays).get(), isEmpty);
        expect(await database.select(database.userProfiles).get(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(
          indexNames,
          containsAll([
            'idx_activities_started_at',
            'idx_activity_samples_activity_id_timestamp_ms',
            'idx_recovery_days_day',
          ]),
        );

        // `activity_samples` was created fresh by the `from < 2` branch
        // using the table's *current* Dart shape, so `is_paused` is already
        // there - the `from < 4 && from >= 2` guard (see
        // `app_database.dart`'s migration doc) must have skipped the
        // `addColumn` step rather than erroring on a duplicate column.
        final id = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: id,
                activityType: 'run',
                title: 'Run',
                startedAt: now,
                movingTimeMs: 0,
                elapsedTimeMs: 0,
                distanceMeters: 0,
                source: 'recorded',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.activitySamples)
            .insert(
              ActivitySamplesCompanion.insert(
                id: EntityId.generate(),
                activityId: id,
                timestampMs: now,
                latitude: 51.5,
                longitude: -0.12,
                isPaused: const Value(true),
              ),
            );
        final row = await database.select(database.activitySamples).getSingle();
        expect(row.isPaused, isTrue);

        // The new S1-3 `user_profiles` columns are usable post-migration.
        final profileId = EntityId.generate();
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: profileId,
                displayName: 'Jordan',
                unitSystem: 'metric',
                createdAt: now,
                updatedAt: now,
                dateOfBirth: const Value('1990-01-01'),
                heightCm: const Value(170),
                trainingDays: const Value('mon,wed,fri'),
              ),
            );
        final profileRow = await database
            .select(database.userProfiles)
            .getSingle();
        expect(profileRow.dateOfBirth, '1990-01-01');
        expect(profileRow.heightCm, 170);
        expect(profileRow.weightKg, isNull);
        expect(profileRow.trainingDays, 'mon,wed,fri');
      },
    );
  });

  group('v3 schema (CycleRecords)', () {
    test('a fresh database opens with the table usable', () async {
      expect(database.schemaVersion, 25);
      // Any query succeeding proves the table (created via `onCreate` ->
      // `createAll()` on a fresh database) exists and is queryable.
      expect(await database.select(database.cycleRecords).get(), isEmpty);
    });

    test('inserting and reading a CycleRecords row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.cycleRecords)
          .insert(
            CycleRecordsCompanion.insert(
              id: id,
              periodStartDay: '2026-08-20',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.cycleRecords).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, id);
      expect(row.periodStartDay, '2026-08-20');
      expect(row.periodEndDay, isNull);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test(
      'a v2-shaped database (cycle_records missing) is upgraded by the '
      'real v2->v8 migration step: the table and its index exist afterwards',
      () async {
        // Same technique as the v1->v2 migration test above: drop the
        // v3-only table (and the v5-/v6-only tables) so the database is
        // shaped like a real v2 install. `activity_samples` must *also* be
        // reshaped back to its pre-v4 (no `is_paused`) form here: a real v2
        // device upgrades straight to the current schemaVersion (7) in one
        // call, so this test's `from` (2) legitimately triggers the
        // `from < 3` (cycle_records), `from < 4 && from >= 2` (is_paused),
        // `from < 5` (daily_checkins/flare_events), `from < 6`
        // (recovery_days), and `from < 7` (user_profiles S1-3 columns)
        // branches together - if `activity_samples` were left at this
        // fixture's already-v4 shape (`AppDatabase.forTesting` created it
        // via `onCreate` with `is_paused` baked in), the `addColumn` step
        // would fail with a duplicate-column error. `user_profiles` needs
        // the same reshaping, for the same reason - see the v1->v7 test's
        // comment above for the full explanation.
        await database.customStatement('DROP TABLE cycle_records');
        await database.customStatement('DROP TABLE daily_checkins');
        await database.customStatement('DROP TABLE flare_events');
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await database.customStatement('DROP TABLE activity_samples');
        await database.customStatement('''
          CREATE TABLE activity_samples (
            id TEXT NOT NULL PRIMARY KEY,
            activity_id TEXT NOT NULL REFERENCES activities (id),
            timestamp_ms INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            elevation_meters REAL,
            horizontal_accuracy_meters REAL,
            heart_rate INTEGER
          )
        ''');
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 2, 10);

        expect(await database.select(database.cycleRecords).get(), isEmpty);
        expect(await database.select(database.userProfiles).get(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(indexNames, contains('idx_cycle_records_period_start_day'));

        // The `is_paused` column must now exist and default to `false`.
        final id = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: id,
                activityType: 'run',
                title: 'Run',
                startedAt: now,
                movingTimeMs: 0,
                elapsedTimeMs: 0,
                distanceMeters: 0,
                source: 'recorded',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.activitySamples)
            .insert(
              ActivitySamplesCompanion.insert(
                id: EntityId.generate(),
                activityId: id,
                timestampMs: now,
                latitude: 51.5,
                longitude: -0.12,
              ),
            );
        final row = await database.select(database.activitySamples).getSingle();
        expect(row.isPaused, isFalse);
      },
    );
  });

  group('v4 schema (ActivitySamples.isPaused)', () {
    test('a fresh database opens at schema v4 with isPaused usable', () async {
      expect(database.schemaVersion, 25);
      final activityId = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: activityId,
              activityType: 'run',
              title: 'Run',
              startedAt: now,
              movingTimeMs: 0,
              elapsedTimeMs: 0,
              distanceMeters: 0,
              source: 'recorded',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Omitting `isPaused` defaults to `false`.
      await database
          .into(database.activitySamples)
          .insert(
            ActivitySamplesCompanion.insert(
              id: 'default',
              activityId: activityId,
              timestampMs: now,
              latitude: 51.5,
              longitude: -0.12,
            ),
          );
      await database
          .into(database.activitySamples)
          .insert(
            ActivitySamplesCompanion.insert(
              id: 'paused',
              activityId: activityId,
              timestampMs: now,
              latitude: 51.5,
              longitude: -0.12,
              isPaused: const Value(true),
            ),
          );

      final rows = await database.select(database.activitySamples).get();
      expect(rows.firstWhere((r) => r.id == 'default').isPaused, isFalse);
      expect(rows.firstWhere((r) => r.id == 'paused').isPaused, isTrue);
    });

    test(
      'a v3-shaped database (activity_samples missing is_paused) is '
      'upgraded by the real v3->v8 migration step: pre-existing rows '
      'default to isPaused=false',
      () async {
        // Reshape `activity_samples` back to its pre-v4 form (drop +
        // recreate without `is_paused`), the same technique used above for
        // the v1/v2-shaped tests, then insert a row directly via raw SQL to
        // simulate data that predates this migration. The v5-/v6-only
        // tables must also be dropped first, and `user_profiles` reshaped
        // back to its v1 form - a real v3 device upgrades straight to v7 in
        // one call, so this test's `from` (3) also triggers the `from < 5`,
        // `from < 6`, and `from < 7` branches (see the v1->v7 test's
        // comment for why `user_profiles` needs reshaping too).
        await database.customStatement('DROP TABLE daily_checkins');
        await database.customStatement('DROP TABLE flare_events');
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await database.customStatement('DROP TABLE activity_samples');
        await database.customStatement('''
          CREATE TABLE activity_samples (
            id TEXT NOT NULL PRIMARY KEY,
            activity_id TEXT NOT NULL REFERENCES activities (id),
            timestamp_ms INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            elevation_meters REAL,
            horizontal_accuracy_meters REAL,
            heart_rate INTEGER
          )
        ''');
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        final activityId = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: activityId,
                activityType: 'run',
                title: 'Pre-v4 run',
                startedAt: now,
                movingTimeMs: 0,
                elapsedTimeMs: 0,
                distanceMeters: 0,
                source: 'recorded',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database.customStatement(
          'INSERT INTO activity_samples '
          '(id, activity_id, timestamp_ms, latitude, longitude) '
          "VALUES ('pre-v4-sample', '$activityId', $now, 51.5, -0.12)",
        );

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 3, 10);

        expect(await database.select(database.userProfiles).get(), isEmpty);

        final rows = await database.select(database.activitySamples).get();
        expect(rows, hasLength(1));
        expect(rows.single.id, 'pre-v4-sample');
        expect(
          rows.single.isPaused,
          isFalse,
          reason:
              'pre-v4 data backfills to isPaused=false (nothing to '
              'recover - see activity_samples.dart doc)',
        );

        // A newly-inserted row can now specify isPaused explicitly.
        await database
            .into(database.activitySamples)
            .insert(
              ActivitySamplesCompanion.insert(
                id: 'post-v4-sample',
                activityId: activityId,
                timestampMs: now,
                latitude: 51.5,
                longitude: -0.12,
                isPaused: const Value(true),
              ),
            );
        final updated = await (database.select(
          database.activitySamples,
        )..where((t) => t.id.equals('post-v4-sample'))).getSingle();
        expect(updated.isPaused, isTrue);
      },
    );
  });

  group('v5 schema (DailyCheckins, FlareEvents)', () {
    test(
      'a fresh database opens at schema v5 with both tables usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await database.select(database.dailyCheckins).get(), isEmpty);
        expect(await database.select(database.flareEvents).get(), isEmpty);
      },
    );

    test('inserting and reading a DailyCheckins row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.dailyCheckins)
          .insert(
            DailyCheckinsCompanion.insert(
              id: id,
              day: '2026-08-20',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.dailyCheckins).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, id);
      expect(row.day, '2026-08-20');
      expect(row.energy, isNull);
      expect(row.sleep, isNull);
      expect(row.soreness, isNull);
      expect(row.stress, isNull);
      expect(row.pain, isNull);
      expect(row.symptoms, '');
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test(
      'the day column has a unique index: a second row for the same day '
      'is rejected',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.dailyCheckins)
            .insert(
              DailyCheckinsCompanion.insert(
                id: 'a',
                day: '2026-08-20',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await expectLater(
          database
              .into(database.dailyCheckins)
              .insert(
                DailyCheckinsCompanion.insert(
                  id: 'b',
                  day: '2026-08-20',
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
          throwsA(anything),
        );
      },
    );

    test('inserting and reading a FlareEvents row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.flareEvents)
          .insert(
            FlareEventsCompanion.insert(
              id: id,
              day: '2026-08-20',
              severity: 'moderate',
              impact: 'reducedTraining',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.flareEvents).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, id);
      expect(row.day, '2026-08-20');
      expect(row.severity, 'moderate');
      expect(row.impact, 'reducedTraining');
      expect(row.symptoms, '');
      expect(row.category, isNull);
      expect(row.notes, isNull);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test('multiple FlareEvents rows are allowed on the same day', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.flareEvents)
          .insert(
            FlareEventsCompanion.insert(
              id: 'a',
              day: '2026-08-20',
              severity: 'mild',
              impact: 'none',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.flareEvents)
          .insert(
            FlareEventsCompanion.insert(
              id: 'b',
              day: '2026-08-20',
              severity: 'severe',
              impact: 'unableToTrain',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.flareEvents).get();
      expect(rows, hasLength(2));
    });

    test(
      'a v4-shaped database (daily_checkins/flare_events missing) is '
      'upgraded by the real v4->v8 migration step: both tables and their '
      'indices exist afterwards',
      () async {
        // Same technique as the earlier migration tests: drop the v5-only
        // tables and the v6-only table so the database is shaped like a
        // real v4 install (activities/activity_samples/cycle_records
        // already have their final v4 shape from `AppDatabase.forTesting`'s
        // `onCreate`, so no other reshaping is needed for a `from` of 4) -
        // except `user_profiles`, which must be reshaped back to its v1
        // form for the same reason as every earlier test in this file (see
        // the v1->v7 test's comment).
        await database.customStatement('DROP TABLE daily_checkins');
        await database.customStatement('DROP TABLE flare_events');
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 4, 10);

        expect(await database.select(database.dailyCheckins).get(), isEmpty);
        expect(await database.select(database.flareEvents).get(), isEmpty);
        expect(await database.select(database.recoveryDays).get(), isEmpty);
        expect(await database.select(database.userProfiles).get(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(
          indexNames,
          containsAll([
            'idx_daily_checkins_day',
            'idx_flare_events_day',
            'idx_recovery_days_day',
          ]),
        );
      },
    );
  });

  group('v6 schema (RecoveryDays)', () {
    test('a fresh database opens at schema v6 with the table usable', () async {
      expect(database.schemaVersion, 25);
      expect(await database.select(database.recoveryDays).get(), isEmpty);
    });

    test('inserting and reading a RecoveryDays row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.recoveryDays)
          .insert(
            RecoveryDaysCompanion.insert(
              id: id,
              day: '2026-08-20',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, id);
      expect(row.day, '2026-08-20');
      expect(row.note, isNull);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test(
      'the day column has a unique index: a second row for the same day '
      'is rejected',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.recoveryDays)
            .insert(
              RecoveryDaysCompanion.insert(
                id: 'a',
                day: '2026-08-20',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await expectLater(
          database
              .into(database.recoveryDays)
              .insert(
                RecoveryDaysCompanion.insert(
                  id: 'b',
                  day: '2026-08-20',
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
          throwsA(anything),
        );
      },
    );

    test(
      'a v5-shaped database (recovery_days missing) is upgraded by the '
      'real v5->v8 migration step: the table and its index exist '
      'afterwards',
      () async {
        // The v6-only table needs dropping, and `user_profiles` reshaped
        // back to its v1 form (see the v1->v7 test's comment) - a real v5
        // install already has daily_checkins in its final shape from
        // `AppDatabase.forTesting`'s `onCreate`, but `flare_events` needs
        // reshaping back to its pre-v9 form for the same reason
        // `activities` does.
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await reshapeFlareEventsToPreV9(database);
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 5, 10);

        expect(await database.select(database.recoveryDays).get(), isEmpty);
        expect(await database.select(database.userProfiles).get(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(indexNames, contains('idx_recovery_days_day'));

        // A newly-inserted row round-trips through the freshly-created
        // table.
        final id = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.recoveryDays)
            .insert(
              RecoveryDaysCompanion.insert(
                id: id,
                day: '2026-08-21',
                note: const Value('felt off today'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.recoveryDays).getSingle();
        expect(row.note, 'felt off today');
      },
    );
  });

  group('v7 schema (UserProfiles S1-3 fields)', () {
    test(
      'a fresh database opens at schema v7 with the new columns usable',
      () async {
        expect(database.schemaVersion, 25);
        final id = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: id,
                displayName: 'Jordan',
                unitSystem: 'metric',
                createdAt: now,
                updatedAt: now,
                dateOfBirth: const Value('1995-06-15'),
                heightCm: const Value(170.2),
                weightKg: const Value(65.5),
                fitnessGoal: const Value('runFurther'),
                runningExperience: const Value('regular'),
                strengthExperience: const Value('newTo'),
                trainingDays: const Value('mon,wed,fri'),
              ),
            );
        final row = await database.select(database.userProfiles).getSingle();
        expect(row.dateOfBirth, '1995-06-15');
        expect(row.heightCm, 170.2);
        expect(row.weightKg, 65.5);
        expect(row.fitnessGoal, 'runFurther');
        expect(row.runningExperience, 'regular');
        expect(row.strengthExperience, 'newTo');
        expect(row.trainingDays, 'mon,wed,fri');
      },
    );

    test(
      'omitting the new S1-3 fields leaves them null/empty - every field is '
      'optional (spec: never force disclosure)',
      () async {
        final id = EntityId.generate();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: id,
                displayName: 'Jordan',
                unitSystem: 'metric',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.userProfiles).getSingle();
        expect(row.dateOfBirth, isNull);
        expect(row.heightCm, isNull);
        expect(row.weightKg, isNull);
        expect(row.fitnessGoal, isNull);
        expect(row.runningExperience, isNull);
        expect(row.strengthExperience, isNull);
        expect(row.trainingDays, '');
      },
    );

    test(
      'a v6-shaped database (user_profiles missing the S1-3 columns) is '
      'upgraded by the real v6->v8 migration step: the new columns exist '
      'and are usable, with pre-existing rows backfilled to null/empty',
      () async {
        // `AppDatabase.forTesting` created `user_profiles` via `onCreate`
        // at its *current* shape - reshape it back to its pre-v7 form
        // (drop + recreate without the S1-3 columns, same technique used
        // throughout this file), simulating a real v6 install, then insert
        // a pre-existing row directly via raw SQL before migrating. The
        // v8-only table, `activities.route_id`, and `flare_events.end_day`
        // need the same treatment - a real v6 device upgrades straight to
        // v9 in one call.
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await reshapeFlareEventsToPreV9(database);
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO user_profiles '
          '(id, display_name, unit_system, created_at, updated_at) '
          "VALUES ('pre-v7-profile', 'Jordan', 'metric', $now, $now)",
        );

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 6, 10);

        final row = await database.select(database.userProfiles).getSingle();
        expect(row.id, 'pre-v7-profile');
        expect(
          row.dateOfBirth,
          isNull,
          reason: 'pre-v7 data backfills to null - nothing to recover',
        );
        expect(row.heightCm, isNull);
        expect(row.weightKg, isNull);
        expect(row.fitnessGoal, isNull);
        expect(row.runningExperience, isNull);
        expect(row.strengthExperience, isNull);
        expect(row.trainingDays, '');

        // A newly-inserted row can now specify the S1-3 fields explicitly.
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: 'post-v7-profile',
                displayName: 'Alex',
                unitSystem: 'imperial',
                createdAt: now,
                updatedAt: now,
                heightCm: const Value(180),
                trainingDays: const Value('sat,sun'),
              ),
            );
        final updated = await (database.select(
          database.userProfiles,
        )..where((t) => t.id.equals('post-v7-profile'))).getSingle();
        expect(updated.heightCm, 180);
        expect(updated.trainingDays, 'sat,sun');
      },
    );
  });

  group('v8 schema (Routes, Activities.routeId)', () {
    test(
      'a fresh database opens at schema v8 with the routes table and '
      'activities.route_id usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await database.select(database.routes).get(), isEmpty);

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.routes)
            .insert(
              RoutesCompanion.insert(
                id: 'route-1',
                name: '5.0 km Run loop',
                distanceMeters: 5030,
                estimatedDurationSeconds: const Value(1800),
                ascentMeters: const Value(42.5),
                geometry: '_p~iF~ps|U_ulLnnqC',
                activityType: 'run',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final routeRow = await database.select(database.routes).getSingle();
        expect(routeRow.name, '5.0 km Run loop');
        expect(routeRow.distanceMeters, 5030);
        expect(routeRow.estimatedDurationSeconds, 1800);
        expect(routeRow.ascentMeters, 42.5);
        expect(routeRow.geometry, '_p~iF~ps|U_ulLnnqC');
        expect(routeRow.activityType, 'run');
        expect(routeRow.source, 'suggested');
        expect(routeRow.deletedAt, isNull);
        expect(routeRow.syncStatus, 'local');

        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: 'activity-1',
                activityType: 'run',
                title: 'Route run',
                startedAt: now,
                movingTimeMs: 0,
                elapsedTimeMs: 0,
                distanceMeters: 0,
                source: 'recorded',
                routeId: const Value('route-1'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final activityRow = await database
            .select(database.activities)
            .getSingle();
        expect(activityRow.routeId, 'route-1');
      },
    );

    test(
      'a v7-shaped database (routes missing, activities missing route_id) '
      'is upgraded by the real v7->v8 migration step: the table exists and '
      'pre-existing activities backfill to a null route_id',
      () async {
        // Same technique as every earlier test in this file: drop the
        // v8-only table and reshape `activities` back to its pre-v8 form,
        // then insert a pre-existing row directly via raw SQL before
        // migrating. `flare_events` needs the same reshaping (a real v7
        // device upgrades straight to v9 in one call, triggering the v9
        // step's guarded `addColumn`); everything else already has its
        // final v7 shape from `AppDatabase.forTesting`'s `onCreate`.
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        await reshapeFlareEventsToPreV9(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO activities '
          '(id, activity_type, title, started_at, moving_time_ms, '
          'elapsed_time_ms, distance_meters, source, created_at, updated_at) '
          "VALUES ('pre-v8-activity', 'run', 'Old run', $now, 0, 0, 0, "
          "'manual', $now, $now)",
        );

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 7, 10);

        expect(await database.select(database.routes).get(), isEmpty);

        final row = await database.select(database.activities).getSingle();
        expect(row.id, 'pre-v8-activity');
        expect(
          row.routeId,
          isNull,
          reason:
              'pre-v8 activities backfill to null - they were never '
              'started from a route',
        );

        // A newly-inserted row can now reference a route, and the routes
        // table is usable.
        await database
            .into(database.routes)
            .insert(
              RoutesCompanion.insert(
                id: 'route-1',
                name: 'Loop',
                distanceMeters: 5000,
                geometry: '',
                activityType: 'run',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: 'post-v8-activity',
                activityType: 'run',
                title: 'Route run',
                startedAt: now,
                movingTimeMs: 0,
                elapsedTimeMs: 0,
                distanceMeters: 0,
                source: 'recorded',
                routeId: const Value('route-1'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final updated = await (database.select(
          database.activities,
        )..where((t) => t.id.equals('post-v8-activity'))).getSingle();
        expect(updated.routeId, 'route-1');
      },
    );
  });

  group('v9 schema (FlareEvents.endDay)', () {
    test(
      'a fresh database opens at schema v9 with end_day usable, defaulting '
      'to null for a single-day flare',
      () async {
        expect(database.schemaVersion, 25);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;

        await database
            .into(database.flareEvents)
            .insert(
              FlareEventsCompanion.insert(
                id: 'single-day',
                day: '2026-08-20',
                severity: 'mild',
                impact: 'none',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.flareEvents)
            .insert(
              FlareEventsCompanion.insert(
                id: 'multi-day',
                day: '2026-08-20',
                endDay: const Value('2026-08-24'),
                severity: 'severe',
                impact: 'unableToTrain',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final rows = await database.select(database.flareEvents).get();
        expect(rows.firstWhere((r) => r.id == 'single-day').endDay, isNull);
        expect(
          rows.firstWhere((r) => r.id == 'multi-day').endDay,
          '2026-08-24',
        );
      },
    );

    test(
      'a v8-shaped database (flare_events missing end_day) is upgraded by '
      'the real v8->v9 migration step: the column exists and pre-existing '
      'flares backfill to a null end_day',
      () async {
        // Same technique as every earlier test in this file: reshape
        // `flare_events` back to its pre-v9 form, then insert a
        // pre-existing row directly via raw SQL before migrating.
        // `routes` is reshaped too: `onUpgrade` ignores its `to` argument
        // and runs every step whose `from` guard matches, so a genuine
        // v8 fixture must also predate v10's descent_meters or that step
        // collides on a duplicate column.
        await reshapeFlareEventsToPreV9(database);
        await reshapeRoutesToPreV10(database);
        await reshapeActivitiesToPreV15(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO flare_events '
          '(id, day, severity, symptoms, impact, created_at, updated_at) '
          "VALUES ('pre-v9-flare', '2026-08-20', 'severe', '', "
          "'unableToTrain', $now, $now)",
        );

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 8, 10);

        final row = await database.select(database.flareEvents).getSingle();
        expect(row.id, 'pre-v9-flare');
        expect(row.day, '2026-08-20');
        expect(
          row.endDay,
          isNull,
          reason:
              'pre-v9 flares backfill to null - they were all single-day, '
              'and null already means "covers `day` only"',
        );

        // A newly-inserted row can now span a range through the migrated
        // table.
        await database
            .into(database.flareEvents)
            .insert(
              FlareEventsCompanion.insert(
                id: 'post-v9-flare',
                day: '2026-08-21',
                endDay: const Value('2026-08-25'),
                severity: 'moderate',
                impact: 'unableToTrain',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final updated = await (database.select(
          database.flareEvents,
        )..where((t) => t.id.equals('post-v9-flare'))).getSingle();
        expect(updated.endDay, '2026-08-25');
      },
    );

    test(
      'a device upgrading from before v5 gets flare_events created with '
      "end_day already present - the v9 step's from >= 5 guard must skip "
      'its addColumn rather than erroring on a duplicate column',
      () async {
        // The mirror of the `is_paused`/`route_id` guard tests: drop every
        // post-v4 table so the fixture is shaped like a real v4 install,
        // then run the real upgrade. `flare_events` is recreated by the
        // `from < 5` branch at its *current* (v9) shape, so the v9 step
        // must not try to add `end_day` a second time.
        await database.customStatement('DROP TABLE daily_checkins');
        await database.customStatement('DROP TABLE flare_events');
        await database.customStatement('DROP TABLE recovery_days');
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        // `user_profiles` needs its usual reshape back to the v1 baseline
        // so the `from < 7` branch's addColumn calls have somewhere to go
        // (see the v1->v9 test's comment).
        await database.customStatement('DROP TABLE user_profiles');
        await database.customStatement('''
          CREATE TABLE user_profiles (
            id TEXT NOT NULL PRIMARY KEY,
            display_name TEXT NOT NULL,
            unit_system TEXT NOT NULL,
            weekly_activity_goal INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER,
            sync_status TEXT NOT NULL DEFAULT 'local'
          )
        ''');

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 4, 10);

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.flareEvents)
            .insert(
              FlareEventsCompanion.insert(
                id: 'f1',
                day: '2026-08-20',
                endDay: const Value('2026-08-22'),
                severity: 'mild',
                impact: 'unableToTrain',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.flareEvents).getSingle();
        expect(row.endDay, '2026-08-22');
      },
    );
  });

  test('inserting and reading a UserProfiles row round-trips', () async {
    final id = EntityId.generate();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await database
        .into(database.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: id,
            displayName: 'Jordan',
            unitSystem: 'metric',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final rows = await database.select(database.userProfiles).get();

    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.id, id);
    expect(row.displayName, 'Jordan');
    expect(row.unitSystem, 'metric');
    expect(row.weeklyActivityGoal, isNull);
    expect(row.createdAt, now);
    expect(row.updatedAt, now);
    expect(row.deletedAt, isNull);
    expect(row.syncStatus, 'local');
  });

  group('v10 schema (Routes.descentMeters)', () {
    Future<void> insertPreV10Route(AppDatabase database, int now) {
      return database.customStatement(
        'INSERT INTO routes '
        '(id, name, distance_meters, ascent_meters, geometry, '
        'activity_type, created_at, updated_at) '
        "VALUES ('pre-v10-route', 'Riverside loop', 5000.0, 40.0, "
        "'_p~iF~ps|U', 'run', $now, $now)",
      );
    }

    test(
      'a v9-shaped database (routes missing descent_meters) is upgraded by '
      'the real v9->v10 step: the column exists and pre-existing routes '
      'backfill to a null descent',
      () async {
        await reshapeRoutesToPreV10(database);
        await reshapeActivitiesToPreV15(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await insertPreV10Route(database, now);

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 9, 10);

        final row = await database.select(database.routes).getSingle();
        expect(row.id, 'pre-v10-route');
        expect(row.ascentMeters, 40.0);
        expect(
          row.descentMeters,
          isNull,
          reason:
              'descent was never captured for routes saved before v10 - '
              'null is the honest value, not zero',
        );
      },
    );

    test(
      'a device upgrading from before v8 gets routes created with '
      "descent_meters already present - the v10 step's from >= 8 guard must "
      'skip its addColumn rather than erroring on a duplicate column',
      () async {
        // Mirror of the is_paused / route_id / end_day guard tests: shape
        // the fixture like a real pre-v8 install, so the `from < 8` branch
        // creates `routes` fresh at its current (v10) shape - including
        // descent_meters. `activities` has to lose `route_id` too, since
        // that same branch adds it back and would otherwise collide.
        await database.customStatement('DROP TABLE routes');
        await reshapeActivitiesToPreV8(database);
        // A real v7 device's flare_events predates end_day too (the column
        // arrived at v9), and `onUpgrade` runs every matching step, so the
        // fixture has to be honest about that as well.
        await reshapeFlareEventsToPreV9(database);

        await dropNutritionTablesToPreV11(database);

        final migrator = Migrator(database);
        await expectLater(
          database.migration.onUpgrade(migrator, 7, 10),
          completes,
          reason:
              'a second addColumn for a just-created table would fail with '
              'a duplicate-column error',
        );

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.routes)
            .insert(
              RoutesCompanion.insert(
                id: 'fresh-route',
                name: 'Hill loop',
                distanceMeters: 8000,
                descentMeters: const Value(120.5),
                geometry: '_p~iF~ps|U',
                activityType: 'run',
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.routes).getSingle();
        expect(row.descentMeters, 120.5);
      },
    );
  });

  group('v11 schema (Foods, NutritionEntries, NutritionGoals)', () {
    test(
      'a fresh database opens at schema v11 with all three tables usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await database.select(database.foods).get(), isEmpty);
        expect(await database.select(database.nutritionEntries).get(), isEmpty);
        expect(await database.select(database.nutritionGoals).get(), isEmpty);
      },
    );

    test('inserting and reading a Foods row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.foods)
          .insert(
            FoodsCompanion.insert(
              id: id,
              name: 'Porridge oats',
              brand: const Value('Quaker'),
              servingDescription: '1 cup (dry)',
              servingGrams: const Value(80),
              caloriesKcal: 300,
              proteinGrams: 10,
              carbsGrams: 54,
              fatGrams: 5,
              ironMg: const Value(3.2),
              barcode: const Value('5000108000000'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.foods).getSingle();
      expect(row.id, id);
      expect(row.name, 'Porridge oats');
      expect(row.brand, 'Quaker');
      expect(row.servingGrams, 80);
      expect(row.ironMg, 3.2);
      expect(row.barcode, '5000108000000');
      expect(
        row.source,
        'custom',
        reason: 'every food written today is user-entered',
      );
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test('omitting the optional food columns leaves them null', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.foods)
          .insert(
            FoodsCompanion.insert(
              id: 'plain',
              name: 'Apple',
              servingDescription: '1 medium',
              caloriesKcal: 95,
              proteinGrams: 0.5,
              carbsGrams: 25,
              fatGrams: 0.3,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.foods).getSingle();
      expect(row.brand, isNull);
      expect(row.servingGrams, isNull);
      expect(row.barcode, isNull);
      expect(
        row.ironMg,
        isNull,
        reason: 'unknown iron stays null - it is never backfilled to zero',
      );
    });

    test('inserting and reading a NutritionEntries row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.nutritionEntries)
          .insert(
            NutritionEntriesCompanion.insert(
              id: id,
              day: '2026-08-20',
              meal: 'breakfast',
              foodId: const Value('food-1'),
              foodName: 'Porridge oats',
              foodBrand: const Value('Quaker'),
              servingDescription: const Value('1 cup (dry)'),
              quantityServings: 1.5,
              caloriesKcal: 300,
              proteinGrams: 10,
              carbsGrams: 54,
              fatGrams: 5,
              ironMg: const Value(3.2),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.nutritionEntries).getSingle();
      expect(row.id, id);
      expect(row.day, '2026-08-20');
      expect(row.meal, 'breakfast');
      expect(row.foodId, 'food-1');
      expect(row.foodName, 'Porridge oats');
      expect(row.quantityServings, 1.5);
      expect(row.caloriesKcal, 300);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, 'local');
    });

    test(
      'the nutrition_entries day index is NOT unique - a day holds as many '
      'entries as the user logs',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        for (final id in ['a', 'b', 'c']) {
          await database
              .into(database.nutritionEntries)
              .insert(
                NutritionEntriesCompanion.insert(
                  id: id,
                  day: '2026-08-20',
                  meal: 'snack',
                  foodName: 'Food $id',
                  quantityServings: 1,
                  caloriesKcal: 10,
                  proteinGrams: 1,
                  carbsGrams: 1,
                  fatGrams: 1,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }

        expect(
          await database.select(database.nutritionEntries).get(),
          hasLength(3),
        );
      },
    );

    test(
      'an entry survives its referenced food being deleted - no FK '
      'constraint blocks or cascades',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.foods)
            .insert(
              FoodsCompanion.insert(
                id: 'food-1',
                name: 'Porridge oats',
                servingDescription: '1 cup',
                caloriesKcal: 300,
                proteinGrams: 10,
                carbsGrams: 54,
                fatGrams: 5,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.nutritionEntries)
            .insert(
              NutritionEntriesCompanion.insert(
                id: 'entry-1',
                day: '2026-08-20',
                meal: 'breakfast',
                foodId: const Value('food-1'),
                foodName: 'Porridge oats',
                quantityServings: 1,
                caloriesKcal: 300,
                proteinGrams: 10,
                carbsGrams: 54,
                fatGrams: 5,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await database.delete(database.foods).go();

        final row = await database
            .select(database.nutritionEntries)
            .getSingle();
        expect(row.foodId, 'food-1');
        expect(
          row.caloriesKcal,
          300,
          reason: 'the snapshot keeps the entry complete on its own',
        );
      },
    );

    test(
      'NutritionGoals defaults are the neutral, non-assuming ones',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'goals-1',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final row = await database.select(database.nutritionGoals).getSingle();
        expect(row.calorieTargetKcal, isNull);
        expect(row.proteinTargetGrams, isNull);
        expect(row.carbTargetGrams, isNull);
        expect(row.fatTargetGrams, isNull);
        expect(row.activityLevel, isNull);
        expect(row.hideCalorieNumbers, isFalse);
        expect(row.weightGoal, 'maintain');
        expect(row.dailyDeficitKcal, 0);
      },
    );

    test(
      'a v10-shaped database (all three nutrition tables missing) is '
      'upgraded by the real v10->v11 step: the tables and their indices '
      'exist afterwards and are usable',
      () async {
        // Same technique as every earlier migration test in this file: drop
        // the v11-only tables so the database is shaped like a real v10
        // install, then invoke the production `onUpgrade` directly.
        // Everything else already has its final v10 shape from
        // `AppDatabase.forTesting`'s `onCreate`, and the v11 step adds no
        // columns to any pre-existing table - which is exactly why it needs
        // no `from >= N` guard (see `app_database.dart`'s migration doc).
        await dropNutritionTablesToPreV11(database);
        await reshapeActivitiesToPreV15(database);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 10, 11);

        expect(await database.select(database.foods).get(), isEmpty);
        expect(await database.select(database.nutritionEntries).get(), isEmpty);
        expect(await database.select(database.nutritionGoals).get(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(
          indexNames,
          containsAll([
            'idx_foods_name',
            'idx_foods_barcode',
            'idx_nutrition_entries_day',
          ]),
        );

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.foods)
            .insert(
              FoodsCompanion.insert(
                id: 'post-v11-food',
                name: 'Banana',
                servingDescription: '1 medium',
                caloriesKcal: 105,
                proteinGrams: 1.3,
                carbsGrams: 27,
                fatGrams: 0.4,
                createdAt: now,
                updatedAt: now,
              ),
            );
        expect(
          (await database.select(database.foods).getSingle()).name,
          'Banana',
        );
      },
    );
  });

  group('v12 schema (NutritionGoals macro mode + percent targets)', () {
    test(
      'a fresh database opens at schema v12 with the mode defaulting to '
      'grams and every percent target null',
      () async {
        expect(database.schemaVersion, 25);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'goals-1',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final row = await database.select(database.nutritionGoals).getSingle();
        expect(
          row.macroTargetMode,
          'grams',
          reason: 'grams is what the columns already meant before v12',
        );
        expect(row.proteinTargetPercent, isNull);
        expect(row.carbTargetPercent, isNull);
        expect(row.fatTargetPercent, isNull);
      },
    );

    test('a percent-mode row round-trips its split', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.nutritionGoals)
          .insert(
            NutritionGoalsCompanion.insert(
              id: 'goals-1',
              macroTargetMode: const Value('percent'),
              proteinTargetPercent: const Value(30),
              carbTargetPercent: const Value(40),
              fatTargetPercent: const Value(30),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.nutritionGoals).getSingle();
      expect(row.macroTargetMode, 'percent');
      expect(row.proteinTargetPercent, 30);
      expect(row.carbTargetPercent, 40);
      expect(row.fatTargetPercent, 30);
    });

    test(
      'a v11-shaped database (nutrition_goals missing the macro-mode and '
      'percent columns) is upgraded by the real v11->v12 step: the columns '
      'exist and a pre-existing row backfills to grams mode with null '
      'percentages',
      () async {
        // Same technique as every earlier migration test in this file:
        // reshape the table back to its pre-v12 form, then insert a
        // pre-existing row via raw SQL before migrating. `nutrition_entries`
        // needs the same treatment: a `from` of 11 is inside the v13 step's
        // `from >= 11` window, and `onUpgrade` ignores its `to` argument, so
        // a fixture still carrying the current-shape table would collide on
        // a duplicate column there.
        await reshapeNutritionGoalsToPreV12(database);
        await reshapeNutritionEntriesToPreV13(database);
        await reshapeActivitiesToPreV15(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO nutrition_goals '
          '(id, calorie_target_kcal, protein_target_grams, created_at, '
          'updated_at) '
          "VALUES ('pre-v12-goals', 2100, 110.0, $now, $now)",
        );

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 11, 12);

        final row = await database.select(database.nutritionGoals).getSingle();
        expect(row.id, 'pre-v12-goals');
        expect(
          row.calorieTargetKcal,
          2100,
          reason: 'the targets a v11 row already held are untouched',
        );
        expect(
          row.proteinTargetGrams,
          110,
          reason: 'the targets a v11 row already held are untouched',
        );
        expect(
          row.macroTargetMode,
          'grams',
          reason:
              'grams is what the columns meant before v12, so every '
              'pre-existing row keeps meaning that',
        );
        expect(
          row.proteinTargetPercent,
          isNull,
          reason: 'percentages were not set on pre-v12 rows',
        );
        expect(row.carbTargetPercent, isNull);
        expect(row.fatTargetPercent, isNull);

        // The new columns are writable through the migrated table.
        await (database.update(
          database.nutritionGoals,
        )..where((t) => t.id.equals('pre-v12-goals'))).write(
          const NutritionGoalsCompanion(
            macroTargetMode: Value('percent'),
            proteinTargetPercent: Value(25),
          ),
        );
        final updated = await database
            .select(database.nutritionGoals)
            .getSingle();
        expect(updated.macroTargetMode, 'percent');
        expect(updated.proteinTargetPercent, 25);
      },
    );

    test(
      'a device upgrading from before v11 gets nutrition_goals created with '
      "the v12 columns already present - the v12 step's from >= 11 guard "
      'must skip its addColumn rather than erroring on a duplicate column',
      () async {
        // Mirror of the is_paused / route_id / end_day / descent_meters
        // guard tests: shape the fixture like a real v10 install, so the
        // `from < 11` branch creates `nutrition_goals` fresh at its current
        // (v12) shape - percent columns included.
        await dropNutritionTablesToPreV11(database);
        await reshapeActivitiesToPreV15(database);

        final migrator = Migrator(database);
        await expectLater(
          database.migration.onUpgrade(migrator, 10, 12),
          completes,
          reason:
              'a second addColumn for a just-created table would fail with '
              'a duplicate-column error',
        );

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'fresh-goals',
                macroTargetMode: const Value('percent'),
                fatTargetPercent: const Value(30),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.nutritionGoals).getSingle();
        expect(row.macroTargetMode, 'percent');
        expect(row.fatTargetPercent, 30);
      },
    );
  });

  group(
    'v13 schema (NutritionEntries quantity amount/unit + servingGrams)',
    () {
      test(
        'a fresh database opens at schema v13 with an entry able to record '
        'the unit it was logged in',
        () async {
          expect(database.schemaVersion, 25);
          final now = DateTime.now().toUtc().millisecondsSinceEpoch;
          await database
              .into(database.nutritionEntries)
              .insert(
                NutritionEntriesCompanion.insert(
                  id: 'grams-entry',
                  day: '2026-08-20',
                  meal: 'breakfast',
                  foodName: 'Porridge oats',
                  quantityServings: 2,
                  quantityAmount: const Value(60),
                  quantityUnit: const Value('gram'),
                  servingGrams: const Value(30),
                  caloriesKcal: 150,
                  proteinGrams: 5,
                  carbsGrams: 27,
                  fatGrams: 2.5,
                  createdAt: now,
                  updatedAt: now,
                ),
              );

          final row = await database
              .select(database.nutritionEntries)
              .getSingle();
          expect(row.quantityAmount, 60);
          expect(row.quantityUnit, 'gram');
          expect(row.servingGrams, 30);
          expect(
            row.quantityServings,
            2,
            reason: 'the multiplier is what the totals use, unit or no unit',
          );
        },
      );

      test(
        'omitting the new columns leaves an entry saying exactly what a '
        'pre-v13 one said',
        () async {
          final now = DateTime.now().toUtc().millisecondsSinceEpoch;
          await database
              .into(database.nutritionEntries)
              .insert(
                NutritionEntriesCompanion.insert(
                  id: 'plain',
                  day: '2026-08-20',
                  meal: 'snack',
                  foodName: 'Apple',
                  quantityServings: 1,
                  caloriesKcal: 95,
                  proteinGrams: 0.5,
                  carbsGrams: 25,
                  fatGrams: 0.3,
                  createdAt: now,
                  updatedAt: now,
                ),
              );

          final row = await database
              .select(database.nutritionEntries)
              .getSingle();
          expect(row.quantityUnit, 'serving');
          expect(
            row.servingGrams,
            isNull,
            reason:
                'no weight was recorded against this entry - null is what '
                'quantity_unit.dart reads as "weight units unavailable"',
          );
        },
      );

      test(
        'a v12-shaped database (nutrition_entries missing the amount, unit '
        'and serving-weight columns) is upgraded by the real v12->v13 step: '
        'the columns exist and every pre-existing row is backfilled from its '
        'own serving count',
        () async {
          // Same technique as every earlier migration test in this file:
          // reshape the table back to its pre-v13 form, then insert
          // pre-existing rows via raw SQL before migrating. `nutrition_goals`
          // needs its own reshape: a `from` of 12 is inside the v14 step's
          // `from >= 11` window, and `onUpgrade` ignores its `to` argument,
          // so a fixture still carrying the current-shape table would collide
          // on a duplicate `macro_locks`.
          await reshapeNutritionEntriesToPreV13(database);
          await reshapeNutritionGoalsToPreV14(database);
          await reshapeActivitiesToPreV15(database);
          final now = DateTime.now().toUtc().millisecondsSinceEpoch;
          await database.customStatement(
            'INSERT INTO nutrition_entries '
            '(id, day, meal, food_name, quantity_servings, calories_kcal, '
            'protein_grams, carbs_grams, fat_grams, created_at, updated_at) '
            "VALUES ('pre-v13-entry', '2026-08-20', 'breakfast', "
            "'Porridge oats', 2.5, 300, 10, 54, 5, $now, $now)",
          );
          await database.customStatement(
            'INSERT INTO nutrition_entries '
            '(id, day, meal, food_name, quantity_servings, calories_kcal, '
            'protein_grams, carbs_grams, fat_grams, created_at, updated_at) '
            "VALUES ('half-entry', '2026-08-20', 'snack', 'Apple', 0.5, 95, "
            '0.5, 25, 0.3, $now, $now)',
          );

          final migrator = Migrator(database);
          await database.migration.onUpgrade(migrator, 12, 13);

          final rows = await database.select(database.nutritionEntries).get();
          final entry = rows.firstWhere((r) => r.id == 'pre-v13-entry');
          expect(
            entry.quantityServings,
            2.5,
            reason: 'the canonical multiplier is never rewritten by this step',
          );
          expect(
            entry.quantityAmount,
            2.5,
            reason:
                'the amount she typed was her serving count, so the backfill '
                'is honest',
          );
          expect(
            entry.quantityUnit,
            'serving',
            reason: 'serving is what the pre-v13 UI accepted',
          );
          expect(
            entry.servingGrams,
            isNull,
            reason:
                'serving weight was never captured before v13 - null is the '
                'honest value, not a guessed weight',
          );
          final half = rows.firstWhere((r) => r.id == 'half-entry');
          expect(half.quantityAmount, 0.5);
          expect(half.quantityUnit, 'serving');

          // The new columns are writable through the migrated table.
          await (database.update(
            database.nutritionEntries,
          )..where((t) => t.id.equals('pre-v13-entry'))).write(
            const NutritionEntriesCompanion(
              quantityAmount: Value(75),
              quantityUnit: Value('gram'),
              servingGrams: Value(30),
            ),
          );
          final updated = await (database.select(
            database.nutritionEntries,
          )..where((t) => t.id.equals('pre-v13-entry'))).getSingle();
          expect(updated.quantityAmount, 75);
          expect(updated.quantityUnit, 'gram');
          expect(updated.servingGrams, 30);
        },
      );

      test(
        'a device upgrading from before v11 gets nutrition_entries created '
        "with the v13 columns already present - the v13 step's from >= 11 "
        'guard must skip its addColumn rather than erroring on a duplicate '
        'column',
        () async {
          // Mirror of the is_paused / route_id / end_day / descent_meters /
          // macro-mode guard tests: shape the fixture like a real v10 install,
          // so the `from < 11` branch creates `nutrition_entries` fresh at its
          // current (v13) shape - the three new columns included.
          await dropNutritionTablesToPreV11(database);
          await reshapeActivitiesToPreV15(database);

          final migrator = Migrator(database);
          await expectLater(
            database.migration.onUpgrade(migrator, 10, 13),
            completes,
            reason:
                'a second addColumn for a just-created table would fail with '
                'a duplicate-column error',
          );

          final now = DateTime.now().toUtc().millisecondsSinceEpoch;
          await database
              .into(database.nutritionEntries)
              .insert(
                NutritionEntriesCompanion.insert(
                  id: 'fresh-entry',
                  day: '2026-08-20',
                  meal: 'lunch',
                  foodName: 'Porridge oats',
                  quantityServings: 1.5,
                  quantityAmount: const Value(45),
                  quantityUnit: const Value('gram'),
                  servingGrams: const Value(30),
                  caloriesKcal: 300,
                  proteinGrams: 10,
                  carbsGrams: 54,
                  fatGrams: 5,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          final row = await database
              .select(database.nutritionEntries)
              .getSingle();
          expect(row.quantityAmount, 45);
          expect(row.quantityUnit, 'gram');
        },
      );
    },
  );

  group('v14 schema (NutritionGoals.macroLocks)', () {
    test(
      'a fresh database opens at schema v14 with no macro locked and a lock '
      'set round-tripping',
      () async {
        expect(database.schemaVersion, 25);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'default-goals',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'locked-goals',
                macroLocks: const Value('protein,fat'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        final rows = await database.select(database.nutritionGoals).get();
        expect(
          rows.firstWhere((r) => r.id == 'default-goals').macroLocks,
          '',
          reason: 'nothing is locked until the user says so',
        );
        expect(
          rows.firstWhere((r) => r.id == 'locked-goals').macroLocks,
          'protein,fat',
        );
      },
    );

    test(
      'a v13-shaped database (nutrition_goals missing macro_locks) is '
      'upgraded by the real v13->v14 step: the column exists, a pre-existing '
      'row keeps its targets, and it reads back with nothing locked',
      () async {
        // Same technique as every earlier migration test in this file:
        // reshape the table back to its pre-v14 form, then insert a
        // pre-existing row via raw SQL before migrating.
        await reshapeNutritionGoalsToPreV14(database);
        await reshapeActivitiesToPreV15(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO nutrition_goals '
          '(id, calorie_target_kcal, protein_target_grams, carb_target_grams, '
          'fat_target_grams, macro_target_mode, created_at, updated_at) '
          "VALUES ('pre-v14-goals', 2000, 150.0, 200.0, 67.0, 'grams', $now, "
          '$now)',
        );

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 13, 14);

        final row = await database.select(database.nutritionGoals).getSingle();
        expect(row.id, 'pre-v14-goals');
        expect(
          row.calorieTargetKcal,
          2000,
          reason: 'the targets a v13 row already held are untouched',
        );
        expect(row.proteinTargetGrams, 150);
        expect(row.carbTargetGrams, 200);
        expect(row.fatTargetGrams, 67);
        expect(row.macroTargetMode, 'grams');
        expect(
          row.macroLocks,
          '',
          reason:
              'nobody locked anything before v14, and the empty set is '
              'exactly what those rows mean - no backfill is owed',
        );

        // The new column is writable through the migrated table.
        await (database.update(
          database.nutritionGoals,
        )..where((t) => t.id.equals('pre-v14-goals'))).write(
          const NutritionGoalsCompanion(macroLocks: Value('protein,carbs')),
        );
        final updated = await database
            .select(database.nutritionGoals)
            .getSingle();
        expect(updated.macroLocks, 'protein,carbs');
      },
    );

    test(
      'a device upgrading from before v11 gets nutrition_goals created with '
      "macro_locks already present - the v14 step's from >= 11 guard must "
      'skip its addColumn rather than erroring on a duplicate column',
      () async {
        // Mirror of the is_paused / route_id / end_day / descent_meters /
        // macro-mode / quantity-amount guard tests: shape the fixture like a
        // real v10 install, so the `from < 11` branch creates
        // `nutrition_goals` fresh at its current (v14) shape - macro_locks
        // included.
        await dropNutritionTablesToPreV11(database);
        await reshapeActivitiesToPreV15(database);

        final migrator = Migrator(database);
        await expectLater(
          database.migration.onUpgrade(migrator, 10, 14),
          completes,
          reason:
              'a second addColumn for a just-created table would fail with '
              'a duplicate-column error',
        );

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: 'fresh-goals',
                macroLocks: const Value('carbs,fat'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.nutritionGoals).getSingle();
        expect(row.macroLocks, 'carbs,fat');
      },
    );
  });

  group('v15 schema (Activities.metadataJson)', () {
    test(
      'a fresh database opens at schema v15 with nullable metadataJson and '
      'stores structured JSON correctly',
      () async {
        expect(database.schemaVersion, 25);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: 'fresh-strength-act',
                activityType: 'strength',
                title: 'Leg Day',
                startedAt: now,
                movingTimeMs: 3600000,
                elapsedTimeMs: 3600000,
                distanceMeters: 0,
                source: 'manual',
                metadataJson: const Value('{"type":"strength","exercises":[]}'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        final row = await database.select(database.activities).getSingle();
        expect(row.metadataJson, '{"type":"strength","exercises":[]}');
      },
    );

    test(
      'a v14-shaped database (activities missing metadata_json) is upgraded '
      'by the real v14->v15 step: pre-existing rows keep their data with '
      'null metadata_json, and the column is writable',
      () async {
        await reshapeActivitiesToPreV15(database);
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database.customStatement(
          'INSERT INTO activities '
          '(id, activity_type, title, started_at, moving_time_ms, '
          'elapsed_time_ms, distance_meters, source, created_at, updated_at) '
          "VALUES ('pre-v15-run', 'run', 'Morning Run', $now, 1800000, "
          "1800000, 5000.0, 'recorded', $now, $now)",
        );

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 14, 15);

        final row = await database.select(database.activities).getSingle();
        expect(row.id, 'pre-v15-run');
        expect(row.title, 'Morning Run');
        expect(row.distanceMeters, 5000.0);
        expect(row.metadataJson, isNull);

        // Update the migrated row with metadataJson.
        await (database.update(
          database.activities,
        )..where((t) => t.id.equals('pre-v15-run'))).write(
          const ActivitiesCompanion(
            metadataJson: Value('{"type":"general","rpe":7}'),
          ),
        );
        final updated = await database.select(database.activities).getSingle();
        expect(updated.metadataJson, '{"type":"general","rpe":7}');
      },
    );

    test(
      'a device upgrading from v1 gets activities created with metadata_json '
      "already present - the v15 step's from >= 2 guard must skip its "
      'addColumn rather than erroring on a duplicate column',
      () async {
        await dropAllTablesToPreV2(database);

        final migrator = Migrator(database);
        await expectLater(
          database.migration.onUpgrade(migrator, 1, 15),
          completes,
          reason:
              'a second addColumn for a just-created table would fail with '
              'a duplicate-column error',
        );

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.activities)
            .insert(
              ActivitiesCompanion.insert(
                id: 'v1-upgraded-act',
                activityType: 'yoga',
                title: 'Evening Flow',
                startedAt: now,
                movingTimeMs: 1800000,
                elapsedTimeMs: 1800000,
                distanceMeters: 0,
                source: 'manual',
                metadataJson: const Value('{"type":"mindful","style":"Yin"}'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        final row = await database.select(database.activities).getSingle();
        expect(row.metadataJson, '{"type":"mindful","style":"Yin"}');
      },
    );
  });

  group('v16 schema (WaterLogs)', () {
    test(
      'a fresh database opens at schema v16 with waterLogs usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await database.select(database.waterLogs).get(), isEmpty);
      },
    );

    test('inserting and reading a WaterLogs row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc();

      await database
          .into(database.waterLogs)
          .insert(
            WaterLogsCompanion.insert(
              id: id,
              day: '2026-08-29',
              milliliters: 250,
              createdAt: now,
            ),
          );

      final row = await database.select(database.waterLogs).getSingle();
      expect(row.id, id);
      expect(row.day, '2026-08-29');
      expect(row.milliliters, 250);
    });

    test(
      'a v15-shaped database (water_logs missing) is upgraded by the real '
      'v15->v16 step: the table and index exist afterwards',
      () async {
        await database.customStatement('DROP TABLE IF EXISTS water_logs');
        await database.customStatement('DROP TABLE IF EXISTS weight_logs');
        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 15, 16);

        expect(await database.select(database.waterLogs).get(), isEmpty);
      },
    );
  });

  group('v17 schema (StrengthRoutines, StrengthCycles)', () {
    test(
      'a fresh database opens at schema v17 with strength tables usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await database.select(database.strengthRoutines).get(), isEmpty);
        expect(await database.select(database.strengthCycles).get(), isEmpty);
      },
    );

    test(
      'inserting and reading strength routines and cycles round-trips',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        final routineId = EntityId.generate();
        final cycleId = EntityId.generate();

        await database
            .into(database.strengthRoutines)
            .insert(
              StrengthRoutinesCompanion.insert(
                id: routineId,
                name: 'Upper Body A',
                exercisesJson: '[]',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await database
            .into(database.strengthCycles)
            .insert(
              StrengthCyclesCompanion.insert(
                id: cycleId,
                name: '4-Week Hypertrophy',
                routinesJson: '[]',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final rRow = await database
            .select(database.strengthRoutines)
            .getSingle();
        expect(rRow.id, routineId);
        expect(rRow.name, 'Upper Body A');

        final cRow = await database.select(database.strengthCycles).getSingle();
        expect(cRow.id, cycleId);
        expect(cRow.name, '4-Week Hypertrophy');
      },
    );

    test(
      'a v16-shaped database (strength tables missing) is upgraded by the '
      'real v16->v17 step: both tables exist afterwards',
      () async {
        await database.customStatement(
          'DROP TABLE IF EXISTS strength_routines',
        );
        await database.customStatement('DROP TABLE IF EXISTS strength_cycles');
        // `onUpgrade` ignores its `to` argument and runs every step whose
        // `from` guard matches, so a genuine v16 fixture must also predate
        // v18's `weight_logs` - otherwise that step's `createIndex`
        // collides with the index `onCreate` already built.
        await database.customStatement('DROP TABLE IF EXISTS weight_logs');
        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 16, 17);

        expect(await database.select(database.strengthRoutines).get(), isEmpty);
        expect(await database.select(database.strengthCycles).get(), isEmpty);
      },
    );
  });

  group('v18 schema (WeightLogs)', () {
    /// Shapes the fixture like a real v17 install: `weight_logs` doesn't
    /// exist at all, so the v18 step creates it (and its index) for real.
    ///
    /// Dropping the *table* is what matters, and not only because of the
    /// table: `Migrator.createTable` emits `CREATE TABLE IF NOT EXISTS` and
    /// would tolerate a leftover, but `createIndex` does not - it emits a
    /// bare `CREATE INDEX`, which collides with the index
    /// `AppDatabase.forTesting`'s `onCreate` already built. Dropping the
    /// table takes its index with it. (Same reason every fixture in this
    /// file drops `water_logs`.)
    Future<void> dropWeightLogsToPreV18() async {
      await database.customStatement('DROP TABLE IF EXISTS weight_logs');
    }

    Future<void> insertProfile({
      required String id,
      double? weightKg,
      int? createdAtMillis,
      int? deletedAtMillis,
    }) async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: id,
              displayName: 'Jordan',
              unitSystem: 'metric',
              weightKg: Value(weightKg),
              deletedAt: Value(deletedAtMillis),
              createdAt: createdAtMillis ?? now,
              updatedAt: now,
            ),
          );
    }

    Future<List<WeightLog>> weightRows() =>
        database.select(database.weightLogs).get();

    test(
      'a fresh database opens at schema v18 with weight_logs usable',
      () async {
        expect(database.schemaVersion, 25);
        expect(await weightRows(), isEmpty);
      },
    );

    test('inserting and reading a WeightLogs row round-trips', () async {
      final id = EntityId.generate();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await database
          .into(database.weightLogs)
          .insert(
            WeightLogsCompanion.insert(
              id: id,
              day: '2026-09-01',
              weightKg: 64.4,
              notes: const Value('after a long run'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.weightLogs).getSingle();
      expect(row.id, id);
      expect(row.day, '2026-09-01');
      expect(row.weightKg, 64.4);
      expect(row.notes, 'after a long run');
      expect(
        row.source,
        'manual',
        reason: 'an unspecified source is a value the user entered herself',
      );
    });

    test('notes default to null when none is given', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await database
          .into(database.weightLogs)
          .insert(
            WeightLogsCompanion.insert(
              id: EntityId.generate(),
              day: '2026-09-01',
              weightKg: 64.4,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row = await database.select(database.weightLogs).getSingle();
      expect(row.notes, isNull);
    });

    test(
      'multiple rows are allowed on the same day - the day index is '
      'deliberately not unique (morning and evening weigh-ins)',
      () async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.weightLogs)
            .insert(
              WeightLogsCompanion.insert(
                id: 'morning',
                day: '2026-09-01',
                weightKg: 64.1,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await database
            .into(database.weightLogs)
            .insert(
              WeightLogsCompanion.insert(
                id: 'evening',
                day: '2026-09-01',
                weightKg: 64.9,
                createdAt: now + 1,
                updatedAt: now + 1,
              ),
            );

        expect(await weightRows(), hasLength(2));
      },
    );

    test(
      'a v17-shaped database (weight_logs missing) is upgraded by the real '
      'v17->v18 step: the table and its index exist afterwards',
      () async {
        await dropWeightLogsToPreV18();

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        expect(await weightRows(), isEmpty);

        final indexNames = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .map((row) => row.read<String>('name'))
            .get();
        expect(indexNames, contains('idx_weight_logs_day'));
      },
    );

    test(
      'the v17->v18 step seeds one profile-migration log when the profile '
      'already held a weight, dated the migration day - so the history '
      "doesn't start empty on an upgrading install",
      () async {
        await dropWeightLogsToPreV18();
        await insertProfile(id: 'profile-1', weightKg: 63.2);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        final rows = await weightRows();
        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.weightKg, 63.2);
        expect(row.source, 'profile-migration');
        expect(
          row.day,
          LocalDate.today().toIso(),
          reason:
              'the profile stores a value with no measurement date - the '
              'migration day is the only date we can honestly claim',
        );
        expect(
          row.notes,
          isNull,
          reason: 'nothing was written about a value copied by a migration',
        );
        expect(
          await database.select(database.userProfiles).getSingle(),
          isA<UserProfile>().having((p) => p.weightKg, 'weightKg', 63.2),
          reason:
              'the seed is a one-way copy - user_profiles.weight_kg stays '
              'put, several features read it',
        );
      },
    );

    test(
      'the v17->v18 step seeds nothing when the profile has no weight',
      () async {
        await dropWeightLogsToPreV18();
        await insertProfile(id: 'profile-1');

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        expect(await weightRows(), isEmpty);
      },
    );

    test(
      'the v17->v18 step seeds nothing when there is no profile at all',
      () async {
        await dropWeightLogsToPreV18();

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        expect(await weightRows(), isEmpty);
      },
    );

    test(
      'the v17->v18 seed reads the earliest-created non-deleted profile - '
      "the same row DriftProfileRepository calls 'her profile'",
      () async {
        await dropWeightLogsToPreV18();
        // Out of insertion order on purpose: the seed must sort, not take
        // whatever sqlite hands back first.
        await insertProfile(
          id: 'profile-late',
          weightKg: 70,
          createdAtMillis: 2000,
        );
        await insertProfile(
          id: 'profile-first',
          weightKg: 63.2,
          createdAtMillis: 1000,
        );
        await insertProfile(
          id: 'profile-deleted',
          weightKg: 55,
          createdAtMillis: 500,
          deletedAtMillis: 900,
        );

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        final rows = await weightRows();
        expect(rows, hasLength(1));
        expect(
          rows.single.weightKg,
          63.2,
          reason:
              'the soft-deleted row is skipped even though it is older, '
              'and the later row loses to the earliest live one',
        );
      },
    );

    test(
      'the v17->v18 seed is idempotent: a re-entered upgrade does not stack '
      'a second profile-migration row onto an existing history',
      () async {
        await dropWeightLogsToPreV18();
        await insertProfile(id: 'profile-1', weightKg: 63.2);

        final migrator = Migrator(database);
        await database.migration.onUpgrade(migrator, 17, 18);

        // A weigh-in the user logged herself after the upgrade - the thing
        // a duplicated seed would sit next to and quietly corrupt.
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await database
            .into(database.weightLogs)
            .insert(
              WeightLogsCompanion.insert(
                id: 'user-logged',
                day: '2026-09-02',
                weightKg: 63,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Re-run the same step against a database that already has the
        // table AND its data. Only the index is dropped first: unlike
        // `createTable`, `createIndex` has no `IF NOT EXISTS`, so it would
        // fail on the index before the seed guard ever got a chance to
        // prove itself - and the index is not what this test is about.
        await database.customStatement('DROP INDEX idx_weight_logs_day');
        await database.migration.onUpgrade(migrator, 17, 18);

        final rows = await weightRows();
        expect(
          rows.where((r) => r.source == 'profile-migration'),
          hasLength(1),
          reason: 'the seed inserts at most once per install, ever',
        );
        expect(rows, hasLength(2), reason: "the user's own log survives");
      },
    );
  });

  group('v19 schema (BadgeAwards)', () {
    /// Shapes the fixture like a real v18 install: `badge_awards` doesn't
    /// exist at all, so the v19 step creates it for real.
    ///
    /// **Note what this file does NOT need for v19, and why.** Every other
    /// table-with-index migration here obliged every `onUpgrade` fixture in
    /// this file to drop the new table first, because `createIndex` has no
    /// `IF NOT EXISTS` and collides with the index `onCreate` already built
    /// (`knowledge/troubleshooting/database_migrations.md`). `badge_awards`
    /// carries a `UNIQUE(badge_id, tier_key)` **table constraint** instead
    /// of a standalone index, so its uniqueness is emitted inside the
    /// `CREATE TABLE IF NOT EXISTS` statement and the v19 step is re-entrant
    /// on its own. That is a deliberate design choice, not luck - see
    /// `core/db/tables/badge_awards.dart`. The re-entrancy test below is
    /// what keeps it true.
    Future<void> dropBadgeAwardsToPreV19() async {
      await database.customStatement('DROP TABLE IF EXISTS badge_awards');
    }

    Future<List<BadgeAwardRow>> awardRows() =>
        database.select(database.badgeAwards).get();

    Future<void> insertAward({
      required String id,
      String badgeId = 'run_distance',
      String tierKey = 'bronze',
      int awardedAt = 1000,
    }) {
      return database
          .into(database.badgeAwards)
          .insert(
            BadgeAwardsCompanion.insert(
              id: id,
              badgeId: badgeId,
              tierKey: tierKey,
              awardedAt: awardedAt,
            ),
          );
    }

    test(
      'a fresh database opens at schema v19 with badge_awards usable',
      () async {
        expect(await awardRows(), isEmpty);
        expect(database.schemaVersion, 25);
      },
    );

    test('inserting and reading a BadgeAwards row round-trips', () async {
      await insertAward(
        id: 'a1',
        tierKey: 'diamond-2',
        awardedAt: 1735689600000,
      );
      final rows = await awardRows();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'a1');
      expect(rows.single.badgeId, 'run_distance');
      expect(rows.single.tierKey, 'diamond-2');
      expect(rows.single.awardedAt, 1735689600000);
    });

    test('the unique key rejects the same badge and tier twice', () async {
      await insertAward(id: 'a1');
      await expectLater(
        insertAward(id: 'a2'),
        throwsA(isA<Exception>()),
        reason:
            'idempotency is enforced by the database, not only by the '
            'repository - see core/db/tables/badge_awards.dart',
      );
    });

    test('different tiers of one badge, and one tier of different badges, '
        'both coexist', () async {
      await insertAward(id: 'a1');
      await insertAward(id: 'a2', tierKey: 'silver');
      await insertAward(id: 'a3', badgeId: 'ride_distance');
      expect(await awardRows(), hasLength(3));
    });

    test('the one-off sentinel is a real value, so it de-duplicates', () async {
      // The whole reason `tier_key` is NOT NULL: SQLite treats two NULLs as
      // distinct inside a UNIQUE constraint, so a nullable column would let
      // the same one-off be awarded any number of times.
      await insertAward(id: 'a1', badgeId: 'first_activity', tierKey: 'once');
      await expectLater(
        insertAward(id: 'a2', badgeId: 'first_activity', tierKey: 'once'),
        throwsA(isA<Exception>()),
      );
    });

    test('migrating from v18 creates badge_awards', () async {
      final migrator = database.createMigrator();
      await dropBadgeAwardsToPreV19();

      await database.migration.onUpgrade(migrator, 18, 19);

      expect(await awardRows(), isEmpty);
      await insertAward(id: 'a1');
      expect(await awardRows(), hasLength(1));
    });

    test('migrating from v1 creates badge_awards too', () async {
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);

      await database.migration.onUpgrade(migrator, 1, 19);

      expect(await awardRows(), isEmpty);
    });

    test('the step is re-entrant with the table already in place', () async {
      // No DROP of any kind before the replay - that is the point. The step
      // has no `createIndex`, so `CREATE TABLE IF NOT EXISTS` carries it,
      // and no data is disturbed.
      await insertAward(id: 'a1');
      final migrator = database.createMigrator();

      await database.migration.onUpgrade(migrator, 18, 19);

      final rows = await awardRows();
      expect(rows, hasLength(1), reason: 'the existing award survives');
      expect(rows.single.id, 'a1');
    });

    test(
      'the step seeds nothing - an award is earned, never backfilled',
      () async {
        final migrator = database.createMigrator();
        await dropBadgeAwardsToPreV19();

        await database.migration.onUpgrade(migrator, 18, 19);

        expect(
          await awardRows(),
          isEmpty,
          reason:
              'dating awards to history logged before this version shipped '
              'would claim she was told something she never was',
        );
      },
    );
  });

  group('v20 schema (Challenges)', () {
    /// Shapes the fixture like a real v19 install: `challenges` does not
    /// exist at all, so the v20 step creates it for real.
    ///
    /// **Note what this file does NOT need for v20, and why.** Like v19's
    /// `badge_awards`, `challenges` carries no standalone index - and
    /// unlike it, it needs no table-level UNIQUE either, because the only
    /// uniqueness it wants is on its own primary key (a challenge id is
    /// derived from the bytes its shareable code carries, so "the same
    /// challenge" *is* "the same primary key" - see
    /// `core/db/tables/challenges.dart`). A bare `createTable` is emitted
    /// as `CREATE TABLE IF NOT EXISTS`, so the step is re-entrant on its
    /// own and no other fixture in this file had to change. The
    /// re-entrancy test below is what keeps that true.
    Future<void> dropChallengesToPreV20() async {
      await database.customStatement('DROP TABLE IF EXISTS challenges');
    }

    Future<List<ChallengeRow>> challengeRows() =>
        database.select(database.challenges).get();

    Future<void> insertChallenge({
      required String id,
      String kind = 'total_distance',
      String activityTypes = 'run',
      int targetUnits = 1000,
      String windowStart = '2026-09-01',
      String windowEnd = '2026-09-30',
      int salt = 12345,
      String selfDisplayName = 'Alex',
      String origin = 'created',
      int authorTag = 0x11223344,
      Value<String?> buddyDisplayName = const Value.absent(),
      Value<double?> buddyProgressPercent = const Value.absent(),
      Value<String?> buddyAsOf = const Value.absent(),
      int createdAt = 1000,
    }) {
      return database
          .into(database.challenges)
          .insert(
            ChallengesCompanion.insert(
              id: id,
              kind: kind,
              activityTypes: activityTypes,
              targetUnits: targetUnits,
              windowStart: windowStart,
              windowEnd: windowEnd,
              salt: salt,
              selfDisplayName: selfDisplayName,
              origin: origin,
              authorTag: authorTag,
              buddyDisplayName: buddyDisplayName,
              buddyProgressPercent: buddyProgressPercent,
              buddyAsOf: buddyAsOf,
              createdAt: createdAt,
            ),
          );
    }

    test(
      'a fresh database opens at schema v20 with challenges usable',
      () async {
        expect(await challengeRows(), isEmpty);
        expect(database.schemaVersion, 25);
      },
    );

    test('inserting and reading a Challenges row round-trips', () async {
      await insertChallenge(id: 'c1');
      final rows = await challengeRows();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'c1');
      expect(rows.single.kind, 'total_distance');
      expect(rows.single.activityTypes, 'run');
      expect(rows.single.targetUnits, 1000);
      expect(rows.single.windowStart, '2026-09-01');
      expect(rows.single.windowEnd, '2026-09-30');
      expect(rows.single.salt, 12345);
      expect(rows.single.selfDisplayName, 'Alex');
      expect(rows.single.origin, 'created');
      expect(rows.single.authorTag, 0x11223344);
      expect(rows.single.createdAt, 1000);
    });

    test('the buddy snapshot columns are nullable together', () async {
      await insertChallenge(id: 'c1');
      await insertChallenge(
        id: 'c2',
        buddyDisplayName: const Value('Sam'),
        buddyProgressPercent: const Value(87.5),
        buddyAsOf: const Value('2026-09-18'),
      );

      final rows = await challengeRows();
      final without = rows.firstWhere((r) => r.id == 'c1');
      final with_ = rows.firstWhere((r) => r.id == 'c2');
      expect(without.buddyDisplayName, isNull);
      expect(without.buddyProgressPercent, isNull);
      expect(without.buddyAsOf, isNull);
      expect(with_.buddyDisplayName, 'Sam');
      expect(with_.buddyProgressPercent, 87.5);
      expect(with_.buddyAsOf, '2026-09-18');
    });

    test('the primary key rejects the same challenge twice', () async {
      await insertChallenge(id: 'c1');
      await expectLater(
        insertChallenge(id: 'c1', selfDisplayName: 'Someone else'),
        throwsA(isA<Exception>()),
        reason:
            'a challenge id is derived from its code, so pasting the same '
            'code twice must collide - see core/db/tables/challenges.dart',
      );
    });

    test('an any-type challenge stores an empty type list', () async {
      await insertChallenge(id: 'c1', activityTypes: '');
      expect((await challengeRows()).single.activityTypes, '');
    });

    test('migrating from v19 creates challenges', () async {
      final migrator = database.createMigrator();
      await dropChallengesToPreV20();

      await database.migration.onUpgrade(migrator, 19, 20);

      expect(await challengeRows(), isEmpty);
      await insertChallenge(id: 'c1');
      expect(await challengeRows(), hasLength(1));
    });

    test('migrating from v1 creates challenges too', () async {
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);
      await dropChallengesToPreV20();

      await database.migration.onUpgrade(migrator, 1, 20);

      expect(await challengeRows(), isEmpty);
    });

    test('the step is re-entrant with the table already in place', () async {
      // No DROP of any kind before the replay - that is the point. The
      // step has no `createIndex`, so `CREATE TABLE IF NOT EXISTS` carries
      // it, and no data is disturbed.
      await insertChallenge(
        id: 'c1',
        buddyDisplayName: const Value('Sam'),
        buddyProgressPercent: const Value(87.5),
        buddyAsOf: const Value('2026-09-18'),
      );
      final migrator = database.createMigrator();

      await database.migration.onUpgrade(migrator, 19, 20);

      final rows = await challengeRows();
      expect(rows, hasLength(1), reason: 'the existing challenge survives');
      expect(rows.single.buddyDisplayName, 'Sam');
    });

    test(
      'the step seeds nothing - a challenge is agreed, never inferred',
      () async {
        final migrator = database.createMigrator();
        await dropChallengesToPreV20();

        await database.migration.onUpgrade(migrator, 19, 20);

        expect(
          await challengeRows(),
          isEmpty,
          reason:
              'no history logged before this version shipped can be read as '
              'a challenge two people agreed on',
        );
      },
    );
  });
  group('v21 schema (optional nutrients on foods + nutrition_entries)', () {
    // The thirteen columns v21 adds, in `NutritionFacts` order, as they are
    // spelled in SQLite. Both tables carry all of them.
    const nutrientColumns = <String>[
      'saturated_fat_grams',
      'trans_fat_grams',
      'monounsaturated_fat_grams',
      'polyunsaturated_fat_grams',
      'fiber_grams',
      'sugars_grams',
      'added_sugars_grams',
      'sodium_mg',
      'potassium_mg',
      'cholesterol_mg',
      'calcium_mg',
      'vitamin_d_mcg',
      'vitamin_c_mg',
    ];

    Future<Set<String>> columnsOf(String table) async {
      final rows = await database
          .customSelect('PRAGMA table_info($table)')
          .get();
      return rows.map((row) => row.read<String>('name')).toSet();
    }

    /// Inserts a `foods` row with raw SQL, so it works against the pre-v21
    /// fixture shape as well as the current one.
    Future<void> insertPreV21Food({String id = 'food-oats'}) {
      return database.customStatement(
        'INSERT INTO foods (id, name, brand, serving_description, '
        'serving_grams, calories_kcal, protein_grams, carbs_grams, '
        'fat_grams, iron_mg, barcode, source, created_at, updated_at) '
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 'custom', ?, ?)",
        [
          id,
          'Porridge oats',
          'Quaker',
          '1 cup (dry)',
          40.0,
          150.0,
          5.0,
          27.0,
          3.0,
          1.8,
          1000,
          1000,
        ],
      );
    }

    /// Same for `nutrition_entries`.
    Future<void> insertPreV21Entry({String id = 'entry-1'}) {
      return database.customStatement(
        'INSERT INTO nutrition_entries (id, day, meal, food_id, food_name, '
        'food_brand, serving_description, quantity_servings, '
        'quantity_amount, quantity_unit, serving_grams, calories_kcal, '
        'protein_grams, carbs_grams, fat_grams, iron_mg, created_at, '
        'updated_at) '
        "VALUES (?, ?, 'breakfast', 'food-oats', ?, NULL, ?, ?, ?, "
        "'serving', ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          '2026-09-03',
          'Porridge oats',
          '1 cup (dry)',
          2.0,
          2.0,
          40.0,
          150.0,
          5.0,
          27.0,
          3.0,
          1.8,
          1000,
          1000,
        ],
      );
    }

    test(
      'a fresh database opens at schema v21 with every nutrient column '
      'present on both tables',
      () async {
        expect(database.schemaVersion, 25);
        expect(await columnsOf('foods'), containsAll(nutrientColumns));
        expect(
          await columnsOf('nutrition_entries'),
          containsAll(nutrientColumns),
        );
      },
    );

    test(
      'a food row round-trips every optional nutrient, nulls included',
      () async {
        await database
            .into(database.foods)
            .insert(
              FoodsCompanion.insert(
                id: 'food-oats',
                name: 'Porridge oats',
                servingDescription: '1 cup (dry)',
                caloriesKcal: 150,
                proteinGrams: 5,
                carbsGrams: 27,
                fatGrams: 3,
                ironMg: const Value(1.8),
                saturatedFatGrams: const Value(0.6),
                fiberGrams: const Value(4.2),
                sodiumMg: const Value(11),
                vitaminDMcg: const Value(0.4),
                createdAt: 1000,
                updatedAt: 1000,
              ),
            );

        final row = (await database.select(database.foods).get()).single;
        expect(row.saturatedFatGrams, 0.6);
        expect(row.fiberGrams, 4.2);
        expect(row.sodiumMg, 11);
        expect(row.vitaminDMcg, 0.4);
        // Unstated stays unstated - never 0 (core/db/tables/foods.dart).
        expect(row.transFatGrams, isNull);
        expect(row.potassiumMg, isNull);
        expect(row.vitaminCMg, isNull);
      },
    );

    test('migrating from v20 adds all 26 columns', () async {
      final migrator = database.createMigrator();
      await reshapeFoodsToPreV21(database);
      await reshapeNutritionEntriesToPreV21(database);
      expect(
        await columnsOf('foods'),
        isNot(contains('fiber_grams')),
        reason: 'the fixture must start without them or it proves nothing',
      );
      expect(
        await columnsOf('nutrition_entries'),
        isNot(contains('fiber_grams')),
        reason: 'the fixture must start without them or it proves nothing',
      );

      await database.migration.onUpgrade(migrator, 20, 21);

      expect(await columnsOf('foods'), containsAll(nutrientColumns));
      expect(
        await columnsOf('nutrition_entries'),
        containsAll(nutrientColumns),
      );
    });

    test(
      'migrating from v20 preserves existing rows with null new columns',
      () async {
        final migrator = database.createMigrator();
        await reshapeFoodsToPreV21(database);
        await reshapeNutritionEntriesToPreV21(database);
        await insertPreV21Food();
        await insertPreV21Entry();

        await database.migration.onUpgrade(migrator, 20, 21);

        final food = (await database.select(database.foods).get()).single;
        expect(food.name, 'Porridge oats');
        expect(food.caloriesKcal, 150);
        expect(food.ironMg, 1.8, reason: 'the stated nutrient is intact');
        for (final value in <double?>[
          food.saturatedFatGrams,
          food.transFatGrams,
          food.monounsaturatedFatGrams,
          food.polyunsaturatedFatGrams,
          food.fiberGrams,
          food.sugarsGrams,
          food.addedSugarsGrams,
          food.sodiumMg,
          food.potassiumMg,
          food.cholesterolMg,
          food.calciumMg,
          food.vitaminDMcg,
          food.vitaminCMg,
        ]) {
          // Null, not 0: nobody recorded these, and 0 would be a claim about
          // the food (see the v21 paragraphs in core/db/app_database.dart).
          expect(value, isNull);
        }

        final entry =
            (await database
                    .select(
                      database.nutritionEntries,
                    )
                    .get())
                .single;
        expect(entry.foodName, 'Porridge oats');
        expect(entry.quantityServings, 2);
        expect(entry.ironMg, 1.8);
        expect(entry.fiberGrams, isNull);
        expect(entry.sodiumMg, isNull);
        expect(entry.vitaminCMg, isNull);
      },
    );

    test(
      'replaying the step is a no-op, not a duplicate-column error',
      () async {
        // The whole reason the adds go through a `PRAGMA table_info` guard:
        // `onUpgrade` ignores `to` and re-runs every matching branch, and
        // SQLite has no ADD COLUMN IF NOT EXISTS.
        final migrator = database.createMigrator();
        await reshapeFoodsToPreV21(database);
        await reshapeNutritionEntriesToPreV21(database);
        await insertPreV21Food();
        await insertPreV21Entry();

        await database.migration.onUpgrade(migrator, 20, 21);
        await database.migration.onUpgrade(migrator, 20, 21);
        await database.migration.onUpgrade(migrator, 20, 21);

        expect(await columnsOf('foods'), containsAll(nutrientColumns));
        expect(await database.select(database.foods).get(), hasLength(1));
        expect(
          await database.select(database.nutritionEntries).get(),
          hasLength(1),
        );
      },
    );

    test(
      'replaying against an untouched current-shape database is a no-op',
      () async {
        // No DROP and no reshape at all - `forTesting`'s `onCreate` already
        // built both tables at their v21 shape. This is the case that let
        // all nineteen pre-existing `onUpgrade` call sites at `from >= 11`
        // stay exactly as they were when v21 landed.
        await insertPreV21Food();
        final migrator = database.createMigrator();

        await database.migration.onUpgrade(migrator, 20, 21);

        expect(await columnsOf('foods'), containsAll(nutrientColumns));
        expect(
          (await database.select(database.foods).get()).single.id,
          'food-oats',
        );
      },
    );

    test('migrating from v1 creates the columns with the tables', () async {
      // Below v11 the guard skips the step entirely: `createTable` builds
      // both tables at their current shape, columns included.
      // No challenges/badge_awards drop is needed: both steps are a bare
      // `createTable` (emitted as CREATE TABLE IF NOT EXISTS) with no index.
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);

      await database.migration.onUpgrade(migrator, 1, 21);

      expect(await columnsOf('foods'), containsAll(nutrientColumns));
      expect(
        await columnsOf('nutrition_entries'),
        containsAll(nutrientColumns),
      );
    });

    test('the step seeds nothing and backfills nothing', () async {
      final migrator = database.createMigrator();
      await reshapeFoodsToPreV21(database);
      await reshapeNutritionEntriesToPreV21(database);

      await database.migration.onUpgrade(migrator, 20, 21);

      expect(await database.select(database.foods).get(), isEmpty);
      expect(await database.select(database.nutritionEntries).get(), isEmpty);
    });
  });
  group('v22 schema (DailyStepTotals)', () {
    /// Shapes the fixture like a real v21 install: `daily_step_totals` does
    /// not exist at all, so the v22 step creates it for real.
    ///
    /// **Note what this file did NOT need for v22, and why.** Like v19's
    /// `badge_awards` and v20's `challenges`, this table has no standalone
    /// index - its one-row-per-day uniqueness is its own
    /// `PRIMARY KEY (day)`, emitted inside the `CREATE TABLE` statement that
    /// `createTable` guards with `IF NOT EXISTS`. So the step is re-entrant
    /// on its own and **zero** of this file's pre-existing `onUpgrade` call
    /// sites had to change; a `createIndex` would have obliged every one of
    /// them to drop the table first
    /// (`knowledge/troubleshooting/database_migrations.md`). The re-entrancy
    /// test below is what keeps that true.
    Future<void> dropDailyStepTotalsToPreV22() async {
      await database.customStatement('DROP TABLE IF EXISTS daily_step_totals');
    }

    Future<List<DailyStepTotal>> stepRows() =>
        database.select(database.dailyStepTotals).get();

    Future<void> insertStepTotal({
      String day = '2026-09-01',
      int steps = 8123,
      Value<String?> source = const Value('Health Connect'),
      int syncedAt = 1000,
    }) {
      return database
          .into(database.dailyStepTotals)
          .insert(
            DailyStepTotalsCompanion.insert(
              day: day,
              steps: steps,
              source: source,
              syncedAt: syncedAt,
            ),
          );
    }

    test(
      'a fresh database opens at the current schema with daily_step_totals '
      'usable',
      () async {
        expect(await stepRows(), isEmpty);
        expect(database.schemaVersion, 25);
      },
    );

    test('inserting and reading a DailyStepTotals row round-trips', () async {
      await insertStepTotal(syncedAt: 1735689600000);
      final rows = await stepRows();
      expect(rows, hasLength(1));
      expect(rows.single.day, '2026-09-01');
      expect(rows.single.steps, 8123);
      expect(rows.single.source, 'Health Connect');
      expect(rows.single.syncedAt, 1735689600000);
    });

    test('source is nullable - an unnamed source stays unnamed', () async {
      await insertStepTotal(source: const Value(null));
      expect((await stepRows()).single.source, isNull);
    });

    test('the primary key rejects the same day twice', () async {
      await insertStepTotal();
      await expectLater(
        insertStepTotal(steps: 9999),
        throwsA(isA<Exception>()),
        reason:
            'two readings of one day are two readings of the same accruing '
            'number - the repository upserts, it never accumulates rows '
            '(see core/db/tables/daily_step_totals.dart)',
      );
    });

    test('zero steps is a storable value, distinct from no row', () async {
      // A day she did not carry her phone is a real zero; a day never
      // synced simply has no row. The table must be able to say both.
      await insertStepTotal(steps: 0);
      expect((await stepRows()).single.steps, 0);
    });

    test('migrating from v21 creates daily_step_totals', () async {
      final migrator = database.createMigrator();
      await dropDailyStepTotalsToPreV22();

      await database.migration.onUpgrade(migrator, 21, 22);

      expect(await stepRows(), isEmpty);
      await insertStepTotal();
      expect(await stepRows(), hasLength(1));
    });

    test('migrating from v1 creates daily_step_totals too', () async {
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);
      await dropDailyStepTotalsToPreV22();

      await database.migration.onUpgrade(migrator, 1, 22);

      expect(await stepRows(), isEmpty);
    });

    test('the step is re-entrant with the table already in place', () async {
      // No DROP of any kind before the replay - that is the point. The step
      // has no `createIndex`, so `CREATE TABLE IF NOT EXISTS` carries it,
      // and no data is disturbed.
      await insertStepTotal();
      final migrator = database.createMigrator();

      await database.migration.onUpgrade(migrator, 21, 22);
      await database.migration.onUpgrade(migrator, 21, 22);

      final rows = await stepRows();
      expect(rows, hasLength(1), reason: 'the existing day survives');
      expect(rows.single.day, '2026-09-01');
      expect(rows.single.steps, 8123);
    });

    test('the step leaves rows in other tables untouched', () async {
      // v22 adds a table and nothing else; a v21 install's data must come
      // through the upgrade unchanged.
      await database
          .into(database.weightLogs)
          .insert(
            WeightLogsCompanion.insert(
              id: 'w1',
              day: '2026-09-01',
              weightKg: 63.2,
              createdAt: 1000,
              updatedAt: 1000,
            ),
          );
      await database
          .into(database.badgeAwards)
          .insert(
            BadgeAwardsCompanion.insert(
              id: 'a1',
              badgeId: 'run_distance',
              tierKey: 'bronze',
              awardedAt: 1000,
            ),
          );
      final migrator = database.createMigrator();
      await dropDailyStepTotalsToPreV22();

      await database.migration.onUpgrade(migrator, 21, 22);

      expect(
        (await database.select(database.weightLogs).get()).single.id,
        'w1',
      );
      expect(
        (await database.select(database.badgeAwards).get()).single.id,
        'a1',
      );
    });

    test('the step seeds nothing - no past day has a step count', () async {
      final migrator = database.createMigrator();
      await dropDailyStepTotalsToPreV22();

      await database.migration.onUpgrade(migrator, 21, 22);

      expect(
        await stepRows(),
        isEmpty,
        reason:
            'nothing in this app held a past day step count, so any row '
            'this step invented would be a number nobody measured',
      );
    });
  });
  group('v23 schema (YogaSequences)', () {
    /// Shapes the fixture like a real v22 install: `yoga_sequences` does not
    /// exist at all, so the v23 step creates it for real.
    ///
    /// **Note what this file did NOT need for v23.** Like v19's
    /// `badge_awards`, v20's `challenges` and v22's `daily_step_totals`, this
    /// table has no standalone index - its identity is its own
    /// `PRIMARY KEY (id)`, emitted inside the `CREATE TABLE` statement that
    /// `createTable` guards with `IF NOT EXISTS`. So the step is re-entrant
    /// on its own and **zero** of this file's pre-existing `onUpgrade` call
    /// sites had to change; only the mechanical `schemaVersion` assertions
    /// moved. A `createIndex` would have obliged every call site to drop the
    /// table first (`knowledge/troubleshooting/database_migrations.md`).
    Future<void> dropYogaSequencesToPreV23() async {
      await database.customStatement('DROP TABLE IF EXISTS yoga_sequences');
    }

    Future<List<YogaSequence>> yogaRows() =>
        database.select(database.yogaSequences).get();

    Future<void> insertSequence({
      String id = 'seq-1',
      String name = 'Morning flow',
      String posesJson =
          '[{"name":"Mountain","holdSeconds":30,'
          '"side":"none","cue":""}]',
      Value<String?> style = const Value('Vinyasa'),
      int createdAt = 1000,
      int updatedAt = 1000,
    }) {
      return database
          .into(database.yogaSequences)
          .insert(
            YogaSequencesCompanion.insert(
              id: id,
              name: name,
              posesJson: posesJson,
              style: style,
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          );
    }

    test('a fresh database opens at schema v23 with yoga_sequences '
        'usable', () async {
      expect(await yogaRows(), isEmpty);
      expect(database.schemaVersion, 25);
    });

    test('inserting and reading a YogaSequences row round-trips', () async {
      await insertSequence(createdAt: 1735689600000, updatedAt: 1735689600001);
      final rows = await yogaRows();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'seq-1');
      expect(rows.single.name, 'Morning flow');
      expect(rows.single.style, 'Vinyasa');
      expect(rows.single.createdAt, 1735689600000);
      expect(rows.single.updatedAt, 1735689600001);
    });

    test('description and transition_seconds carry their defaults', () async {
      await insertSequence();
      final row = (await yogaRows()).single;
      expect(row.description, '');
      expect(
        row.transitionSeconds,
        5,
        reason:
            'the default gap between poses (see '
            'core/db/tables/yoga_sequences.dart)',
      );
    });

    test('style is nullable - a sequence with no style stays unset', () async {
      await insertSequence(style: const Value(null));
      expect((await yogaRows()).single.style, isNull);
    });

    test('deleted_at starts null - a saved sequence is live', () async {
      await insertSequence();
      expect((await yogaRows()).single.deletedAt, isNull);
    });

    test('the primary key rejects the same id twice', () async {
      await insertSequence();
      await expectLater(
        insertSequence(name: 'Different name'),
        throwsA(isA<Exception>()),
      );
    });

    test('migrating from v22 creates yoga_sequences', () async {
      final migrator = database.createMigrator();
      await dropYogaSequencesToPreV23();

      await database.migration.onUpgrade(migrator, 22, 23);

      expect(await yogaRows(), isEmpty);
      await insertSequence();
      expect(await yogaRows(), hasLength(1));
    });

    test('migrating from v1 creates yoga_sequences too', () async {
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);
      await dropYogaSequencesToPreV23();

      await database.migration.onUpgrade(migrator, 1, 23);

      expect(await yogaRows(), isEmpty);
    });

    test('the step is re-entrant with the table already in place', () async {
      // No DROP of any kind before the replay - that is the point. The step
      // has no `createIndex`, so `CREATE TABLE IF NOT EXISTS` carries it,
      // and no data is disturbed.
      await insertSequence();
      final migrator = database.createMigrator();

      await database.migration.onUpgrade(migrator, 22, 23);
      await database.migration.onUpgrade(migrator, 22, 23);

      final rows = await yogaRows();
      expect(rows, hasLength(1), reason: 'the existing sequence survives');
      expect(rows.single.id, 'seq-1');
      expect(rows.single.name, 'Morning flow');
    });

    test('the step leaves rows in other tables untouched', () async {
      await database
          .into(database.dailyStepTotals)
          .insert(
            DailyStepTotalsCompanion.insert(
              day: '2026-09-01',
              steps: 8123,
              syncedAt: 1000,
            ),
          );
      final migrator = database.createMigrator();
      await dropYogaSequencesToPreV23();

      await database.migration.onUpgrade(migrator, 22, 23);

      expect(
        (await database.select(database.dailyStepTotals).get()).single.day,
        '2026-09-01',
      );
    });

    test('the step seeds nothing - the starters are not rows', () async {
      final migrator = database.createMigrator();
      await dropYogaSequencesToPreV23();

      await database.migration.onUpgrade(migrator, 22, 23);

      expect(
        await yogaRows(),
        isEmpty,
        reason:
            'YogaSequenceStarters is a domain constant, never persisted - an '
            'empty table honestly means she has saved nothing, and accepting '
            'a starter writes her own copy under a fresh id',
      );
    });
  });

  group('v23 -> v24 migration (WellbeingEvents)', () {
    Future<void> dropWellbeingEventsToPreV24() async {
      await database.customStatement('DROP TABLE IF EXISTS wellbeing_events');
    }

    Future<List<WellbeingEvent>> eventRows() =>
        database.select(database.wellbeingEvents).get();

    Future<void> insertEvent({
      String id = 'event-1',
      String day = '2026-09-01',
      String type = 'intimacy',
      String title = 'Intimacy',
      bool isCustomSaved = false,
      String? notes,
      int createdAt = 1000,
      int updatedAt = 1000,
      int? deletedAt,
    }) {
      return database
          .into(database.wellbeingEvents)
          .insert(
            WellbeingEventsCompanion.insert(
              id: id,
              day: day,
              type: type,
              title: title,
              isCustomSaved: Value(isCustomSaved),
              notes: Value(notes),
              createdAt: createdAt,
              updatedAt: updatedAt,
              deletedAt: Value(deletedAt),
            ),
          );
    }

    test(
      'a fresh database opens at schema v24 with wellbeing_events usable',
      () async {
        expect(await eventRows(), isEmpty);
        expect(database.schemaVersion, 25);
      },
    );

    test('inserting and reading a WellbeingEvents row round-trips', () async {
      await insertEvent();
      final rows = await eventRows();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.id, 'event-1');
      expect(row.day, '2026-09-01');
      expect(row.type, 'intimacy');
      expect(row.title, 'Intimacy');
      expect(row.isCustomSaved, isFalse);
      expect(row.notes, isNull);
      expect(row.createdAt, 1000);
      expect(row.updatedAt, 1000);
      expect(row.deletedAt, isNull);
    });

    test('deleted_at starts null - a saved event is live', () async {
      await insertEvent();
      expect((await eventRows()).single.deletedAt, isNull);
    });

    test('the primary key rejects the same id twice', () async {
      await insertEvent();
      await expectLater(
        insertEvent(title: 'Different title'),
        throwsA(isA<Exception>()),
      );
    });

    test('migrating from v23 creates wellbeing_events', () async {
      final migrator = database.createMigrator();
      await dropWellbeingEventsToPreV24();

      await database.migration.onUpgrade(migrator, 23, 24);

      expect(await eventRows(), isEmpty);
      await insertEvent();
      expect(await eventRows(), hasLength(1));
    });

    test('migrating from v1 creates wellbeing_events too', () async {
      final migrator = database.createMigrator();
      await dropAllTablesToPreV2(database);
      await dropWellbeingEventsToPreV24();

      await database.migration.onUpgrade(migrator, 1, 24);

      expect(await eventRows(), isEmpty);
    });

    test('the step is re-entrant with the table already in place', () async {
      await insertEvent();
      final migrator = database.createMigrator();

      await database.migration.onUpgrade(migrator, 23, 24);
      await database.migration.onUpgrade(migrator, 23, 24);

      final rows = await eventRows();
      expect(rows, hasLength(1), reason: 'the existing event survives');
      expect(rows.single.id, 'event-1');
      expect(rows.single.title, 'Intimacy');
    });

    test('the step leaves rows in other tables untouched', () async {
      await database
          .into(database.dailyStepTotals)
          .insert(
            DailyStepTotalsCompanion.insert(
              day: '2026-09-01',
              steps: 8123,
              syncedAt: 1000,
            ),
          );
      final migrator = database.createMigrator();
      await dropWellbeingEventsToPreV24();

      await database.migration.onUpgrade(migrator, 23, 24);

      expect(
        (await database.select(database.dailyStepTotals).get()).single.day,
        '2026-09-01',
      );
    });
  });

  group(
    'v24 -> v25 migration (serving_volume_ml in foods and nutrition_entries)',
    () {
      Future<Set<String>> columnsOf(String table) async {
        final rows = await database
            .customSelect('PRAGMA table_info($table)')
            .get();
        return rows.map((row) => row.read<String>('name')).toSet();
      }

      Future<void> insertPreV25Food({String id = 'food-milk'}) {
        return database.customStatement(
          'INSERT INTO foods (id, name, brand, serving_description, '
          'serving_grams, calories_kcal, protein_grams, carbs_grams, '
          'fat_grams, iron_mg, barcode, source, created_at, updated_at) '
          "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 'custom', ?, ?)",
          [
            id,
            'Whole Milk',
            'Dairy Farmers',
            '1 glass',
            250.0,
            150.0,
            8.0,
            12.0,
            8.0,
            0.1,
            1000,
            1000,
          ],
        );
      }

      Future<void> insertPreV25Entry({String id = 'entry-milk'}) {
        return database.customStatement(
          'INSERT INTO nutrition_entries (id, day, meal, food_id, food_name, '
          'food_brand, serving_description, quantity_servings, '
          'quantity_amount, quantity_unit, serving_grams, calories_kcal, '
          'protein_grams, carbs_grams, fat_grams, iron_mg, created_at, '
          'updated_at) '
          "VALUES (?, ?, 'breakfast', NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "
          '?, ?, ?)',
          [
            id,
            '2026-09-01',
            'Whole Milk',
            'Dairy Farmers',
            '1 glass',
            1.0,
            1.0,
            'serving',
            250.0,
            150.0,
            8.0,
            12.0,
            8.0,
            0.1,
            1000,
            1000,
          ],
        );
      }

      test(
        'migrating from v24 adds serving_volume_ml to foods and '
        'nutrition_entries',
        () async {
          final migrator = database.createMigrator();
          await reshapeFoodsToPreV25(database);
          await reshapeNutritionEntriesToPreV25(database);

          expect(
            await columnsOf('foods'),
            isNot(contains('serving_volume_ml')),
          );
          expect(
            await columnsOf('nutrition_entries'),
            isNot(contains('serving_volume_ml')),
          );

          await database.migration.onUpgrade(migrator, 24, 25);

          expect(await columnsOf('foods'), contains('serving_volume_ml'));
          expect(
            await columnsOf('nutrition_entries'),
            contains('serving_volume_ml'),
          );
        },
      );

      test(
        'migrating from v24 preserves existing rows with null '
        'serving_volume_ml',
        () async {
          final migrator = database.createMigrator();
          await reshapeFoodsToPreV25(database);
          await reshapeNutritionEntriesToPreV25(database);
          await insertPreV25Food();
          await insertPreV25Entry();

          await database.migration.onUpgrade(migrator, 24, 25);

          final food = (await database.select(database.foods).get()).single;
          expect(food.name, 'Whole Milk');
          expect(food.servingGrams, 250.0);
          expect(food.servingVolumeMl, isNull);

          final entry =
              (await database.select(database.nutritionEntries).get()).single;
          expect(entry.foodName, 'Whole Milk');
          expect(entry.servingGrams, 250.0);
          expect(entry.servingVolumeMl, isNull);
        },
      );

      test(
        'replaying the step is a no-op, not a duplicate-column error',
        () async {
          final migrator = database.createMigrator();
          await reshapeFoodsToPreV25(database);
          await reshapeNutritionEntriesToPreV25(database);
          await insertPreV25Food();
          await insertPreV25Entry();

          await database.migration.onUpgrade(migrator, 24, 25);
          await database.migration.onUpgrade(migrator, 24, 25);
          await database.migration.onUpgrade(migrator, 24, 25);

          expect(await columnsOf('foods'), contains('serving_volume_ml'));
          expect(
            await columnsOf('nutrition_entries'),
            contains('serving_volume_ml'),
          );
          expect(await database.select(database.foods).get(), hasLength(1));
          expect(
            await database.select(database.nutritionEntries).get(),
            hasLength(1),
          );
        },
      );

      test(
        'replaying against an untouched current-shape database is a no-op',
        () async {
          await insertPreV25Food();
          final migrator = database.createMigrator();

          await database.migration.onUpgrade(migrator, 24, 25);

          expect(await columnsOf('foods'), contains('serving_volume_ml'));
          expect(
            (await database.select(database.foods).get()).single.id,
            'food-milk',
          );
        },
      );

      test('migrating from v1 creates the columns with the tables', () async {
        final migrator = database.createMigrator();
        await dropAllTablesToPreV2(database);

        await database.migration.onUpgrade(migrator, 1, 25);

        expect(await columnsOf('foods'), contains('serving_volume_ml'));
        expect(
          await columnsOf('nutrition_entries'),
          contains('serving_volume_ml'),
        );
      });

      test('the step seeds nothing and backfills nothing', () async {
        final migrator = database.createMigrator();
        await reshapeFoodsToPreV25(database);
        await reshapeNutritionEntriesToPreV25(database);

        await database.migration.onUpgrade(migrator, 24, 25);

        expect(await database.select(database.foods).get(), isEmpty);
        expect(await database.select(database.nutritionEntries).get(), isEmpty);
      });
    },
  );
}
