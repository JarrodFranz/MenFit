import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
// `show AppDatabase`: the generated Drift row classes include their own
// `Activity` and `CycleRecord`, which would collide with the domain
// entities this test builds fixtures from.
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Two logged periods, so June 1–28 is one **completed** cycle.
final List<CycleRecord> _records = [
  CycleRecord(
    id: 'cycle-a',
    periodStart: LocalDate(2026, 6, 1),
    periodEnd: LocalDate(2026, 6, 5),
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6),
  ),
  CycleRecord(
    id: 'cycle-b',
    periodStart: LocalDate(2026, 6, 29),
    createdAt: DateTime.utc(2026, 6, 29),
    updatedAt: DateTime.utc(2026, 6, 29),
  ),
];

Activity _lift({required String id, required LocalDate day}) => Activity(
  id: id,
  activityType: ActivityType.strength,
  title: 'Squat session',
  startedAt: DateTime(day.year, day.month, day.day, 12).toUtc(),
  movingTime: const Duration(minutes: 45),
  elapsedTime: const Duration(minutes: 45),
  distanceMeters: 0,
  source: ActivitySource.manual,
  createdAt: DateTime.utc(day.year, day.month, day.day),
  updatedAt: DateTime.utc(day.year, day.month, day.day),
  workoutDetails: const StrengthWorkoutDetails(
    exercises: [
      StrengthExercise(
        name: 'Barbell Squat',
        sets: [StrengthSet(setNumber: 1, reps: 5, weightKg: 70)],
      ),
    ],
  ),
);

/// End-to-end guard for review finding C1 and its fix (retrospective
/// phasing): a PR set inside a **completed logged cycle** must carry a
/// real estimated phase on the recap — this exact fixture used to reach
/// the recap as `CyclePhase.none` and render "None phase" on the story
/// slide and the exported share card. The engine now retro-phases days
/// between two logged period starts, so 20 June (9 days before the
/// logged 29 June start) resolves to `luteal`.
///
/// The counter-case stays load-bearing: a day the engine genuinely
/// cannot anchor — before the first logged cycle — must still surface as
/// an ABSENT phase (`null`), never as a rendered "None".
void main() {
  /// Pumps the `FakeAsync` clock a few times — every read in
  /// `recapForPeriod` is a one-shot `get`, so this is enough to resolve
  /// them (see `recap_providers_fake_async_test.dart` for why a `.first`
  /// snapshot would not).
  Future<void> pumpAFew(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Future<ProviderContainer> seededContainer(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
      await tester.pump(const Duration(milliseconds: 1));
    });
    await container.read(cycleRepositoryProvider).saveRecords(_records);
    return container;
  }

  testWidgets('a PR inside a completed cycle carries its retrospective '
      'phase on the recap', (tester) async {
    final container = await seededContainer(tester);
    await container
        .read(activityRepositoryProvider)
        .saveActivity(_lift(id: 'lift-1', day: LocalDate(2026, 6, 20)));

    // Guard the premise of the FIX: the engine now retro-phases the day
    // (14 luteal days anchored back from the logged 29 June start).
    expect(
      CyclePredictionEngine()
          .getDayStatus(
            date: LocalDate(2026, 6, 20),
            records: _records,
            today: LocalDate.today(),
          )
          .phase,
      CyclePhase.luteal,
    );

    final period = completedCyclePeriods(_records).single;
    final subscription = container.listen(
      recapForPeriodProvider(period),
      (previous, next) {},
    );

    await pumpAFew(tester);

    final recap = (subscription.read() as AsyncData<CycleRecap?>).value;
    expect(recap, isNotNull);
    final pr = recap!.topPrs.single;
    expect(pr.phase, CyclePhase.luteal);
    expect(pr.displayPhase, CyclePhase.luteal);
  });

  testWidgets('a day the engine cannot anchor still reaches the recap as '
      'an absent phase, never a rendered "none"', (tester) async {
    // A month period BEFORE the first logged cycle: 20 May has no logged
    // or completed cycle on either side, so the engine resolves it to
    // `CyclePhase.none` — and the provider must leave the day out of the
    // phase map entirely, so the PR's phase is null (absent), which is
    // what keeps "None phase" off the story slide and the share card.
    final container = await seededContainer(tester);
    final may20 = LocalDate(2026, 5, 20);
    for (var i = 0; i < 3; i++) {
      await container
          .read(activityRepositoryProvider)
          .saveActivity(_lift(id: 'may-$i', day: may20.addDays(i)));
    }
    expect(
      CyclePredictionEngine()
          .getDayStatus(
            date: may20,
            records: _records,
            today: LocalDate.today(),
          )
          .phase,
      CyclePhase.none,
    );

    final period = RecapPeriod.forMonth(may20);
    final subscription = container.listen(
      recapForPeriodProvider(period),
      (previous, next) {},
    );

    await pumpAFew(tester);

    final recap = (subscription.read() as AsyncData<CycleRecap?>).value;
    expect(recap, isNotNull);
    final pr = recap!.topPrs.first;
    expect(pr.phase, isNull);
    expect(pr.displayPhase, isNull);
  });
}
