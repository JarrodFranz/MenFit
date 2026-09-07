import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/insights/domain/insight_statistics.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// One completed session, reduced to the few numbers the engine can
/// compare across days.
///
/// A plain DTO rather than an `Activity`: the engine must stay trivially
/// testable and must not depend on repositories, Drift rows, or the
/// activity feature's data layer. The mapping from `Activity` (and its
/// `WorkoutDetails`) lives with whoever calls the engine.
class ObservedSession {
  const ObservedSession({
    required this.activityType,
    this.distanceMeters = 0,
    this.strengthTonnageKg,
    this.perceivedExertion,
  });

  final ActivityType activityType;

  /// Distance covered, in metres. `0` for non-distance sessions.
  final double distanceMeters;

  /// Completed strength volume in kilograms (sum of `reps x weightKg`
  /// over completed sets). `null` when the session recorded no sets —
  /// which is not the same as a session of zero tonnage.
  final double? strengthTonnageKg;

  /// Rating of perceived exertion, 1-10, **as the user actually stated
  /// it**.
  ///
  /// Must be `null` whenever the value was never answered. The workout
  /// detail types in `features/activity/domain/workout_details.dart`
  /// store `rpe` as nullable (since 2026-09-01): `null` means "never
  /// asked", so a caller maps the stored value straight through. Rows
  /// written before that change stored a hard default of 6 and are
  /// indistinguishable from a genuine 6 - accepted because the app is
  /// pre-release and a constant produces no spread, so it cannot clear
  /// the engine's gates anyway. Feeding assumed values in here would let
  /// the engine find a pattern in its own defaults.
  final int? perceivedExertion;
}

/// Everything the engine knows about one calendar day.
///
/// Every field beyond [day] is nullable or empty-able, because every one
/// of them genuinely can be missing: check-in scores are individually
/// optional, nutrition may not be logged, and most days have no session at
/// all. The engine drops incomplete pairs rather than imputing — see
/// [metricValue].
///
/// S2/S3 data (`knowledge/engineering/security_and_privacy.md`). No
/// `toString()` override, for the same reason as [PersonalInsight].
class DailyObservation {
  const DailyObservation({
    required this.day,
    this.energy,
    this.sleep,
    this.soreness,
    this.stress,
    this.pain,
    this.proteinGrams,
    this.proteinTargetGrams,
    this.waterMl,
    this.waterTargetMl,
    this.sessions = const <ObservedSession>[],
  });

  final LocalDate day;

  /// Check-in energy, 1-5, higher is better. `null` when not answered.
  final int? energy;

  /// Check-in sleep, 1-5, higher is better. `null` when not answered.
  final int? sleep;

  /// Check-in soreness, 1-5, higher is worse. `null` when not answered.
  final int? soreness;

  /// Check-in stress, 1-5, higher is worse. `null` when not answered.
  final int? stress;

  /// Check-in pain, 1-5, higher is worse. `null` when not answered.
  final int? pain;

  /// Protein logged for the day, in grams. `null` when nothing was logged
  /// — distinct from a logged day that happened to total zero.
  final double? proteinGrams;

  /// The protein target in force on this day, in grams. `null` when the
  /// user has set no target, in which case no "met / not met" split
  /// exists and the protein evaluator stays silent.
  final double? proteinTargetGrams;

  /// Water logged for the day, in millilitres. `null` when nothing was
  /// logged.
  final int? waterMl;

  /// The hydration target in force on this day, in millilitres. `null`
  /// when the user has set no target.
  final int? waterTargetMl;

  /// Sessions completed on this day. Empty for a rest day.
  final List<ObservedSession> sessions;

  /// Whether the day's protein reached
  /// `InsightThresholds.targetMetFraction` of its target. `null` when
  /// either the intake or the target is missing — the day is then dropped
  /// rather than counted as "not met", because an unlogged day is not a
  /// day she ate nothing.
  bool? proteinTargetMet(double metFraction) {
    final grams = proteinGrams;
    final target = proteinTargetGrams;
    if (grams == null || target == null || target <= 0) return null;
    return grams >= target * metFraction;
  }

  /// Whether the day's water reached [metFraction] of its target. `null`
  /// when either side is missing, for the same reason as
  /// [proteinTargetMet].
  bool? hydrationTargetMet(double metFraction) {
    final ml = waterMl;
    final target = waterTargetMl;
    if (ml == null || target == null || target <= 0) return null;
    return ml >= target * metFraction;
  }

  /// This day's value of [metric], or `null` when the day cannot supply
  /// one.
  ///
  /// A day with no qualifying session yields `null`, **never zero**. A
  /// rest day is not a day of zero output; folding rest days in as zeros
  /// would turn every one of these comparisons into a measurement of how
  /// often she trained rather than of what the session looked like when
  /// she did.
  double? metricValue(InsightMetric metric) {
    return switch (metric) {
      InsightMetric.runDistanceMeters => _sumRunDistance(),
      InsightMetric.strengthTonnageKg => _sumStrengthTonnage(),
      InsightMetric.perceivedExertion => _typicalExertion(),
    };
  }

  double? _sumRunDistance() {
    var total = 0.0;
    var found = false;
    for (final session in sessions) {
      if (session.activityType != ActivityType.run) continue;
      if (session.distanceMeters <= 0) continue;
      total += session.distanceMeters;
      found = true;
    }
    return found ? total : null;
  }

  double? _sumStrengthTonnage() {
    var total = 0.0;
    var found = false;
    for (final session in sessions) {
      if (session.activityType != ActivityType.strength) continue;
      final tonnage = session.strengthTonnageKg;
      if (tonnage == null || tonnage <= 0) continue;
      total += tonnage;
      found = true;
    }
    return found ? total : null;
  }

  /// The median RPE of the day's sessions that stated one — a median so a
  /// single brutal interval session does not redefine the whole day.
  double? _typicalExertion() {
    final values = <double>[];
    for (final session in sessions) {
      final rpe = session.perceivedExertion;
      if (rpe == null) continue;
      values.add(rpe.toDouble());
    }
    return median(values);
  }
}
