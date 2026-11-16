import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';

void main() {
  group('classifyBloodPressure', () {
    const cases = <(int, int, BloodPressureCategory?)>[
      (119, 79, BloodPressureCategory.optimal),
      (120, 79, BloodPressureCategory.normal),
      (119, 80, BloodPressureCategory.normal),
      (129, 84, BloodPressureCategory.normal),
      (130, 80, BloodPressureCategory.highNormal),
      (139, 89, BloodPressureCategory.highNormal),
      (140, 60, BloodPressureCategory.grade1),
      (159, 99, BloodPressureCategory.grade1),
      (160, 100, BloodPressureCategory.grade2),
      (179, 109, BloodPressureCategory.grade2),
      (180, 90, BloodPressureCategory.grade3),
      (120, 110, BloodPressureCategory.grade3),
      (89, 70, null),
      (100, 59, null),
    ];
    for (final (s, d, expected) in cases) {
      test('$s/$d is $expected', () {
        expect(classifyBloodPressure(s, d), expected);
      });
    }

    test('higher of the systolic and diastolic categories wins', () {
      expect(classifyBloodPressure(118, 92), BloodPressureCategory.grade1);
      expect(classifyBloodPressure(165, 70), BloodPressureCategory.grade2);
      expect(classifyBloodPressure(131, 101), BloodPressureCategory.grade2);
    });

    test('fractional values use >= on the raw number', () {
      expect(classifyBloodPressure(129.6, 70), BloodPressureCategory.normal);
      expect(
        classifyBloodPressure(130.0, 70),
        BloodPressureCategory.highNormal,
      );
      expect(classifyBloodPressure(89.9, 70), isNull);
    });

    test('range predicates', () {
      expect(isHighestRange(180, 70), isTrue);
      expect(isHighestRange(150, 110), isTrue);
      expect(isHighestRange(179, 109), isFalse);
      expect(isBelowClassifiedRange(89, 70), isTrue);
      expect(isBelowClassifiedRange(100, 59), isTrue);
      expect(isBelowClassifiedRange(90, 60), isFalse);
    });
  });

  group('bloodPressureWeeklyAverage', () {
    final today = LocalDate(2026, 11, 16);
    final stamp = DateTime.utc(2026, 11, 16);
    var counter = 0;
    BloodPressureReading reading(int daysAgo, int s, int d) =>
        BloodPressureReading(
          id: 'r${counter++}',
          day: today.addDays(-daysAgo),
          measuredAt: stamp,
          systolic: s,
          diastolic: d,
          createdAt: stamp,
          updatedAt: stamp,
        );

    List<BloodPressureReading> days(int n, int s, int d) => [
      for (var i = 0; i < n; i++) reading(i, s, d),
    ];

    test('4 distinct days gives null; days logged counts them', () {
      final readings = days(4, 120, 80);
      expect(bloodPressureWeeklyAverage(readings, today), isNull);
      expect(bloodPressureDaysLoggedThisWeek(readings, today), 4);
    });

    test('5 distinct days gives the mean', () {
      final readings = [
        ...days(4, 120, 80),
        reading(4, 130, 90),
      ];
      final average = bloodPressureWeeklyAverage(readings, today)!;
      expect(average.systolic, 122);
      expect(average.diastolic, 82);
      expect(average.daysWithReadings, 5);
      expect(average.readingCount, 5);
      expect(average.category, BloodPressureCategory.normal);
    });

    test('readings outside the 7-day window are ignored', () {
      final readings = [
        ...days(4, 120, 80),
        reading(7, 200, 120),
        reading(-1, 200, 120),
      ];
      expect(bloodPressureWeeklyAverage(readings, today), isNull);
      expect(bloodPressureDaysLoggedThisWeek(readings, today), 4);
      final withSixth = [...readings, reading(6, 120, 80)];
      final average = bloodPressureWeeklyAverage(withSixth, today)!;
      expect(average.systolic, 120);
      expect(average.readingCount, 5);
    });

    test('several readings in a day count once as a day, all in the mean', () {
      final readings = [
        ...days(5, 120, 80),
        reading(0, 140, 100),
        reading(0, 140, 100),
      ];
      final average = bloodPressureWeeklyAverage(readings, today)!;
      expect(average.daysWithReadings, 5);
      expect(average.readingCount, 7);
      expect(average.systolic, closeTo((120 * 5 + 280) / 7, 1e-9));
      expect(average.diastolic, closeTo((80 * 5 + 200) / 7, 1e-9));
    });

    test('home-threshold note at 135/85 and 139/89, not at 140/90', () {
      expect(
        bloodPressureWeeklyAverage(
          days(5, 135, 85),
          today,
        )!.showHomeThresholdNote,
        isTrue,
      );
      expect(
        bloodPressureWeeklyAverage(
          days(5, 139, 89),
          today,
        )!.showHomeThresholdNote,
        isTrue,
      );
      final grade1 = bloodPressureWeeklyAverage(days(5, 140, 90), today)!;
      expect(grade1.category, BloodPressureCategory.grade1);
      expect(grade1.showHomeThresholdNote, isFalse);
      expect(
        bloodPressureWeeklyAverage(
          days(5, 134, 84),
          today,
        )!.showHomeThresholdNote,
        isFalse,
      );
    });

    test('range filter keeps days inside the window', () {
      final readings = [
        reading(0, 120, 80),
        reading(29, 120, 80),
        reading(30, 120, 80),
      ];
      expect(
        bloodPressureReadingsInRange(
          readings,
          BloodPressureRange.days30,
          today,
        ),
        hasLength(2),
      );
      expect(
        bloodPressureReadingsInRange(readings, BloodPressureRange.all, today),
        hasLength(3),
      );
    });
  });
}
