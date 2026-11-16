import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';

/// National Heart Foundation of Australia 2016, Table 2.1 (clinic readings),
/// in ascending order so the index comparison is "higher category".
/// Thresholds: `knowledge/research/blood_pressure_classification.md`.
enum BloodPressureCategory {
  optimal,
  normal,
  highNormal,
  grade1,
  grade2,
  grade3,
}

// Lower bounds in mmHg, highest category first. Compared with `>=` on the raw
// number so a fractional average such as 129.6 stays below the 130 boundary.
const List<(int, BloodPressureCategory)> _systolicFloors = [
  (180, BloodPressureCategory.grade3),
  (160, BloodPressureCategory.grade2),
  (140, BloodPressureCategory.grade1),
  (130, BloodPressureCategory.highNormal),
  (120, BloodPressureCategory.normal),
];
const List<(int, BloodPressureCategory)> _diastolicFloors = [
  (110, BloodPressureCategory.grade3),
  (100, BloodPressureCategory.grade2),
  (90, BloodPressureCategory.grade1),
  (85, BloodPressureCategory.highNormal),
  (80, BloodPressureCategory.normal),
];

BloodPressureCategory _categoryFor(
  num value,
  List<(int, BloodPressureCategory)> floors,
) {
  for (final (floor, category) in floors) {
    if (value >= floor) return category;
  }
  return BloodPressureCategory.optimal;
}

/// Below 90 systolic or 60 diastolic: outside what the guideline classifies.
bool isBelowClassifiedRange(num systolic, num diastolic) =>
    systolic < 90 || diastolic < 60;

/// The guideline's highest range (grade 3): 180 systolic or 110 diastolic.
bool isHighestRange(num systolic, num diastolic) =>
    systolic >= 180 || diastolic >= 110;

/// Null when systolic < 90 or diastolic < 60: the guideline does not classify
/// low readings (hypotension is out of its scope), so no category is shown.
/// When the two values fall in different categories the higher one wins.
BloodPressureCategory? classifyBloodPressure(num systolic, num diastolic) {
  if (isBelowClassifiedRange(systolic, diastolic)) return null;
  final bySystolic = _categoryFor(systolic, _systolicFloors);
  final byDiastolic = _categoryFor(diastolic, _diastolicFloors);
  return bySystolic.index >= byDiastolic.index ? bySystolic : byDiastolic;
}

class BloodPressureWeeklyAverage {
  const BloodPressureWeeklyAverage({
    required this.systolic,
    required this.diastolic,
    required this.daysWithReadings,
    required this.readingCount,
    required this.category,
    required this.showHomeThresholdNote,
  });

  final double systolic;
  final double diastolic;
  final int daysWithReadings;
  final int readingCount;
  final BloodPressureCategory? category;

  /// Average at or above the home threshold (135 and/or 85) while still
  /// classified below grade 1 on the clinic table.
  final bool showHomeThresholdNote;
}

// Home-monitoring hypertension threshold: Heart Foundation 2016, Table 4.3.
const homeThresholdSystolic = 135;
const homeThresholdDiastolic = 85;

const bloodPressureWeeklyWindowDays = 7;
const bloodPressureWeeklyMinimumDays = 5;

Iterable<BloodPressureReading> _inWeek(
  Iterable<BloodPressureReading> readings,
  LocalDate today,
) {
  final start = today.addDays(-(bloodPressureWeeklyWindowDays - 1));
  return readings.where((r) => !r.day.isBefore(start) && !r.day.isAfter(today));
}

/// Distinct local days with a reading in the 7 days ending [today].
int bloodPressureDaysLoggedThisWeek(
  Iterable<BloodPressureReading> readings,
  LocalDate today,
) => {for (final r in _inWeek(readings, today)) r.day}.length;

/// Mean of every reading in the 7 local days ending [today] (inclusive).
/// Null when fewer than 5 distinct days have readings.
BloodPressureWeeklyAverage? bloodPressureWeeklyAverage(
  Iterable<BloodPressureReading> readings,
  LocalDate today,
) {
  final week = _inWeek(readings, today).toList();
  final days = {for (final r in week) r.day}.length;
  if (days < bloodPressureWeeklyMinimumDays) return null;
  var systolicSum = 0;
  var diastolicSum = 0;
  for (final r in week) {
    systolicSum += r.systolic;
    diastolicSum += r.diastolic;
  }
  final systolic = systolicSum / week.length;
  final diastolic = diastolicSum / week.length;
  final category = classifyBloodPressure(systolic, diastolic);
  return BloodPressureWeeklyAverage(
    systolic: systolic,
    diastolic: diastolic,
    daysWithReadings: days,
    readingCount: week.length,
    category: category,
    showHomeThresholdNote:
        category != null &&
        category.index < BloodPressureCategory.grade1.index &&
        (systolic >= homeThresholdSystolic ||
            diastolic >= homeThresholdDiastolic),
  );
}

/// The spans the chart and history can be shown over. [days] is inclusive
/// of today; null means everything.
enum BloodPressureRange {
  days30(30),
  days90(90),
  oneYear(365),
  all(null);

  const BloodPressureRange(this.days);

  final int? days;
}

/// Readings whose local [BloodPressureReading.day] falls inside [range]
/// ending [today], in the input order.
List<BloodPressureReading> bloodPressureReadingsInRange(
  Iterable<BloodPressureReading> readings,
  BloodPressureRange range,
  LocalDate today,
) {
  final span = range.days;
  if (span == null) return readings.toList();
  final start = today.addDays(-(span - 1));
  return readings.where((r) => !r.day.isBefore(start)).toList();
}
