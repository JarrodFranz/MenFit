import 'dart:math' as math;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

/// Mandatory disclaimer copy required by
/// `knowledge/research/energy_expenditure_estimates.md` §7.2.
const String activityEnergyDisclaimer =
    'Estimate based on population averages. Not medical advice, and not '
    'extra food you need to eat.';

/// Sealed outcome of computing estimated energy expenditure for an activity.
sealed class ActivityEnergyOutcome {
  const ActivityEnergyOutcome();
}

/// A computed energy expenditure estimate as a coarsely rounded range.
final class ActivityEnergyEstimate extends ActivityEnergyOutcome {
  const ActivityEnergyEstimate({
    required this.minKcal,
    required this.maxKcal,
    required this.netPointEstimateKcal,
    required this.met,
    this.elevationWidened = false,
  });

  /// The lower bound of the estimated energy range (net point estimate - 20%).
  final int minKcal;

  /// The upper bound of the estimated energy range (net point estimate + 20%,
  /// plus optional elevation widening).
  final int maxKcal;

  /// The unrounded net point estimate in kcal.
  final double netPointEstimateKcal;

  /// The interpolated MET value used for this activity.
  final double met;

  /// Whether the upper bound was widened due to cumulative elevation gain.
  final bool elevationWidened;

  /// User-facing rounded range string (e.g. "220–330 kcal").
  String get rangeLabel => '$minKcal–$maxKcal kcal';
}

/// No estimate could be calculated because required profile inputs are missing.
final class NoActivityEnergyBasis extends ActivityEnergyOutcome {
  const NoActivityEnergyBasis(this.reason);

  final String reason;
}

/// Linear interpolation data point for speed -> MET.
class _SpeedMetPoint {
  const _SpeedMetPoint(this.speedKmh, this.met);
  final double speedKmh;
  final double met;
}

/// 2024 Compendium of Physical Activities speed bands (measured values).
const List<_SpeedMetPoint> _runningBands = [
  _SpeedMetPoint(6.4, 6.5),
  _SpeedMetPoint(8, 8.5),
  _SpeedMetPoint(9.7, 9.3),
  _SpeedMetPoint(10.8, 10.5),
  _SpeedMetPoint(11.3, 11),
  _SpeedMetPoint(12.1, 11.8),
  _SpeedMetPoint(12.9, 12),
  _SpeedMetPoint(14.5, 13),
  _SpeedMetPoint(16.1, 14.8),
];

const List<_SpeedMetPoint> _walkingBands = [
  _SpeedMetPoint(2.5, 2.3),
  _SpeedMetPoint(3.5, 2.8),
  _SpeedMetPoint(4, 3),
  _SpeedMetPoint(5, 3.8),
  _SpeedMetPoint(6, 4.8),
  _SpeedMetPoint(6.8, 5.5),
  _SpeedMetPoint(7.5, 7),
  _SpeedMetPoint(8.5, 8.5),
];

const List<_SpeedMetPoint> _hikingBands = [
  _SpeedMetPoint(3, 3.8),
  _SpeedMetPoint(4.5, 5.3),
  _SpeedMetPoint(6, 6),
];

const List<_SpeedMetPoint> _cyclingBands = [
  _SpeedMetPoint(14, 4),
  _SpeedMetPoint(17.5, 6.8),
  _SpeedMetPoint(20.5, 8),
  _SpeedMetPoint(23.5, 10),
  _SpeedMetPoint(28, 12),
];

/// Linearly interpolates MET from [bands] for a given [speedKmh].
double _interpolateMet(double speedKmh, List<_SpeedMetPoint> bands) {
  if (bands.isEmpty) return 1;
  if (speedKmh <= bands.first.speedKmh) return bands.first.met;
  if (speedKmh >= bands.last.speedKmh) return bands.last.met;

  for (var i = 0; i < bands.length - 1; i++) {
    final p1 = bands[i];
    final p2 = bands[i + 1];
    if (speedKmh >= p1.speedKmh && speedKmh <= p2.speedKmh) {
      final t = (speedKmh - p1.speedKmh) / (p2.speedKmh - p1.speedKmh);
      return p1.met + t * (p2.met - p1.met);
    }
  }
  return bands.last.met;
}

/// Resolves the interpolated MET for an [activityType] at [speedKmh].
double resolveActivityMet(ActivityType activityType, double speedKmh) {
  return switch (activityType) {
    ActivityType.run => _interpolateMet(speedKmh, _runningBands),
    ActivityType.walk => _interpolateMet(speedKmh, _walkingBands),
    ActivityType.hike => _interpolateMet(speedKmh, _hikingBands),
    ActivityType.ride => _interpolateMet(speedKmh, _cyclingBands),
    ActivityType.strength => 5.0,
    ActivityType.yoga => 3.0,
    ActivityType.hiit => 8.0,
    ActivityType.pilates => 3.5,
    ActivityType.swim => 6.0,
    ActivityType.other => 4.5,
  };
}

