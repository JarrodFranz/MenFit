import 'package:menfit_app/features/challenges/domain/challenge.dart';

/// Persistence for buddy challenges.
///
/// **Ordering is newest window first** on every read (`window_start`
/// descending, ties broken on `id` descending so two challenges starting
/// the same day come back in a stable order). The active/archived split
/// the UI shows is derived from the window against today, never stored —
/// a challenge does not change when it ends, the calendar does.
///
/// **Deletion is hard.** There is no `deleted_at` column and no soft
/// delete: leaving a challenge removes the row, buddy's name included.
/// Same posture as `weight_logs` and `badge_awards`, and for the same
/// reason — there is no backend to reconcile with (ADR 004), and a row
/// hiding behind a flag is not a deleted row.
///
/// S1 data (`knowledge/engineering/security_and_privacy.md`): display
/// names and one shared percentage. Never logged — and note what is
/// *absent* from every method here: nothing in this interface reads,
/// writes or returns a protected day, an adjusted target or anything
/// cycle-derived. The user's own progress is recomputed on demand by
/// `domain/challenge_progress_engine.dart` and stored nowhere.
abstract interface class ChallengeRepository {
  /// Emits every challenge, newest window first, on every change.
  Stream<List<Challenge>> watchChallenges();

  /// One-shot fetch of exactly what [watchChallenges] emits.
  ///
  /// Its own method rather than `watchChallenges().first` — see
  /// `features/activity/domain/activity_repository.dart#getActivities`
  /// and the 2026-09-01 entry in the central `testing-pitfalls.md` for the
  /// widget-test deadlock that pattern causes.
  Future<List<Challenge>> getChallenges();

  /// Emits the challenge with [id], or `null` if there isn't one, on
  /// every change.
  Stream<Challenge?> watchChallenge(String id);

  /// One-shot fetch of the challenge with [id], or `null`.
  Future<Challenge?> getChallenge(String id);

  /// Upserts [challenge] by id.
  ///
  /// The persisted `createdAt` is always the value of the first-ever save
  /// for that id — a later call with a different [Challenge.createdAt]
  /// does not move it, so callers never need to read-before-write (same
  /// convention as `activity` and `profile`). This is what makes "join a
  /// challenge you already hold" harmless: the id is derived from the
  /// challenge's own defining bytes, so a second join is the same row,
  /// and the moment she first picked it up is preserved.
  Future<void> saveChallenge(Challenge challenge);

  /// Permanently removes the challenge with [id]. A no-op when there is
  /// no such row.
  Future<void> deleteChallenge(String id);

  /// Permanently deletes every challenge on this device (part of the
  /// "Delete my data" flow — see
  /// `features/settings/presentation/settings_screen.dart`).
  Future<void> deleteAllData();
}
