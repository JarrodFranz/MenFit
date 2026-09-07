import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';

// Copy rules for every message in this file
// (`knowledge/domain/nutrition.md`'s ED-safe stance, restated as a
// constraint on the code):
//
// 1. No message may shame, praise, or moralise about food, about an amount
//    eaten, or about a number. Messages describe what the *app* can store,
//    never what the user should eat.
// 2. No message is clinical, and none implies a health consequence.
// 3. The numeric bounds below are fat-finger guards on a text field, in the
//    same spirit as `features/profile/domain/profile_validation.dart`'s
//    height/weight bounds — they are not statements about what any food or
//    any portion can be. That is why the copy asks "worth a second look?"
//    rather than telling the user a value is wrong.
// 4. S2: no message interpolates a logged value. The bounds it does quote
//    are fixed constants, not user data. There are two exceptions, both
//    narrow and both about *targets* rather than about anything eaten:
//    [validateMacroTargetPercentages]'s sum message, which quotes the
//    arithmetic the user just typed back to them because the message is
//    useless without it; and [macroLockNote], which quotes what their locked
//    gram targets come to in energy. Both are shapes they chose for their day,
//    not things they logged — see those functions' dartdocs — and both remain
//    UI strings that must never reach a log, an analytics event or an
//    exception.
// 5. Every message that would name an energy figure has to say the same
//    thing without one when `hideCalorieNumbers` is on. Falling silent is
//    not an option: a user who cannot see *that* their locked targets exceed
//    their calories is worse off than one who sees it without the number.

/// Result of validating a user-entered food definition.
///
/// A typed result value, not an exception — same convention as
/// `features/wellbeing/domain/wellbeing_validation.dart`'s
/// `CheckinValidation`.
class FoodValidation {
  const FoodValidation({
    this.nameError,
    this.servingDescriptionError,
    this.servingGramsError,
    this.servingVolumeMlError,
    this.caloriesError,
    this.proteinError,
    this.carbsError,
    this.fatError,
    this.saturatedFatError,
    this.transFatError,
    this.monounsaturatedFatError,
    this.polyunsaturatedFatError,
    this.fiberError,
    this.sugarsError,
    this.addedSugarsError,
    this.sodiumError,
    this.potassiumError,
    this.cholesterolError,
    this.ironError,
    this.calciumError,
    this.vitaminDError,
    this.vitaminCError,
  });

  final String? nameError;
  final String? servingDescriptionError;
  final String? servingGramsError;
  final String? servingVolumeMlError;
  final String? caloriesError;
  final String? proteinError;
  final String? carbsError;
  final String? fatError;
  final String? saturatedFatError;
  final String? transFatError;
  final String? monounsaturatedFatError;
  final String? polyunsaturatedFatError;
  final String? fiberError;
  final String? sugarsError;
  final String? addedSugarsError;
  final String? sodiumError;
  final String? potassiumError;
  final String? cholesterolError;
  final String? ironError;
  final String? calciumError;
  final String? vitaminDError;
  final String? vitaminCError;

  bool get isValid =>
      nameError == null &&
      servingDescriptionError == null &&
      servingGramsError == null &&
      servingVolumeMlError == null &&
      caloriesError == null &&
      proteinError == null &&
      carbsError == null &&
      fatError == null &&
      saturatedFatError == null &&
      transFatError == null &&
      monounsaturatedFatError == null &&
      polyunsaturatedFatError == null &&
      fiberError == null &&
      sugarsError == null &&
      addedSugarsError == null &&
      sodiumError == null &&
      potassiumError == null &&
      cholesterolError == null &&
      ironError == null &&
      calciumError == null &&
      vitaminDError == null &&
      vitaminCError == null;
}

/// Widest per-serving energy this app will store, in kilocalories. A
/// fat-finger guard, not a claim about food — see this file's copy rules.
const double maxCaloriesPerServing = 5000;

