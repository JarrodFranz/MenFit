import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:menfit_app/core/db/tables/activities.dart';
import 'package:menfit_app/core/db/tables/activity_samples.dart';
import 'package:menfit_app/core/db/tables/badge_awards.dart';
import 'package:menfit_app/core/db/tables/challenges.dart';
import 'package:menfit_app/core/db/tables/daily_checkins.dart';
import 'package:menfit_app/core/db/tables/daily_step_totals.dart';
import 'package:menfit_app/core/db/tables/flare_events.dart';
import 'package:menfit_app/core/db/tables/foods.dart';
import 'package:menfit_app/core/db/tables/nutrition_entries.dart';
import 'package:menfit_app/core/db/tables/nutrition_goals.dart';
import 'package:menfit_app/core/db/tables/recovery_days.dart';
import 'package:menfit_app/core/db/tables/routes.dart';
import 'package:menfit_app/core/db/tables/strength_tables.dart';
import 'package:menfit_app/core/db/tables/user_profiles.dart';
import 'package:menfit_app/core/db/tables/water_logs.dart';
import 'package:menfit_app/core/db/tables/weight_logs.dart';
import 'package:menfit_app/core/db/tables/wellbeing_events.dart';
import 'package:menfit_app/core/db/tables/yoga_sequences.dart';

part 'app_database.g.dart';

/// The single Drift database for the app (ADR 003).
///
/// All tables live centrally under `core/db/tables/`; DAOs live with their
/// owning feature's `data/` layer. Bump [schemaVersion] and add a migration
/// step whenever a table changes shape — never edit an already-shipped
/// version's baseline in place.
@DriftDatabase(
  tables: [
    UserProfiles,
    Activities,
    ActivitySamples,
    DailyCheckins,
    FlareEvents,
    RecoveryDays,
    Routes,
    Foods,
    NutritionEntries,
    NutritionGoals,
    WaterLogs,
    StrengthRoutines,
    StrengthCycles,
    WeightLogs,
    BadgeAwards,
    Challenges,
    DailyStepTotals,
    YogaSequences,
    WellbeingEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the real, platform-appropriate database (native SQLite file, or
  /// sqlite3-WASM/OPFS on web).
  AppDatabase() : super(_openConnection());

  /// Opens against a caller-provided [executor] — use
  /// `NativeDatabase.memory()` in tests for a real in-memory SQLite
  /// database with no mocks.
  // ignore: use_super_parameters (generated base ctor's param is named `e`)
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  /// MenFit forked from FemFit with no installed base, so the schema starts
  /// again at v1 with a clean `createAll`. Future changes: bump
  /// [schemaVersion], add an `onUpgrade` branch, and never edit this
  /// baseline in place (`knowledge/troubleshooting/database_migrations.md`).
  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'menfit',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
