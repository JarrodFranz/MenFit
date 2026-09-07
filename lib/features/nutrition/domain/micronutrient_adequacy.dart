import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

part 'micronutrient_adequacy.freezed.dart';

/// Supported micronutrients with evidence-based biological reference intakes.
enum MicronutrientType {
  /// Iron (Fe): Adult male standard is 8 mg/day.
  iron,

  /// Calcium (Ca): Adult male standard is 1,000 mg/day (1,200 mg for >70).
  calcium,

  /// Vitamin D: Adult male standard is 15 mcg/day (600 IU).
  vitaminD,

  /// Dietary Fiber: Adequate intake is 38 g/day for adult males.
  fiber,

  /// Vitamin C: Recommended intake is 90 mg/day.
  vitaminC;

  String get label => switch (this) {
    MicronutrientType.iron => 'Iron',
    MicronutrientType.calcium => 'Calcium',
    MicronutrientType.vitaminD => 'Vitamin D',
    MicronutrientType.fiber => 'Fiber',
    MicronutrientType.vitaminC => 'Vitamin C',
  };

  String get unit => switch (this) {
    MicronutrientType.iron => 'mg',
    MicronutrientType.calcium => 'mg',
    MicronutrientType.vitaminD => 'mcg',
    MicronutrientType.fiber => 'g',
    MicronutrientType.vitaminC => 'mg',
  };

  /// Standard daily reference intake for adult males (19–50, DRI).
  double get standardDailyReference => switch (this) {
    MicronutrientType.iron => 8.0,
    MicronutrientType.calcium => 1000.0,
    MicronutrientType.vitaminD => 15.0,
    MicronutrientType.fiber => 38.0,
    MicronutrientType.vitaminC => 90.0,
  };

  /// Informational rationale for active men.
  String get biologicalRationale => switch (this) {
    MicronutrientType.iron =>
      'Carries oxygen (haemoglobin) and powers cellular energy. Endurance '
          'training raises losses through foot-strike haemolysis and sweat.',
    MicronutrientType.calcium =>
      'Builds bone mineral density and drives muscle contraction; protects '
          'against bone stress injuries under high training loads.',
    MicronutrientType.vitaminD =>
      'Needed to absorb calcium, for skeletal recovery and immune defence.',
    MicronutrientType.fiber =>
      'Supports gut health, steady energy and satiety during a cut.',
    MicronutrientType.vitaminC =>
      'Supports collagen synthesis, tissue repair and iron absorption.',
  };
}

/// Evaluated adequacy for a single micronutrient over a day or period.
@freezed
abstract class MicronutrientAdequacyItem with _$MicronutrientAdequacyItem {
  const factory MicronutrientAdequacyItem({
    required MicronutrientType type,

    /// Logged amount for the period. Null when no entries listed this
    /// nutrient.
    required double? loggedAmount,

    /// Biological daily reference intake.
    required double dailyReference,

    /// Whether at least one logged food did not state this nutrient, making
    /// [loggedAmount] a minimum floor rather than a complete figure.
    required bool isPartial,

    /// Progress ratio towards daily reference intake clamped between 0.0
    /// and 1.0.
    required double progress,

    /// Contextual message explaining status or partial data.
    required String statusMessage,
  }) = _MicronutrientAdequacyItem;

  const MicronutrientAdequacyItem._();

  /// Whether this nutrient had any logged value at all.
  bool get hasLoggedValue => loggedAmount != null;

  /// Formatted logged amount with units, or 'Not listed' if null.
  String get formattedLogged {
    if (loggedAmount == null) return 'Not listed';
    final amount = loggedAmount!;
    final formatted = amount >= 10
        ? amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1)
        : amount.toStringAsFixed(1);
    return '$formatted ${type.unit}';
  }

  /// Formatted reference amount with units.
  String get formattedReference {
    final ref = dailyReference;
    final formatted = ref.truncateToDouble() == ref
        ? ref.toStringAsFixed(0)
        : ref.toStringAsFixed(1);
    return '$formatted ${type.unit}';
  }
}

/// Evaluates micronutrient adequacy across [totals].
List<MicronutrientAdequacyItem> evaluateMicronutrientAdequacy({
  required NutritionTotals totals,
}) {
  return MicronutrientType.values.map((type) {
    final (amount, isPartial) = switch (type) {
      MicronutrientType.iron => (totals.ironMg, totals.ironIsPartial),
      MicronutrientType.calcium => (totals.calciumMg, totals.calciumIsPartial),
      MicronutrientType.vitaminD => (
        totals.vitaminDMcg,
        totals.vitaminDIsPartial,
      ),
      MicronutrientType.fiber => (totals.fiberGrams, totals.fiberIsPartial),
      MicronutrientType.vitaminC => (
        totals.vitaminCMg,
        totals.vitaminCIsPartial,
      ),
    };

    final reference = type.standardDailyReference;
    final progress = amount != null && reference > 0
        ? (amount / reference).clamp(0.0, 1.0)
        : 0.0;

    final statusMessage = switch (type) {
      MicronutrientType.iron =>
        isPartial
            ? 'Partial report: some foods did not list iron.'
            : '8 mg recommended for adult men.',
      MicronutrientType.calcium =>
        isPartial
            ? 'Partial report: some foods did not list calcium.'
            : '1,000 mg recommended for bone density & training recovery.',
      MicronutrientType.vitaminD =>
        isPartial
            ? 'Partial report: some foods did not list vitamin D.'
            : '15 mcg (600 IU) recommended for calcium absorption.',
      MicronutrientType.fiber =>
        isPartial
            ? 'Partial report: some foods did not list fiber.'
            : '38 g recommended for digestive health.',
      MicronutrientType.vitaminC =>
        isPartial
            ? 'Partial report: some foods did not list vitamin C.'
            : '90 mg recommended; enhances non-heme iron absorption.',
    };

    return MicronutrientAdequacyItem(
      type: type,
      loggedAmount: amount,
      dailyReference: reference,
      isPartial: isPartial,
      progress: progress,
      statusMessage: statusMessage,
    );
  }).toList();
}
