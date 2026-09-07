import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';

/// Persistence for the user's daily step history.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`:
/// health-platform data): step counts never appear in logs, analytics, or a
/// thrown exception's message, and [deleteAllData] is a genuine **hard**
/// delete — there is no soft-delete column to hide behind (see
/// `core/db/tables/daily_step_totals.dart`).
///
/// **Ordering is chronological — oldest first** on every read here, and for
/// the same reason as `features/weight/domain/weight_repository.dart`: the
/// consumers are a chart and a rolling-average engine, which want the points
/// in the order they happened. Reversing at each call site is the sort of
/// thing one call site eventually forgets to do.
///
/// **At most one row per day**, unlike weight logs. Two step readings for one
/// day are two readings of the same accruing number, not two facts, so
/// [upsertMany] replaces by day.
abstract interface class StepsRepository {
  /// Emits every stored day whose date falls in `[start, end]` — **inclusive
  /// on both ends** — oldest first, on every change.
  ///
  /// **Only days that have a row are emitted.** Gaps are not filled with
  /// zeroes: a day nothing was ever synced for and a day of genuinely zero
  /// steps are different statements, and only the second one is a number
  /// this app is entitled to make. Callers that need a dense series fill the
  /// gaps themselves, deliberately.
  ///
  /// Emits an empty list when nothing was synced in the window; an empty
  /// window is an expected state, not an error. A [start] after [end] yields
  /// an empty list rather than throwing.
  Stream<List<DailySteps>> watchRange(LocalDate start, LocalDate end);

  /// One-shot fetch of exactly what [watchRange] emits — same window, same
  /// order.
  ///
  /// It exists as its own method rather than as `watchRange(...).first` on
  /// purpose: that pattern deadlocks widget tests (central
  /// `testing-pitfalls.md`, 2026-09-01), which is why every repository in
  /// this codebase pairs its streams with one-shot reads.
  Future<List<DailySteps>> getRange(LocalDate start, LocalDate end);

  /// Upserts [rows] **by day**, in one transaction.
  ///
  /// A day already present is overwritten wholesale — steps, source and
  /// `syncedAt` — because a later reading of an accruing day supersedes the
  /// earlier one entirely. Today's row is therefore rewritten on every sync
  /// by design. An empty [rows] is a no-op, not an error.
  Future<void> upsertMany(List<DailySteps> rows);

  /// Permanently deletes every stored step total on this device (part of the
  /// "Delete my data" flow — see
  /// `features/settings/presentation/settings_screen.dart`).
  ///
  /// A hard delete: this is a local copy of a fact the health platform owns,
  /// so there is nothing a soft-deleted step total could mean. Note that the
  /// health platform still holds its own copy — deleting here removes what
  /// *this app* stored, which is all this app is able to remove.
  Future<void> deleteAllData();
}
