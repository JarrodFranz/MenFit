import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart'
    show formatDuration;
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/insights/domain/insight_statistics.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_pr_highlight.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

/// Pure, injectable builder that turns raw month data into a [MonthRecap]
/// (Task 1.3, `TASKS_TO_DO.md`).
///
/// Every input is data the caller has already fetched (this class does no
/// I/O), and everything it needs from other features arrives through their
/// domain types only — `activity/domain`, `nutrition/domain`,
/// `wellbeing/domain` — never a repository or a provider, which is what
/// keeps this fully unit-testable with plain fixtures (see
/// `test/features/recaps/recap_builder_test.dart`).
///
/// Formats PR value labels directly in metric (`"12.40 km"`, `"65.0 kg"`)
/// rather than taking a `UnitSystem`, the same simplification
/// `activity/domain/milestone_evaluator.dart` already makes for its
/// achievement text — a stricter "convert at presentation" split
/// (`coding_standards.md`) is future work, not a new deviation this class
/// introduces.
class RecapBuilder {
  const RecapBuilder();

  /// Sparse-data guard (Task 1.3): a month recap with fewer sessions than
  /// this inside that month has nothing worth interrupting him for —
  /// [build] returns `null` and the trigger silently skips.
  ///
  /// Public because the recap history list applies the same bar *before*
  /// offering a month at all
  /// (`recaps_providers.dart#recentRecapPeriods`) — a row that could only
  /// ever answer "not enough logged yet" is worth not showing, and the
  /// two places must agree on the number by construction rather than by
  /// two copies of `3`.
  static const int minSessionsForMonthRecap = 3;

  /// The daily hydration goal (`features/nutrition/domain/water_repository.dart`
  /// consumers, e.g. `home/presentation/widgets/water_quick_add_card.dart`).
  static const int _hydrationTargetMl = 2000;

  /// Fraction of the protein target that counts as "met" — mirrors
  /// `domain/fueling_consistency_evaluator.dart`'s threshold so the recap's
  /// fueling slide agrees with the 7-day milestone card's definition of
  /// "met".
  static const double _proteinGoalThreshold = 0.85;

  /// Minimum check-ins logged in the period before a wellbeing observation
  /// is even considered (Task 1.3's explicit "≥8 check-ins" gate).
  ///
  /// A cheap entry gate on *engagement*, not a statistical one: how many
  /// days of the period he answered anything at all. The statistical
  /// floor is the insights engine's, reused verbatim — see
  /// [_buildWellbeingObservation].
  static const int _minCheckinsForObservation = 8;

