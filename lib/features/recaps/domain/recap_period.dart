import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';

/// Which kind of period a [RecapPeriod] spans.
enum RecapPeriodKind {
  /// A completed calendar month.
  monthEnd,
}

/// A bounded date range a monthly recap can be built for — a completed
/// calendar month (Task 1.3, `TASKS_TO_DO.md`).
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
      kind: RecapPeriodKind.monthEnd,
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

  /// Display label (e.g. "Your July").
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
  /// This class is reachable from a `MonthRecap` held as a Riverpod
  /// provider value, and provider errors interpolate their value into a
  /// description that `app/bootstrap.dart`'s error hooks pass to
  /// `developer.log`. [key] is safe to keep: it names an opaque calendar
  /// month (`month:2026-07`), never a date the user logged.
  @override
  String toString() => 'RecapPeriod(${kind.name}, $key)';
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
