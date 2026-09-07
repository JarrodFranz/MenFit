import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

/// How active a user's typical day is, outside of the app's own logged
/// activities — the multiplier a TDEE estimate applies to an estimated BMR.
///
/// The factors are the conventional Mifflin-St Jeor activity multipliers
/// (1.2 to 1.9). They are coarse by nature: see
/// `knowledge/research/nutrition_energy_estimates.md` for what that costs
/// in accuracy and why we still use them. Never inferred — the user picks,
/// and `null` (no level chosen) means no TDEE is estimated at all.
enum ActivityLevel {
  sedentary(1.2),
  lightlyActive(1.375),
  moderatelyActive(1.55),
  veryActive(1.725),
  extraActive(1.9);

  const ActivityLevel(this.factor);

  /// The multiplier applied to estimated BMR to reach estimated TDEE.
  final double factor;

  /// Parses the persisted string form. Returns `null` for `null` or any
  /// unrecognised value — "no level chosen" is a real state, and guessing
  /// one would silently produce an energy estimate the user never asked
  /// for.
  static ActivityLevel? fromStorage(String? value) {
    if (value == null) return null;
    return switch (value) {
      'sedentary' => ActivityLevel.sedentary,
      'lightlyActive' => ActivityLevel.lightlyActive,
      'moderatelyActive' => ActivityLevel.moderatelyActive,
      'veryActive' => ActivityLevel.veryActive,
      'extraActive' => ActivityLevel.extraActive,
      _ => null,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    ActivityLevel.sedentary => 'sedentary',
    ActivityLevel.lightlyActive => 'lightlyActive',
    ActivityLevel.moderatelyActive => 'moderatelyActive',
    ActivityLevel.veryActive => 'veryActive',
    ActivityLevel.extraActive => 'extraActive',
  };

  /// Warm, plain-English display label.
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Mostly sitting',
    ActivityLevel.lightlyActive => 'Lightly active',
    ActivityLevel.moderatelyActive => 'Moderately active',
    ActivityLevel.veryActive => 'Very active',
    ActivityLevel.extraActive => 'Extremely active',
  };

  /// One-line description of the day this level describes, so the user can
  /// recognise themselves without guessing at a number.
  String get description => switch (this) {
    ActivityLevel.sedentary => 'Desk work, little movement most days',
    ActivityLevel.lightlyActive => 'Light movement or exercise 1-3 days a week',
    ActivityLevel.moderatelyActive => 'Exercise most days, or an active job',
    ActivityLevel.veryActive => 'Hard training most days',
    ActivityLevel.extraActive =>
      'Hard training twice a day, or heavy manual work',
  };
}

/// A profile input the energy estimate needs, named so a caller can tell
/// the user exactly what is missing rather than showing a blank.
enum EnergyEstimateInput {
  dateOfBirth,
  heightCm,
  weightKg;

  /// Warm, plain-English name for this input, for a "we still need…"
  /// message. Never framed as a failure on the user's part — every profile
  /// field is optional by design (`knowledge/product/stage1_audit.md`
  /// §5.1).
  String get label => switch (this) {
    EnergyEstimateInput.dateOfBirth => 'your date of birth',
    EnergyEstimateInput.heightCm => 'your height',
    EnergyEstimateInput.weightKg => 'your weight',
  };
}

/// The result of estimating a user's energy needs: either an
/// [EnergyEstimate], or [NoEnergyEstimate] naming what's missing.
///
/// A sealed result rather than a nullable double, so a caller is forced to
/// handle "we can't estimate this" as a first-class outcome instead of
/// receiving a silent default. There is no fallback number anywhere in this
/// file — an invented default calorie figure would be exactly the kind of
/// unsourced, medical-flavoured claim `knowledge/domain/womens_health.md`
/// rule 1 forbids.
///
/// Expected outcome, not an exception (see
/// `knowledge/engineering/error_handling.md` and the typed-result
/// convention in `features/wellbeing/domain/wellbeing_validation.dart`).
sealed class EnergyEstimateResult {
  const EnergyEstimateResult();
}

/// An estimate of resting and total daily energy expenditure.
///
/// Both figures are **estimates**, never measurements, and never medical
/// advice — see `knowledge/research/nutrition_energy_estimates.md` for the
/// documented error margins the UI must not paper over.
final class EnergyEstimate extends EnergyEstimateResult {
  const EnergyEstimate({
    required this.basalMetabolicRateKcal,
    required this.totalDailyEnergyKcal,
    required this.activityLevel,
  });

  /// Estimated basal metabolic rate — the energy the body uses at complete
  /// rest, per day, in kilocalories. Also the **floor** the daily calorie
  /// target is never allowed below (see `domain/calorie_target.dart`).
  final double basalMetabolicRateKcal;

