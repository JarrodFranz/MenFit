import 'package:menfit_app/features/nutrition/domain/label_ocr/label_columns.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';

/// Collects the values that land in one column and closes it out.
///
/// The derivations that happen in [finish] — kilojoules to calories, salt
/// to sodium — can only be done once the whole panel has been read, since
/// a directly printed figure must always win over a derived one and the
/// rows arrive in whatever order the panel prints them.
///
/// Nothing here writes user-facing copy. It raises flags and the parser
/// turns them into warnings, so every string a user might read lives in
/// one file and can be reviewed as copy.
class ColumnAccumulator {
  ColumnAccumulator(this.kind);

  final ColumnKind kind;

  final Map<LabelField, ParsedValue> _values = {};
  ParsedValue? _energyKj;

  /// Two values for one nutrient in one column — the first was kept.
  bool sawDuplicate = false;

  /// Calories were computed from the kilojoule figure.
  bool derivedKcalFromKj = false;

  /// Both energy figures were printed and they disagree by more than 5%.
  bool energyDisagrees = false;

  /// Sodium was computed from a salt figure.
  bool derivedSodiumFromSalt = false;

  bool get isEmpty => _values.isEmpty && _energyKj == null;

  /// Record a value, keeping the first when a nutrient appears twice.
  void add(LabelField field, ParsedValue value) {
    if (_values.containsKey(field)) {
      sawDuplicate = true;
      return;
    }
    _values[field] = value;
  }

  /// Energy in kilojoules gets its own slot: a panel states both, and
  /// they are not interchangeable.
  void addEnergyKj(ParsedValue value) {
    if (_energyKj != null) {
      sawDuplicate = true;
      return;
    }
    _energyKj = value;
  }

  ParsedValue? valueFor(LabelField field) => _values[field];

  /// Derive what can be derived, then cross-check what was stated twice.
  void finish() {
    final salt = _values[LabelField.salt];
    if (salt != null && _values[LabelField.sodium] == null) {
      _values[LabelField.sodium] = ParsedValue(
        value: saltGramsToSodiumMg(salt.value),
        // Empty, not the salt figure's unit: nothing on the panel stated a
        // unit *for sodium*, and carrying "g" beside a milligram value
        // would render as "500 g" on the review form.
        unitAsRead: '',
        // A conversion factor is an approximation for a real product, so
        // a derived figure can never be as good as a printed one.
        confidence: salt.confidence * 0.9,
        sourceText: salt.sourceText,
      );
      derivedSodiumFromSalt = true;
    }

    final kj = _energyKj;
    final kcal = _values[LabelField.energy];
    if (kj != null && kcal == null) {
      _values[LabelField.energy] = ParsedValue(
        value: kilojoulesToKilocalories(kj.value),
        // Same reason as the salt case: this is a kilocalorie figure and
        // the panel never printed one, so it carries no printed unit.
        unitAsRead: '',
        confidence: kj.confidence * 0.85,
        sourceText: kj.sourceText,
      );
      derivedKcalFromKj = true;
    } else if (kj != null && kcal != null) {
      final expected = kilojoulesToKilocalories(kj.value);
      if (expected > 0 && (kcal.value - expected).abs() / expected > 0.05) {
        energyDisagrees = true;
      }
    }
  }

  /// The immutable column. Call [finish] first.
  ParsedColumn build() => ParsedColumn(
    basis: basisForKind(kind),
    energyKcal: _values[LabelField.energy],
    energyKj: _energyKj,
    proteinG: _values[LabelField.protein],
    fatG: _values[LabelField.fat],
    saturatedFatG: _values[LabelField.saturatedFat],
    transFatG: _values[LabelField.transFat],
    carbsG: _values[LabelField.carbs],
    sugarsG: _values[LabelField.sugars],
    addedSugarsG: _values[LabelField.addedSugars],
    fiberG: _values[LabelField.fiber],
    sodiumMg: _values[LabelField.sodium],
    potassiumMg: _values[LabelField.potassium],
    cholesterolMg: _values[LabelField.cholesterol],
    calciumMg: _values[LabelField.calcium],
    ironMg: _values[LabelField.iron],
    vitaminDMcg: _values[LabelField.vitaminD],
    vitaminCMg: _values[LabelField.vitaminC],
  );
}

/// What a detected column is per.
ColumnBasis basisForKind(ColumnKind kind) => switch (kind) {
  ColumnKind.perServing => ColumnBasis.perServing,
  ColumnKind.per100g => ColumnBasis.per100g,
  ColumnKind.per100ml => ColumnBasis.per100ml,
  ColumnKind.percentDaily => ColumnBasis.unknown,
};
