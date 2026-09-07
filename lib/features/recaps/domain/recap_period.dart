import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Which kind of period a [RecapPeriod] spans.
enum RecapPeriodKind {
  /// A completed menstrual cycle — bounded by two consecutive
  /// [CycleRecord.periodStart] values (see [completedCyclePeriods]).
  cycleEnd,

  /// A completed calendar month.
  month,
}

/// A bounded date range a "Your Cycle in Motion" recap can be built for —
/// either a completed menstrual cycle or a completed calendar month (Task
/// 1.3, `TASKS_TO_DO.md`).
///
/// Deliberately a plain immutable class rather than `freezed`, matching
/// `features/activity/domain/workout_milestone.dart#WorkoutMilestone`'s
/// precedent: this is a computed, presentation-facing value, never
/// persisted, so freezed's union/copyWith machinery buys nothing here.
class RecapPeriod {
  const RecapPeriod({
    required this.kind,
    required this.start,
    required this.end,
    required this.label,
    required this.key,
  });

  /// Builds the [RecapPeriod] for a completed cycle: [cycleStart] is the
  /// record whose period began the cycle, and [nextCycleStart] is the
  /// record whose period start closed it out. The cycle spans
  /// `[cycleStart.periodStart, nextCycleStart.periodStart - 1 day]`
  /// inclusive — see [completedCyclePeriods]'s dartdoc for why a cycle is
  /// only "completed" once the next one has started.
  factory RecapPeriod.forCompletedCycle({
    required CycleRecord cycleStart,
    required CycleRecord nextCycleStart,
  }) {
    final end = nextCycleStart.periodStart.addDays(-1);
    final endLabel = DateFormat('d MMM').format(
      DateTime(end.year, end.month, end.day),
    );
    return RecapPeriod(
      kind: RecapPeriodKind.cycleEnd,
      start: cycleStart.periodStart,
      end: end,
      label: 'Cycle ending $endLabel',
      // Keyed by the record that *started* the completed cycle: that
      // record's id is stable for as long as the cycle it describes
      // exists, and never collides with a different completed cycle.
      key: 'cycle:${cycleStart.id}',
    );
  }

  /// Builds the [RecapPeriod] for the calendar month containing
  /// [anyDayInMonth].
  factory RecapPeriod.forMonth(LocalDate anyDayInMonth) {
    final year = anyDayInMonth.year;
    final month = anyDayInMonth.month;
    final start = LocalDate(year, month, 1);
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    final end = LocalDate(year, month, lastDay);
    final monthLabel = DateFormat('MMMM').format(DateTime(year, month));
    return RecapPeriod(
      kind: RecapPeriodKind.month,
      start: start,
      end: end,
      label: 'Your $monthLabel',
      key:
          'month:${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}',
    );
  }

  final RecapPeriodKind kind;

  /// First day of the period, inclusive.
  final LocalDate start;

  /// Last day of the period, inclusive.
  final LocalDate end;

  /// Display label (e.g. "Your July", "Cycle ending 14 Aug").
  final String label;

  /// Stable identity used both for the "already shown" marker
  /// (`data/recap_marker_store.dart`) and for de-duplicating/sorting the
  /// recap history list (`recaps_providers.dart#recentRecapPeriodsProvider`).
  final String key;

  /// Number of calendar days this period spans, inclusive of both ends.
  int get totalDays => start.difference(end) + 1;

  @override
  // This class has no setters and every field is final - it's immutable in
  // substance, just not annotated `@immutable` (that annotation lives in
  // `package:meta`, and `domain/` code stays dependency-free per
  // `architecture_overview.md`'s layer rules), same reasoning as
  // `core/domain/local_date.dart`'s identical suppression.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecapPeriod &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          start == other.start &&
          end == other.end &&
          key == other.key;

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(kind, start, end, key);

  /// Deliberately opaque: [kind] and [key] only, never [start], [end] or
  /// [label].
  ///
  /// For a cycle-end period [start] **is** a logged period-start date and
  /// [label] names the day the cycle closed — S3 cycle data, which
  /// `knowledge/engineering/security_and_privacy.md` bars from logs and
  /// crash reports. This class is the family argument of
  /// `recaps_providers.dart#recapForPeriodProvider`, so it lands in
  /// Riverpod's provider description and from there in the
  /// `developer.log` call `app/bootstrap.dart`'s error hooks make. [key]
  /// is safe to keep: it is either an opaque cycle-record id
  /// (`cycle:<uuid>`) or a calendar month (`month:2026-07`), neither of
  /// which is a date she logged. Same reasoning as
  /// `features/insights/domain/personal_insight.dart`, which omits
  /// `toString()` entirely.
  @override
  String toString() => 'RecapPeriod(${kind.name}, $key)';
}

/// Every **completed** cycle derivable from [records]: a cycle completes
/// only once the *next* period has started (`knowledge/domain/womens_health.md`
/// gates phase/period claims to what's actually logged) — the most recent
/// logged period, ongoing or not, never yields a completed cycle of its
/// own, since nothing has started after it yet.
///
/// Returned oldest-first (ascending by [RecapPeriod.start]), mirroring
/// [records] sorted by [CycleRecord.periodStart].
List<RecapPeriod> completedCyclePeriods(List<CycleRecord> records) {
  if (records.length < 2) return const [];
  final sorted = List<CycleRecord>.from(records)
    ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

  final periods = <RecapPeriod>[];
  for (var i = 0; i < sorted.length - 1; i++) {
    periods.add(
      RecapPeriod.forCompletedCycle(
        cycleStart: sorted[i],
        nextCycleStart: sorted[i + 1],
      ),
    );
  }
  return periods;
}

/// The most recently **completed** calendar month relative to [today] —
/// i.e. the month before the one [today] falls in. A recap for the
/// in-progress current month is never produced, since it hasn't finished
/// yet.
RecapPeriod mostRecentCompletedMonth(LocalDate today) {
  final firstOfThisMonth = LocalDate(today.year, today.month, 1);
  final lastDayOfPreviousMonth = firstOfThisMonth.addDays(-1);
  return RecapPeriod.forMonth(lastDayOfPreviousMonth);
}
