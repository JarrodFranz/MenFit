import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';

/// The engine's input, normalised once so every evaluator sees the same
/// days in the same order.
///
/// Construction is the only place ordering is decided, which is what makes
/// the engine deterministic: duplicates are resolved by input order (the
/// **first** observation for a given day wins) *before* sorting, so the
/// sort only ever sees unique keys and cannot depend on `List.sort`'s
/// instability.
///
/// There is no clock anywhere in this class or below it. "Today" is
/// whatever the caller chose to include.
class InsightDataset {
  const InsightDataset._(this.days, this._byDay);

  /// Normalises [observations] into a sorted, day-unique dataset.
  factory InsightDataset.from(List<DailyObservation> observations) {
    final byDay = <LocalDate, DailyObservation>{};
    for (final observation in observations) {
      byDay.putIfAbsent(observation.day, () => observation);
    }
    final days = byDay.values.toList()..sort((a, b) => a.day.compareTo(b.day));
    return InsightDataset._(List<DailyObservation>.unmodifiable(days), byDay);
  }

  /// Every observed day, ascending, one entry per calendar date.
  final List<DailyObservation> days;

  final Map<LocalDate, DailyObservation> _byDay;

  /// The observation for [day], or `null` if that day was never observed.
  DailyObservation? on(LocalDate day) => _byDay[day];

  /// The observation for the calendar day after [observation], or `null`
  /// when the next day is absent from the input — a gap, not a zero.
  DailyObservation? next(DailyObservation observation) {
    return _byDay[observation.day.addDays(1)];
  }
}
