import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/domain/ketone_validation.dart';

void main() {
  final stamp = DateTime.utc(2026, 1, 2);
  final reading = KetoneReading(
    id: 'reading',
    day: LocalDate(2026, 1, 1),
    measuredAt: stamp,
    type: KetoneMeasurementType.blood,
    result: '0.10',
    createdAt: stamp,
    updatedAt: stamp,
  );

  test('numeric methods preserve precision and meter flags', () {
    for (final type in [
      KetoneMeasurementType.blood,
      KetoneMeasurementType.breath,
    ]) {
      for (final result in ['0', '0.10', '.25', '2.500', 'LO', 'HI']) {
        expect(ketoneResultError(type, result), isNull);
        expect(reading.copyWith(type: type, result: result).result, result);
      }
    }
  });

  test('numeric methods reject malformed, negative and nonfinite input', () {
    for (final type in [
      KetoneMeasurementType.blood,
      KetoneMeasurementType.breath,
    ]) {
      for (final result in [
        '',
        ' ',
        '-1',
        '-0',
        'NaN',
        'Infinity',
        '1e999',
        '1,2',
        '0.2 mmol/L',
        'hi',
        '1\n',
      ]) {
        expect(
          ketoneResultError(type, result),
          isNotNull,
          reason: 'Invalid input accepted',
        );
      }
    }
  });

  test(
    'urine retains brand-specific result and unit without a numeric scale',
    () {
      for (final result in ['Trace', '++', 'Negative', '5 mg/dL']) {
        expect(ketoneResultError(KetoneMeasurementType.urine, result), isNull);
      }
      for (final result in ['', 'x\ny', 'x\u0000y', 'x\u2028y', 'x' * 41]) {
        expect(
          ketoneResultError(KetoneMeasurementType.urine, result),
          isNotNull,
        );
      }
    },
  );

  test('storage parser rejects unknown method without echoing it', () {
    for (final type in KetoneMeasurementType.values) {
      expect(KetoneMeasurementType.fromStorage(type.toStorage()), type);
    }
    expect(
      () => KetoneMeasurementType.fromStorage('sensitive-input'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.toString(),
          'message',
          isNot(contains('sensitive-input')),
        ),
      ),
    );
  });

  test('validates identity, UTC and timestamp chronology', () {
    expect(isValidKetoneReading(reading), isTrue);
    for (final invalid in [
      reading.copyWith(id: ''),
      reading.copyWith(id: ' padded'),
      reading.copyWith(result: 'NaN'),
      reading.copyWith(measuredAt: DateTime(2026)),
      reading.copyWith(updatedAt: stamp.subtract(const Duration(seconds: 1))),
    ]) {
      expect(isValidKetoneReading(invalid), isFalse);
    }
  });

  test(
    'editing time after creation and keeping original local day is valid',
    () {
      final edited = reading.copyWith(
        measuredAt: stamp.add(const Duration(hours: 1)),
        updatedAt: stamp.add(const Duration(hours: 2)),
      );
      expect(isValidKetoneReading(edited), isTrue);
    },
  );

  test('clock correction does not invalidate archived timestamps', () {
    expect(
      isValidKetoneReading(
        reading.copyWith(
          measuredAt: DateTime.utc(2099),
          createdAt: DateTime.utc(2099),
          updatedAt: DateTime.utc(2099),
        ),
      ),
      isTrue,
    );
  });

  test('entity string representation does not expose result or day', () {
    expect(reading.toString(), isNot(contains('0.10')));
    expect(reading.toString(), isNot(contains('2026-01-01')));
  });
}