/// Widest per-serving mass this app will store for any one macro, in grams.
const double maxMacroGramsPerServing = 1000;

/// Widest per-serving iron this app will store, in milligrams.
///
/// Higher than a portion of anything anybody eats, on purpose. When a
/// provider record has no serving weight the serving *is* 100 g
/// (`ServingBasis.per100g`), so this field then holds milligrams per 100 g,
/// and dried herbs and spices genuinely sit above 100 there — dried thyme is
/// about 124 mg/100 g. At 100 the only way past the form was to clear the
/// field, which turns a known figure into `null`, i.e. *unknown* — the one
/// inversion `domain/nutrition_facts.dart` exists to prevent.
///
/// 250 still catches what this bound is for: a stray digit, or the
/// grams-to-milligrams conversion applied twice (which lands near 16,000 on
/// the fortified cereals that motivated it). Like every bound here it is a
/// fat-finger guard on a text field, not a statement about what anyone
/// should eat.
const double maxIronMgPerServing = 250;

/// Widest serving mass this app will store, in grams.
const double maxServingGrams = 5000;

/// Widest serving volume this app will store, in millilitres (10 litres).
const double maxServingVolumeMl = 10000;

/// Most servings this app will record in one diary entry.
const double maxQuantityServings = 100;

const String _blankNameMessage =
    'Give this food a name so you can find it again.';
const String _blankServingMessage =
    "Describe one serving — something like '1 cup' or '2 slices'.";
const String _missingNumberMessage = 'Add a number here (0 is fine).';
const String _negativeMessage = "That can't be less than zero.";
const String _tooLargeMessage =
    "That's larger than we can store for one serving — worth a second look?";
// Both quantity messages are worded without naming a unit: the same field
// now holds servings, grams, ounces, kilograms or pounds
// (`domain/quantity_unit.dart`), and copy that says "servings" to someone
// who just typed a gram figure reads like the app misunderstood them.
const String _nonPositiveQuantityMessage = 'That needs to be more than zero.';
const String _tooManyServingsMessage =
    "That's more than we can log in one entry — splitting it into a few "
    'entries works well.';
const String _futureDayMessage =
    "That hasn't happened yet — pick a day that's today or earlier.";

