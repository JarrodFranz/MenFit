import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

part 'micronutrient_adequacy.freezed.dart';

/// Supported micronutrients with evidence-based biological reference intakes.
enum MicronutrientType {
  /// Iron (Fe): Premenopausal adult female standard is 18 mg/day.
  iron,

  /// Calcium (Ca): Adult female standard is 1,000 mg/day (1,200 mg for >50).
  calcium,

  /// Vitamin D: Adult female standard is 15 mcg/day (600 IU).
  vitaminD,

  /// Dietary Fiber: Adequate intake is 25 g/day for adult females.
  fiber,

  /// Vitamin C: Recommended intake is 75 mg/day.
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

  /// Standard daily reference intake for premenopausal adult females.
  double get standardDailyReference => switch (this) {
    MicronutrientType.iron => 18.0,
    MicronutrientType.calcium => 1000.0,
    MicronutrientType.vitaminD => 15.0,
    MicronutrientType.fiber => 25.0,
    MicronutrientType.vitaminC => 75.0,
  };

  /// Informational biological rationale for active women.
  String get biologicalRationale => switch (this) {
    MicronutrientType.iron =>
      'Essential for oxygen transport (hemoglobin) and cellular energy. '
          'Active females experience elevated losses through menstruation '
          'and foot-strike impact.',
    MicronutrientType.calcium =>
      'Crucial for bone mineral density, neuromuscular contraction, and '
          'protecting against bone stress injuries in runners.',
    MicronutrientType.vitaminD =>
      'Essential for active intestinal calcium absorption, skeletal '
          'recovery, and immune defense.',
    MicronutrientType.fiber =>
      'Supports digestive motility, microbiome balance, and healthy '
          'circulating estrogen clearance.',
    MicronutrientType.vitaminC =>
      'Synergistically enhances non-heme (plant) iron absorption and '
          'promotes collagen synthesis for joint and tendon health.',
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

    /// Contextual message explaining status, menstrual demands, or partial
    /// data.
    required String statusMessage,

    /// Active menstrual cycle phase on the evaluated day, if known.
    CyclePhase? cyclePhase,
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

/// Evaluates micronutrient adequacy across [totals] for the given [cyclePhase].
List<MicronutrientAdequacyItem> evaluateMicronutrientAdequacy({
  required NutritionTotals totals,
  CyclePhase? cyclePhase,
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

    final isMenstrual = cyclePhase == CyclePhase.menstrual;

    final statusMessage = switch (type) {
      MicronutrientType.iron =>
        isMenstrual
            ? (isPartial
                  ? 'Menstrual phase: iron needs are higher (~18 mg). Logged '
                        'foods report partial data.'
                  : 'Menstrual phase: ~18 mg recommended to compensate for '
                        'blood loss.')
            : (isPartial
                  ? 'Partial report: some foods did not list iron.'
                  : 'Daily reference: 18 mg for premenopausal women.'),
      MicronutrientType.calcium =>
        isPartial
            ? 'Partial report: some foods did not list calcium.'
            : '1,000 mg recommended for bone density & runner health.',
      MicronutrientType.vitaminD =>
        isPartial
            ? 'Partial report: some foods did not list vitamin D.'
            : '15 mcg (600 IU) recommended for calcium absorption.',
      MicronutrientType.fiber =>
        isPartial
            ? 'Partial report: some foods did not list fiber.'
            : '25 g recommended for digestive & hormone clearance health.',
      MicronutrientType.vitaminC =>
        isPartial
            ? 'Partial report: some foods did not list vitamin C.'
            : '75 mg recommended; enhances non-heme iron absorption.',
    };

    return MicronutrientAdequacyItem(
      type: type,
      loggedAmount: amount,
      dailyReference: reference,
      isPartial: isPartial,
      progress: progress,
      cyclePhase: cyclePhase,
      statusMessage: statusMessage,
    );
  }).toList();
}
