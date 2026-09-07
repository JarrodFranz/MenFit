import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/units.dart';

void main() {
  group('UnitSystem', () {
    test('fromStorage parses known values', () {
      expect(UnitSystem.fromStorage('metric'), UnitSystem.metric);
      expect(UnitSystem.fromStorage('imperial'), UnitSystem.imperial);
    });

    test('fromStorage defaults to metric for unknown values', () {
      expect(UnitSystem.fromStorage('bogus'), UnitSystem.metric);
      expect(UnitSystem.fromStorage(''), UnitSystem.metric);
    });

    test('toStorage round-trips through fromStorage', () {
      for (final system in UnitSystem.values) {
        expect(UnitSystem.fromStorage(system.toStorage()), system);
      }
    });
  });

  group('UnitConversions', () {
    test('kmToMi converts a known distance', () {
      expect(UnitConversions.kmToMi(10), closeTo(6.2137, 0.001));
    });

    test('miToKm converts a known distance', () {
      expect(UnitConversions.miToKm(1), closeTo(1.609344, 0.0001));
    });

    test('kmToMi and miToKm round-trip', () {
      const km = 42.195; // marathon distance
      final roundTripped = UnitConversions.miToKm(
        UnitConversions.kmToMi(km),
      );
      expect(roundTripped, closeTo(km, 1e-9));
    });

    test('kgToLb converts a known mass', () {
      expect(UnitConversions.kgToLb(1), closeTo(2.20462, 0.001));
    });

    test('lbToKg converts a known mass', () {
      expect(UnitConversions.lbToKg(1), closeTo(0.453592, 0.001));
    });

    test('kgToLb and lbToKg round-trip', () {
      const kg = 63.5;
      final roundTripped = UnitConversions.lbToKg(
        UnitConversions.kgToLb(kg),
      );
      expect(roundTripped, closeTo(kg, 1e-9));
    });

    test('lbToKg converts 150 lb to ~68.04 kg', () {
      expect(UnitConversions.lbToKg(150), closeTo(68.04, 0.01));
    });

    test('feetInchesToCm converts 5\'7" to exactly 170.18 cm', () {
      expect(UnitConversions.feetInchesToCm(5, 7), closeTo(170.18, 1e-9));
    });

    test('cmToFeetInches converts a known height', () {
      final (feet, inches) = UnitConversions.cmToFeetInches(170.18);
      expect(feet, 5);
      expect(inches, closeTo(7, 1e-9));
    });

    test('cmToFeetInches keeps inches within [0, 12)', () {
      // 6 feet exactly - inches must read as 0, not roll over to 12.
      final (feet, inches) = UnitConversions.cmToFeetInches(
        UnitConversions.feetInchesToCm(6, 0),
      );
      expect(feet, 6);
      expect(inches, closeTo(0, 1e-9));
    });

    test('cmToFeetInches and feetInchesToCm round-trip', () {
      const cm = 165.0;
      final (feet, inches) = UnitConversions.cmToFeetInches(cm);
      final roundTripped = UnitConversions.feetInchesToCm(feet, inches);
      expect(roundTripped, closeTo(cm, 1e-9));
    });
  });
}