/// Validates a user-entered food definition.
///
/// - [name] and [servingDescription] must not be blank: a food with no
///   name can't be found again, and nutrition numbers mean nothing without
///   knowing what they're *per*.
/// - [caloriesKcal], [proteinGrams], [carbsGrams] and [fatGrams] are
///   required, must be at or above zero, and must sit inside the
///   fat-finger bounds above. Required rather than optional because these
///   four are what the food is *for* — zero is an accepted answer, absence
///   isn't.
/// - [ironMg] and [servingGrams] are optional (`null` is always valid).
///   `null` iron means **unknown**, which is a meaningfully different thing
///   from `0` — see `domain/nutrition_facts.dart`.
///
/// Nothing here judges the food. See this file's copy rules.
FoodValidation validateFood({
  required String name,
  required String servingDescription,
  double? caloriesKcal,
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
  double? saturatedFatGrams,
  double? transFatGrams,
  double? monounsaturatedFatGrams,
  double? polyunsaturatedFatGrams,
  double? fiberGrams,
  double? sugarsGrams,
  double? addedSugarsGrams,
  double? sodiumMg,
  double? potassiumMg,
  double? cholesterolMg,
  double? ironMg,
  double? calciumMg,
  double? vitaminDMcg,
  double? vitaminCMg,
  double? servingGrams,
  double? servingVolumeMl,
}) {
  return FoodValidation(
    nameError: name.trim().isEmpty ? _blankNameMessage : null,
    servingDescriptionError: servingDescription.trim().isEmpty
        ? _blankServingMessage
        : null,
    servingGramsError: _optionalBoundedError(servingGrams, maxServingGrams),
    servingVolumeMlError: _optionalBoundedError(
      servingVolumeMl,
      maxServingVolumeMl,
    ),
    caloriesError: _requiredBoundedError(caloriesKcal, maxCaloriesPerServing),
    proteinError: _requiredBoundedError(proteinGrams, maxMacroGramsPerServing),
    carbsError: _requiredBoundedError(carbsGrams, maxMacroGramsPerServing),
    fatError: _requiredBoundedError(fatGrams, maxMacroGramsPerServing),
    saturatedFatError: _optionalBoundedError(
      saturatedFatGrams,
      maxMacroGramsPerServing,
    ),
    transFatError: _optionalBoundedError(
      transFatGrams,
      maxMacroGramsPerServing,
    ),
    monounsaturatedFatError: _optionalBoundedError(
      monounsaturatedFatGrams,
      maxMacroGramsPerServing,
    ),
    polyunsaturatedFatError: _optionalBoundedError(
      polyunsaturatedFatGrams,
      maxMacroGramsPerServing,
    ),
    fiberError: _optionalBoundedError(fiberGrams, maxMacroGramsPerServing),
    sugarsError: _optionalBoundedError(sugarsGrams, maxMacroGramsPerServing),
    addedSugarsError: _optionalBoundedError(
      addedSugarsGrams,
      maxMacroGramsPerServing,
    ),
    sodiumError: _optionalBoundedError(sodiumMg, 100000),
    potassiumError: _optionalBoundedError(potassiumMg, 100000),
    cholesterolError: _optionalBoundedError(cholesterolMg, 100000),
    ironError: _optionalBoundedError(ironMg, maxIronMgPerServing),
    calciumError: _optionalBoundedError(calciumMg, 100000),
    vitaminDError: _optionalBoundedError(vitaminDMcg, 100000),
    vitaminCError: _optionalBoundedError(vitaminCMg, 100000),
  );
}

/// A required non-negative number that must not exceed [max].
String? _requiredBoundedError(double? value, double max) {
  if (value == null) return _missingNumberMessage;
  return _boundedError(value, max);
}

/// An optional non-negative number that must not exceed [max] when given.
String? _optionalBoundedError(double? value, double max) {
  if (value == null) return null;
  return _boundedError(value, max);
}

String? _boundedError(double value, double max) {
  // NaN/infinity can only reach here from a parse of something that wasn't
  // a number — treat it as "no number given" rather than as out of range,
  // since every comparison against NaN is false and would otherwise pass.
  if (value.isNaN || value.isInfinite) return _missingNumberMessage;
  if (value < 0) return _negativeMessage;
  if (value > max) return _tooLargeMessage;
  return null;
}

/// Result of validating the three macro-target percentages together.
///
/// A typed result value, not an exception — the same convention as
/// [FoodValidation] above. [sumError] is separate from the three field
/// errors because it belongs to the three of them *together*: no single
/// field is the wrong one when a split doesn't add up.
class MacroPercentValidation {
  const MacroPercentValidation({
    this.proteinError,
    this.carbError,
    this.fatError,
    this.sumError,
  });

  final String? proteinError;
  final String? carbError;
  final String? fatError;

  /// The message about the three fields as a set, or `null` when they add
  /// up.
  final String? sumError;

  bool get isValid =>
      proteinError == null &&
      carbError == null &&
      fatError == null &&
      sumError == null;
}

/// The largest share of a day's energy this app will store for one macro.
///
/// 100 is arithmetic, not a fat-finger guard: one macro cannot be more than
/// all of the day. The lower bound is 0, and 0 is an accepted answer.
const double maxMacroTargetPercent = 100;

/// How far a split may land from 100% and still be accepted, in percentage
/// points.
///
/// Exists for float arithmetic and for thirds, not as slack in the rule:
/// `33.3 + 33.3 + 33.4` is a user writing 100 by hand, and rejecting it
/// would be pedantry rather than validation.
const double macroPercentSumTolerance = 0.05;

