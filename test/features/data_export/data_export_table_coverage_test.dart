import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/data_export/domain/data_export_tables.dart';

/// Every table in `AppDatabase` has to have had its sensitivity decided:
/// either it goes into a whole-app export by default, or it is one of the
/// S3-tier tables in `sensitiveHealthTables` that only go in when the user
/// ticks the box.
///
/// **The list below is the enforcement mechanism, not test data.** The
/// exporter iterates `db.allTables` generically, so a table added tomorrow is
/// exported the day it exists — which is the right default, and exactly why
/// nobody would otherwise be forced to *think* about it. This test is where
/// the thinking is forced: a new table with no entry here fails by name, and
/// whoever adds it has to choose a side. Same shape, and the same reasoning,
/// as `test/features/settings/delete_my_data_covers_every_table_test.dart`,
/// which is the deletion half of security_and_privacy.md rule 7.
void main() {
  /// Tables that go into every export. Reviewed as S0-S2 (activities and
  /// routes are location data, nutrition/weight/steps are body and health
  /// data, the rest is profile and self-authored training content) — all of
  /// it the user's, and none of it in the health check-in tier that makes a
  /// file dangerous to hand to someone else.
  const exportedByDefault = <String>{
    'user_profiles',
    'activities',
    'activity_samples',
    'routes',
    'foods',
    'nutrition_entries',
    'nutrition_goals',
    'water_logs',
    'strength_routines',
    'strength_cycles',
    'weight_logs',
    'badge_awards',
    'challenges',
    'daily_step_totals',
    'yoga_sequences',
  };

  test('every table is either exported by default or an S3 opt-in', () {
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    // sqlite_sequence and friends are SQLite internals, not user data. In
    // practice `allTables` only lists the declared tables, but the filter
    // costs nothing and documents the exclusion.
    final allTables = database.allTables
        .map((t) => t.actualTableName)
        .where((name) => !name.startsWith('sqlite_'))
        .toSet();

    final classified = exportedByDefault.union(sensitiveHealthTables);

    final unclassified = allTables.difference(classified);
    expect(
      unclassified,
      isEmpty,
      reason:
          'These tables exist in AppDatabase but nobody has decided whether '
          'they belong in a data export: $unclassified. The exporter will '
          'include them by default. Decide: if the table holds check-in, '
          'flare or recovery data (S3 in '
          'knowledge/engineering/security_and_privacy.md), add it to '
          "sensitiveHealthTables in the feature's "
          'domain/data_export_tables.dart so it is only exported on opt-in; '
          "otherwise add it to this test's exportedByDefault list to record "
          'that the decision was made.',
    );

    final stale = classified.difference(allTables);
    expect(
      stale,
      isEmpty,
      reason:
          'These table names are classified here but no longer exist in '
          'AppDatabase: $stale. Remove them, so this guard keeps counting '
          'the tables that are actually there.',
    );
  });

  test('the two groups do not overlap', () {
    expect(exportedByDefault.intersection(sensitiveHealthTables), isEmpty);
  });

  test('the S3 opt-in set matches the first deleted health tables', () {
    // Pinned rather than derived: `DeleteMyDataService.run()` deletes
    // wellbeing (check-ins, flares, events) and recovery days first as the most
    // sensitive tier, and export must draw its opt-in line in the same
    // place. If one of these moves, both flows should move together.
    expect(sensitiveHealthTables, {
      'daily_checkins',
      'flare_events',
      'recovery_days',
      'wellbeing_events',
      'ketone_readings',
      'blood_pressure_readings',
      'blood_marker_readings',
    });
  });
}
