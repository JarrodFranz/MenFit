import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';

/// Persistence for the user's body-weight history.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): weight
/// values and notes never appear in logs, analytics, or a thrown
/// [Exception]'s message, and deletion is a genuine **hard** delete —
/// there is no soft-delete column to hide behind (see
/// `core/db/tables/weight_logs.dart`).
///
/// **Ordering is chronological — oldest first** on every read here
/// (`day` ascending, then `createdAt` ascending, then `id` ascending so
/// two readings recorded in the same millisecond still come back in a
/// stable order). That is a deliberate departure from
/// `features/wellbeing/domain/wellbeing_repository.dart`'s newest-first
/// lists: those feed a history *list*, these feed a time *series* — a
/// trend/EMA engine and a chart both want the points in the order they
/// happened, and reversing a list at every call site is the sort of thing
/// one call site eventually forgets to do. Two consequences worth naming:
/// the last element of a day's runs is that day's latest reading, and the
/// last element overall is the most recent reading in the window.
///
/// **Several logs may share a day** (morning and evening weigh-ins are
/// real). Nothing here collapses them; a caller that needs one value per
/// day picks it — see [getLatestLog] for the "current weight" case.
abstract interface class WeightRepository {
  /// Emits every log whose day falls in `[start, end]` — **inclusive on
  /// both ends** — oldest first, on every change.
  ///
  /// Emits an empty list when nothing was logged in the window; an empty
  /// window is an expected state, not an error. A [start] after [end]
  /// yields an empty list rather than throwing.
  Stream<List<WeightLog>> watchLogsForRange(LocalDate start, LocalDate end);

  /// One-shot fetch of exactly what [watchLogsForRange] emits.
  ///
  /// For callers that read the window once and stop (trend computation
  /// over a fixed range, recaps, exports). It exists as its own method
  /// rather than as `watchLogsForRange(...).first` on purpose — see
  /// `features/activity/domain/activity_repository.dart#getActivities`
  /// and the 2026-09-01 entry in the central `testing-pitfalls.md` for
  /// the widget-test deadlock that pattern causes.
  Future<List<WeightLog>> getLogsForRange(LocalDate start, LocalDate end);

  /// Emits every log within the [days] days up to and including [today]
  /// (inclusive on both ends, so `days: 7` covers `today - 6 .. today`),
  /// oldest first, on every change.
  Stream<List<WeightLog>> watchRecentLogs(int days, LocalDate today);

  /// One-shot fetch of exactly what [watchRecentLogs] emits — same window,
  /// same order, same reason for existing as [getLogsForRange].
  Future<List<WeightLog>> getRecentLogs(int days, LocalDate today);

  /// Emits the single most recent log — the last day with any reading, and
  /// within it the last reading recorded — or `null` when nothing has ever
  /// been logged, on every change.
  ///
  /// `null` is an expected state (a fresh install whose profile carried no
  /// weight to seed from), not an error.
  Stream<WeightLog?> watchLatestLog();

  /// One-shot fetch of what [watchLatestLog] emits.
  Future<WeightLog?> getLatestLog();

  /// Upserts [log] **by id** — not by day, since multiple readings per day
  /// are allowed and there is no "the day's log" to replace.
  ///
  /// The persisted `updatedAt` is always stamped to UTC-now regardless of
  /// what [log] carries. The persisted `createdAt` is the value of the
  /// first-ever save for that id: a later save with a different
  /// [WeightLog.createdAt] does not move it, so callers never need to
  /// read-before-write themselves (same contract as
  /// `features/profile/domain/profile_repository.dart#saveProfile`).
  ///
  /// [WeightLog.notes] is persisted as given, `null` included — saving a
  /// log with no note clears any note the row previously had.
  Future<void> saveLog(WeightLog log);

  /// Permanently (hard-)deletes the log with [id]. Deleting an id that
  /// doesn't exist is a no-op, not an error.
  ///
  /// A hard delete, not the soft-delete-and-sync-later pattern of ADR 004:
  /// a weigh-in the user removed must actually be gone. Body weight is
  /// ED-sensitive as well as S2 — a number they chose to delete must not be
  /// recoverable by anything in the app.
  Future<void> deleteLog(String id);

  /// Permanently deletes every weight log on this device (part of the
  /// "Delete my data" flow — see
  /// `features/settings/presentation/settings_screen.dart`). Notes go with
  /// the rows.
  Future<void> deleteAllData();
}