/// The over-100% copy, public so the goals form's field reader can raise
/// the identical message from its own bounds check rather than inventing a
/// second wording for the same fact.
const String macroPercentTooLargeMessage =
    "One share can't be more than 100% of the day.";

/// Validates the three macro targets **as percentages of the day's energy**.
///
/// - Each percentage, when given, sits between 0 and
///   [maxMacroTargetPercent]. `0` is an accepted answer.
/// - All three blank is valid and means no percentage targets — no target
///   is a permanent, valid state (`domain/nutrition_goals.dart`), and this
///   function never asks for a number that hasn't been started.
/// - Once *any* of the three is given, all three are required and they must
///   add up to 100% within [macroPercentSumTolerance]. A part-written split
///   describes a part of a day, and there is no honest way to read the
///   remainder.
///
/// **The sum message quotes the total the user typed** — "These come to 96%
/// …" — which is the one place in this file a message carries a number that
/// came from the user. It is deliberate and narrow: without the total the
/// message can only say "these don't add up", which leaves them to do the
/// arithmetic the app already did. A split is a *shape* they chose for their
/// day, not something they logged eating, so quoting it back is not the S2
/// disclosure rule 4 exists to prevent — but the message is still a UI
/// string only, and like everything else here must never reach a log, an
/// analytics event or an exception.
///
/// The message states arithmetic and nothing else. It does not call a split
/// balanced, sensible, high, low, or anything else — this app makes no
/// nutrition recommendation (`knowledge/domain/mens_health.md` rule 1),
/// and a validator is the last place one should sneak in.
MacroPercentValidation validateMacroTargetPercentages({
  double? proteinPercent,
  double? carbPercent,
  double? fatPercent,
}) {
  final rangeErrors = MacroPercentValidation(
    proteinError: _percentError(proteinPercent),
    carbError: _percentError(carbPercent),
    fatError: _percentError(fatPercent),
  );
  if (!rangeErrors.isValid) return rangeErrors;

  final given = [
    proteinPercent,
    carbPercent,
    fatPercent,
  ].where((value) => value != null).length;
  if (given == 0) return const MacroPercentValidation();
  if (given < 3) {
    return MacroPercentValidation(
      proteinError: proteinPercent == null ? _missingNumberMessage : null,
      carbError: carbPercent == null ? _missingNumberMessage : null,
      fatError: fatPercent == null ? _missingNumberMessage : null,
    );
  }

  final sum = proteinPercent! + carbPercent! + fatPercent!;
  if ((sum - 100).abs() <= macroPercentSumTolerance) {
    return const MacroPercentValidation();
  }
  return MacroPercentValidation(sumError: _sumMessage(sum));
}

String _sumMessage(double sum) =>
    'These come to ${_formatPercent(sum)}% — they need to add up to 100% '
    'between them.';

/// The total as the user would write it: `'96'`, `'99.5'`. One decimal at
/// most, so float arithmetic on three typed numbers can't print noise.
String _formatPercent(double value) {
  final rounded = double.parse(value.toStringAsFixed(1));
  return rounded == rounded.roundToDouble()
      ? rounded.round().toString()
      : rounded.toString();
}

String? _percentError(double? value) {
  final percent = value;
  if (percent == null) return null;
  if (percent.isNaN || percent.isInfinite) return _missingNumberMessage;
  if (percent < 0) return _negativeMessage;
  if (percent > maxMacroTargetPercent) return macroPercentTooLargeMessage;
  return null;
}

