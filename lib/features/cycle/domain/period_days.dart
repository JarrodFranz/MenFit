import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart'
    show CyclePredictionEngine;
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Pure period-day queries consumed by the (upcoming) streak engine — see
/// `knowledge/architecture/data_architecture.md`'s "Streak & cycle
/// interaction" section: days within a confirmed logged period are paused
/// (neither extend nor break a streak).
///
/// Deliberately pure functions, not methods on [CycleRecord] or a
/// repository call: the streak engine needs to ask "was this day a period
/// day" for arbitrary days against an already-loaded list of records
/// without touching persistence, and a pure function is trivially,
/// exhaustively unit-testable. [today] is always passed in explicitly
/// (never read from the system clock) so these functions stay pure and
/// deterministic in tests.

/// The last day an ongoing record — one with no logged
/// [CycleRecord.periodEnd] — is treated as covering.
///
/// Two caps, whichever is earlier:
///
/// * **[today]**, because a period's future days aren't known yet and a
///   prediction must never pause a streak (see
///   `knowledge/domain/womens_health.md`);
/// * **[periodStart] + `maxPlausiblePeriodDuration - 1` days**, because a
///   record left open is a record she forgot to close, not a bleed that is
///   still running months later. Without this cap one stale ongoing record
///   marks every day since as a period day — pausing her streak forever and
///   auto-qualifying every all-protected week of the achievements
///   consistency ladder, permanently (awards are never revoked).
///
/// The bound is [CyclePredictionEngine.maxPlausiblePeriodDuration], the
/// codebase's single stated limit for a plausible logged period — the same
/// number the prediction engine uses to reject an implausible duration from
/// its statistics. There is deliberately no second number for this.
///
/// The cap only ever applies to the *fallback*. A record with a logged end
/// is honoured exactly as logged, however long it is: that is a fact she
/// entered, and this function never sees it.
///
/// Past the cap the day is simply unprotected again. She can still log the
/// real end (or a recovery day) to say otherwise — which is the point: the
/// old behaviour offered no way back at all.
LocalDate ongoingPeriodEffectiveEnd(LocalDate periodStart, LocalDate today) {
  final plausibleEnd = periodStart.addDays(
    CyclePredictionEngine.maxPlausiblePeriodDuration - 1,
  );
  return plausibleEnd.isBefore(today) ? plausibleEnd : today;
}

/// Whether [day] falls within any non-deleted record's period range,
/// inclusive of both endpoints.
///
/// An ongoing record (null [CycleRecord.periodEnd]) is treated as covering
/// every day from its start up to [ongoingPeriodEffectiveEnd] — today at
/// the latest, and a plausible period's length at the most.
///
/// Nit N5: delegates to [periodDaysInRange] with a single-day
/// `[day, day]` range instead of re-implementing the same clamp/ongoing-cap
/// logic - that rule (in particular the ongoing-record cap) now lives in
/// exactly one place.
bool isPeriodDay(LocalDate day, List<CycleRecord> records, LocalDate today) {
  return periodDaysInRange(day, day, records, today).contains(day);
}

/// The union of every period day across [records] that falls within
/// `[from, to]` inclusive.
///
/// Ongoing records are capped by [ongoingPeriodEffectiveEnd], the same way
/// [isPeriodDay] caps them. Returns an empty set when [from] is after [to]
/// or [records] is empty.
Set<LocalDate> periodDaysInRange(
  LocalDate from,
  LocalDate to,
  List<CycleRecord> records,
  LocalDate today,
) {
  final result = <LocalDate>{};
  if (from.isAfter(to)) return result;

  for (final record in records) {
    final effectiveEnd =
        record.periodEnd ??
        ongoingPeriodEffectiveEnd(record.periodStart, today);
    // Clamp this record's [start, effectiveEnd] range to [from, to].
    final rangeStart = record.periodStart.isAfter(from)
        ? record.periodStart
        : from;
    final rangeEnd = effectiveEnd.isBefore(to) ? effectiveEnd : to;
    if (rangeStart.isAfter(rangeEnd)) continue;

    var cursor = rangeStart;
    while (!cursor.isAfter(rangeEnd)) {
      result.add(cursor);
      cursor = cursor.addDays(1);
    }
  }
  return result;
}
