import 'dart:math' as math;

/// The unit system a user prefers for display and input.
///
/// Canonical stored units are always metric (km, kg) — see
/// `knowledge/engineering/coding_standards.md`. [UnitSystem] only governs
/// conversion at the presentation boundary; it never changes what's
/// persisted.
enum UnitSystem {
  metric,
  imperial;

  /// Parses the persisted string form (`'metric'` / `'imperial'`),
  /// defaulting to [metric] for any unrecognised value.
  static UnitSystem fromStorage(String value) {
    return switch (value) {
      'imperial' => UnitSystem.imperial,
      _ => UnitSystem.metric,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    UnitSystem.metric => 'metric',
    UnitSystem.imperial => 'imperial',
  };
}

/// Pure unit-conversion helpers. Canonical storage is always metric
/// (kilometres, kilograms); these functions convert only at the point of
/// display or user input.
abstract final class UnitConversions {
  static const double _kmPerMile = 1.609344;
  static const double _kgPerLb = 0.45359237;
  static const double _cmPerInch = 2.54;

  /// Converts a distance in kilometres to miles.
  static double kmToMi(double km) => km / _kmPerMile;

  /// Converts a distance in miles to kilometres.
  static double miToKm(double mi) => mi * _kmPerMile;

  /// Converts a mass in kilograms to pounds.
  static double kgToLb(double kg) => kg / _kgPerLb;

  /// Converts a mass in pounds to kilograms.
  static double lbToKg(double lb) => lb * _kgPerLb;

  /// Converts a length in centimetres to inches.
  static double cmToInches(double cm) => cm / _cmPerInch;

  /// Converts a length in metres to feet. Used for elevation, where metres
  /// (not kilometres) are the canonical stored unit.
  static double metersToFeet(double meters) => meters * 100 / _cmPerInch / 12;

  /// Converts a length in feet to metres.
  static double feetToMeters(double feet) => feet * 12 * _cmPerInch / 100;

  /// Converts a height in centimetres to a (feet, inches) pair, where
  /// `inches` is in `[0, 12)`. Exact for exact inch values (e.g.
  /// `feetInchesToCm(5, 7)` round-trips to exactly `(5, 7.0)`) modulo normal
  /// floating-point representation error.
  static (int feet, double inches) cmToFeetInches(double cm) {
    final totalInches = cm / _cmPerInch;
    final feet = (totalInches / 12).floor();
    final inches = totalInches - feet * 12;
    return (feet, inches);
  }

  /// Like [cmToFeetInches], but with `inches` already rounded to
  /// [fractionDigits] decimal places and **carried into `feet` when that
  /// rounding reaches 12**.
  ///
  /// Display code must use this rather than rounding [cmToFeetInches]'s
  /// output itself: 179.9 cm is 5 ft 11.96 in, which naive one-decimal
  /// rounding renders as the nonsense `5 ft 12.0 in`.
  static (int feet, double inches) cmToFeetInchesForDisplay(
    double cm, {
    int fractionDigits = 1,
  }) {
    var (feet, inches) = cmToFeetInches(cm);
    final factor = math.pow(10, fractionDigits).toDouble();
    inches = (inches * factor).round() / factor;
    if (inches >= 12) {
      feet += 1;
      inches -= 12;
    }
    return (feet, inches);
  }

  /// Converts a height given as feet + inches to centimetres. Canonical
  /// storage is always metric — this is a presentation/input-boundary
  /// conversion only, same as every other function in this class.
  static double feetInchesToCm(int feet, double inches) {
    final totalInches = feet * 12 + inches;
    return totalInches * _cmPerInch;
  }
}