/// What the goals form says about a set of locked macro targets, or `null`
/// when there is nothing to say.
///
/// Not a validation — nothing here blocks a save, and no configuration of
/// locks is *wrong*. It lives in this file because it is user-facing copy
/// about numbers, and this file is where the copy rules at the top are
/// enforced. Every message states arithmetic: what the locked targets come
/// to, and how that sits against the day's energy figure. None of them
/// describes a split as balanced, sensible, high or low, and none implies
/// the user has done something wrong — the app is doing their sums, not
/// recommending a diet (`knowledge/domain/mens_health.md` rule 1).
///
/// **`null` when nothing is locked.** A user who hasn't asked for this
/// doesn't need a paragraph about it; the lock buttons are the affordance.
///
/// **[hideCalorieNumbers] changes the wording, never the presence of a
/// message** (copy rule 5). "Your locked targets add up to more than your
/// calorie target" is the fact; the kcal figures are the detail. Dropping
/// the message with the preference on would leave a user staring at a
/// target that cannot be met, with no explanation.
///
/// Quotes energy figures derived from the gram targets the user typed —
/// permitted, narrowly, by the second exception in copy rule 4 above.
String? macroLockNote(
  MacroLockSolution solution, {
  required MacroLocks locks,
  required bool hideCalorieNumbers,
}) {
  if (locks.isEmpty) return null;
  return switch (solution) {
    // The field itself shows the answer, with its own "this was worked out"
    // note. A second sentence saying so would be noise.
    SolvedMacroTarget() => null,
    NoMacroLockSolutionBasis() => _lockNoBasisMessage,
    MacroTargetsOverBudget(
      :final overageKcal,
      :final lockedKcal,
      :final basisIsEstimated,
    ) =>
      _overBudgetMessage(
        overageKcal: overageKcal,
        lockedKcal: lockedKcal,
        basisIsEstimated: basisIsEstimated,
        hideCalorieNumbers: hideCalorieNumbers,
      ),
    AllMacroTargetsLocked(
      :final differenceKcal,
      :final lockedKcal,
      :final basisIsEstimated,
    ) =>
      _allLockedMessage(
        differenceKcal: differenceKcal,
        lockedKcal: lockedKcal,
        basisIsEstimated: basisIsEstimated,
        hideCalorieNumbers: hideCalorieNumbers,
      ),
    UnderdeterminedMacroTargets(
      :final lockedCount,
      :final unaccountedKcal,
      :final basisIsEstimated,
    ) =>
      _underdeterminedMessage(
        lockedCount: lockedCount,
        unaccountedKcal: unaccountedKcal,
        basisIsEstimated: basisIsEstimated,
        hideCalorieNumbers: hideCalorieNumbers,
      ),
  };
}

const String _lockNoBasisMessage =
    "Locking two of these works out the third, once there's a daily calorie "
    'figure to work from. Set a calorie target above, or add your details so '
    'the estimate can stand in.';

const String _lockTwoMessage =
    'Lock two of the three and the app works out the third.';

String _overBudgetMessage({
  required double overageKcal,
  required double lockedKcal,
  required bool basisIsEstimated,
  required bool hideCalorieNumbers,
}) {
  final basis = _basisName(basisIsEstimated);
  if (hideCalorieNumbers) {
    return 'Your locked targets already come to more energy than $basis.';
  }
  final over = overageKcal.round();
  if (over == 0) {
    return 'Your locked targets already come to ${_kcal(lockedKcal)}, just '
        'past $basis.';
  }
  return 'Your locked targets already come to ${_kcal(lockedKcal)} — $over '
      'more than $basis.';
}

String _allLockedMessage({
  required double differenceKcal,
  required double lockedKcal,
  required bool basisIsEstimated,
  required bool hideCalorieNumbers,
}) {
  const opening = "All three are locked, so there's nothing left to work out.";
  final basis = _basisName(basisIsEstimated);
  final difference = differenceKcal.round();
  if (hideCalorieNumbers) {
    final comparison = switch (difference) {
      0 => 'the same as',
      > 0 => 'more than',
      _ => 'less than',
    };
    return '$opening Together they come to $comparison $basis.';
  }
  if (difference == 0) {
    return '$opening They come to ${_kcal(lockedKcal)} — the same as $basis.';
  }
  final direction = difference > 0 ? 'more' : 'less';
  return '$opening They come to ${_kcal(lockedKcal)} — ${difference.abs()} '
      '$direction than $basis.';
}

