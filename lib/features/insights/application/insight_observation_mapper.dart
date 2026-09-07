import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

/// How many calendar days of history the insights engine is fed, ending on
/// (and including) "today".
///
/// Ninety days is roughly three cycles, which is the shortest window in
/// which `CyclePhaseEvaluator` can plausibly accumulate
/// `InsightThresholds.minObservationsPerGroup` sessions in a single phase
/// without stretching so far back that a pattern reflects a training block
/// the user has long since moved on from.
const int insightWindowDays = 90;

/// Builds the engine's input from raw per-feature records.
///
/// Pure: every source is passed in, nothing here reads a repository or a
/// clock. That is what makes both this mapping and the provider that feeds
/// it (`insights_providers.dart`) testable against fixtures — the engine's
/// determinism is worthless if the layer assembling its input quietly
/// consults `DateTime.now()`.
///
/// **Every** calendar day in the window is emitted, including days with
/// nothing logged at all. `InsightDataset.next` pairs a day with the
/// *following calendar day* by map lookup, so a skipped empty day would
/// silently break `ProteinOutputEvaluator`'s day-after pairing across it.
/// An empty day carries nulls everywhere and contributes to no comparison.
///
/// ## Absence is never a zero
///
/// A day with no diary entries gets `proteinGrams: null`, not `0` — an
/// unlogged day is not a day she ate nothing. Likewise a day absent from
/// [waterTotalsByDay] gets `waterMl: null`, and a day with no check-in
/// gets `null` for all five scores. [DailyObservation] documents why the
/// engine needs that distinction.
///
/// ## Hydration targets
///
/// [DailyObservation.waterTargetMl] is always `null`: the app has no
/// user-set hydration target, and `HydrationOutputEvaluator`'s dartdoc is
/// explicit that inventing a default one would have the engine measure her
/// against a number she never chose. The evaluator therefore stays dormant
/// until a real target exists; water intake is still mapped so that adding
/// one later is the only change needed.
List<DailyObservation> buildDailyObservations({
  required LocalDate today,
  required List<Activity> activities,
  required List<NutritionEntry> nutritionEntries,
  required NutritionGoals? nutritionGoals,
  required Map<LocalDate, int> waterTotalsByDay,
  required List<DailyCheckin> checkins,
  required Map<LocalDate, CyclePhase> phaseByDay,
  int windowDays = insightWindowDays,
}) {
  final start = today.addDays(-(windowDays - 1));
  bool inWindow(LocalDate day) => !day.isBefore(start) && !day.isAfter(today);

  final proteinTarget = resolveProteinTargetGrams(nutritionGoals);

  final entriesByDay = <LocalDate, List<NutritionEntry>>{};
  for (final entry in nutritionEntries) {
    if (!inWindow(entry.day)) continue;
    entriesByDay.putIfAbsent(entry.day, () => <NutritionEntry>[]).add(entry);
  }

  final checkinByDay = <LocalDate, DailyCheckin>{};
  for (final checkin in checkins) {
    if (!inWindow(checkin.day)) continue;
    checkinByDay.putIfAbsent(checkin.day, () => checkin);
  }

  final sessionsByDay = <LocalDate, List<ObservedSession>>{};
  for (final activity in activities) {
    final day = LocalDate.fromDateTime(activity.startedAt.toLocal());
    if (!inWindow(day)) continue;
    sessionsByDay
        .putIfAbsent(day, () => <ObservedSession>[])
        .add(observedSessionFor(activity));
  }

  final observations = <DailyObservation>[];
  for (var day = start; !day.isAfter(today); day = day.addDays(1)) {
    final dayEntries = entriesByDay[day];
    final checkin = checkinByDay[day];
    final phase = phaseByDay[day];

    observations.add(
      DailyObservation(
        day: day,
        energy: checkin?.energy,
        sleep: checkin?.sleep,
        soreness: checkin?.soreness,
        stress: checkin?.stress,
        pain: checkin?.pain,
        proteinGrams: dayEntries == null
            ? null
            : computeDayTotals(dayEntries).total.proteinGrams,
        // The target is "in force on this day" whether or not she logged
        // against it, matching `DailyObservation.proteinTargetGrams`'s
        // meaning ("`null` when the user has set no target"). A day with a
        // target but no intake still contributes nothing: `proteinTargetMet`
        // is null unless *both* sides are present.
        proteinTargetGrams: proteinTarget,
        waterMl: waterTotalsByDay[day],
        cyclePhase: phase,
        sessions: sessionsByDay[day] ?? const <ObservedSession>[],
      ),
    );
  }

  return observations;
}

