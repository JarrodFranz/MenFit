import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';

/// Whether the user states her three macro targets directly in grams, or as
/// percentages of the day's energy target.
///
/// Both representations are stored side by side on the same row and neither
/// is derived from the other; this value is the answer to "which of the two
/// counts". That is deliberate: a user who switches to percentages and back
/// again finds the grams she typed still there, because nothing overwrote
/// them. Grams are never written from a split — [deriveMacroTargetGrams]
/// computes them on demand, so a changed calorie target moves the grams with
/// it instead of leaving a stale snapshot behind
/// (`knowledge/architecture/data_architecture.md`'s derived-vs-stored rule).
///
/// [grams] is the default everywhere. A row written before this mode existed
/// has no opinion, and grams is what its numbers already meant.
enum MacroTargetMode {
  grams,
  percent;

  /// Parses the persisted string form, defaulting to [grams] for `null` or
  /// any unrecognised value — the same convention as `FoodSource` and
  /// `WeightGoal`, and the reading that keeps every pre-v12 row meaning
  /// exactly what it meant before.
  static MacroTargetMode fromStorage(String? value) => switch (value) {
    'percent' => MacroTargetMode.percent,
    _ => MacroTargetMode.grams,
  };

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    MacroTargetMode.grams => 'grams',
    MacroTargetMode.percent => 'percent',
  };

  /// Short display label for the mode toggle.
  String get label => switch (this) {
    MacroTargetMode.grams => 'Grams',
    MacroTargetMode.percent => 'Percent',
  };
}

/// Kilocalories per gram of protein — the Atwater general factor.
///
/// The three factors below are a **unit conversion**: roughly how much
/// energy the body gets from a gram of each macronutrient. They are what
/// makes "30% of my energy from protein" and "135 g of protein" two ways of
/// writing the same target. Nothing in this file says any split is better
/// than any other, and nothing here may grow into saying so
/// (`knowledge/domain/womens_health.md` rule 1 — the app makes no nutrition
/// recommendation).
const double proteinKcalPerGram = 4;

/// Kilocalories per gram of carbohydrate — see [proteinKcalPerGram].
const double carbKcalPerGram = 4;

/// Kilocalories per gram of fat — see [proteinKcalPerGram].
const double fatKcalPerGram = 9;

/// The Atwater factor for [macro], so callers holding a [MacroNutrient] can
/// reach the same three constants rather than carrying their own copy.
double kcalPerGramFor(MacroNutrient macro) => switch (macro) {
  MacroNutrient.protein => proteinKcalPerGram,
  MacroNutrient.carbs => carbKcalPerGram,
  MacroNutrient.fat => fatKcalPerGram,
};

/// The outcome of turning a percentage split into grams.
///
/// A sealed result rather than three nullable doubles, because "there is no
/// calorie figure to take a percentage *of*" is a state the UI has to
/// explain rather than paper over — returning zeros there would print three
/// targets of `0 g` that the user never set. Same typed-result convention as
/// `domain/calorie_target.dart` and `domain/energy_estimate.dart`.
sealed class MacroTargetGramsOutcome {
  const MacroTargetGramsOutcome();
}

/// The grams a percentage split works out to, and the energy figure they
/// were worked out from.
///
/// Each gram figure is `null` when its own percentage isn't set — a split
/// can be half-entered, and an unset share is not a share of zero.
final class DerivedMacroTargetGrams extends MacroTargetGramsOutcome {
  const DerivedMacroTargetGrams({
    required this.basisKcal,
    required this.basisIsEstimated,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
  });

  /// The daily energy figure the percentages are percentages of.
  ///
  /// S2-tier (`knowledge/engineering/security_and_privacy.md`) and, on top
  /// of that, inside the scope of the hide-calorie-numbers preference: a
  /// caller that renders this must check the preference first
  /// (`knowledge/domain/nutrition.md`). The grams themselves are not
  /// calories and are always safe to show.
  final int basisKcal;

  /// Whether [basisKcal] came from the resolved estimate rather than from a
  /// calorie target the user typed herself. Carried so the UI can say which
  /// of the two it used instead of implying a figure was chosen.
  final bool basisIsEstimated;

  /// Daily protein target in grams, or `null` when no protein percentage is
  /// set.
  final double? proteinGrams;

