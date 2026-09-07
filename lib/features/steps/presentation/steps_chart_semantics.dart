import 'package:intl/intl.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';

/// The bars, said out loud.
///
/// A bar chart carries its whole meaning in a picture, so a screen-reader
/// user given only "steps chart" is told one exists and nothing it shows.
/// This names the span, the busiest and quietest recorded days, how many
/// cleared the target and how many days have no data at all — built from
/// the same values the bars are drawn from, never a canned sentence.
///
/// Pure, so it is tested as text rather than through a pumped chart.
String stepsChartDescription({
  required List<StepsDayView> days,
  required int target,
  required NumberFormat numberFormat,
}) {
  final recorded = days.where((day) => day.hasData).toList();
  if (recorded.isEmpty) {
    return 'Daily steps chart, no recorded step counts in this range.';
  }

  var high = recorded.first;
  var low = recorded.first;
  for (final day in recorded) {
    if (day.steps! > high.steps!) high = day;
    if (day.steps! < low.steps!) low = day;
  }
  final stats = computeStepsRangeStats(days, target: target);
  final atTargetPhrase =
      '${stats.daysAtTarget} of ${stats.daysWithData} recorded days reached '
      '${numberFormat.format(target)} steps';

  String dayPhrase(StepsDayView day) => DateFormat(
    'EEEE d MMMM',
  ).format(DateTime(day.day.year, day.day.month, day.day.day));

  final sentences = <String>[
    'Daily steps chart',
    '${days.length} days, ${recorded.length} with a recorded count',
    'Highest ${dayPhrase(high)}, ${numberFormat.format(high.steps)} steps',
    'Lowest ${dayPhrase(low)}, ${numberFormat.format(low.steps)} steps',
    atTargetPhrase,
    if (stats.missingDays == 1)
      '1 day has no recorded count'
    else if (stats.missingDays > 1)
      '${stats.missingDays} days have no recorded count',
  ];
  return '${sentences.join('. ')}.';
}
