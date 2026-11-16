import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';

// Owner-approved copy, verbatim from the "Draft copy" section of
// knowledge/research/blood_pressure_classification.md. Change only with a new
// sign-off; the vocabulary gate is test/features/health/presentation/
// blood_pressure_copy_test.dart.

const bpSectionTitle = 'Blood pressure';
const bpAddReading = 'Add reading';
const bpEmptyState = 'No blood pressure readings yet.';
const bpRangeEmpty = 'No readings in this range.';
const bpUnit = 'mmHg';

const bpSourceLine =
    'Categories: National Heart Foundation of Australia, Guideline for the '
    'diagnosis and management of hypertension in adults (2016). Defined for '
    'clinic readings.';

const bpNotADiagnosis =
    'This shows where your numbers sit in a published guideline. It is not a '
    'diagnosis or medical advice. Only a health professional can diagnose '
    'high blood pressure.';

const bpSingleReading =
    'One reading is a snapshot. Blood pressure changes through the day. The '
    'guideline works from averages: two readings a minute apart, morning and '
    'evening, over about a week.';

const bpHomeNote =
    'Home readings usually run lower than clinic readings. The same guideline '
    'treats a home average of 135/85 or more like 140/90 in a clinic.';

const bpAgeSex =
    'These categories are the same for all adults. They do not change with '
    'age or sex.';

const bpHighestRangeLine =
    'This reading is in the highest range of the guideline. Sit quietly for '
    'five minutes and measure again. If it is still this high, contact a '
    'doctor today. If you also have chest pain, shortness of breath, a severe '
    'headache, confusion, weakness or numbness, or trouble seeing or '
    'speaking, call 000 now.';

const bpLowLine =
    'This reading is below the ranges the guideline classifies. Low blood '
    'pressure is often normal, especially in fit people. If you feel dizzy, '
    'faint or unwell, talk to a doctor. If you collapse or feel very unwell, '
    'call 000.';

// Average variants: an average is not a reading, so no "measure again".
const bpAverageHighestRangeLine =
    'Your 7-day average is in the highest range of the guideline. Contact a '
    'doctor today. If you also have chest pain, shortness of breath, a severe '
    'headache, confusion, weakness or numbness, or trouble seeing or '
    'speaking, call 000 now.';

const bpAverageLowLine =
    'Your 7-day average is below the ranges the guideline classifies. Low '
    'blood pressure is often normal, especially in fit people. If you feel '
    'dizzy, faint or unwell, talk to a doctor. If you collapse or feel very '
    'unwell, call 000.';

const bpChartCaption =
    'Dashed lines: 140/90, where the hypertension range starts in the Heart '
    'Foundation 2016 guideline (clinic readings).';
const bpChartTooFew = 'Log at least 2 readings in this range to see a chart.';
const bpLegendSystolic = 'Systolic (top number)';
const bpLegendDiastolic = 'Diastolic (bottom number)';

const bpWeeklyAverageTitle = '7-day average';

String bpWeeklyHint(int daysLogged) =>
    'Log readings on $bloodPressureWeeklyMinimumDays of the last '
    '$bloodPressureWeeklyWindowDays days to see a weekly average. '
    '$daysLogged of $bloodPressureWeeklyMinimumDays so far.';

String bpWeeklyBasis(int readings, int days) =>
    'Average of $readings ${readings == 1 ? 'reading' : 'readings'} '
    'on $days days.';

// Floor, not round: floor(x) >= n exactly when x >= n for whole thresholds,
// so a 129.6 average shows as 129 next to its "Normal" label, never 130.
String bpValues(num systolic, num diastolic) =>
    '${systolic.floor()}/${diastolic.floor()} $bpUnit';

extension BloodPressureCategoryLabel on BloodPressureCategory {
  String get label => switch (this) {
    BloodPressureCategory.optimal => 'Optimal',
    BloodPressureCategory.normal => 'Normal',
    BloodPressureCategory.highNormal => 'High-normal',
    BloodPressureCategory.grade1 => 'Grade 1 (mild) hypertension range',
    BloodPressureCategory.grade2 => 'Grade 2 (moderate) hypertension range',
    BloodPressureCategory.grade3 => 'Grade 3 (severe) hypertension range',
  };
}

extension BloodPressureRangeLabel on BloodPressureRange {
  String get label => switch (this) {
    BloodPressureRange.days30 => '30 d',
    BloodPressureRange.days90 => '90 d',
    BloodPressureRange.oneYear => '1 y',
    BloodPressureRange.all => 'All',
  };
}