/// The protein target in force, in grams, or `null` when the user has set
/// none.
///
/// Deliberately the **same** derivation as
/// `features/nutrition/domain/fueling_consistency_evaluator.dart`: it reads
/// `NutritionGoals.proteinTargetGrams` and treats a non-positive value as
/// "no target" rather than as a target of zero. The 85% "met" fraction that
/// goes with it is not repeated here either — it lives once, in
/// `InsightThresholds.targetMetFraction`, whose dartdoc records that it
/// matches the fueling evaluator for exactly this reason. Two surfaces
/// disagreeing about whether she hit her protein target on a given day
/// would be worse than either rule being slightly off.
double? resolveProteinTargetGrams(NutritionGoals? goals) {
  final target = goals?.proteinTargetGrams;
  if (target == null || target <= 0) return null;
  return target;
}

/// Reduces one [activity] to the few numbers the engine compares.
ObservedSession observedSessionFor(Activity activity) {
  return ObservedSession(
    activityType: activity.activityType,
    distanceMeters: activity.distanceMeters,
    strengthTonnageKg: completedTonnageKg(activity.workoutDetails),
    perceivedExertion: statedPerceivedExertion(activity),
  );
}

/// The RPE the user actually stated for [activity], or `null` when she was
/// never asked or did not answer.
///
/// `MindfulWorkoutDetails.rpe` and `GeneralWorkoutDetails.rpe` (see
/// `features/activity/domain/workout_details.dart`) are nullable `int?`s
/// with no default, and their `fromJson` no longer coalesces an absent key
/// to 6 — which is what makes this mapping possible at all.
/// `StrengthWorkoutDetails`, `HiitWorkoutDetails` and `SwimWorkoutDetails`
/// carry no RPE, so for those there is nothing to map even in principle.
///
/// **Honest caveat about older rows.** Sessions written *before* that
/// change stored a hard `6` whether or not she chose it, so those rows are
/// indistinguishable from a genuine 6 and will be read as stated values
/// here. That is accepted rather than worked around: the app is pre-release
/// with no real user data, and any exertion comparison still has to clear
/// `InsightThresholds.minPairedObservations` (10 pairs) plus the
/// effect-size gates, which a constant 6 across every legacy row cannot do
/// — a group with no spread produces no relative difference.
///
/// `ObservedSession.perceivedExertion`'s dartdoc states the rule this
/// upholds: an assumed value must never be fed in, because the engine would
/// find a pattern in its own defaults and report it back to her as a fact
/// about her body.
int? statedPerceivedExertion(Activity activity) {
  return switch (activity.workoutDetails) {
    MindfulWorkoutDetails(:final rpe) => rpe,
    GeneralWorkoutDetails(:final rpe) => rpe,
    _ => null,
  };
}

/// Completed strength volume for [details] in kilograms, or `null` when it
/// is not a strength session or recorded no sets at all.
///
/// Only sets marked completed are counted, via
/// `StrengthWorkoutDetails.completedVolumeKg` — the one shared definition
/// of "tonnage lifted", which
/// `features/recaps/domain/recap_builder.dart` uses too. It matches
/// [DailyObservation]'s "sum of `reps x weightKg` over completed sets",
/// unlike `StrengthWorkoutDetails.totalVolumeKg`, which includes
/// planned-but-unfinished sets and would overstate what she actually
/// lifted. A session whose sets were all bodyweight totals zero kilograms
/// and is reported as `null` by `DailyObservation._sumStrengthTonnage`
/// anyway; the distinction that matters here is "recorded no sets" versus
/// "recorded sets" — which is what the `totalSets` check below carries
/// (`totalSets` counts completed sets).
double? completedTonnageKg(WorkoutDetails? details) {
  if (details is! StrengthWorkoutDetails) return null;
  if (details.totalSets == 0) return null;
  return details.completedVolumeKg;
}
