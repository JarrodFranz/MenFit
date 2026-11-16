import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';

void main() {
  final stamp = DateTime.utc(2026, 1, 2);
  final bp = BloodPressureReading(
    id: 'reading',
    day: LocalDate(2026, 1, 1),
    measuredAt: stamp,
    systolic: 131,
    diastolic: 87,
    pulse: 64,
    note: 'after coffee',
    createdAt: stamp,
    updatedAt: stamp,
  );
  final glucose = BloodMarkerReading(
    id: 'reading',
    day: LocalDate(2026, 1, 1),
    measuredAt: stamp,
    marker: BloodMarker.glucose,
    value: 5.4,
    unit: BloodMarkerUnit.mmolPerL,
    context: GlucoseContext.fasting,
    createdAt: stamp,
    updatedAt: stamp,
  );

  group('blood pressure text input', () {
    test('accepts whole numbers at and inside the bounds', () {
      for (final input in ['40', '120', '300']) {
        expect(systolicError(input), isNull, reason: input);
      }
      for (final input in ['20', '80', '200']) {
        expect(diastolicError(input), isNull, reason: input);
      }
      for (final input in ['', '25', '60', '250']) {
        expect(pulseError(input), isNull, reason: input);
      }
    });

    test('rejects out-of-bounds, decimals, signs and junk', () {
      const junk = [
        '',
        ' 120',
        '120 ',
        '-120',
        '+120',
        '120.0',
        '1e2',
        'NaN',
        'Infinity',
        '12O',
        '1\n2',
        '99999',
      ];
      for (final input in [...junk, '39', '301']) {
        expect(systolicError(input), isNotNull, reason: input);
      }
      for (final input in [...junk, '19', '201']) {
        expect(diastolicError(input), isNotNull, reason: input);
      }
      for (final input in [...junk.skip(1), '24', '251']) {
        expect(pulseError(input), isNotNull, reason: input);
      }
    });

    test('systolic must exceed diastolic', () {
      expect(bloodPressurePairError(120, 80), isNull);
      expect(bloodPressurePairError(80, 80), isNotNull);
      expect(bloodPressurePairError(70, 80), isNotNull);
    });

    test('messages never echo the input', () {
      expect(systolicError('987654'), isNot(contains('987654')));
      expect(diastolicError('987654'), isNot(contains('987654')));
      expect(pulseError('987654'), isNot(contains('987654')));
    });
  });

  group('blood marker text input', () {
    test('glucose bounds per unit', () {
      for (final input in ['0.5', '5', '5.4', '.9', '50', '50.0']) {
        expect(
          bloodMarkerValueError(
            BloodMarker.glucose,
            BloodMarkerUnit.mmolPerL,
            input,
          ),
          isNull,
          reason: input,
        );
      }
      for (final input in ['0.4', '50.1', '-5', '', 'NaN', 'Infinity', '1e1']) {
        expect(
          bloodMarkerValueError(
            BloodMarker.glucose,
            BloodMarkerUnit.mmolPerL,
            input,
          ),
          isNotNull,
          reason: input,
        );
      }
      for (final input in ['9', '97', '900']) {
        expect(
          bloodMarkerValueError(
            BloodMarker.glucose,
            BloodMarkerUnit.mgPerDl,
            input,
          ),
          isNull,
          reason: input,
        );
      }
      for (final input in ['8.9', '901', '5,4', ' 97']) {
        expect(
          bloodMarkerValueError(
            BloodMarker.glucose,
            BloodMarkerUnit.mgPerDl,
            input,
          ),
          isNotNull,
          reason: input,
        );
      }
    });

    test('message never echoes the input', () {
      expect(
        bloodMarkerValueError(
          BloodMarker.glucose,
          BloodMarkerUnit.mmolPerL,
          '77.77',
        ),
        isNot(contains('77.77')),
      );
    });
  });

  test('notes: optional, single line, length-limited', () {
    expect(healthNoteError(''), isNull);
    expect(healthNoteError('a' * maxHealthNoteLength), isNull);
    for (final input in [
      'a' * (maxHealthNoteLength + 1),
      'line\nbreak',
      'tab\there',
      'x\u0000y',
      'x\u2028y',
      'x\u202ey',
    ]) {
      expect(healthNoteError(input), isNotNull);
    }
  });

  group('isValidBloodPressureReading', () {
    test('accepts a well-formed reading, with or without optionals', () {
      expect(isValidBloodPressureReading(bp), isTrue);
      expect(
        isValidBloodPressureReading(bp.copyWith(pulse: null, note: null)),
        isTrue,
      );
    });

    test('rejects identity, day, UTC, chronology and value faults', () {
      for (final invalid in [
        bp.copyWith(id: ''),
        bp.copyWith(id: ' padded'),
        bp.copyWith(id: 'x' * 129),
        bp.copyWith(id: 'a\nb'),
        bp.copyWith(measuredAt: DateTime(2026)),
        bp.copyWith(createdAt: DateTime(2026), updatedAt: DateTime(2026)),
        bp.copyWith(updatedAt: stamp.subtract(const Duration(seconds: 1))),
        bp.copyWith(measuredAt: DateTime.utc(10000)),
        bp.copyWith(systolic: 39),
        bp.copyWith(systolic: 301),
        bp.copyWith(diastolic: 19),
        bp.copyWith(diastolic: 201),
        bp.copyWith(systolic: 90, diastolic: 90),
        bp.copyWith(pulse: 24),
        bp.copyWith(pulse: 251),
        bp.copyWith(note: 'two\nlines'),
        bp.copyWith(note: 'a' * (maxHealthNoteLength + 1)),
      ]) {
        expect(isValidBloodPressureReading(invalid), isFalse);
      }
    });

    test('clock correction does not invalidate archived timestamps', () {
      final future = DateTime.utc(2099);
      expect(
        isValidBloodPressureReading(
          bp.copyWith(measuredAt: future, createdAt: future, updatedAt: future),
        ),
        isTrue,
      );
    });
  });

  group('isValidBloodMarkerReading', () {
    test('accepts a well-formed glucose reading in either unit', () {
      expect(isValidBloodMarkerReading(glucose), isTrue);
      expect(
        isValidBloodMarkerReading(
          glucose.copyWith(value: 97, unit: BloodMarkerUnit.mgPerDl),
        ),
        isTrue,
      );
      expect(
        isValidBloodMarkerReading(glucose.copyWith(context: null)),
        isTrue,
      );
    });

    test('rejects NaN, infinity, out-of-bounds and envelope faults', () {
      for (final invalid in [
        glucose.copyWith(value: double.nan),
        glucose.copyWith(value: double.infinity),
        glucose.copyWith(value: double.negativeInfinity),
        glucose.copyWith(value: 0.4),
        glucose.copyWith(value: 50.1),
        // 97 is plausible in mg/dL but not as mmol/L: no silent conversion.
        glucose.copyWith(value: 97),
        glucose.copyWith(unit: BloodMarkerUnit.mgPerDl, value: 5.4),
        glucose.copyWith(id: ''),
        glucose.copyWith(measuredAt: DateTime(2026)),
        glucose.copyWith(updatedAt: stamp.subtract(const Duration(days: 1))),
        glucose.copyWith(note: 'x\ry'),
      ]) {
        expect(isValidBloodMarkerReading(invalid), isFalse);
      }
    });
  });

  test('entity string representations expose no values or day', () {
    for (final text in [bp.toString(), glucose.toString()]) {
      for (final secret in [
        '131',
        '87',
        '64',
        'after coffee',
        '5.4',
        'fasting',
        '2026-01-01',
      ]) {
        expect(text, isNot(contains(secret)));
      }
    }
  });
}
