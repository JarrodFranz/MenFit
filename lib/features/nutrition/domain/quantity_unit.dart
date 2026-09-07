/// The units a diary entry can be logged in.
///
/// A food is *defined* per serving (`domain/food.dart`), but people do not
/// always eat in servings — a packet says "serving: 30 g" and the scale says
/// 47 g. Logging by weight and having the nutrition follow is the difference
/// between a diary someone keeps and one they abandon.
///
/// Everything except [serving] is a **mass**, and converting any of them into
/// servings needs the food's gram equivalent per serving. That weight is
/// optional (`Food.servingGrams`) and genuinely often unknown, so the
/// conversion below returns a typed result rather than assuming one — see
/// [servingsFor].
///
/// ## No millilitres and no milligrams — the rule, and why the values are
/// still here
///
/// `knowledge/domain/nutrition.md` states it: **a millilitre is not a mass.**
/// 100 ml of oil is ~92 g and of honey ~140 g, and this app stores no notion
/// of whether a food is a liquid, let alone its density. A volume unit that
/// silently behaved as a mass would produce numbers that look right and are
/// wrong — in a diary, silently wrong is the worst possible failure mode.
/// Supporting volume properly means storing a serving *volume* beside the
/// serving weight and offering it only for foods that have one; that is a
/// deliberate future step with its own design, not something to approximate
/// here.
///
/// [millilitre] and [fluidOunce] were nonetheless added at one point with
/// `gramsPerUnit` values that treat them as water, and entries logged in them
/// exist. So the enum values **stay** — [fromStorage] must keep reading those
/// rows, and `NutritionEntry` must keep displaying them exactly as it always
/// has — but [availableFor] no longer offers them, so no *new* entry can pick
/// one. Deleting the values would break deserialisation of real rows to fix a
/// rule about new input, which is a trade nobody wants.
enum QuantityUnit {
  /// One serving, as the food itself describes it. Always available, and the
  /// only unit available when a food has no stated gram weight or millilitre
  /// volume.
  serving(
    label: 'serving',
    shortLabel: 'serving',
    gramsPerUnit: null,
    mlPerUnit: null,
  ),

  gram(
    label: 'gram',
    shortLabel: 'g',
    gramsPerUnit: 1,
    mlPerUnit: null,
  ),

  /// Millilitres, for liquid foods defined with a volume per serving.
  millilitre(
    label: 'millilitre',
    shortLabel: 'ml',
    gramsPerUnit: null,
    mlPerUnit: 1,
  ),

  /// International avoirdupois ounce, exactly 28.349523125 g.
  ounce(
    label: 'ounce',
    shortLabel: 'oz',
    gramsPerUnit: 28.349523125,
    mlPerUnit: null,
  ),

  /// US customary fluid ounce (~29.5735295625 ml).
  fluidOunce(
    label: 'fluid ounce',
    shortLabel: 'fl oz',
    gramsPerUnit: null,
    mlPerUnit: 29.5735295625,
  ),

  kilogram(
    label: 'kilogram',
    shortLabel: 'kg',
    gramsPerUnit: 1000,
    mlPerUnit: null,
  ),

  /// International avoirdupois pound, exactly 453.59237 g.
  pound(
    label: 'pound',
    shortLabel: 'lb',
    gramsPerUnit: 453.59237,
    mlPerUnit: null,
  );

  const QuantityUnit({
    required this.label,
    required this.shortLabel,
    required this.gramsPerUnit,
    required this.mlPerUnit,
  });

  /// Singular, lower-case name for a picker row ('gram').
  final String label;

  /// Compact suffix for displaying an amount ('g'). Spelled out in full for
  /// [QuantityUnit.serving], which has no conventional abbreviation.
  final String shortLabel;

  /// How many grams one of this unit is, or `null` for non-mass units.
  final double? gramsPerUnit;

  /// How many millilitres one of this unit is, or `null` for non-volume units.
  final double? mlPerUnit;

  /// Whether this unit measures mass, and therefore needs the food's
  /// gram-per-serving weight before it can be logged.
  bool get isMass => gramsPerUnit != null;

  /// Whether this unit measures volume, and therefore needs the food's
  /// millilitre-per-serving volume before it can be logged.
  bool get isVolume => mlPerUnit != null;

  /// Mass units offerable for a food defined by weight.
  static const List<QuantityUnit> offerableMass = [
    serving,
    gram,
    ounce,
    kilogram,
    pound,
  ];

  /// Volume units offerable for a food defined by volume.
  static const List<QuantityUnit> offerableVolume = [
    serving,
    millilitre,
    fluidOunce,
  ];

  /// Backward-compatible alias for mass units offerable for a food defined by
  /// weight.
  static const List<QuantityUnit> offerable = offerableMass;

  /// The units offerable for a food whose serving weighs [servingGrams] and/or
  /// measures [servingVolumeMl].
  ///
  /// Just [serving] when neither is known or usable: offering units for a food
  /// whose serving size nobody recorded would mean either inventing a value or
  /// logging a zero, and both are worse than a picker with one entry in it.
  ///
  /// [including] is the unit a picker is *currently sitting on* — the unit an
  /// entry being edited was logged in. It is appended when it would otherwise
  /// be missing. Without it, reopening such an entry would hand a dropdown a
  /// selected value that is not among its items, which asserts.
  static List<QuantityUnit> availableFor(
    double? servingGrams, {
    double? servingVolumeMl,
    QuantityUnit? including,
  }) {
    final hasWeight = _hasUsableWeight(servingGrams);
    final hasVolume = _hasUsableVolume(servingVolumeMl);

    final List<QuantityUnit> base;
    if (hasWeight && hasVolume) {
      base = const [
        serving,
        gram,
        ounce,
        kilogram,
        pound,
        millilitre,
        fluidOunce,
      ];
    } else if (hasWeight) {
      base = offerableMass;
    } else if (hasVolume) {
      base = offerableVolume;
    } else {
      base = const [serving];
    }

    if (including != null && !base.contains(including)) {
      return [...base, including];
    }
    return base;
  }