/// Estimates energy expenditure for [activity] given user [profile] on
/// [referenceDate].
///
/// Implements `knowledge/research/energy_expenditure_estimates.md`:
/// - Formula: `netKcal = (MET × bodyMassKg × hours) − (bmr / 1440) × minutes`
/// - Rounded range (±20%), with ascent widening the upper bound.
/// - Requires valid weight and Mifflin-St Jeor BMR; returns
///   [NoActivityEnergyBasis] otherwise.
ActivityEnergyOutcome estimateActivityEnergy({
  required Activity activity,
  required UserProfile profile,
  required DateTime referenceDate,
}) {
  final weightKg = profile.weightKg;
  if (weightKg == null || weightKg <= 0) {
    return const NoActivityEnergyBasis(
      'Add your weight in your profile to estimate energy used.',
    );
  }

  // Need user's Mifflin-St Jeor BMR for net energy calculation
  final bmrResult = estimateEnergyNeedsForProfile(
    profile: profile,
    activityLevel: ActivityLevel.sedentary,
    today: LocalDate.fromDateTime(referenceDate),
  );

  final double bmrPerDay;
  if (bmrResult is EnergyEstimate) {
    bmrPerDay = bmrResult.basalMetabolicRateKcal;
  } else {
    return const NoActivityEnergyBasis(
      'Add your date of birth and height to complete your energy estimate.',
    );
  }

  final movingSeconds = activity.movingTime.inSeconds;
  if (movingSeconds <= 0) {
    return const ActivityEnergyEstimate(
      minKcal: 0,
      maxKcal: 0,
      netPointEstimateKcal: 0,
      met: 1,
    );
  }

  final hours = movingSeconds / 3600.0;
  final minutes = movingSeconds / 60.0;
  final speedKmh = activity.avgSpeedKmh;
  final met = resolveActivityMet(activity.activityType, speedKmh);

  // Gross energy (kcal)
  final grossKcal = met * weightKg * hours;

  // Resting energy during moving time (kcal)
  final restingKcal = (bmrPerDay / 1440.0) * minutes;

  // Net energy (kcal)
  final netKcal = math.max<double>(0, grossKcal - restingKcal);

  // ±20% base range
  final minKcal = (netKcal * 0.80).round();
  var maxKcal = (netKcal * 1.20).round();

  // Elevation ascent adjustment (widens upper bound only, §6.4)
  var elevationWidened = false;
  final elevationGain = activity.elevationGainMeters;
  if (elevationGain != null && elevationGain > 10) {
    // Walking/hiking: 0.009 kcal/kg/m; Running/cycling: 0.0045 kcal/kg/m
    final factor =
        (activity.activityType == ActivityType.walk ||
            activity.activityType == ActivityType.hike)
        ? 0.009
        : 0.0045;
    final ascentAdjustmentKcal = factor * weightKg * elevationGain;
    maxKcal = (maxKcal + ascentAdjustmentKcal).round();
    elevationWidened = true;
  }

  return ActivityEnergyEstimate(
    minKcal: minKcal,
    maxKcal: maxKcal,
    netPointEstimateKcal: netKcal,
    met: met,
    elevationWidened: elevationWidened,
  );
}

/// Computes net active calories burned (in kcal) for a collection of
/// activities.
///
/// Uses the evidence-based [estimateActivityEnergy] calculation when profile
/// BMR is available; otherwise falls back to standard 2024 Compendium METs
/// with net energy adjustment and reference body mass (65 kg).
double calculateTotalActiveCaloriesKcal({
  required Iterable<Activity> activities,
  required UserProfile? profile,
  required DateTime referenceDate,
}) {
  var totalKcal = 0.0;
  for (final activity in activities) {
    if (profile != null) {
      final estimate = estimateActivityEnergy(
        activity: activity,
        profile: profile,
        referenceDate: referenceDate,
      );
      if (estimate is ActivityEnergyEstimate) {
        totalKcal += estimate.netPointEstimateKcal;
        continue;
      }
    }

    final seconds = activity.movingTime.inSeconds > 0
        ? activity.movingTime.inSeconds
        : activity.elapsedTime.inSeconds;
    if (seconds <= 0) continue;
    final weightKg = profile?.weightKg ?? 65.0;
    final met = resolveActivityMet(
      activity.activityType,
      activity.avgSpeedKmh,
    );
    final hours = seconds / 3600.0;
    final netMet = math.max(0.5, met - 1.0);
    totalKcal += netMet * weightKg * hours;
  }
  return totalKcal;
}
