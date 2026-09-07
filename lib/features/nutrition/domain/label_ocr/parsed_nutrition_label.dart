import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';

/// Which printed nutrition-label standard the panel appears to follow.
enum LabelFormat {
  /// Australia/New Zealand Nutrition Information Panel: "Per Serving" and
  /// "Per 100 g" columns, energy as kJ with Cal beside it, indented
  /// "- saturated" / "- sugars" sub-rows, optional "%DI" column.
  fsanz,

  /// US FDA "Nutrition Facts": one per-serving column plus "% Daily
  /// Value", a large "Calories" row, "Total Fat"/"Total Carbohydrate".
  usFda,

  /// EU/UK "Typical values": per 100 g (sometimes plus a portion column),
  /// "of which saturates" / "of which sugars", salt rather than sodium.
  euUk,

  /// Nothing recognisable. Also what a receipt, a menu, or a blurred
  /// frame produces — see [ParsedNutritionLabel.unrecognised].
  unknown,
}

/// What one column of numbers is *per*.
enum ColumnBasis {
  perServing,
  per100g,

  /// Per 100 **millilitres**. Kept distinct from [per100g] because a
  /// millilitre is not a gram — the same reason `QuantityUnit` refuses to
  /// offer ml (see `knowledge/domain/nutrition.md`). Anything turning this
  /// column into a `Food` needs a serving *volume*, which the app does not
  /// yet model, so this basis is reported and never silently treated as
  /// mass.
  per100ml,

  /// Values were found but no heading said what they are per.
  unknown,
}

/// One number read off the panel, with everything needed to show the user
/// where it came from and how much to trust it.
class ParsedValue {
  const ParsedValue({
    required this.value,
    required this.unitAsRead,
    required this.confidence,
    required this.sourceText,
  });

  /// The number **converted to this app's canonical unit for the field it
  /// landed on** — grams for macros, mg for minerals, mcg for vitamin D,
  /// kcal or kJ for the two energy fields. [unitAsRead] says what was
  /// actually printed, which is often something else (`0.12 g` of sodium
  /// becomes `120` here with `unitAsRead: 'g'`).
  final double value;

  /// The unit exactly as recognised, or `''` when the panel printed none
  /// and the field's default was assumed.
  final String unitAsRead;

  /// Parser-derived, 0..1. Deliberately **not** the engine's confidence:
  /// ADR 012 records that ML Kit's is unreliable and frequently null. It
  /// combines label-match distance, unit plausibility, column-assignment
  /// certainty and (when present) the engine's own signal.
  ///
  /// A high value is never permission to skip the review form.
  final double confidence;

  /// The recognised text this came from, for "we read this as…" display.
  final String sourceText;

  @override
  String toString() => 'ParsedValue($value $unitAsRead, c=$confidence)';
}

/// The serving statement above the table, when there is one.
class ParsedServing {
  const ParsedServing({
    required this.description,
    this.grams,
    this.millilitres,
    this.servingsPerPackage,
  });

  /// The serving text as printed (`'2/3 cup (55 g)'`, `'30 g'`). Shown,
  /// never re-parsed downstream — the same stance `ProviderFood` takes on
  /// `servingDescription`.
  final String description;

  /// Serving mass in grams, when the text stated one.
  final double? grams;

  /// Serving volume in millilitres, when the text stated one. Never
  /// treated as a mass.
  final double? millilitres;

  /// "Servings per package: 12", when stated.
  final double? servingsPerPackage;
}

/// One column of the panel: every nutrient the parser could place in it.
///
/// Every field is a nullable [ParsedValue] and `null` means **the panel
/// did not state it** — never zero. That is the same rule
/// `NutritionFacts` and `ProviderFood` already hold, and it is the whole
/// reason this type exists instead of building a `NutritionFacts`
/// directly: `NutritionFacts` cannot express "energy unknown".
class ParsedColumn {
  const ParsedColumn({
    required this.basis,
    this.energyKcal,
    this.energyKj,
    this.proteinG,
    this.fatG,
    this.saturatedFatG,
    this.transFatG,
    this.carbsG,
    this.sugarsG,
    this.addedSugarsG,
    this.fiberG,
    this.sodiumMg,
    this.potassiumMg,
    this.cholesterolMg,
    this.calciumMg,
    this.ironMg,
    this.vitaminDMcg,
    this.vitaminCMg,
  });

  final ColumnBasis basis;
  final ParsedValue? energyKcal;
  final ParsedValue? energyKj;
  final ParsedValue? proteinG;
  final ParsedValue? fatG;
  final ParsedValue? saturatedFatG;
  final ParsedValue? transFatG;
  final ParsedValue? carbsG;
  final ParsedValue? sugarsG;
  final ParsedValue? addedSugarsG;
  final ParsedValue? fiberG;
  final ParsedValue? sodiumMg;
  final ParsedValue? potassiumMg;
  final ParsedValue? cholesterolMg;
  final ParsedValue? calciumMg;
  final ParsedValue? ironMg;
  final ParsedValue? vitaminDMcg;
  final ParsedValue? vitaminCMg;

