import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';

/// A published general reference interval for one marker in one context.
/// Bounds are inclusive, in [unit]. Evidence and the owner's ruling:
/// `knowledge/research/blood_glucose_reference_ranges.md`.
class BloodMarkerReference {
  const BloodMarkerReference({
    required this.marker,
    required this.context,
    required this.low,
    required this.high,
    required this.sourceName,
    required this.sourceYear,
    this.unit = BloodMarkerUnit.mmolPerL,
    this.qualifier,
  });

  final BloodMarker marker;
  final GlucoseContext? context;
  final double low;
  final double high;
  final BloodMarkerUnit unit;
  final String sourceName;
  final int sourceYear;

  /// Extra condition on when the range applies, e.g. "2 hours or more after
  /// eating".
  final String? qualifier;
}

const _rcpa = 'RCPA Manual, Glucose reference interval';

/// The reviewed table. Contexts not listed (before a meal, bedtime, other,
/// none) have no sourced range and stay store-and-chart only. A new marker or
/// guideline is a row here.
const List<BloodMarkerReference> bloodMarkerReferences = [
  BloodMarkerReference(
    marker: BloodMarker.glucose,
    context: GlucoseContext.fasting,
    low: 3,
    high: 5.4,
    sourceName: _rcpa,
    sourceYear: 2024,
  ),
  BloodMarkerReference(
    marker: BloodMarker.glucose,
    context: GlucoseContext.afterMeal,
    low: 3,
    high: 7.7,
    sourceName: _rcpa,
    sourceYear: 2024,
    qualifier: '2 hours or more after eating',
  ),
];

/// Null when no reviewed range exists for [marker] in [context].
BloodMarkerReference? bloodMarkerReferenceFor(
  BloodMarker marker,
  GlucoseContext? context,
) {
  for (final ref in bloodMarkerReferences) {
    if (ref.marker == marker && ref.context == context) return ref;
  }
  return null;
}

enum ReferencePosition { below, within, above }

/// Converts [value] in [unit] to the reference's unit, rounds to 1 decimal
/// place (the precision the range is published at) and compares inclusively.
ReferencePosition positionInReference(
  BloodMarkerReference ref,
  double value,
  BloodMarkerUnit unit,
) {
  // Whole tenths avoid float equality at the bounds (5.4 vs 5.4000001).
  int tenths(double v) => (v * 10).round();
  final reading = tenths(glucoseIn(ref.unit, value, unit));
  if (reading < tenths(ref.low)) return ReferencePosition.below;
  if (reading > tenths(ref.high)) return ReferencePosition.above;
  return ReferencePosition.within;
}

/// Lower bound shared by every reviewed glucose range, in mmol/L.
const lowGlucoseMmolPerL = 3.0;

/// Under 3.0 mmol/L after conversion and 1 dp rounding, in any context:
/// the low lines apply even where no range is shown.
bool isLowGlucose(double value, BloodMarkerUnit unit) =>
    (glucoseIn(BloodMarkerUnit.mmolPerL, value, unit) * 10).round() <
    (lowGlucoseMmolPerL * 10).round();

/// Position of [r] against its own context's range; null without one.
ReferencePosition? positionOf(BloodMarkerReading r) {
  final ref = bloodMarkerReferenceFor(r.marker, r.context);
  return ref == null ? null : positionInReference(ref, r.value, r.unit);
}

/// Readings whose local day falls inside [range] ending [today], in input
/// order. Same rule as `bloodPressureReadingsInRange`.
List<BloodMarkerReading> bloodMarkerReadingsInRange(
  Iterable<BloodMarkerReading> readings,
  BloodPressureRange range,
  LocalDate today,
) {
  final span = range.days;
  if (span == null) return readings.toList();
  final start = today.addDays(-(span - 1));
  return readings.where((r) => !r.day.isBefore(start)).toList();
}