  /// Parses the persisted string form, defaulting to [serving] for anything
  /// unrecognised — every entry written before units existed was in
  /// servings, so that is the correct reading of an unknown key.
  static QuantityUnit fromStorage(String value) {
    for (final unit in values) {
      if (unit.name == value) return unit;
    }
    return serving;
  }

  /// The persisted string form of this value.
  String toStorage() => name;
}

/// Result of turning an amount-and-unit into a number of servings.
///
/// A sealed result rather than a nullable double because "this food has no
/// recorded serving weight/volume" is a specific, actionable thing the UI has to
/// say out loud (`knowledge/engineering/error_handling.md`: expected
/// outcomes are values, not exceptions, and not silent nulls).
sealed class QuantityConversion {
  const QuantityConversion();
}

/// The amount converted cleanly into servings.
final class ConvertedQuantity extends QuantityConversion {
  const ConvertedQuantity(this.servings);

  /// How many servings the amount works out to. Fractional is normal.
  final double servings;
}

/// A serving count converted cleanly back into an amount of some unit.
///
/// A separate type from [ConvertedQuantity] rather than a reused one,
/// because the two carry numbers in opposite directions and a single field
/// named `servings` holding "47 grams" is exactly the sort of thing that
/// reads fine and computes wrong.
final class ConvertedAmount extends QuantityConversion {
  const ConvertedAmount(this.amount);

  /// How much of the requested unit the servings work out to.
  final double amount;
}

/// A mass was given for a food with no usable gram weight per serving, so
/// there is nothing to convert against.
///
/// Not an error state to apologise for: it means the food needs its serving
/// weight filled in, which is a thing the user can do.
final class NoServingWeight extends QuantityConversion {
  const NoServingWeight();
}

/// A volume was given for a food with no usable serving volume, and no legacy
/// serving weight to convert against.
final class NoServingVolume extends QuantityConversion {
  const NoServingVolume();
}

/// Converts [amount] of [unit] into servings of a food whose one serving
/// weighs [servingGrams] grams and/or measures [servingVolumeMl] ml.
///
/// [QuantityUnit.serving] passes straight through — it needs no weight or
/// volume, which is why a food with no recorded serving amount can still be
/// logged.
///
/// Returns [NoServingWeight] when a mass unit is used and [servingGrams] is
/// absent, zero, negative, or not finite.
///
/// Returns [NoServingVolume] when a volume unit is used and neither
/// [servingVolumeMl] nor legacy [servingGrams] is usable.
QuantityConversion servingsFor({
  required double amount,
  required QuantityUnit unit,
  required double? servingGrams,
  double? servingVolumeMl,
}) {
  if (unit == QuantityUnit.serving) return ConvertedQuantity(amount);

  if (unit.isVolume) {
    if (_hasUsableVolume(servingVolumeMl)) {
      return ConvertedQuantity(amount * unit.mlPerUnit! / servingVolumeMl!);
    }
    // Legacy fallback: pre-v25 entries treated 1 ml as 1 g and 1 fl oz
    // as 29.5735 g.
    if (_hasUsableWeight(servingGrams)) {
      final legacyFactor = unit == QuantityUnit.millilitre ? 1.0 : 29.5735;
      return ConvertedQuantity(amount * legacyFactor / servingGrams!);
    }
    return const NoServingVolume();
  }

  if (unit.isMass) {
    if (!_hasUsableWeight(servingGrams)) return const NoServingWeight();
    return ConvertedQuantity(amount * unit.gramsPerUnit! / servingGrams!);
  }

  return ConvertedQuantity(amount);
}

/// The inverse of [servingsFor]: how much of [unit] [servings] servings is.
///
/// Used to re-display an entry in the unit it was logged in, so an entry
/// entered as "47 g" or "250 ml" reads back as what was typed rather than
/// as "1.57 servings".
QuantityConversion amountFor({
  required double servings,
  required QuantityUnit unit,
  required double? servingGrams,
  double? servingVolumeMl,
}) {
  if (unit == QuantityUnit.serving) return ConvertedAmount(servings);

  if (unit.isVolume) {
    if (_hasUsableVolume(servingVolumeMl)) {
      return ConvertedAmount(servings * servingVolumeMl! / unit.mlPerUnit!);
    }
    // Legacy fallback
    if (_hasUsableWeight(servingGrams)) {
      final legacyFactor = unit == QuantityUnit.millilitre ? 1.0 : 29.5735;
      return ConvertedAmount(servings * servingGrams! / legacyFactor);
    }
    return const NoServingVolume();
  }

  if (unit.isMass) {
    if (!_hasUsableWeight(servingGrams)) return const NoServingWeight();
    return ConvertedAmount(servings * servingGrams! / unit.gramsPerUnit!);
  }

  return ConvertedAmount(servings);
}

/// Whether a serving weight is present and arithmetically usable.
bool _hasUsableWeight(double? servingGrams) {
  return servingGrams != null && servingGrams.isFinite && servingGrams > 0;
}

/// Whether a serving volume is present and arithmetically usable.
bool _hasUsableVolume(double? servingVolumeMl) {
  return servingVolumeMl != null &&
      servingVolumeMl.isFinite &&
      servingVolumeMl > 0;
}
