import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';

/// Which direction the user wants their weight to go.
///
/// Defaults to [maintain] everywhere: the app never assumes a user wants to
/// lose weight (`knowledge/domain/nutrition.md`'s ED-safe stance).
enum WeightGoal {
  maintain,
  lose,
  gain;

  /// Parses the persisted string form, defaulting to [maintain] for `null`
  /// or any unrecognised value — the neutral reading.
  static WeightGoal fromStorage(String? value) {
    return switch (value) {
      'lose' => WeightGoal.lose,
      'gain' => WeightGoal.gain,
      _ => WeightGoal.maintain,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    WeightGoal.maintain => 'maintain',
    WeightGoal.lose => 'lose',
    WeightGoal.gain => 'gain',
  };

  /// Warm, plain-English display label. Deliberately about the direction,
  /// never about the user.
  String get label => switch (this) {
    WeightGoal.maintain => 'Stay where I am',
    WeightGoal.lose => 'Lose weight',
    WeightGoal.gain => 'Gain weight',
  };

  /// The sign this goal applies to the requested daily gap: `-1` for a
  /// deficit, `+1` for a surplus, `0` when maintaining.
  int get adjustmentSign => switch (this) {
    WeightGoal.maintain => 0,
    WeightGoal.lose => -1,
    WeightGoal.gain => 1,
  };
}

/// The outcome of turning an energy estimate plus a requested weight goal
/// into a daily calorie target.
///
/// A sealed result, not an exception and not a bare number: the "we
/// wouldn't go that low" case has to reach the UI as something it can
/// *explain*, carrying the floor it applied and why (see
/// [FlooredCalorieTarget]). Same typed-result convention as
/// `features/wellbeing/domain/wellbeing_validation.dart`.
sealed class CalorieTargetOutcome {
  const CalorieTargetOutcome();
}

/// A target the requested goal produced as-is.
final class CalorieTarget extends CalorieTargetOutcome {
  const CalorieTarget({
    required this.targetKcal,
    required this.maintenanceKcal,
    required this.appliedAdjustmentKcal,
  });

  /// The daily energy target, in kilocalories.
  final int targetKcal;

  /// Estimated TDEE — the "no change" figure this target moves away from.
  final int maintenanceKcal;

  /// How far [targetKcal] sits from [maintenanceKcal]: negative for a
  /// deficit, positive for a surplus, zero when maintaining.
  final int appliedAdjustmentKcal;
}

/// The requested gap would have put the daily target below the user's
/// estimated resting needs, so the target was raised to that floor.
///
/// This is product decision 2 made visible: deficits are allowed, but
/// floored, and the app must be able to say why. Everything the
/// explanation needs is carried here — no UI-side arithmetic, no second
/// source of truth for the rule.
final class FlooredCalorieTarget extends CalorieTargetOutcome {
  const FlooredCalorieTarget({
    required this.targetKcal,
    required this.requestedKcal,
    required this.floorKcal,
    required this.maintenanceKcal,
    required this.requestedAdjustmentKcal,
  });

  /// The daily energy target actually produced — always equal to
  /// [floorKcal].
  final int targetKcal;

  /// What the requested gap would have produced, had it not been floored.
  /// Below [floorKcal] by definition.
  final int requestedKcal;

  /// The floor that was applied: the user's **estimated BMR**. Anchored in
  /// the estimate this app already computes rather than a hardcoded
  /// number — see [resolveCalorieTarget]'s dartdoc.
  final int floorKcal;

  /// Estimated TDEE — the "no change" figure.
  final int maintenanceKcal;

  /// The gap the user asked for (negative — only a deficit can floor).
  final int requestedAdjustmentKcal;

  /// How much of the requested gap survived the floor, as a negative
  /// number. Between [requestedAdjustmentKcal] and `0`.
  int get effectiveAdjustmentKcal => targetKcal - maintenanceKcal;

