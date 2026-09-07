import 'package:menfit_app/core/domain/units.dart';

/// Formats an elevation gain/loss for display.
///
/// Canonical storage is metres (the routing provider and the `routes` table
/// both speak metres); this converts only at the presentation boundary,
/// the same rule every other measurement surface follows (see
/// `knowledge/engineering/coding_standards.md` and
/// `features/activity/domain/pace_format.dart`, whose shape this mirrors).
///
/// Feet come from [UnitConversions.metersToFeet] rather than a local
/// metres-per-foot constant so there is exactly one inch/centimetre ratio
/// in the codebase.
///
/// Non-finite input is treated as zero rather than surfacing a broken
/// string; a negative value keeps its sign (descent is reported as a
/// positive magnitude by the routing provider, but nothing guarantees it).
String formatElevation(double meters, UnitSystem unitSystem) {
  final safeMeters = meters.isFinite ? meters : 0.0;
  if (unitSystem == UnitSystem.imperial) {
    final feet = UnitConversions.metersToFeet(safeMeters);
    return '${feet.toStringAsFixed(0)} ft';
  }
  return '${safeMeters.toStringAsFixed(0)} m';
}