  /// Daily carbohydrate target in grams, or `null` when no carbohydrate
  /// percentage is set.
  final double? carbGrams;

  /// Daily fat target in grams, or `null` when no fat percentage is set.
  final double? fatGrams;
}

/// No grams could be derived, because there is no daily energy figure to
/// take a percentage of.
///
/// Reached when the user has set no calorie target *and* the estimate can't
/// be made (see `domain/energy_estimate.dart` for what that needs), or when
/// the calorie target she set is not a positive number. There is no fallback
/// figure — inventing one would be exactly the unsourced,
/// medical-flavoured claim `domain/calorie_target.dart` refuses to make.
final class NoMacroTargetBasis extends MacroTargetGramsOutcome {
  const NoMacroTargetBasis();
}

/// Turns a percentage split into daily gram targets.
///
/// **What the percentages are percentages of**, in order:
///
/// 1. [calorieTargetKcal] — the target the user typed herself — whenever
///    she has set one. Hers wins over anything the app worked out; a
///    non-positive value set explicitly yields [NoMacroTargetBasis] rather
///    than quietly falling through to the estimate, because falling through
///    would silently replace her number with a different one.
/// 2. Otherwise the target [resolvedTarget] resolves to, which is the
///    estimate with the BMR floor already applied
///    (`domain/calorie_target.dart`) — including the floored case, where the
///    floor *is* the target she is working to.
/// 3. Otherwise [NoMacroTargetBasis].
///
/// A percentage that is absent, negative or non-finite yields `null` grams
/// for that macro rather than zero: an unset share is unset, not none.
///
/// Nothing here checks that the three add up — that is
/// `domain/nutrition_validation.dart`'s job, and this function stays useful
/// while a split is half-typed. Pure: no clock, no I/O.
MacroTargetGramsOutcome deriveMacroTargetGrams({
  required int? calorieTargetKcal,
  required CalorieTargetOutcome? resolvedTarget,
  double? proteinTargetPercent,
  double? carbTargetPercent,
  double? fatTargetPercent,
}) {
  final basis = macroEnergyBasis(
    calorieTargetKcal: calorieTargetKcal,
    resolvedTarget: resolvedTarget,
  );
  if (basis == null) return const NoMacroTargetBasis();

  return DerivedMacroTargetGrams(
    basisKcal: basis.kcal,
    basisIsEstimated: basis.isEstimated,
    proteinGrams: macroGramsForPercent(
      basisKcal: basis.kcal,
      percent: proteinTargetPercent,
      kcalPerGram: proteinKcalPerGram,
    ),
    carbGrams: macroGramsForPercent(
      basisKcal: basis.kcal,
      percent: carbTargetPercent,
      kcalPerGram: carbKcalPerGram,
    ),
    fatGrams: macroGramsForPercent(
      basisKcal: basis.kcal,
      percent: fatTargetPercent,
      kcalPerGram: fatKcalPerGram,
    ),
  );
}

/// The daily energy figure any macro arithmetic works from, or `null` when
/// there isn't one.
///
/// The single answer to "what is a macro target a share of", used by both
/// [deriveMacroTargetGrams] and [solveMacroTargets] so the two can never
/// disagree about which number the user is budgeting against. The rule is
/// spelled out in [deriveMacroTargetGrams]'s dartdoc: her own
/// [calorieTargetKcal] first, then the target [resolvedTarget] settled on
/// (the estimate with the BMR floor already applied), then nothing.
///
/// The record's `isEstimated` field says which of the two it came from, so
/// the UI can name the source instead of implying she chose a figure she
/// didn't.
({int kcal, bool isEstimated})? macroEnergyBasis({
  required int? calorieTargetKcal,
  required CalorieTargetOutcome? resolvedTarget,
}) {
  final explicit = calorieTargetKcal;
  final basisKcal = explicit ?? _resolvedTargetKcal(resolvedTarget);
  if (basisKcal == null || basisKcal <= 0) return null;
  return (kcal: basisKcal, isEstimated: explicit == null);
}

