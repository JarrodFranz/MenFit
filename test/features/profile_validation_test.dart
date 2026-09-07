import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/profile/domain/profile_validation.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  group('validateProfileFields - dateOfBirth', () {
    test('null is always valid - the field is optional', () {
      final result = validateProfileFields(today: today);
      expect(result.isValid, isTrue);
      expect(result.dateOfBirthError, isNull);
    });

    test('a date in the future is rejected', () {
      final result = validateProfileFields(
        today: today,
        dateOfBirth: today.addDays(1),
      );
      expect(result.dateOfBirthError, isNotNull);
      expect(result.isValid, isFalse);
    });

    test('exactly today is valid', () {
      final result = validateProfileFields(today: today, dateOfBirth: today);
      expect(result.dateOfBirthError, isNull);
    });

    test('1899-12-31 is rejected - before the earliest accepted date', () {
      final result = validateProfileFields(
        today: today,
        dateOfBirth: LocalDate(1899, 12, 31),
      );
      expect(result.dateOfBirthError, isNotNull);
    });

    test('exactly 1900-01-01 is valid', () {
      final result = validateProfileFields(
        today: today,
        dateOfBirth: LocalDate(1900, 1, 1),
      );
      expect(result.dateOfBirthError, isNull);
    });

    test('a normal adult date of birth is valid', () {
      final result = validateProfileFields(
        today: today,
        dateOfBirth: LocalDate(1990, 3, 15),
      );
      expect(result.dateOfBirthError, isNull);
    });
  });

  group('validateProfileFields - heightCm', () {
    test('null is always valid - the field is optional', () {
      final result = validateProfileFields(today: today);
      expect(result.heightError, isNull);
    });

    test('below the minimum bound is rejected', () {
      final result = validateProfileFields(today: today, heightCm: 89.9);
      expect(result.heightError, isNotNull);
    });

    test('exactly the minimum bound (90) is valid', () {
      final result = validateProfileFields(today: today, heightCm: 90);
      expect(result.heightError, isNull);
    });

    test('exactly the maximum bound (250) is valid', () {
      final result = validateProfileFields(today: today, heightCm: 250);
      expect(result.heightError, isNull);
    });

    test('above the maximum bound is rejected', () {
      final result = validateProfileFields(today: today, heightCm: 250.1);
      expect(result.heightError, isNotNull);
    });

    test('a typical height is valid', () {
      final result = validateProfileFields(today: today, heightCm: 170);
      expect(result.heightError, isNull);
    });
  });

  group('validateProfileFields - weightKg', () {
    test('null is always valid - the field is optional', () {
      final result = validateProfileFields(today: today);
      expect(result.weightError, isNull);
    });

    test('below the minimum bound is rejected', () {
      final result = validateProfileFields(today: today, weightKg: 24.9);
      expect(result.weightError, isNotNull);
    });

    test('exactly the minimum bound (25) is valid', () {
      final result = validateProfileFields(today: today, weightKg: 25);
      expect(result.weightError, isNull);
    });

    test('exactly the maximum bound (350) is valid', () {
      final result = validateProfileFields(today: today, weightKg: 350);
      expect(result.weightError, isNull);
    });

    test('above the maximum bound is rejected', () {
      final result = validateProfileFields(today: today, weightKg: 350.1);
      expect(result.weightError, isNotNull);
    });
  });

  test('isValid is true only when every field passes', () {
    final allValid = validateProfileFields(
      today: today,
      dateOfBirth: LocalDate(1990, 1, 1),
      heightCm: 170,
      weightKg: 65,
    );
    expect(allValid.isValid, isTrue);

    final oneInvalid = validateProfileFields(
      today: today,
      dateOfBirth: LocalDate(1990, 1, 1),
      heightCm: 10,
      weightKg: 65,
    );
    expect(oneInvalid.isValid, isFalse);
  });
}