  /// Builds the recap for [period], or returns `null` when fewer than
  /// [minSessionsForMonthRecap] sessions were logged inside it.
  ///
  /// - [periodActivities]: every activity whose local calendar day falls
  ///   within `[period.start, period.end]`, any order (sorted internally).
  /// - [samplesByActivityId]: GPS/HR samples for every **recorded**
  ///   activity in [periodActivities] — manual activities need no entry.
  /// - [priorRecords]: best-ever cardio records ([PersonalRecords]) as of
  ///   just *before* [period] started, so a PR can be told apart from a
  ///   merely-good session that doesn't actually beat history.
  /// - [priorMaxWeightsByExercise]: best-ever heaviest completed set per
  ///   exercise (key: `name.trim().toLowerCase()`), same "as of before the
  ///   period" scoping — mirrors
  ///   `activity/domain/milestone_evaluator.dart#evaluateStrengthMilestones`'s
  ///   `priorMaxWeights` parameter.
  /// - [waterTotalsByDay]: total millilitres logged per day within the
  ///   period — a day with **no** log is absent from the map, never
  ///   present as `0` (see `WaterRepository.getWaterTotalsForRange`).
  /// - [periodNutritionEntries] / [nutritionGoals]: the period's food
  ///   diary and the user's current targets.
  /// - [periodCheckins]: check-ins logged within the period.
  MonthRecap? build({
    required RecapPeriod period,
    required List<Activity> periodActivities,
    required Map<String, List<ActivitySample>> samplesByActivityId,
    required PersonalRecords priorRecords,
    required Map<String, double> priorMaxWeightsByExercise,
    required Map<LocalDate, int> waterTotalsByDay,
    required List<NutritionEntry> periodNutritionEntries,
    required NutritionGoals? nutritionGoals,
    required List<DailyCheckin> periodCheckins,
  }) {
    // Sparse-data guard. A month recap must earn its interruption with
    // sessions logged *in that month*.
    if (periodActivities.length < minSessionsForMonthRecap) {
      return null;
    }

    final sortedActivities = List<Activity>.from(periodActivities)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final activeDays = <LocalDate>{};
    final distanceByType = <ActivityType, double>{};
    var totalTonnageKg = 0.0;
    var mindfulMinutes = 0;
    final prHighlights = <RecapPrHighlight>[];

    var runningRecords = priorRecords;
    final runningMaxWeights = Map<String, double>.from(
      priorMaxWeightsByExercise,
    );

    for (final activity in sortedActivities) {
      final localDay = LocalDate.fromDateTime(activity.startedAt.toLocal());
      activeDays.add(localDay);

      if (activity.distanceMeters > 0) {
        distanceByType[activity.activityType] =
            (distanceByType[activity.activityType] ?? 0) +
            activity.distanceMeters;
      }

      if (activity.activityType == ActivityType.yoga ||
          activity.activityType == ActivityType.pilates) {
        mindfulMinutes += activity.movingTime.inMinutes;
      }

      final details = activity.workoutDetails;
      if (details is StrengthWorkoutDetails) {
        // Completed sets only — `MonthRecap.totalTonnageKg`'s contract,
        // and the same definition
        // `insights/application/insight_observation_mapper.dart#completedTonnageKg`
        // reports against. `totalVolumeKg` would count a set he racked
        // but never lifted.
        totalTonnageKg += details.completedVolumeKg;
      }

      final samples = activity.source == ActivitySource.recorded
          ? (samplesByActivityId[activity.id] ?? const <ActivitySample>[])
          : const <ActivitySample>[];
      final beforeRecords = runningRecords;
      runningRecords = foldActivityIntoRecords(
        current: runningRecords,
        activity: activity,
        samples: samples,
      );
      _detectCardioPrs(
        activity: activity,
        before: beforeRecords,
        after: runningRecords,
        highlights: prHighlights,
      );

      if (details is StrengthWorkoutDetails) {
        _detectStrengthPrs(
          exercises: details.exercises,
          runningMaxWeights: runningMaxWeights,
          activity: activity,
          highlights: prHighlights,
        );
      }
    }

    final totalDistanceMeters = distanceByType.values.isEmpty
        ? null
        : distanceByType.values.fold<double>(0, (a, b) => a + b);

    final consistencyRatio = period.totalDays > 0
        ? activeDays.length / period.totalDays
        : 0.0;

    final loggedWaterDays = waterTotalsByDay.length;
    final metWaterDays = waterTotalsByDay.values
        .where((ml) => ml >= _hydrationTargetMl)
        .length;
    final hydrationConsistencyRatio = loggedWaterDays >= 3 && metWaterDays > 0
        ? metWaterDays / loggedWaterDays
        : null;

    return MonthRecap(
      period: period,
      sessionCount: sortedActivities.length,
      consistencyRatio: consistencyRatio,
      distanceByType: distanceByType,
      totalDistanceMeters: totalDistanceMeters,
      totalTonnageKg: totalTonnageKg > 0 ? totalTonnageKg : null,
      mindfulMinutes: mindfulMinutes > 0 ? mindfulMinutes : null,
      hydrationConsistencyRatio: hydrationConsistencyRatio,
      fuelingConsistencyRatio: _computeFuelingConsistency(
        entries: periodNutritionEntries,
        goals: nutritionGoals,
      ),
      topPrs: prHighlights.take(3).toList(),
      wellbeingObservation: _buildWellbeingObservation(periodCheckins),
    );
  }