  /// Whether energy and all three macros were read — i.e. whether a
  /// review form could pre-fill every field `Food` requires. Mirrors
  /// `ProviderFood.hasCompleteMacros`.
  bool get hasCompleteMacros =>
      energyKcal != null && proteinG != null && carbsG != null && fatG != null;

  /// Nothing at all was read into this column.
  bool get isEmpty => values.isEmpty;

  /// Every value actually read, in declaration order.
  List<ParsedValue> get values => <ParsedValue>[
    for (final v in <ParsedValue?>[
      energyKcal,
      energyKj,
      proteinG,
      fatG,
      saturatedFatG,
      transFatG,
      carbsG,
      sugarsG,
      addedSugarsG,
      fiberG,
      sodiumMg,
      potassiumMg,
      cholesterolMg,
      calciumMg,
      ironMg,
      vitaminDMcg,
      vitaminCMg,
    ])
      ?v,
  ];

  /// This column as `NutritionFacts`, in canonical units.
  ///
  /// **The thirteen optional nutrients stay `null` when unread**, which is
  /// the guarantee that matters. Energy, protein, carbs and fat cannot:
  /// `NutritionFacts` requires them, so an unread one arrives here as `0`
  /// — a limit of the target type, not a claim about the food. Anything
  /// pre-filling a form must read [energyKcal] / [proteinG] / [carbsG] /
  /// [fatG] (or check [hasCompleteMacros]) and seed a **blank** field for
  /// a null, exactly as the Open Food Facts review screen does. Never
  /// seed a field from a zero this method produced.
  NutritionFacts toNutritionFacts() => NutritionFacts(
    caloriesKcal: energyKcal?.value ?? 0,
    proteinGrams: proteinG?.value ?? 0,
    carbsGrams: carbsG?.value ?? 0,
    fatGrams: fatG?.value ?? 0,
    saturatedFatGrams: saturatedFatG?.value,
    transFatGrams: transFatG?.value,
    fiberGrams: fiberG?.value,
    sugarsGrams: sugarsG?.value,
    addedSugarsGrams: addedSugarsG?.value,
    sodiumMg: sodiumMg?.value,
    potassiumMg: potassiumMg?.value,
    cholesterolMg: cholesterolMg?.value,
    ironMg: ironMg?.value,
    calciumMg: calciumMg?.value,
    vitaminDMcg: vitaminDMcg?.value,
    vitaminCMg: vitaminCMg?.value,
  );
}

/// A **candidate** nutrition label — what the camera thinks it saw.
///
/// Deliberately not a `Food` and deliberately not convertible into one,
/// for the reason `ProviderFood` gives at greater length: closing the gap
/// between "what was printed" and "what I am about to eat" is a decision,
/// and the decision belongs to the person eating. ADR 012 makes the review
/// form mandatory; there is no path from here to a saved row that does not
/// pass through a human.
///
/// S2-tier once associated with the diary
/// (`knowledge/engineering/security_and_privacy.md`): never logged, never
/// in analytics, never in an exception message.
class ParsedNutritionLabel {
  const ParsedNutritionLabel({
    required this.format,
    required this.warnings,
    this.serving,
    this.perServing,
    this.per100,
  });

  /// Nothing usable was found. Not an error state — a receipt, a blurred
  /// frame and an ingredients list all land here, and the caller shows
  /// "we couldn't read a panel, enter it by hand" rather than a failure.
  factory ParsedNutritionLabel.unrecognised({
    List<String> warnings = const [],
  }) => ParsedNutritionLabel(
    format: LabelFormat.unknown,
    warnings: warnings,
  );

  final LabelFormat format;

  /// The serving statement, when the panel carried one.
  final ParsedServing? serving;

  /// The per-serving column, when the panel had one.
  final ParsedColumn? perServing;

  /// The per-100 column, when the panel had one. Check [ParsedColumn.basis]
  /// before using it: it may be per 100 **ml**.
  final ParsedColumn? per100;

  /// Plain-language cautions for the review form, in reading order.
  ///
  /// These are user-facing copy and follow the same rules as
  /// `nutrition_validation.dart`: no blame, no moralising, and — because
  /// these strings can end up in test output and crash text — **no
  /// recognised values interpolated into them**.
  final List<String> warnings;

  /// Whether anything at all was read.
  bool get isEmpty =>
      (perServing?.isEmpty ?? true) && (per100?.isEmpty ?? true);

  /// The column a review form should pre-fill from: the per-serving one
  /// when the panel stated it, otherwise the per-100 one.
  ParsedColumn? get primaryColumn => perServing ?? per100;

  /// What the per-100 column is per, when there is one.
  ColumnBasis? get per100Basis => per100?.basis;
}