/// One macro's daily grams: [percent] of [basisKcal], converted at
/// [kcalPerGram].
///
/// Returns `null` for an absent, negative or non-finite [percent] — see
/// [deriveMacroTargetGrams] for why that is not zero.
double? macroGramsForPercent({
  required int basisKcal,
  required double? percent,
  required double kcalPerGram,
}) {
  final share = percent;
  if (share == null || !share.isFinite || share < 0) return null;
  return basisKcal * share / 100 / kcalPerGram;
}

/// The daily target [outcome] settled on, or `null` when it produced none.
///
/// [FlooredCalorieTarget] counts: the floor is the figure the user is
/// actually working to, so a split of it is a split of her day.
int? _resolvedTargetKcal(CalorieTargetOutcome? outcome) => switch (outcome) {
  CalorieTarget(:final targetKcal) => targetKcal,
  FlooredCalorieTarget(:final targetKcal) => targetKcal,
  NoCalorieTarget() || null => null,
};

/// Where a set of locked gram targets leaves the day's energy budget.
///
/// A sealed result rather than a nullable gram figure, because the five
/// answers below are genuinely different things to *say*, and collapsing
/// them would leave the UI guessing. In particular, "your locked targets
/// already come to more than your calorie target" is information the user
/// needs, not an error to swallow — see [MacroTargetsOverBudget].
///
/// Same typed-result convention as [MacroTargetGramsOutcome] above and
/// `domain/calorie_target.dart`.
sealed class MacroLockSolution {
  const MacroLockSolution();
}

/// Exactly one macro is free, every locked one carries a number, and the
/// energy left over is enough to state it in grams.
final class SolvedMacroTarget extends MacroLockSolution {
  const SolvedMacroTarget({
    required this.macro,
    required this.grams,
    required this.remainingKcal,
    required this.lockedKcal,
    required this.basisKcal,
    required this.basisIsEstimated,
  });

  /// The macro that was worked out. The other two are the locked ones.
  final MacroNutrient macro;

  /// [macro]'s daily target in grams: [remainingKcal] at its Atwater factor.
  /// Never negative — a locked total above the basis is
  /// [MacroTargetsOverBudget] instead.
  final double grams;

  /// The energy left after the locked macros, in kilocalories. Zero is a
  /// legitimate answer and yields a zero-gram target.
  final double remainingKcal;

  /// What the locked macros come to, in kilocalories.
  final double lockedKcal;

  /// The day energy figure this was solved against. S2-tier and inside the
  /// hide-calorie-numbers preference's scope, exactly as
  /// [DerivedMacroTargetGrams.basisKcal] is.
  final int basisKcal;

  /// Whether [basisKcal] came from the resolved estimate rather than a
  /// calorie target the user typed.
  final bool basisIsEstimated;
}

/// The locked macros alone come to more energy than the day's basis, so
/// there is nothing left for the free one.
///
/// **The overage is carried rather than clamped.** Solving anyway would
/// produce a negative gram figure, and clamping it to zero would hide the
/// arithmetic behind a target the user could meet by eating nothing of that
/// macro — neither is honest about the numbers she entered. This is not a
/// judgement about the numbers; it is the app declining to print one it
/// can't stand behind.
final class MacroTargetsOverBudget extends MacroLockSolution {
  const MacroTargetsOverBudget({
    required this.overageKcal,
    required this.lockedKcal,
    required this.basisKcal,
    required this.basisIsEstimated,
  });

  /// How far past the basis the locked macros go, in kilocalories. Always
  /// greater than zero.
  final double overageKcal;

  /// What the locked macros come to, in kilocalories.
  final double lockedKcal;

  /// See [SolvedMacroTarget.basisKcal].
  final int basisKcal;

  /// See [SolvedMacroTarget.basisIsEstimated].
  final bool basisIsEstimated;
}

/// Not enough is pinned down to work anything out: fewer than two macros are
/// locked *with a number in them*.
///
/// Carries what is still unaccounted for so the UI can be useful without
/// inventing the rest. It must not: distributing the remainder across the
/// free macros would be the app recommending a split
/// (`knowledge/domain/womens_health.md` rule 1), which is precisely the
/// thing it does not do.
final class UnderdeterminedMacroTargets extends MacroLockSolution {
  const UnderdeterminedMacroTargets({
    required this.lockedCount,
    required this.lockedKcal,
    required this.unaccountedKcal,
    required this.basisKcal,
    required this.basisIsEstimated,
  });