  /// Detects a new longest-distance, most-elevation, or best-effort PR set
  /// by [activity], comparing [before] (the running records prior to
  /// folding this activity in) against [after] (the result of that fold,
  /// already computed by the caller) — appends to [highlights] in place.
  ///
  /// A PR is only credited to *this* activity when the record holder
  /// changed to it: [PersonalRecords]' tie-break rule
  /// (`personal_records.dart#_beatsRecord`) keeps the earlier activity on
  /// an exact tie, so comparing holder identity (not just "is a value
  /// present") is what correctly excludes a merely-equalling session.
  void _detectCardioPrs({
    required Activity activity,
    required PersonalRecords before,
    required PersonalRecords after,
    required List<RecapPrHighlight> highlights,
  }) {
    final beforeLongest = before.longestDistance;
    final afterLongest = after.longestDistance;
    if (afterLongest != null &&
        afterLongest.activityId == activity.id &&
        beforeLongest?.activityId != activity.id) {
      highlights.add(
        RecapPrHighlight(
          type: RecapPrType.longestDistance,
          label: 'Longest distance',
          valueLabel:
              '${(activity.distanceMeters / 1000).toStringAsFixed(2)} km',
          achievedAt: activity.startedAt,
        ),
      );
    }

    final elevation = activity.elevationGainMeters;
    final beforeElevation = before.mostElevationGain;
    final afterElevation = after.mostElevationGain;
    if (elevation != null &&
        afterElevation != null &&
        afterElevation.activityId == activity.id &&
        beforeElevation?.activityId != activity.id) {
      highlights.add(
        RecapPrHighlight(
          type: RecapPrType.mostElevation,
          label: 'Highest climb',
          valueLabel: '${elevation.round()} m',
          achievedAt: activity.startedAt,
        ),
      );
    }

    for (final targetMeters in standardEffortDistances) {
      final beforeEntry = before.bestEfforts[targetMeters];
      final afterEntry = after.bestEfforts[targetMeters];
      if (afterEntry != null &&
          afterEntry.activityId == activity.id &&
          beforeEntry?.activityId != activity.id) {
        final distanceName =
            standardEffortDistanceNames[targetMeters] ??
            '${targetMeters.round()} m';
        highlights.add(
          RecapPrHighlight(
            type: RecapPrType.bestEffort,
            label: '$distanceName best effort',
            valueLabel: formatDuration(afterEntry.value),
            achievedAt: activity.startedAt,
          ),
        );
      }
    }
  }

