import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

/// One calendar day as the steps screen draws it.
///
/// [steps] is `null` when the repository has **no row** for that day, which
/// is a different fact from a row that says `0`: the first means nothing
/// was recorded, the second means the device recorded no movement. Every
/// surface below (chart, list, summary) has to keep those apart, so the
/// distinction is carried in the type rather than re-derived per widget.
@immutable
class StepsDayView {
  const StepsDayView({required this.day, required this.steps});

  final LocalDate day;
  final int? steps;

  bool get hasData => steps != null;

  bool metTarget(int target) => steps != null && steps! >= target;

  @override
  bool operator ==(Object other) =>
      other is StepsDayView && other.day == day && other.steps == steps;

  @override
  int get hashCode => Object.hash(day, steps);
}

/// The numbers under the chart.
///
/// [average] and [daysAtTarget] are both computed over [daysWithData] only.
/// Dividing the total by the calendar length instead would turn every
/// unsynced day into a silent zero and report an average they never walked.
class StepsRangeStats {
  const StepsRangeStats({
    required this.totalSteps,
    required this.daysInRange,
    required this.daysWithData,
    required this.daysAtTarget,
  });

  final int totalSteps;
  final int daysInRange;
  final int daysWithData;
  final int daysAtTarget;

  int get missingDays => daysInRange - daysWithData;

  bool get hasAnyData => daysWithData > 0;

  /// Mean steps across the days that have a row, rounded to a whole step.
  /// `null` when nothing in the range was recorded — there is no average of
  /// no measurements, and rendering `0` there would be a claim.
  int? get average =>
      daysWithData == 0 ? null : (totalSteps / daysWithData).round();
}

/// Expands `[start, end]` into one entry per calendar day, filling in
/// [stepsByDay] where a row exists and leaving the rest `null`.
///
/// [end] is inclusive. A [start] after [end] yields an empty list rather
/// than throwing: the caller is a screen reacting to a period switch, and
/// an empty range is a legitimate (if transient) thing for it to ask for.
List<StepsDayView> buildStepsDays({
  required LocalDate start,
  required LocalDate end,
  required Map<LocalDate, int> stepsByDay,
}) {
  if (start.isAfter(end)) return const [];
  final days = <StepsDayView>[];
  for (var day = start; !day.isAfter(end); day = day.addDays(1)) {
    days.add(StepsDayView(day: day, steps: stepsByDay[day]));
  }
  return days;
}

/// Summarises [days] against [target].
StepsRangeStats computeStepsRangeStats(
  List<StepsDayView> days, {
  required int target,
}) {
  var total = 0;
  var withData = 0;
  var atTarget = 0;
  for (final day in days) {
    final steps = day.steps;
    if (steps == null) continue;
    total += steps;
    withData++;
    if (steps >= target) atTarget++;
  }
  return StepsRangeStats(
    totalSteps: total,
    daysInRange: days.length,
    daysWithData: withData,
    daysAtTarget: atTarget,
  );
}

/// A "nice" y-axis step for a steps chart.
///
/// Deliberately **not** `features/progress`'s general `niceInterval`: that
/// lives in another feature's `presentation/` (which this feature may not
/// import, `architecture_overview.md` rule 2) and it solves a different
/// problem — a distance axis measured in single-digit kilometres. Step
/// counts are read in thousands, so the ladder below is the set of
/// intervals a person actually reads a step axis in; a computed
/// 1/2/5x10^n step would happily offer 2,000 where 2,500 is the familiar
/// half of a 5,000 line.
///
/// Pure, so it is unit-tested as arithmetic rather than through a chart.
double stepsAxisInterval(double maxValue) {
  const ladder = [1000.0, 2000.0, 2500.0, 5000.0, 10000.0, 20000.0, 50000.0];
  const targetGridlines = 4;
  for (final step in ladder) {
    if (maxValue / step <= targetGridlines) return step;
  }
  return ladder.last;
}

/// The smallest multiple of [interval] at or above [maxValue], so the
/// tallest bar never clips the top gridline and every gridline is an exact
/// multiple of [interval].
double stepsAxisMax(double maxValue, double interval) {
  if (maxValue <= 0) return interval;
  return (maxValue / interval).ceil() * interval;
}
