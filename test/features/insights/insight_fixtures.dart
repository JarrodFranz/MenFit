import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';

/// Day 1 of every fixture. Arbitrary but fixed — nothing in the engine
/// reads a clock, so the absolute date never changes an outcome.
final LocalDate fixtureEpoch = LocalDate(2026, 3, 1);

/// The [fixtureEpoch]-relative calendar day, 1-based.
LocalDate day(int index) => fixtureEpoch.addDays(index - 1);

/// Builds one observed day. Every parameter is omitted-means-absent, which
/// is the whole point: the engine has to drop what it was not given rather
/// than substitute a zero.
DailyObservation obs(
  int index, {
  int? energy,
  int? sleep,
  double? proteinGrams,
  double? proteinTargetGrams,
  int? waterMl,
  int? waterTargetMl,
  CyclePhase? phase,
  double? runMeters,
  double? tonnageKg,
  int? rpe,
}) {
  final sessions = <ObservedSession>[
    if (runMeters != null)
      ObservedSession(
        activityType: ActivityType.run,
        distanceMeters: runMeters,
      ),
    if (tonnageKg != null)
      ObservedSession(
        activityType: ActivityType.strength,
        strengthTonnageKg: tonnageKg,
      ),
    if (rpe != null)
      ObservedSession(
        activityType: ActivityType.hiit,
        perceivedExertion: rpe,
      ),
  ];

  return DailyObservation(
    day: day(index),
    energy: energy,
    sleep: sleep,
    proteinGrams: proteinGrams,
    proteinTargetGrams: proteinTargetGrams,
    waterMl: waterMl,
    waterTargetMl: waterTargetMl,
    cyclePhase: phase,
    sessions: sessions,
  );
}

/// Turns raw values into samples on consecutive days starting at
/// [startIndex]. Only the values matter to the statistics; the days exist
/// so an insight can report the range it covers.
List<ObservationSample> samples(List<double> values, {int startIndex = 1}) {
  return [
    for (var i = 0; i < values.length; i++)
      ObservationSample(day: day(startIndex + i), value: values[i]),
  ];
}

/// [count] copies of [value].
List<double> repeated(double value, int count) =>
    List<double>.filled(count, value);