  /// How many macros are locked *and* carry a usable number, 0-2. A lock on
  /// a blank field pins nothing, so it is not counted here — and a locked
  /// blank is exactly how a three-lock set can land in this case.
  final int lockedCount;

  /// What those macros come to, in kilocalories. Zero when none are locked.
  final double lockedKcal;

  /// The part of the basis the locked macros don't account for, in
  /// kilocalories. Never negative — a locked total above the basis is
  /// [MacroTargetsOverBudget].
  final double unaccountedKcal;

  /// See [SolvedMacroTarget.basisKcal].
  final int basisKcal;

  /// See [SolvedMacroTarget.basisIsEstimated].
  final bool basisIsEstimated;
}

/// All three macros are locked with numbers, so there is nothing left to
/// compute.
///
/// Reports [differenceKcal] and stops. Deliberately **not** an error: three
/// locked targets that don't add up to the day's energy are a shape the user
/// chose, and she may not want them to sum exactly. The app states the
/// arithmetic and leaves it there.
final class AllMacroTargetsLocked extends MacroLockSolution {
  const AllMacroTargetsLocked({
    required this.differenceKcal,
    required this.lockedKcal,
    required this.basisKcal,
    required this.basisIsEstimated,
  });

  /// The locked total minus the basis, in kilocalories: positive when the
  /// three come to more than the day's figure, negative when they come to
  /// less, zero when they meet it.
  final double differenceKcal;

  /// What the three locked macros come to, in kilocalories.
  final double lockedKcal;

  /// See [SolvedMacroTarget.basisKcal].
  final int basisKcal;

  /// See [SolvedMacroTarget.basisIsEstimated].
  final bool basisIsEstimated;
}

/// There is no daily energy figure to solve against, so no lock can
/// determine anything.
///
/// Reached under exactly the conditions [NoMacroTargetBasis] is (see
/// [macroEnergyBasis]). As there, no fallback figure is invented.
final class NoMacroLockSolutionBasis extends MacroLockSolution {
  const NoMacroLockSolutionBasis();
}

/// Works out the one macro target the user has left free, from the day's
/// energy basis and the two she locked.
///
/// The whole rule, in order:
///
/// 1. No energy basis at all → [NoMacroLockSolutionBasis].
/// 2. All three locked, each with a number → [AllMacroTargetsLocked]: there
///    is nothing to solve for, only a difference to report.
/// 3. The locked macros already come to more than the basis →
///    [MacroTargetsOverBudget], carrying the overage. Checked before the
///    solve so a negative gram figure can never be produced.
/// 4. Exactly one macro free and every locked one carrying a number →
///    [SolvedMacroTarget]: the leftover energy at that macro's Atwater
///    factor.
/// 5. Anything else → [UnderdeterminedMacroTargets].
///
/// **A lock on a blank field pins nothing**, so it cannot make a set
/// solvable; the free macro is still the one the lock set names, but with a
/// locked value missing there is no total to subtract and the answer is
/// case 5. A negative or non-finite gram figure is treated the same way as a
/// missing one.
///
/// Grams-mode only. A percentage split has its own rule — the three must add
/// up to 100 — and its third value is `100 - a - b` by arithmetic, so a
/// second mechanism there would be two ways to say one thing.
///
/// Pure: no clock, no I/O, and nothing here suggests what any macro *should*
/// be. It only divides the energy the user has already accounted for.
MacroLockSolution solveMacroTargets({
  required MacroLocks locks,
  required int? calorieTargetKcal,
  required CalorieTargetOutcome? resolvedTarget,
  double? proteinTargetGrams,
  double? carbTargetGrams,
  double? fatTargetGrams,
}) {
  final basis = macroEnergyBasis(
    calorieTargetKcal: calorieTargetKcal,
    resolvedTarget: resolvedTarget,
  );
  if (basis == null) return const NoMacroLockSolutionBasis();

  double? gramsOf(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => proteinTargetGrams,
    MacroNutrient.carbs => carbTargetGrams,
    MacroNutrient.fat => fatTargetGrams,
  };

  final pinned = [
    for (final macro in locks.locked)
      if (_isUsableGrams(gramsOf(macro))) macro,
  ];
  final lockedKcal = pinned.fold<double>(
    0,
    (sum, macro) => sum + gramsOf(macro)! * kcalPerGramFor(macro),
  );
  final everyLockHasANumber = pinned.length == locks.lockedCount;
  final free = locks.free;

  if (free.isEmpty && everyLockHasANumber) {
    return AllMacroTargetsLocked(
      differenceKcal: lockedKcal - basis.kcal,
      lockedKcal: lockedKcal,
      basisKcal: basis.kcal,
      basisIsEstimated: basis.isEstimated,
    );
  }
  if (lockedKcal > basis.kcal) {
    return MacroTargetsOverBudget(
      overageKcal: lockedKcal - basis.kcal,
      lockedKcal: lockedKcal,
      basisKcal: basis.kcal,
      basisIsEstimated: basis.isEstimated,
    );
  }
  if (free.length == 1 && everyLockHasANumber) {
    final macro = free.single;
    final remainingKcal = basis.kcal - lockedKcal;
    return SolvedMacroTarget(
      macro: macro,
      grams: remainingKcal / kcalPerGramFor(macro),
      remainingKcal: remainingKcal,
      lockedKcal: lockedKcal,
      basisKcal: basis.kcal,
      basisIsEstimated: basis.isEstimated,
    );
  }
  return UnderdeterminedMacroTargets(
    lockedCount: pinned.length,
    lockedKcal: lockedKcal,
    unaccountedKcal: basis.kcal - lockedKcal,
    basisKcal: basis.kcal,
    basisIsEstimated: basis.isEstimated,
  );
}

