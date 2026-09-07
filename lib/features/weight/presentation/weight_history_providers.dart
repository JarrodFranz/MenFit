import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
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

/// Whether the user has logged any period at all.
///
/// Gates the cycle overlay: the chart offers it, and defaults it on, only
/// for a user who tracks her cycle. Cycle tracking is opt-in and every
/// consumer degrades to silence without it
/// (`knowledge/domain/womens_health.md` rule 4) — here that means no
/// toggle, no band, and no copy mentioning phases.
@riverpod
Stream<bool> weightHasCycleContext(Ref ref) {
  return ref
      .watch(cycleRepositoryProvider)
      .watchRecords()
      .map((records) => records.isNotEmpty);
}

/// How far back [weightCyclePhases] will phase a window, in days.
///
/// A backstop, not the primary bound: callers pass the **plotted span**
/// (first to last drawn point), which is already the only stretch the
/// chart can paint a band across. The "All" range over a long history can
/// still make that span a decade, and phasing a decade of days to paint
/// bands nobody can distinguish at that zoom is wasted work. Three years
/// and change is well past the point where an individual band is legible.
const int maxCycleOverlayDays = 1200;

/// Per-day cycle phase for `[start, end]`, for the chart's background
/// bands.
///
/// **[start] and [end] are the first and last plotted points**, not the
/// selected range's calendar bounds. `WeightTrendChart` only draws
/// annotations between those two days, so phasing anything outside them
/// produces phases no band is ever painted from — and worse, made the
/// panel's legend and cycle explainer appear for a window whose visible
/// chart carries no band at all (the map was non-empty, the bands were
/// not). Bounding the window at the plotted span makes "the map has a
/// banded phase in it" and "the chart drew a band" the same statement.
///
/// Days whose phase is [CyclePhase.none] are **left out of the map**
/// rather than stored: `none` is the engine's "no phase is known for this
/// day", and an absent key is how every consumer in this codebase spells
/// unknown — storing it would make untracked days look like a tracked
/// group. Same skip as `features/insights/insights_providers.dart` and
/// `features/recaps/recaps_providers.dart`.
///
/// Returns an empty map when nothing is logged. S3 data
/// (`knowledge/engineering/security_and_privacy.md`): this map is derived
/// in memory for one chart and is never logged, persisted, or attached to
/// a weight row.
@riverpod
Future<Map<LocalDate, CyclePhase>> weightCyclePhases(
  Ref ref, {
  required LocalDate start,
  required LocalDate end,
}) async {
  // A genuine one-shot `get`, never `watchRecords().first`: cancelling a
  // Drift query stream resolves through a root-zone future that escapes
  // `flutter_test`'s `FakeAsync`, deadlocking widget tests. See
  // `features/activity/domain/activity_repository.dart#getActivities`.
  final records = await ref.watch(cycleRepositoryProvider).getRecords();
  if (records.isEmpty) return const {};

  final today = ref.watch(weightTodayProvider);
  final floor = end.addDays(-(maxCycleOverlayDays - 1));

  // One pass over the window: `phaseRange` hoists the analysis and the
  // forward projection out of the per-day loop that `getDayStatus` would
  // otherwise redo for every single day.
  return CyclePredictionEngine().phaseRange(
    start: start.isBefore(floor) ? floor : start,
    end: end,
    records: records,
    today: today,
  );
}