  /// Estimated total daily energy expenditure: BMR times the activity
  /// factor, in kilocalories. The "maintenance" figure a deficit is
  /// subtracted from.
  final double totalDailyEnergyKcal;

  /// The activity level the TDEE was computed with.
  final ActivityLevel activityLevel;
}

/// No estimate could be made, because [missing] inputs are absent from the
/// profile (or an activity level was never chosen).
///
/// Carrying the specific inputs — rather than just "no" — is what lets the
/// UI say "add your height and we can estimate this" instead of showing an
/// unexplained blank.
final class NoEnergyEstimate extends EnergyEstimateResult {
  const NoEnergyEstimate({
    required this.missing,
    required this.activityLevelMissing,
  });

  /// Which profile inputs are absent. Empty only when the sole missing
  /// piece was the activity level.
  final Set<EnergyEstimateInput> missing;

  /// Whether the user hasn't chosen an [ActivityLevel] yet. Tracked
  /// separately from [missing] because it lives in nutrition goals, not in
  /// the profile, so the UI sends the user somewhere different to fix it.
  final bool activityLevelMissing;
}

/// Estimates BMR and TDEE with the **Mifflin-St Jeor** equation, using its
/// **female coefficients**.
///
/// ```text
/// BMR  = (10 × weightKg) + (6.25 × heightCm) − (5 × age) − 161
/// TDEE = BMR × activityLevel.factor
/// ```
///
/// **Why the female coefficients, stated plainly:** Mifflin-St Jeor has two
/// variants that differ only in their final constant (−161 for women, +5
/// for men). This app's population is women, and the profile deliberately
/// does not collect sex — so rather than guess per user, or ask a question
/// the product decided not to ask, the female variant is applied
/// uniformly. That is an assumption, and it has limits: for a user the
/// equation's female variant doesn't fit, the estimate will be low by
/// roughly 166 kcal/day. It is stated here, in
/// `knowledge/research/nutrition_energy_estimates.md`, and must be stated
/// in the UI too.
///
/// Returns [NoEnergyEstimate] when any input is absent — or present but
/// nonsensical (a non-positive height, weight, or age, which can only come
/// from corrupt or imported data). A missing input never falls back to a
/// default: see [EnergyEstimateResult]'s dartdoc.
///
/// Pure: no clock read, no I/O. Callers pass [ageYears] already derived
/// (see [estimateEnergyNeedsForProfile], which derives it from the
/// profile's date of birth via the existing `UserProfile.ageOn`).
EnergyEstimateResult estimateEnergyNeeds({
  required int? ageYears,
  required double? heightCm,
  required double? weightKg,
  required ActivityLevel? activityLevel,
}) {
  // Locals so the null checks below promote — a non-positive value is
  // treated exactly like an absent one (it can only come from corrupt or
  // imported data, and there is no sane estimate to make from it).
  final age = ageYears;
  final height = heightCm;
  final weight = weightKg;

  final missing = <EnergyEstimateInput>{
    if (age == null || age <= 0) EnergyEstimateInput.dateOfBirth,
    if (height == null || height <= 0) EnergyEstimateInput.heightCm,
    if (weight == null || weight <= 0) EnergyEstimateInput.weightKg,
  };
  if (age == null ||
      height == null ||
      weight == null ||
      activityLevel == null ||
      missing.isNotEmpty) {
    return NoEnergyEstimate(
      missing: missing,
      activityLevelMissing: activityLevel == null,
    );
  }

  final bmr = (10 * weight) + (6.25 * height) - (5 * age) - _femaleConstant;
  return EnergyEstimate(
    basalMetabolicRateKcal: bmr,
    totalDailyEnergyKcal: bmr * activityLevel.factor,
    activityLevel: activityLevel,
  );
}

/// Mifflin-St Jeor's female constant, subtracted from the weight/height/age
/// terms. The male variant adds 5 instead; see [estimateEnergyNeeds]'s
/// dartdoc for why only this one is used.
const double _femaleConstant = 161;

/// [estimateEnergyNeeds] over a [UserProfile], deriving age from
/// [UserProfile.dateOfBirth] via the existing [UserProfile.ageOn] (leap-day
/// rules and all) rather than re-implementing calendar arithmetic here.
///
/// A `null` [profile] — no profile saved yet — reports every profile input
/// as missing, which is exactly what the UI needs to say.
///
/// Depends on `profile`'s `domain/` only, which
/// `knowledge/architecture/architecture_overview.md` rule 2 permits.
EnergyEstimateResult estimateEnergyNeedsForProfile({
  required UserProfile? profile,
  required ActivityLevel? activityLevel,
  required LocalDate today,
}) {
  return estimateEnergyNeeds(
    ageYears: profile?.ageOn(today),
    heightCm: profile?.heightCm,
    weightKg: profile?.weightKg,
    activityLevel: activityLevel,
  );
}