String _underdeterminedMessage({
  required int lockedCount,
  required double unaccountedKcal,
  required bool basisIsEstimated,
  required bool hideCalorieNumbers,
}) {
  // Locks on blank fields pin nothing, so there is no total to report yet —
  // saying what they "leave unaccounted for" would be the whole day.
  if (lockedCount == 0) {
    return 'Lock two of the three, with a number in each, and the app works '
        'out the third.';
  }
  final basis = _basisName(basisIsEstimated);
  if (hideCalorieNumbers) {
    return '$_lockTwoMessage Your locked targets leave part of $basis '
        'unaccounted for.';
  }
  return '$_lockTwoMessage Your locked targets leave '
      '${_kcal(unaccountedKcal)} of $basis unaccounted for.';
}

/// Which daily energy figure the arithmetic is against, in words — the same
/// pair of phrasings `widgets/macro_target_fields.dart` uses for the percent
/// basis note, so the two never describe the same number differently.
String _basisName(bool isEstimated) =>
    isEstimated ? 'your estimated daily target' : 'your calorie target';

/// Energy as this feature prints it: whole kilocalories, never tenths (see
/// `presentation/nutrition_format.dart` for why). Duplicated as a private
/// helper rather than imported, because `domain/` may not depend on
/// `presentation/`.
String _kcal(double value) => '${value.round()} kcal';

/// Result of validating a diary entry being logged or edited.
class NutritionEntryValidation {
  const NutritionEntryValidation({this.dayError, this.quantityError});

  final String? dayError;
  final String? quantityError;

  bool get isValid => dayError == null && quantityError == null;
}

/// Validates a diary entry:
///
/// - [day] must not be in the future relative to [today] — the diary
///   records what happened, and meal *planning* is a different feature we
///   haven't built (calendar-day semantics:
///   `knowledge/architecture/data_architecture.md`).
/// - [quantityServings] is required and must be greater than zero (a
///   zero-serving entry is a deletion, not a log), and must not exceed
///   [maxQuantityServings].
/// - [quantityAmount], when the caller has one, is the number the user
///   actually typed, before `domain/quantity_unit.dart` converted it. It
///   must be finite and greater than zero too.
///
/// **The bounds live on the serving count, not on the typed amount**, and
/// that is what lets one set of limits cover every unit: 100 g and 3.5 oz
/// are not comparable numbers, but the servings they work out to are
/// (`quantity_unit.dart#servingsFor` says the same thing from the other
/// side). [quantityAmount] is checked only for the two things no unit can
/// make sense of — a zero-or-less amount is a deletion rather than a log
/// whatever it measures, and a non-finite one came from a parse of
/// something that wasn't a number. Checking it *first* also means a typed
/// `0` is reported against what they typed rather than against a converted
/// zero they never saw.
NutritionEntryValidation validateNutritionEntry({
  required LocalDate day,
  required LocalDate today,
  double? quantityServings,
  double? quantityAmount,
}) {
  return NutritionEntryValidation(
    dayError: day.isAfter(today) ? _futureDayMessage : null,
    quantityError:
        _typedAmountError(quantityAmount) ?? _quantityError(quantityServings),
  );
}

/// The typed amount's own two failures, or `null` when the caller passed
/// none — a caller that only has a serving count (the entry is already
/// converted) is not asked to invent one.
String? _typedAmountError(double? amount) {
  if (amount == null) return null;
  if (amount.isNaN || amount.isInfinite) return _missingNumberMessage;
  if (amount <= 0) return _nonPositiveQuantityMessage;
  return null;
}

String? _quantityError(double? quantity) {
  if (quantity == null) return _missingNumberMessage;
  if (quantity.isNaN || quantity.isInfinite) return _missingNumberMessage;
  if (quantity <= 0) return _nonPositiveQuantityMessage;
  if (quantity > maxQuantityServings) return _tooManyServingsMessage;
  return null;
}
