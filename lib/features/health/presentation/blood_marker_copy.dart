import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reference.dart';

// Copy from the "Draft copy" section of
// knowledge/research/blood_glucose_reference_ranges.md, narrowed by the
// orchestrator's ruling (no "well above" line, no 3.0-3.9 soft note, no
// before-meal range). The vocabulary gate is
// test/features/health/presentation/blood_marker_copy_test.dart.

const glucoseSectionTitle = 'Blood glucose';
const glucoseAddReading = 'Add reading';
const glucoseEmptyState = 'No blood glucose readings yet.';
const glucoseRangeEmpty = 'No readings in this range.';
const glucoseChartTooFew =
    'Log at least 2 readings in this range to see a chart.';
const glucoseReferenceTitle = 'Reference ranges';
const glucoseContextHint = 'Choose when this was measured';

const glucoseRangeFastingMmol = 'Reference range, fasting: 3.0–5.4 mmol/L';
// mg/dL bounds are the outermost whole values the 1 dp mmol/L rule counts
// as within (98 mg/dL -> 5.44 -> 5.4), hence "about".
const glucoseRangeFastingMgDl = 'Reference range, fasting: about 54–98 mg/dL';
const glucoseRangeAfterMealMmol =
    'Reference range, 2 hours or more after eating: 3.0–7.7 mmol/L';
const glucoseRangeAfterMealMgDl =
    'Reference range, 2 hours or more after eating: about 54–139 mg/dL';
const glucoseNoRange = 'No reference range for this context.';

const glucoseSourceLine =
    'Source: RCPA Manual, Glucose reference interval (Royal College of '
    'Pathologists of Australasia, reviewed 2024). Defined for laboratory '
    'tests on blood from a vein, for adults in general.';

const glucoseNotADiagnosis =
    'This shows where your reading sits against a published reference range. '
    'It is not a diagnosis or medical advice. Only a health professional can '
    'interpret your results.';

const glucoseScopeLine =
    'This range is for adults without diagnosed diabetes. If you have '
    'diabetes or take medicine that lowers glucose, use the targets from your '
    'care team.';

const glucoseMeterLine =
    'Finger-prick meters and laboratory tests differ. A meter can read up to '
    'about 15% away from a laboratory result, and readings after food run '
    'higher from a finger-prick. One reading is a snapshot.';

const glucoseAboveLine =
    'If your readings are often above the range, mention it to a health '
    'professional. They can arrange a laboratory test.';

const glucoseBelowLine =
    'This reading is below the reference range. Wash and dry your hands and '
    'measure again. If it is still this low and you feel shaky, sweaty, dizzy '
    'or confused, eat or drink something sugary and contact a health '
    'professional today.';

const glucoseUrgentLine =
    'If someone is very drowsy, cannot swallow, has a seizure or passes out, '
    'call 000.';

/// Range lines for the "Reference ranges" block, in [unit].
List<String> glucoseRangeLines(BloodMarkerUnit unit) => switch (unit) {
  BloodMarkerUnit.mmolPerL => const [
    glucoseRangeFastingMmol,
    glucoseRangeAfterMealMmol,
  ],
  BloodMarkerUnit.mgPerDl => const [
    glucoseRangeFastingMgDl,
    glucoseRangeAfterMealMgDl,
  ],
};

/// The reading in the unit it was entered in: mmol/L at 1 dp, mg/dL whole
/// unless entered with a fraction.
String glucoseValue(double value, BloodMarkerUnit unit) {
  final text = value.toStringAsFixed(1);
  final shown = unit == BloodMarkerUnit.mgPerDl && text.endsWith('.0')
      ? text.substring(0, text.length - 2)
      : text;
  return '$shown ${unit.label}';
}

extension ReferencePositionLabel on ReferencePosition {
  String get label => switch (this) {
    ReferencePosition.below => 'Below the reference range',
    ReferencePosition.within => 'Within the reference range',
    ReferencePosition.above => 'Above the reference range',
  };
}