  /// Detects a new heaviest completed set per exercise in [exercises],
  /// updating [runningMaxWeights] in place (chronological accumulation, so
  /// a second PR on the same exercise later in the same period is credited
  /// too) and appending to [highlights].
  void _detectStrengthPrs({
    required List<StrengthExercise> exercises,
    required Map<String, double> runningMaxWeights,
    required Activity activity,
    required List<RecapPrHighlight> highlights,
  }) {
    for (final exercise in exercises) {
      final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isEmpty) continue;

      final sessionMax = completedSets.fold<double>(
        0,
        (max, s) => s.weightKg > max ? s.weightKg : max,
      );
      if (sessionMax <= 0) continue;

      final key = exercise.name.trim().toLowerCase();
      final priorMax = runningMaxWeights[key] ?? 0;
      if (sessionMax > priorMax) {
        runningMaxWeights[key] = sessionMax;
        highlights.add(
          RecapPrHighlight(
            type: RecapPrType.strengthWeight,
            label: exercise.name,
            valueLabel: '${sessionMax.toStringAsFixed(1)} kg',
            achievedAt: activity.startedAt,
          ),
        );
      }
    }
  }

  /// Days the protein target was met divided by days with anything logged
  /// — `null` when no protein target is set, or nothing was logged this
  /// period. Same day-qualifies rule and threshold as
  /// `domain/fueling_consistency_evaluator.dart`, generalised from its
  /// fixed 7-day window to an arbitrary period.
  double? _computeFuelingConsistency({
    required List<NutritionEntry> entries,
    required NutritionGoals? goals,
  }) {
    final target = goals?.proteinTargetGrams ?? 0;
    if (target <= 0 || entries.isEmpty) return null;

    final entriesByDay = <LocalDate, List<NutritionEntry>>{};
    for (final entry in entries) {
      entriesByDay.putIfAbsent(entry.day, () => []).add(entry);
    }

    var daysLogged = 0;
    var daysMet = 0;
    for (final dayEntries in entriesByDay.values) {
      final totals = computeDayTotals(dayEntries).total;
      if (totals.caloriesKcal <= 0 && totals.proteinGrams <= 0) continue;
      daysLogged++;
      if (totals.proteinGrams >= target * _proteinGoalThreshold) daysMet++;
    }

    if (daysLogged < 3 || daysMet == 0) return null;
    return daysMet / daysLogged;
  }

  /// A plain, descriptive-only observation (never causal, never
  /// prescriptive) comparing logged energy on better-slept days against
  /// the rest, or `null` when there isn't enough paired data or no
  /// difference worth naming.
  ///
  /// Deliberately one-directional: it only ever names "better sleep,
  /// higher energy" when the data actually shows that (the intuitive,
  /// safe-to-state direction), and stays silent otherwise rather than
  /// inventing a description for a negative or flat difference that would
  /// need much more careful, unshaming wording to state responsibly.
  ///
  /// ## The statistical floor is the insights engine's, not a second one
  ///
  /// This sentence makes the same *kind* of claim as
  /// `features/insights/domain/evaluators/wellbeing_output_evaluator.dart`
  /// — "on higher-sleep days, X measured higher" — so it clears the same
  /// bar, drawn from the same constants
  /// (`insights/domain/insight_thresholds.dart`) and the same
  /// outlier-resistant statistics (`insights/domain/insight_statistics.dart`):
  ///
  /// 1. sleep scores are bucketed by
  ///    [InsightThresholds.highCheckinScore] / [InsightThresholds.lowCheckinScore],
  ///    with the neutral 3 dropped from **both** arms rather than split;
  /// 2. each arm needs [InsightThresholds.minObservationsPerGroup] days;
  /// 3. the two arms' **medians** must differ by at least
  ///    [InsightThresholds.minRelativeDifference];
  /// 4. Cliff's delta must reach [InsightThresholds.minCliffsDelta].
  ///
  /// `compareGroups` itself is not called: it returns a `PersonalInsight`
  /// keyed to an `InsightMetric`, and a check-in energy score is not one of
  /// those three metrics — inventing a metric value to satisfy it would be
  /// worse than reusing the gate's parts. What must never diverge are the
  /// numbers and the maths, and those are imported, not copied.
  ///
  /// [InsightThresholds.minPairedObservations] (10) is deliberately *not*
  /// applied: it sizes a 90-day insights window, whereas this describes one
  /// month, and [_minCheckinsForObservation] plus the 4-per-arm floor
  /// already put the minimum at 8 retained days.
  String? _buildWellbeingObservation(List<DailyCheckin> checkins) {
    if (checkins.length < _minCheckinsForObservation) return null;

    final goodSleepEnergy = <double>[];
    final otherSleepEnergy = <double>[];
    for (final checkin in checkins) {
      final energy = checkin.energy;
      final sleep = checkin.sleep;
      if (energy == null || sleep == null) continue;

      if (sleep >= InsightThresholds.highCheckinScore) {
        goodSleepEnergy.add(energy.toDouble());
      } else if (sleep <= InsightThresholds.lowCheckinScore) {
        otherSleepEnergy.add(energy.toDouble());
      }
    }

    if (goodSleepEnergy.length < InsightThresholds.minObservationsPerGroup) {
      return null;
    }
    if (otherSleepEnergy.length < InsightThresholds.minObservationsPerGroup) {
      return null;
    }

    // Medians, not means: a 1-5 ordinal has too few levels for one
    // outlying day to be allowed to set the number this sentence rests on.
    final goodMedian = median(goodSleepEnergy)!;
    final otherMedian = median(otherSleepEnergy)!;
    if (goodMedian <= otherMedian) return null;

    final difference = relativeDifference(
      higher: goodMedian,
      lower: otherMedian,
    );
    if (difference == null) return null;
    if (difference < InsightThresholds.minRelativeDifference) return null;

    final delta = cliffsDelta(goodSleepEnergy, otherSleepEnergy)!.abs();
    if (delta < InsightThresholds.minCliffsDelta) return null;

    return 'On the days you logged better sleep, your energy check-ins '
        'tended to be higher too.';
  }
}
