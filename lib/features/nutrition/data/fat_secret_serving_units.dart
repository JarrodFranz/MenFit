/// Reading a FatSecret serving size into the two units this app stores, and
/// writing it back out as the text a row shows.
///
/// Split out of `fat_secret_mapper.dart` (2026-09-08) so that file holds the
/// shape of the API's responses and this one holds the unit arithmetic. They
/// change for different reasons: the response shape comes from FatSecret's
/// XML-to-JSON serialiser, while everything here comes from the units a food
/// is actually sold in.
///
/// Nothing here is a behaviour change from the mapper it came out of.
library;

import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

/// A serving size resolved into the two units this app stores. Both may be
/// present (a record stating both units), and both may be absent.
class FatSecretMeasurement {
  const FatSecretMeasurement({this.grams, this.volumeMl});

  final double? grams;
  final double? volumeMl;

  /// Whether anything at all was resolved.
  bool get hasAny => grams != null || volumeMl != null;
}

/// Reads `metric_serving_amount`/`metric_serving_unit` into a mass and/or
/// a volume.
///
/// Mass ounces never imply fluid volume, including for beverages.
FatSecretMeasurement measureFatSecretServing({
  required double? metricAmount,
  required String? metricUnit,
}) {
  if (metricAmount == null ||
      !metricAmount.isFinite ||
      metricAmount <= 0 ||
      metricUnit == null) {
    return const FatSecretMeasurement();
  }
  final unit = metricUnit.toLowerCase().trim().replaceAll('.', '');
  switch (unit) {
    case 'g':
    case 'gram':
    case 'grams':
      return FatSecretMeasurement(grams: metricAmount);
    case 'ml':
    case 'milliliter':
    case 'millilitre':
      return FatSecretMeasurement(volumeMl: metricAmount);
    case 'oz':
    case 'ounce':
    case 'ounces':
      return FatSecretMeasurement(
        grams: metricAmount * QuantityUnit.ounce.gramsPerUnit!,
      );
    case 'fl oz':
    case 'floz':
    case 'fluid ounce':
    case 'fluid ounces':
      return FatSecretMeasurement(
        volumeMl: metricAmount * QuantityUnit.fluidOunce.mlPerUnit!,
      );
    default:
      return const FatSecretMeasurement();
  }
}

/// Reads the size out of a free-text portion ("1 serving", "8 fl oz",
/// "1/4 cup (45g)", "1 package (16 oz)").
///
/// Used for a search hit's portion prefix, and for a detail serving whose
/// `metric_serving_*` fields are absent — FatSecret leaves them null on
/// plenty of stated servings, and the description is then the only size
/// there is.
///
/// Fluid ounces are matched before ounces, so "8 fl oz" is never read as
/// eight ounces of mass.
FatSecretMeasurement measureFatSecretPortion(String portion) {
  final flOz = RegExp(
    r'(\d+(?:\.\d+)?)\s*fl\.?\s*oz',
    caseSensitive: false,
  ).firstMatch(portion);
  if (flOz != null) {
    final amount = double.tryParse(flOz.group(1)!);
    return FatSecretMeasurement(
      volumeMl: amount == null
          ? null
          : amount * QuantityUnit.fluidOunce.mlPerUnit!,
    );
  }

  final oz = RegExp(
    r'(\d+(?:\.\d+)?)\s*oz\b',
    caseSensitive: false,
  ).firstMatch(portion);
  if (oz != null) {
    final amount = double.tryParse(oz.group(1)!);
    if (amount != null) {
      return FatSecretMeasurement(
        grams: amount * QuantityUnit.ounce.gramsPerUnit!,
      );
    }
  }

  return FatSecretMeasurement(
    grams: _extractGrams(portion),
    volumeMl: _extractMl(portion),
  );
}

/// Appends the resolved size to a serving description that does not
/// already state one: `'1 serving'` plus 709.8 ml → `'1 serving (710 ml)'`.
///
/// [preferVolume] decides which half of a dual-unit serving is written;
/// the other stays on the record either way.
String formatFatSecretServingDescription(
  String desc, {
  required bool preferVolume,
  double? servingGrams,
  double? servingVolumeMl,
}) {
  final trimmed = desc.trim();
  if (trimmed.isEmpty) return '1 serving';

  if (trimmed.toLowerCase() == '100g' || trimmed.toLowerCase() == '100 g') {
    return '100 g';
  }

  if (trimmed.toLowerCase() == '100ml' || trimmed.toLowerCase() == '100 ml') {
    return '100 ml';
  }

  final hasVolume = servingVolumeMl != null && servingVolumeMl > 0;
  final hasGrams = servingGrams != null && servingGrams > 0;
  final useVolume = hasVolume && (preferVolume || !hasGrams);
  if (!useVolume && !hasGrams) return trimmed;

  final amount = useVolume ? servingVolumeMl : servingGrams;
  final unit = useVolume ? 'ml' : 'g';
  final metricText = '${_formatMetricAmount(amount!)} $unit';

  final hasUnit = RegExp(
    '\\b$unit\\b|\\d+\\s*$unit',
    caseSensitive: false,
  ).hasMatch(trimmed);
  if (hasUnit) {
    return trimmed;
  }

  final isGenericServing = RegExp(
    r'^(1\s+)?(serving|portion)$',
    caseSensitive: false,
  ).hasMatch(trimmed);

  if (isGenericServing) {
    return '1 serving ($metricText)';
  }

  return '$trimmed ($metricText)';
}

double? _extractGrams(String text) {
  final match = RegExp(
    r'\(?(\d+(?:\.\d+)?)\s*g\)?',
    caseSensitive: false,
  ).firstMatch(text);
  return match == null ? null : double.tryParse(match.group(1)!);
}

double? _extractMl(String text) {
  final match = RegExp(
    r'\(?(\d+(?:\.\d+)?)\s*ml\)?',
    caseSensitive: false,
  ).firstMatch(text);
  return match == null ? null : double.tryParse(match.group(1)!);
}

/// Whole grams and whole millilitres: writing a converted serving as
/// "680.4 g" claims a precision an ounce figure does not have. Sub-gram
/// servings keep one decimal, because rounding those to `0` would be a false
/// zero of the kind `domain/provider_food.dart` exists to prevent.
String _formatMetricAmount(double amount) {
  final rounded = amount.roundToDouble();
  if (rounded == amount || rounded >= 1) return rounded.toStringAsFixed(0);
  return amount.toStringAsFixed(1);
}
