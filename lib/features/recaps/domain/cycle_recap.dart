import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_pr_highlight.dart';

/// The built result of `RecapBuilder` (`domain/recap_builder.dart`) for one
/// [RecapPeriod] — everything the story UI needs to render, with nothing
/// left for the presentation layer to compute.
///
/// **Framing rule, enforced here, not in the widgets**
/// (`TASKS_TO_DO.md` Task 1.3): every metric that has genuinely nothing to
/// show is `null` (or an empty list), never a manufactured zero — a
/// `totalTonnageKg` of `0` for a period with no strength work would render
/// as a shameful "you lifted 0 kg", so it's absent instead. The story
/// screen's job is only to skip whichever slides have nothing to show, not
/// to decide what counts as "nothing".
class CycleRecap {
  const CycleRecap({
    required this.period,
    required this.sessionCount,
    required this.consistencyRatio,
    this.distanceByType = const {},
    this.totalDistanceMeters,
    this.totalTonnageKg,
    this.mindfulMinutes,
    this.hydrationConsistencyRatio,
    this.fuelingConsistencyRatio,
    this.topPrs = const [],
    this.wellbeingObservation,
  });

  final RecapPeriod period;

  /// Total logged activities (of any type) within the period.
  final int sessionCount;

  /// Distinct active days divided by [RecapPeriod.totalDays]. `0.0` when
  /// [sessionCount] is `0` — unlike the other metrics this is always shown
  /// (the movement-consistency slide already only renders when
  /// [sessionCount] is positive, so a caller never sees a bare "0%").
  final double consistencyRatio;

  /// Total distance moved, in metres, by [ActivityType] — only types with
  /// a positive total are present.
  final Map<ActivityType, double> distanceByType;

  /// Sum of [distanceByType]'s values. `null` when [distanceByType] is
  /// empty (no cardio distance logged this period).
  final double? totalDistanceMeters;

  /// Total strength tonnage lifted (kg), summed across every completed
  /// set. `null` when no strength work was logged this period.
  final double? totalTonnageKg;

  /// Total minutes spent in mindful (yoga/Pilates) sessions. `null` when
  /// none were logged this period.
  final int? mindfulMinutes;

  /// Days that hit the 2,000 ml hydration target divided by days with
  /// *any* water logged (not by [RecapPeriod.totalDays] — an unlogged day
  /// is neither a hit nor a miss, it's absent data). `null` when nothing
  /// was logged at all.
  final double? hydrationConsistencyRatio;

  /// Days the protein target was met divided by days with any nutrition
  /// logged. `null` when no protein target is set, or nothing was logged.
  final double? fuelingConsistencyRatio;

  /// Up to 3 personal records set during the period, with phase context —
  /// see `RecapBuilder` for selection order. Empty when none were set.
  final List<RecapPrHighlight> topPrs;

  /// A plain, descriptive (never causal or prescriptive —
  /// `knowledge/domain/womens_health.md`) observation about energy and
  /// sleep check-ins, only ever produced from at least 8 check-ins in the
  /// period. `null` when there isn't enough paired data, or no pattern
  /// worth naming.
  final String? wellbeingObservation;

  @override
  String toString() =>
      'CycleRecap(${period.key}, sessions: $sessionCount, '
      'prs: ${topPrs.length})';
}
