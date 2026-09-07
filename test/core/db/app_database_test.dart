import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('schema version is 1 (fresh app, no migration chain)', () {
    expect(db.schemaVersion, 1);
  });

  test('onCreate creates every table the app uses', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    const expected = {
      'user_profiles',
      'activities',
      'activity_samples',
      'daily_checkins',
      'flare_events',
      'recovery_days',
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
      'wellbeing_events',
    };
    expect(
      names.containsAll(expected),
      isTrue,
      reason: 'missing: ${expected.difference(names)}',
    );
    expect(names.contains('cycle_records'), isFalse);
  });

  test('a profile round-trips through the fresh schema', () async {
    final nowMillis = DateTime.utc(2026).millisecondsSinceEpoch;
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: 'u1',
            displayName: 'Test',
            unitSystem: 'metric',
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
        );
    final row = await db.select(db.userProfiles).getSingle();
    expect(row.displayName, 'Test');
  });
}