/// Whether a gram target is present and arithmetically usable. A negative or
/// non-finite figure pins nothing, the same as a blank field — the form's
/// own bounds check reports it, and this function has no business inventing
/// a reading for it.
bool _isUsableGrams(double? grams) =>
    grams != null && grams.isFinite && grams >= 0;

/// Standard baseline macro distribution (50% Carbs, 20% Protein, 30% Fat).
const double standardProteinPercent = 20;
const double standardCarbPercent = 50;
const double standardFatPercent = 30;

/// Standard baseline distribution for [macro].
double standardPercentFor(MacroNutrient macro) => switch (macro) {
  MacroNutrient.protein => standardProteinPercent,
  MacroNutrient.carbs => standardCarbPercent,
  MacroNutrient.fat => standardFatPercent,
};

/// The outcome of the "Calculate" action on nutrition targets.
sealed class CalculateTargetsOutcome {
  const CalculateTargetsOutcome();
}

/// Calculated macro targets in grams.
final class CalculatedMacroGrams extends CalculateTargetsOutcome {
  const CalculatedMacroGrams({
    required this.basisKcal,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
  });

  final int basisKcal;
  final double? proteinGrams;
  final double? carbGrams;
  final double? fatGrams;
}

/// Recalculated total daily calories from 3 locked macros.
final class CalculatedCalories extends CalculateTargetsOutcome {
  const CalculatedCalories({required this.caloriesKcal});

  final int caloriesKcal;
}

/// Calculation could not proceed because no daily energy figure exists.
final class NoCalculateBasis extends CalculateTargetsOutcome {
  const NoCalculateBasis(this.message);

  final String message;
}

/// Calculation could not proceed due to invalid inputs or locked values
/// exceeding basis.
final class CalculateError extends CalculateTargetsOutcome {
  const CalculateError(this.message);

  final String message;
}

