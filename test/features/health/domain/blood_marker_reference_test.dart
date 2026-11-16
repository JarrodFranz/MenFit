import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reference.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';

void main() {
  const mmol = BloodMarkerUnit.mmolPerL;
  const mg = BloodMarkerUnit.mgPerDl;
  final fasting = bloodMarkerReferenceFor(
    BloodMarker.glucose,
    GlucoseContext.fasting,
  )!;
  final afterMeal = bloodMarkerReferenceFor(
    BloodMarker.glucose,
    GlucoseContext.afterMeal,
  )!;

  test('only fasting and after-meal have a reviewed range', () {
    expect((fasting.low, fasting.high, fasting.unit), (3.0, 5.4, mmol));
    expect((afterMeal.low, afterMeal.high), (3.0, 7.7));
    expect(afterMeal.qualifier, '2 hours or more after eating');
    expect(fasting.sourceYear, 2024);
    for (final context in [
      GlucoseContext.beforeMeal,
      GlucoseContext.bedtime,
      GlucoseContext.other,
      null,
    ]) {
      expect(bloodMarkerReferenceFor(BloodMarker.glucose, context), isNull);
    }
  });

  test('fasting edges in mmol/L', () {
    expect(positionInReference(fasting, 2.9, mmol), ReferencePosition.below);
    expect(positionInReference(fasting, 3, mmol), ReferencePosition.within);
    expect(positionInReference(fasting, 5.4, mmol), ReferencePosition.within);
    expect(positionInReference(fasting, 5.5, mmol), ReferencePosition.above);
    // Rounded to 1 dp before comparing.
    expect(positionInReference(fasting, 5.44, mmol), ReferencePosition.within);
    expect(positionInReference(fasting, 2.95, mmol), ReferencePosition.within);
  });

  test('after-meal edges in mmol/L', () {
    expect(
      positionInReference(afterMeal, 7.7, mmol),
      ReferencePosition.within,
    );
    expect(positionInReference(afterMeal, 7.8, mmol), ReferencePosition.above);
  });

  test('fasting edges in mg/dL follow the 1 dp mmol/L rule', () {
    // 53 -> 2.94 -> 2.9; 54 -> 2.997 -> 3.0; 97 -> 5.38 -> 5.4;
    // 98 -> 5.44 -> 5.4 (still within); 99 -> 5.495 -> 5.5; 100 -> 5.55.
    expect(positionInReference(fasting, 53, mg), ReferencePosition.below);
    expect(positionInReference(fasting, 54, mg), ReferencePosition.within);
    expect(positionInReference(fasting, 97, mg), ReferencePosition.within);
    expect(positionInReference(fasting, 98, mg), ReferencePosition.within);
    expect(positionInReference(fasting, 99, mg), ReferencePosition.above);
    expect(positionInReference(fasting, 100, mg), ReferencePosition.above);
  });

  test('after-meal edges in mg/dL', () {
    // 139 -> 7.72 -> 7.7; 140 -> 7.77 -> 7.8.
    expect(positionInReference(afterMeal, 139, mg), ReferencePosition.within);
    expect(positionInReference(afterMeal, 140, mg), ReferencePosition.above);
  });

  test('isLowGlucose uses the 1 dp mmol/L rule in either unit', () {
    expect(isLowGlucose(2.9, mmol), isTrue);
    expect(isLowGlucose(2.95, mmol), isFalse);
    expect(isLowGlucose(3, mmol), isFalse);
    expect(isLowGlucose(53, mg), isTrue);
    expect(isLowGlucose(54, mg), isFalse);
    expect(isLowGlucose(50, mg), isTrue);
  });

  test('positionOf uses the reading context', () {
    BloodMarkerReading r(GlucoseContext? context) => BloodMarkerReading(
      id: 'r',
      day: LocalDate(2026, 11, 1),
      measuredAt: DateTime.utc(2026, 11, 1, 7),
      marker: BloodMarker.glucose,
      value: 6,
      unit: mmol,
      context: context,
      createdAt: DateTime.utc(2026, 11, 1, 7),
      updatedAt: DateTime.utc(2026, 11, 1, 7),
    );
    expect(positionOf(r(GlucoseContext.fasting)), ReferencePosition.above);
    expect(positionOf(r(GlucoseContext.afterMeal)), ReferencePosition.within);
    expect(positionOf(r(GlucoseContext.other)), isNull);
    expect(positionOf(r(null)), isNull);
  });

  test('range filter keeps days inside the window', () {
    final today = LocalDate(2026, 11, 16);
    BloodMarkerReading r(int daysAgo) => BloodMarkerReading(
      id: '$daysAgo',
      day: today.addDays(-daysAgo),
      measuredAt: DateTime.utc(2026),
      marker: BloodMarker.glucose,
      value: 5,
      unit: mmol,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final readings = [r(0), r(29), r(30)];
    expect(
      bloodMarkerReadingsInRange(
        readings,
        BloodPressureRange.days30,
        today,
      ).map((e) => e.id),
      ['0', '29'],
    );
    expect(
      bloodMarkerReadingsInRange(readings, BloodPressureRange.all, today),
      hasLength(3),
    );
  });
}
