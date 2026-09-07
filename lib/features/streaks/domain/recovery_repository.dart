import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';

/// Persistence for user-logged protected recovery days — an explicit
/// voluntary act of declaring a day as recovery
/// (`knowledge/product/terminology.md`'s "Protected Recovery": "requires no
/// proof"), independent of any flare or period. One of three protection
/// sources the streak engine unions together — see
/// `domain/streak_assembly.dart`'s dartdoc.
///
/// Health-adjacent data, same handling as
/// `features/cycle/domain/cycle_repository.dart`: never logged, hard
/// deleted (not soft), wiped first in the "Delete my data" flow.
abstract interface class RecoveryRepository {
  /// Emits every non-deleted recovery day, as a set of calendar days, on
  /// every change. The streak engine's only need — see
  /// `domain/streak_assembly.dart`.
  Stream<Set<LocalDate>> watchRecoveryDays();

  /// Emits every non-deleted recovery day as a full [RecoveryDayEntry]
  /// (day + note), newest day first, on every change.
  ///
  /// Deliberately **unwindowed**, same F1 reasoning as
  /// `wellbeing/domain/wellbeing_repository.dart#watchProtectingFlareDays`:
  /// the set of ever-marked recovery days stays small in practice, so
  /// loading all of them is cheap enough not to need its own windowed
  /// query — callers that want a bounded window (the wellbeing history
  /// screen's 30-day view) filter client-side instead, same as
  /// `streaks_providers.dart#recoveryDayEntriesProvider`'s consumers do.
  /// Powers the streak card's "Today" management sheet (which needs
  /// today's note, not just whether today is marked) and the wellbeing
  /// history screen's recovery-day rows.
  Stream<List<RecoveryDayEntry>> watchRecoveryDayEntries();

  /// Marks [day] as a protected recovery day, with an optional [note] —
  /// upserts **by calendar day**, not by id (same convention as
  /// `features/wellbeing/domain/wellbeing_repository.dart#saveCheckin`):
  /// marking a day that's already marked replaces its note in place,
  /// preserving the existing row's `id`/`createdAt`. There is at most one
  /// recovery record per calendar day.
  ///
  /// Throws a `ValidationException` (see
  /// `domain/recovery_validation.dart#validateRecoveryDay`) if [day] is in
  /// the future.
  ///
  /// The single-day case of [markRecoveryDays] — identical semantics, kept
  /// as its own method because most call sites mark exactly one day.
  Future<void> markRecoveryDay(LocalDate day, {String? note});

  /// Marks every calendar day in the **inclusive** range `[from, to]` as a
  /// protected recovery day, with the same optional [note] on each.
  ///
  /// Per-day semantics are exactly [markRecoveryDay]'s: an upsert **by
  /// calendar day**, so a day already marked keeps its existing
  /// `id`/`createdAt` and only has its note replaced. The whole range is
  /// written in a single transaction — either every day in it is marked or
  /// none is, so a failure part-way through can't leave a half-marked
  /// stretch behind.
  ///
  /// Throws a `ValidationException` (see
  /// `domain/recovery_validation.dart#validateRecoveryDayRange`), before
  /// writing anything, if [to] is before [from], if [to] is in the future,
  /// or if the range is longer than `maxRecoveryRangeDays`.
  Future<void> markRecoveryDays(LocalDate from, LocalDate to, {String? note});

  /// Un-marks [day] — permanently (hard-)deletes its recovery record, if
  /// any. A no-op if [day] was never marked. Backs the streak card's
  /// "Recovery day marked — Undo" affordance
  /// (`home/presentation/widgets/streak_card.dart`).
  Future<void> unmarkRecoveryDay(LocalDate day);

  /// Un-marks every day in the **inclusive** range `[from, to]` —
  /// permanently (hard-)deletes each day's recovery record, in a single
  /// transaction. Days in the range that were never marked are simply
  /// skipped, so this is a no-op on an unmarked range rather than an error.
  ///
  /// Backs undo of a [markRecoveryDays] action. Deliberately unvalidated:
  /// removing records can't put anything in the future, and an inverted
  /// range just matches nothing.
  Future<void> unmarkRecoveryDays(LocalDate from, LocalDate to);

  /// Permanently deletes every recovery day on this device (part of the
  /// "Delete my data" flow).
  Future<void> deleteAllData();
}
