import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/streaks/domain/streak_assembly.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';

/// The seam between the multi-day flare storage/expansion added in schema v9
/// and the streak engine: `watchProtectingFlareDays` expands a stored range
/// into individual days, so `assembleStreakResult` — which consumes a flat
/// day set — needs no change at all to honour a multi-day flare. These tests
/// exist to hold that seam in place: if the expansion ever regressed to
/// emitting only a flare's first day, a multi-day flare would stop bridging a
/// streak and these would fail.
void main() {
  late db.AppDatabase database;
  late DriftWellbeingRepository wellbeing;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    wellbeing = DriftWellbeingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  final today = LocalDate(2026, 8, 26);

  Activity runOn(LocalDate day, {required String id}) {
    return Activity(
      id: id,
      activityType: ActivityType.run,
      title: 'Run',
      // Local noon, so `.toLocal()` in the assembler can't shift the day.
      startedAt: DateTime(day.year, day.month, day.day, 12).toUtc(),
      movingTime: const Duration(minutes: 30),
      elapsedTime: const Duration(minutes: 30),
      distanceMeters: 5000,
      source: ActivitySource.manual,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  Future<void> saveFlare({
    required String id,
    required LocalDate day,
    LocalDate? endDay,
    FlareImpact impact = FlareImpact.unableToTrain,
  }) {
    return wellbeing.saveFlare(
      FlareEvent(
        id: id,
        day: day,
        endDay: endDay,
        severity: FlareSeverity.severe,
        impact: impact,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
  }

  Future<StreakResult> assemble(List<Activity> activities) async {
    return assembleStreakResult(
      activities: activities,
      recoveryDays: const {},
      flareProtectedDays: await wellbeing.watchProtectingFlareDays().first,
      today: today,
    );
  }

  test(
    'a multi-day unable-to-train flare protects the streak across its whole '
    'range, bridging activities either side of it',
    () async {
      // Ran on the 20th and again on the 26th; the 21st-25th are covered by
      // one five-day flare.
      await saveFlare(
        id: 'flare',
        day: LocalDate(2026, 8, 21),
        endDay: LocalDate(2026, 8, 25),
      );

      final result = await assemble([
        runOn(LocalDate(2026, 8, 20), id: 'a1'),
        runOn(today, id: 'a2'),
      ]);

      // Protected days bridge a streak without themselves counting (see
      // `computeStreaks` rule 3), so the run is the two activity days -
      // the point is that the walk backwards from today never *broke*
      // across the 21st-25th.
      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
      expect(result.todaySatisfied, isTrue);
    },
  );

  test(
    'the same gap with a single-day flare instead breaks the streak - the '
    'range is doing the work, not the flare merely existing',
    () async {
      await saveFlare(id: 'flare', day: LocalDate(2026, 8, 21));

      final result = await assemble([
        runOn(LocalDate(2026, 8, 20), id: 'a1'),
        runOn(today, id: 'a2'),
      ]);

      expect(
        result.currentStreak,
        1,
        reason: 'the walk breaks at the 25th - only today survives',
      );
      expect(result.longestStreak, 1);
    },
  );

  test(
    'a multi-day flare with impact "none" protects nothing, so the same gap '
    'still breaks the streak',
    () async {
      await saveFlare(
        id: 'flare',
        day: LocalDate(2026, 8, 21),
        endDay: LocalDate(2026, 8, 25),
        impact: FlareImpact.none,
      );

      final result = await assemble([
        runOn(LocalDate(2026, 8, 20), id: 'a1'),
        runOn(today, id: 'a2'),
      ]);

      expect(result.currentStreak, 1);
    },
  );

  test(
    'a flare range running up to today leaves today protected rather than '
    'pending-and-unsatisfied',
    () async {
      await saveFlare(
        id: 'flare',
        day: LocalDate(2026, 8, 24),
        endDay: today,
      );

      final result = await assemble([runOn(LocalDate(2026, 8, 23), id: 'a1')]);

      expect(result.todayStatus, DayStatus.protectedRecovery);
      expect(result.todaySatisfied, isFalse);
      expect(
        result.currentStreak,
        1,
        reason: 'the 23rd still counts - the 24th-26th bridge, not break',
      );
    },
  );
}