  /// The user-facing explanation. Warm, specific, and framed as something
  /// the app won't do — never as something the user did wrong, and never
  /// as clinical advice (`knowledge/domain/womens_health.md` rule 1).
  String get explanation => floorExplanation;
}

/// The one place the floor is explained in words. Carries no numbers, so it
/// stays valid however the estimate moves, and so nothing S2-tier ends up
/// baked into a string that could reach a log.
const String floorExplanation =
    "We've set your daily calories to your estimated resting needs "
    'instead. A bigger gap than that would mean planning to eat less than '
    'your body uses at rest, and that is not something this app will '
    "suggest. It's an estimate, not medical advice — a dietitian can help "
    'you go further with this.';

/// No target could be produced, because there is no energy estimate to
/// build one from.
final class NoCalorieTarget extends CalorieTargetOutcome {
  const NoCalorieTarget(this.estimateGap);

  /// The unavailable estimate, passed straight through so the UI can tell
  /// the user which inputs are still needed rather than showing a blank.
  final NoEnergyEstimate estimateGap;
}

/// The daily calorie figure the diary compares the day's total against, and
/// — when the figure came from the BMR floor — the outcome that explains it.
///
/// Not a bare `int?` because product decision 2 says a floored target is
/// never presented silently: the day view needs to be able to say *why* the
/// number is what it is, and [floored] is what lets it.
class DayCalorieTarget {
  const DayCalorieTarget({
    this.targetKcal,
    this.floored,
    this.isEstimate = false,
  });

  /// The target to show, or `null` when there is none to show — either the
  /// user set none and no estimate could be made, or the estimate is still
  /// loading. A `null` target is a normal state: the diary works without one
  /// (`domain/nutrition_goals.dart`).
  final int? targetKcal;

  /// Set when [targetKcal] came from [resolveCalorieTarget] *and* it applied
  /// the BMR floor. `null` whenever the user's own target is in force, since
  /// then the floor didn't decide anything.
  final FlooredCalorieTarget? floored;

  /// Whether [targetKcal] came out of the energy estimate rather than off a
  /// number the user typed. Estimated figures are shown with "about" and
  /// labelled as estimates — the research review forbids presenting them as
  /// precise.
  final bool isEstimate;
}

/// Turns an [estimate] plus a requested [weightGoal]/[dailyDeficitKcal]
/// into a daily calorie target, applying the **BMR floor**.
///
/// The rule, in full:
///
/// 1. No estimate → [NoCalorieTarget]. There is no fallback number; an
///    invented default would be an unsourced medical-flavoured claim.
/// 2. Otherwise the requested target is `TDEE + sign × dailyDeficitKcal`,
///    where the sign comes from [weightGoal] ([WeightGoal.maintain] ignores
///    the requested gap entirely).
/// 3. If that requested target is **below the estimated BMR**, the target
///    becomes the BMR and the result is a [FlooredCalorieTarget] carrying
///    the floor, the request, and [floorExplanation].
/// 4. Otherwise it's a plain [CalorieTarget].
///
/// **Why BMR is the floor.** "Never target below your estimated resting
/// needs" is defensible, personal to the user, and anchored in a figure
/// this app already computes and already labels as an estimate.
/// Deliberately *not* a hardcoded number (a flat "1200 kcal" floor is an
/// unsourced, medical-flavoured claim, and is wrong in both directions for
/// real people). See `knowledge/research/nutrition_energy_estimates.md` for
/// the full rationale and its limits.
///
/// [dailyDeficitKcal] is a magnitude; a negative value is treated as zero
/// rather than quietly flipping the goal's direction. Pure — no clock, no
/// I/O.
CalorieTargetOutcome resolveCalorieTarget({
  required EnergyEstimateResult estimate,
  WeightGoal weightGoal = WeightGoal.maintain,
  int dailyDeficitKcal = 0,
}) {
  switch (estimate) {
    case NoEnergyEstimate():
      return NoCalorieTarget(estimate);
    case EnergyEstimate():
      final maintenance = estimate.totalDailyEnergyKcal.round();
      final floor = estimate.basalMetabolicRateKcal.round();
      final gap = dailyDeficitKcal < 0 ? 0 : dailyDeficitKcal;
      final adjustment = weightGoal.adjustmentSign * gap;
      final requested = maintenance + adjustment;

      if (requested < floor) {
        return FlooredCalorieTarget(
          targetKcal: floor,
          requestedKcal: requested,
          floorKcal: floor,
          maintenanceKcal: maintenance,
          requestedAdjustmentKcal: adjustment,
        );
      }
      return CalorieTarget(
        targetKcal: requested,
        maintenanceKcal: maintenance,
        appliedAdjustmentKcal: adjustment,
      );
  }
}
