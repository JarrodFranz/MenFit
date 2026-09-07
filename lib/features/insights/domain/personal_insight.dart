import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';

/// Which pairing of the user's own logs an insight was drawn from.
///
/// The name says *what was compared with what*, never *what caused what* —
/// see [PersonalInsight] for why that distinction is structural here.
enum InsightKind {
  /// Days after a day whose protein target was met, versus days after a
  /// day whose protein target was not met.
  proteinTargetNextDayOutput,

  /// Days with a higher logged sleep score versus a lower one.
  sleepScoreSameDayOutput,

  /// Days with a higher logged energy score versus a lower one.
  energyScoreSameDayOutput,

  /// One cycle phase's sessions versus every other phase's, measured by
  /// perceived exertion.
  cyclePhaseExertion,

  /// One cycle phase's sessions versus every other phase's, measured by
  /// training output.
  cyclePhaseOutput,

  /// Days whose hydration target was met versus days it was not.
  hydrationTargetSameDayOutput,
}

/// The quantity an insight measured.
///
/// Note the absence of any "higher is better" flag. None of these has a
/// good direction: a shorter run is not a failure and a higher RPE is not
/// a fault, and encoding a direction here would leak a judgement into
/// every sentence the UI builds.
enum InsightMetric {
  /// Total distance of that day's runs, in metres.
  runDistanceMeters,

  /// Total completed strength tonnage for that day, in kilograms
  /// (reps x weight, matching
  /// `features/activity/domain/workout_details.dart`'s `volumeKg`).
  strengthTonnageKg,

  /// That day's typical rating of perceived exertion, 1-10.
  perceivedExertion,
}

/// One side of a comparison, named structurally rather than in prose.
///
/// The UI turns these into words. Keeping them as enum values is what
/// stops a sentence like "because you ate more protein" from ever being
/// constructible in the domain layer.
enum InsightGroup {
  proteinTargetMet,
  proteinTargetNotMet,
  higherSleepScore,
  lowerSleepScore,
  higherEnergyScore,
  lowerEnergyScore,
  hydrationTargetMet,
  hydrationTargetNotMet,

  /// The single cycle phase an insight singled out. Read
  /// [PersonalInsight.cyclePhase] for which one.
  cyclePhaseFocus,

  /// Every logged cycle phase other than [cyclePhaseFocus], pooled.
  otherCyclePhases,
}

/// How firmly the user's own data separates the two groups.
///
/// Deliberately **not** a p-value and **not** a percentage "accuracy".
/// Both would invite reading a personal, uncontrolled, self-reported
/// pattern as a test result. These two words say only how much data there
/// is and how cleanly it splits.
enum InsightConfidence {
  /// Clears every gate, but only just — a pattern worth noticing, not a
  /// settled fact about her.
  emerging,

  /// A large sample with a large, clean separation.
  clear,
}

/// A descriptive pattern found in the user's **own** logged data.
///
/// ## This type cannot express causation, by construction
///
/// There is no free-text field anywhere on it. Everything is an enum, a
/// count, a date, or a number, so the domain layer has no way to write
/// "because", "this will improve", "you should", or any statement about
/// women in general. The UI composes a sentence from these parts, and the
/// parts it is given only support the shape *"across N logged days, X
/// measured Y% higher than Z"*.
///
/// [pairedObservations] is exported precisely so the sentence can always
/// carry its own sample size. An insight shown without it would be a
/// stronger claim than the data supports.
///
/// ## Privacy
///
/// This object is built from S2 and S3 data
/// (`knowledge/engineering/security_and_privacy.md`) — nutrition logs,
/// check-in scores, and cycle phase. It deliberately has **no
/// `toString()` override**, so an accidental interpolation into a log line
/// or exception message yields an opaque instance rather than the user's
/// numbers. Do not add one.
class PersonalInsight {
  const PersonalInsight({
    required this.kind,
    required this.metric,
    required this.higherGroup,
    required this.lowerGroup,
    required this.higherTypicalValue,
    required this.lowerTypicalValue,
    required this.higherGroupCount,
    required this.lowerGroupCount,
    required this.relativeDifference,
    required this.effectSize,
    required this.pairedObservations,
    required this.confidence,
    required this.rangeStart,
    required this.rangeEnd,
    this.cyclePhase,
  });

  /// Which pairing this came from.
  final InsightKind kind;

  /// What was measured.
  final InsightMetric metric;

  /// The group whose typical value was the larger of the two.
  final InsightGroup higherGroup;

  /// The group whose typical value was the smaller of the two.
  final InsightGroup lowerGroup;

  /// [higherGroup]'s **median** value of [metric]. A median, not a mean,
  /// so a single unusual session cannot set the number the user reads
  /// (`domain/insight_statistics.dart`).
  final double higherTypicalValue;

  /// [lowerGroup]'s median value of [metric].
  final double lowerTypicalValue;

  /// How many retained days fell in [higherGroup].
  final int higherGroupCount;

  /// How many retained days fell in [lowerGroup].
  final int lowerGroupCount;

  /// ([higherTypicalValue] - [lowerTypicalValue]) / [lowerTypicalValue].
  /// Always positive, and always at least
  /// `InsightThresholds.minRelativeDifference`.
  final double relativeDifference;

  /// Absolute Cliff's delta between the two groups, 0-1 — the
  /// outlier-resistant measure of how far the two groups separate.
  final double effectSize;

  /// Total complete pairs retained after incomplete days were dropped.
  /// Equals [higherGroupCount] + [lowerGroupCount].
  final int pairedObservations;

  /// How firmly the data separates. Never a probability.
  final InsightConfidence confidence;

  /// Earliest day contributing a retained observation.
  final LocalDate rangeStart;

  /// Latest day contributing a retained observation.
  final LocalDate rangeEnd;

  /// The phase [higherGroup] or [lowerGroup] refers to when either of them
  /// is [InsightGroup.cyclePhaseFocus]. Non-null exactly for
  /// [InsightKind.cyclePhaseExertion] and [InsightKind.cyclePhaseOutput],
  /// and never [CyclePhase.none].
  final CyclePhase? cyclePhase;
}
