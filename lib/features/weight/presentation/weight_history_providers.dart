import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_history_providers.g.dart';

/// The calendar day every weight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside each provider
/// below, so "today" is an explicit, overridable input — same seam and
/// same reasoning as `features/insights/insights_providers.dart`'s
/// `insightsToday`.
@riverpod
LocalDate weightToday(Ref ref) => LocalDate.today();

/// Every reading inside [range], oldest first (the repository's ordering,
/// unchanged — see `domain/weight_repository.dart`).
///
/// The history list reverses this for display; the chart and the trend
/// engine both want it as it comes.
@riverpod
Stream<List<WeightLog>> weightLogsInRange(Ref ref, WeightRange range) {
  final today = ref.watch(weightTodayProvider);
  return ref
      .watch(weightRepositoryProvider)
      .watchLogsForRange(range.startFor(today), today);
}

/// The smoothed series for [range].
///
/// Derived from [weightLogsInRange] rather than opening a second query
/// stream over the same window, so the list and the chart on one screen
/// share a single subscription.
@riverpod
Future<WeightTrendSeries> weightTrend(Ref ref, WeightRange range) async {
  final logs = await ref.watch(weightLogsInRangeProvider(range).future);
  return computeWeightTrend(logs: logs);
}

/// The single most recent reading, whenever it was — independent of the
/// selected range, since the header's "latest reading" should not vanish
/// because the user narrowed the chart to the last month.
@riverpod
Stream<WeightLog?> latestWeightLog(Ref ref) {
  return ref.watch(weightRepositoryProvider).watchLatestLog();
}