/// Calculates macro distributions or daily calories based on how many macros
/// are locked:
/// - 0 locked: calculates a standard spread (20% protein, 50% carbs, 30% fat)
///   from the energy basis into grams.
/// - 1 locked: divides remaining calories between the 2 free macros using
///   their relative standard ratio.
/// - 2 locked: calculates the 1 free macro from the leftover calorie budget.
/// - 3 locked: recalculates total daily calories from the 3 locked gram
///   targets.
CalculateTargetsOutcome calculateMacroTargets({
  required MacroLocks locks,
  required int? calorieTargetKcal,
  required CalorieTargetOutcome? resolvedTarget,
  double? proteinTargetGrams,
  double? carbTargetGrams,
  double? fatTargetGrams,
}) {
  double? gramsOf(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => proteinTargetGrams,
    MacroNutrient.carbs => carbTargetGrams,
    MacroNutrient.fat => fatTargetGrams,
  };

  // Case: All 3 macros locked -> Recalculate daily calories
  if (locks.lockedCount == 3) {
    final p = proteinTargetGrams;
    final c = carbTargetGrams;
    final f = fatTargetGrams;
    if (!_isUsableGrams(p) || !_isUsableGrams(c) || !_isUsableGrams(f)) {
      return const CalculateError(
        'Enter targets for all three locked macros to calculate calories.',
      );
    }
    final totalKcal =
        (p! * proteinKcalPerGram) +
        (c! * carbKcalPerGram) +
        (f! * fatKcalPerGram);
    return CalculatedCalories(caloriesKcal: totalKcal.round());
  }

  // For 0, 1, or 2 locked macros, we need a daily energy basis (calories).
  final basis = macroEnergyBasis(
    calorieTargetKcal: calorieTargetKcal,
    resolvedTarget: resolvedTarget,
  );
  if (basis == null) {
    return const NoCalculateBasis(
      'Enter a calorie target to calculate your macros.',
    );
  }

  // Case: 0 locked macros -> standard spread (20% protein, 50% carbs, 30% fat)
  if (locks.lockedCount == 0) {
    final pGrams =
        (basis.kcal * (standardProteinPercent / 100)) / proteinKcalPerGram;
    final cGrams = (basis.kcal * (standardCarbPercent / 100)) / carbKcalPerGram;
    final fGrams = (basis.kcal * (standardFatPercent / 100)) / fatKcalPerGram;
    return CalculatedMacroGrams(
      basisKcal: basis.kcal,
      proteinGrams: pGrams,
      carbGrams: cGrams,
      fatGrams: fGrams,
    );
  }

  // Case: 1 or 2 locked macros
  final lockedMacros = locks.locked;
  for (final macro in lockedMacros) {
    if (!_isUsableGrams(gramsOf(macro))) {
      return CalculateError(
        'Enter a target for your locked ${macro.label.toLowerCase()} first.',
      );
    }
  }

  final lockedKcal = lockedMacros.fold<double>(
    0,
    (sum, macro) => sum + gramsOf(macro)! * kcalPerGramFor(macro),
  );

  if (lockedKcal > basis.kcal) {
    return const CalculateError(
      'Locked macro targets already exceed your daily calorie target.',
    );
  }

  final remainingKcal = basis.kcal - lockedKcal;
  final freeMacros = locks.free;

  // If 2 locked (1 free)
  if (freeMacros.length == 1) {
    final freeMacro = freeMacros.single;
    final freeGrams = remainingKcal / kcalPerGramFor(freeMacro);
    return CalculatedMacroGrams(
      basisKcal: basis.kcal,
      proteinGrams: locks.protein ? proteinTargetGrams : freeGrams,
      carbGrams: locks.carbs ? carbTargetGrams : freeGrams,
      fatGrams: locks.fat ? fatTargetGrams : freeGrams,
    );
  }

  // If 1 locked (2 free)
  // Split remainingKcal between the 2 free macros by their standard shares
  if (freeMacros.length == 2) {
    final free1 = freeMacros[0];
    final free2 = freeMacros[1];
    final std1 = standardPercentFor(free1);
    final std2 = standardPercentFor(free2);
    final totalStd = std1 + std2;

    final kcal1 = remainingKcal * (std1 / totalStd);
    final kcal2 = remainingKcal * (std2 / totalStd);

    final grams1 = kcal1 / kcalPerGramFor(free1);
    final grams2 = kcal2 / kcalPerGramFor(free2);

    double? resolvedGrams(MacroNutrient macro) {
      if (locks.isLocked(macro)) return gramsOf(macro);
      if (macro == free1) return grams1;
      if (macro == free2) return grams2;
      return null;
    }

    return CalculatedMacroGrams(
      basisKcal: basis.kcal,
      proteinGrams: resolvedGrams(MacroNutrient.protein),
      carbGrams: resolvedGrams(MacroNutrient.carbs),
      fatGrams: resolvedGrams(MacroNutrient.fat),
    );
  }

  return const CalculateError('Unable to calculate macro targets.');
}
