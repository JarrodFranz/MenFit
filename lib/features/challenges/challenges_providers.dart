/// Composition surface for the `challenges` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence and derived
/// state: other features may import this file, never `data/`,
/// `application/` or `presentation/` directly (see
/// `knowledge/decisions/007_cross_feature_providers.md`).
///
/// The user's own progress is **derived, never stored**
/// (`data_architecture.md`'s "Derived vs stored" section): the only thing
/// this feature persists is the shared challenge definition, the name they
/// chose, and the last thing their buddy handed over. Their adjusted target —
/// the one figure that carries any trace of their cycle — exists only inside
/// [selfProgress]'s return value, and never leaves the device.
library;

import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/challenges/application/challenge_code_service.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenges_providers.g.dart';

/// Persistence for challenges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.
@Riverpod(keepAlive: true)
ChallengeRepository challengeRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftChallengeRepository(database);
}

/// The calendar day everything below is evaluated against.
///
/// A provider rather than a `LocalDate.today()` call inside each consumer
/// so "today" is an explicit, overridable seam — a test that cannot pin
/// today cannot pin a window boundary. Same pattern as
/// `achievements_providers.dart#achievementsToday` and
/// `insights_providers.dart#insightsToday`.
@riverpod
LocalDate challengesToday(Ref ref) => LocalDate.today();

/// Every challenge on this device, newest window first.
@riverpod
Stream<List<Challenge>> challenges(Ref ref) {
  return ref.watch(challengeRepositoryProvider).watchChallenges();
}

/// Challenges whose window has not closed yet (today inclusive).
///
/// Derived from the window against [challengesToday], never a stored
/// flag: a challenge does not change when it ends — the calendar moves.
///
/// Reads the repository stream directly rather than mapping
/// [challenges]: Riverpod 3 removed `StreamProvider.stream`, and a Drift
/// query stream is cheap enough that a second subscription over a handful
/// of rows is the simpler correct answer.
@riverpod
Stream<List<Challenge>> activeChallenges(Ref ref) {
  final today = ref.watch(challengesTodayProvider);
  return ref
      .watch(challengeRepositoryProvider)
      .watchChallenges()
      .map((all) => all.where((c) => c.isActiveOn(today)).toList());
}

/// Challenges whose window has closed. Kept, not deleted — a finished
/// challenge is something they did, and the celebration card lives here.
@riverpod
Stream<List<Challenge>> archivedChallenges(Ref ref) {
  final today = ref.watch(challengesTodayProvider);
  return ref
      .watch(challengeRepositoryProvider)
      .watchChallenges()
      .map((all) => all.where((c) => !c.isActiveOn(today)).toList());
}

/// Where the user stands in one challenge, recomputed from their own logs.
///
/// Null when there is no such challenge (it was deleted while a screen
/// held its id).
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `achievements_providers.dart#badgeInputs`: it walks the activity log,
/// and re-running that on every unrelated write while nothing is looking
/// would be waste. It refreshes when invalidated, when `today` rolls over,
/// and whenever protection changes.
///
/// Every read is a genuine one-shot `get` or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot, which
/// deadlocks widget tests (see
/// `features/activity/domain/activity_repository.dart#getActivities`).
///
/// **Protection comes from `streaks`' single decision source**
/// (`streaks_providers.dart#protectedDays` over
/// `assembleProtectedDays`), never a re-derivation — a second definition
/// of "protected" would eventually disagree with the first, and the day it
/// did, a period would start raising the ask.
///
/// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
/// in this provider or below it is logged, and the adjusted target it
/// returns is never persisted or encoded — see
/// `domain/challenge_codes.dart`'s privacy invariant.
@riverpod
Future<ChallengeSelfProgress?> selfProgress(Ref ref, String challengeId) async {
  final challenge = await ref
      .watch(challengeRepositoryProvider)
      .getChallenge(challengeId);
  if (challenge == null) return null;

  final activities = await ref
      .watch(activityRepositoryProvider)
      .getActivities();
  final protectedDays = await ref.watch(protectedDaysProvider.future);

  return computeSelfProgress(
    challenge: challenge.blueprint,
    activities: activities,
    protectedDays: protectedDays,
  );
}

/// Creates, joins, exports and imports codes. Stateless apart from its
/// repository, so `keepAlive` costs nothing and saves rebuilding it on
/// every paste.
@Riverpod(keepAlive: true)
ChallengeCodeService challengeCodeService(Ref ref) {
  return ChallengeCodeService(ref.watch(challengeRepositoryProvider));
}
