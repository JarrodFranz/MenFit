import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';

part 'nutrition_goals.freezed.dart';

/// The user's nutrition targets and nutrition-display preferences.
///
/// Mirrors `core/db/tables/nutrition_goals.dart` one field at a time; the
/// Drift row is mapped in `data/drift_nutrition_goals_repository.dart` so
/// the Drift type never leaks above the data layer.
///
/// Single-row: exactly one of these exists (or none, before the user has
/// touched anything — the repository reports that as `null`, and every
/// field below documents its own "not set" meaning).
///
/// **Every target is optional.** No target is a valid, permanent state: the
/// diary works entirely without one, which is deliberate
/// (`knowledge/domain/nutrition.md`'s ED-safe stance — adequacy first, no
/// pressure to name a number).
///
/// [dailyDeficitKcal] and [weightGoal] hold the user's **request**, never
/// the resolved answer: `domain/calorie_target.dart` resolves them against
/// the energy estimate and applies the BMR floor. Storing the request is
/// what lets the app re-explain the floor whenever the estimate moves.
///
/// The macro targets exist in **two independent representations** — grams
/// and percentages of the day's energy — held side by side, with
/// [macroTargetMode] naming which one is authoritative. Neither is written
/// from the other, so switching modes never destroys what the other one
/// held; `domain/macro_targets.dart` turns a split into grams on demand.
///
/// [macroLocks] pins gram targets the user wants left alone, which is what
/// lets the app work out the third from the other two and their calorie
/// target. It is stored for the same reason the targets themselves are: a
/// lock that vanished on reopen would stop the free macro tracking a changed
/// calorie target, which is the entire point of locking one.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, never in analytics, never in an exception message.
@freezed
abstract class NutritionGoals with _$NutritionGoals {
  const factory NutritionGoals({
    required String id,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// Daily energy target in kilocalories. `null` means none set.
    int? calorieTargetKcal,

    /// Daily protein target in grams. `null` means none set.
    double? proteinTargetGrams,

    /// Daily carbohydrate target in grams. `null` means none set.
    double? carbTargetGrams,

    /// Daily fat target in grams. `null` means none set.
    double? fatTargetGrams,

    /// Which of the two macro representations counts. Defaults to
    /// [MacroTargetMode.grams] — what every row written before this field
    /// existed already means.
    @Default(MacroTargetMode.grams) MacroTargetMode macroTargetMode,

    /// Daily protein target as a percentage of the day's energy target,
    /// 0-100. `null` means none set. Only authoritative when
    /// [macroTargetMode] is [MacroTargetMode.percent].
    double? proteinTargetPercent,

    /// Daily carbohydrate target as a percentage of the day's energy
    /// target, 0-100. `null` means none set.
    double? carbTargetPercent,

    /// Daily fat target as a percentage of the day's energy target, 0-100.
    /// `null` means none set.
    double? fatTargetPercent,

    /// Which gram targets the user has pinned, so the one they left free can
    /// be worked out from their calorie target
    /// (`domain/macro_targets.dart#solveMacroTargets`). Defaults to
    /// [MacroLocks.none] — nothing is locked until they say so, and nothing
    /// is prefilled.
    ///
    /// Only meaningful in [MacroTargetMode.grams]; a percentage split is
    /// already determined by its own add-to-100 rule.
    @Default(MacroLocks.none) MacroLocks macroLocks,

    /// The user's typical activity level, for the TDEE estimate. `null`
    /// means never chosen, and no TDEE is estimated.
    ActivityLevel? activityLevel,

    /// When `true`, the app shows the food diary without calorie figures.
    /// A display preference only — calories are still recorded, so turning
    /// it off again loses nothing.
    @Default(false) bool hideCalorieNumbers,

    /// Which way the user wants their weight to go. Defaults to
    /// [WeightGoal.maintain]; the app never assumes otherwise.
    @Default(WeightGoal.maintain) WeightGoal weightGoal,

    /// The daily energy gap the user asked for, as a **magnitude** in
    /// kilocalories — [weightGoal] carries the direction. `0` means no gap.
    @Default(0) int dailyDeficitKcal,
  }) = _NutritionGoals;

  const NutritionGoals._();

  /// The three macro targets **in grams**, whichever way the user chose to
  /// state them, against a day energy basis of [basisKcal].
  ///
  /// The diary measures intake in grams, so every surface that shows "X of
  /// Y g" has to go through here rather than reading
  /// [proteinTargetGrams] and friends directly — those are only populated in
  /// [MacroTargetMode.grams] mode, and a percent-mode goal read that way
  /// silently shows no target at all.
  ///
  /// Percent-mode grams are **derived here, never stored**
  /// (`domain/macro_targets.dart`): the whole point of stating a target as a
  /// share is that it moves when the energy target moves, which a stored
  /// snapshot would not do.
  ///
  /// All three come back `null` when a percent-mode goal has no energy basis
  /// to work from ([basisKcal] absent or non-positive). That is the honest
  /// answer rather than zero: a share of nothing is not a target of nothing.
  ({double? protein, double? carbs, double? fat}) macroTargetGramsFor(
    int? basisKcal,
  ) {
    if (macroTargetMode == MacroTargetMode.grams) {
      return (
        protein: proteinTargetGrams,
        carbs: carbTargetGrams,
        fat: fatTargetGrams,
      );
    }
    if (basisKcal == null || basisKcal <= 0) {
      return (protein: null, carbs: null, fat: null);
    }
    return (
      protein: macroGramsForPercent(
        basisKcal: basisKcal,
        percent: proteinTargetPercent,
        kcalPerGram: proteinKcalPerGram,
      ),
      carbs: macroGramsForPercent(
        basisKcal: basisKcal,
        percent: carbTargetPercent,
        kcalPerGram: carbKcalPerGram,
      ),
      fat: macroGramsForPercent(
        basisKcal: basisKcal,
        percent: fatTargetPercent,
        kcalPerGram: fatKcalPerGram,
      ),
    );
  }

  /// Whether the user has set any target at all. The UI uses this to tell
  /// "hasn't set targets" apart from "set them and cleared them", without
  /// having to know which fields exist.
  ///
  /// Only the macro set [macroTargetMode] names counts. The other set may
  /// still hold numbers from before a mode switch, and those are kept
  /// (nothing the user typed is thrown away) but they are not targets while
  /// the other mode is the authoritative one.
  bool get hasAnyTarget =>
      calorieTargetKcal != null || _hasAnyAuthoritativeMacroTarget;

  bool get _hasAnyAuthoritativeMacroTarget => switch (macroTargetMode) {
    MacroTargetMode.grams =>
      proteinTargetGrams != null ||
          carbTargetGrams != null ||
          fatTargetGrams != null,
    MacroTargetMode.percent =>
      proteinTargetPercent != null ||
          carbTargetPercent != null ||
          fatTargetPercent != null,
  };
}
