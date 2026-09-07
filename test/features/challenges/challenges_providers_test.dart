import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'challenge_fixtures.dart';

/// The wiring the UI half depends on: that `selfProgress` really does read
/// the activity log and `streaks`' protected days, and that the
/// active/archived split is derived from the injected today.
///
/// **Every test seeds the database first and opens the container second.**
/// These providers are Drift-backed streams, and `.future` resolves on a
/// stream's *first* emission — so a container opened before the writes
/// would answer with the empty database it started against, no matter how
/// long the test waited. Seeding first makes the first emission the
/// interesting one, which is both deterministic and closer to what a real
/// screen sees when it opens onto data that is already there.
void main() {
  late db.AppDatabase database;
  late SharedPreferences prefs;
  late ProviderContainer container;

  final today = LocalDate(2026, 9, 20);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
  });

  void openContainer() {
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
        challengesTodayProvider.overrideWithValue(today),
      ],
    );
    addTearDown(container.dispose);

    // Riverpod v3 test trap (central `testing-pitfalls.md`, and the same
    // no-op listen `streaks_providers_test.dart` needs): an autoDispose
    // StreamProvider with no listener can be torn down mid-flight on its
    // very first pending emission, surfacing as "disposed during loading
    // state". These keep them alive for the container's lifetime, exactly
    // as a watching widget would.
    container
      ..listen(protectedDaysProvider, (previous, next) {})
      ..listen(challengesProvider, (previous, next) {})
      ..listen(activeChallengesProvider, (previous, next) {})
      ..listen(archivedChallengesProvider, (previous, next) {});
  }

  Future<void> seedChallenge(Challenge challenge) =>
      DriftChallengeRepository(database).saveChallenge(challenge);

  test('selfProgress is null for a challenge that is not there', () async {
    openContainer();

    expect(await container.read(selfProgressProvider('nope').future), isNull);
  });

  test('selfProgress reads the activity log through the engine', () async {
    final realToday = LocalDate.today();
    final challenge = challengeFrom(
      distanceBlueprint(
        windowStart: realToday.addDays(-29),
        windowEnd: realToday,
      ),
    );
    await seedChallenge(challenge);
    await DriftActivityRepository(database).saveActivity(
      activityOn(realToday.addDays(-3), distanceMeters: 25000),
    );
    openContainer();

    final progress = await container.read(
      selfProgressProvider(challenge.id).future,
    );

    expect(progress!.rawValue, 25000);
    expect(progress.nominalTarget, 100000);
    expect(progress.adjustedTarget, 100000);
    expect(progress.percent, 25);
  });

  test('selfProgress pro-rates by the protected days streaks owns, not by '
      'its own derivation', () async {
    // Anchored to the real calendar rather than to a fixed date: this
    // provider reads `streaks`' `protectedDaysProvider`, whose own
    // `today` is the system clock and is not overridable from here. A
    // fixed 2026 window would drift in and out of being "the future" as
    // the clock moves, and a recovery day cannot be marked in the future.
    // The point of the test is the wiring, so the arithmetic below is kept
    // to a shape the engine tests already verify exhaustively.
    final realToday = LocalDate.today();
    final windowStart = realToday.addDays(-29);
    final challenge = challengeFrom(
      distanceBlueprint(windowStart: windowStart, windowEnd: realToday),
    );
    await seedChallenge(challenge);
    await DriftActivityRepository(database).saveActivity(
      activityOn(realToday.addDays(-3), distanceMeters: 25000),
    );
    // Five protected days, from the source `assembleProtectedDays` owns.
    // If this provider ever re-derived "protected" itself, this test would
    // keep passing only by coincidence.
    await DriftRecoveryRepository(database).markRecoveryDays(
      realToday.addDays(-10),
      realToday.addDays(-6),
    );
    openContainer();

    final progress = await container.read(
      selfProgressProvider(challenge.id).future,
    );

    expect(progress!.windowDays, 30);
    expect(progress.protectedDaysInWindow, 5);
    expect(
      progress.adjustedTarget,
      closeTo(83333.33, 0.01),
      reason: 'five protected days lower a 100 km ask to 25/30 of it',
    );
    expect(progress.percent, closeTo(30, 0.001));
  });

  test('the active/archived split follows the injected today', () async {
    final current = challengeFrom(distanceBlueprint(salt: 1));
    final finished = challengeFrom(
      distanceBlueprint(
        salt: 2,
        windowStart: LocalDate(2026, 7, 1),
        windowEnd: LocalDate(2026, 7, 31),
      ),
    );
    await seedChallenge(current);
    await seedChallenge(finished);
    openContainer();

    final active = await container.read(activeChallengesProvider.future);
    final archived = await container.read(archivedChallengesProvider.future);

    expect(active.map((c) => c.id), [current.id]);
    expect(archived.map((c) => c.id), [finished.id]);
  });

  test('a window ending exactly today is still active', () async {
    final endingToday = challengeFrom(
      distanceBlueprint(windowStart: LocalDate(2026, 9, 1), windowEnd: today),
    );
    await seedChallenge(endingToday);
    openContainer();

    expect(
      (await container.read(activeChallengesProvider.future)).single.id,
      endingToday.id,
    );
    expect(await container.read(archivedChallengesProvider.future), isEmpty);
  });

  test(
    'the code service reaches the same repository the providers do',
    () async {
      openContainer();
      final service = container.read(challengeCodeServiceProvider);

      await service.createChallenge(
        kind: ChallengeKind.sessionCount,
        activityTypes: const {},
        targetUnits: 12,
        windowStart: LocalDate(2026, 9, 1),
        windowEnd: LocalDate(2026, 9, 30),
        displayName: 'Alex',
        today: today,
      );

      // A one-shot read through the repository the provider hands out, not
      // through a stream: the container was open before the write, so the
      // stream provider's first emission is the empty one it started from.
      expect(
        await container.read(challengeRepositoryProvider).getChallenges(),
        hasLength(1),
      );
    },
  );
}
