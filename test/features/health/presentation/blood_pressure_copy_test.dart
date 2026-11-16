import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_category.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';

void main() {
  // Approved sentences that must name diagnosis: the not-a-diagnosis line and
  // the guideline's own title in the source line.
  const approvedDiagnosisCopy = {bpNotADiagnosis, bpSourceLine};

  final copy = <String, String>{
    'sectionTitle': bpSectionTitle,
    'addReading': bpAddReading,
    'empty': bpEmptyState,
    'rangeEmpty': bpRangeEmpty,
    'source': bpSourceLine,
    'notADiagnosis': bpNotADiagnosis,
    'singleReading': bpSingleReading,
    'homeNote': bpHomeNote,
    'ageSex': bpAgeSex,
    'highest': bpHighestRangeLine,
    'low': bpLowLine,
    'averageHighest': bpAverageHighestRangeLine,
    'averageLow': bpAverageLowLine,
    'caption': bpChartCaption,
    'tooFew': bpChartTooFew,
    'legendSystolic': bpLegendSystolic,
    'legendDiastolic': bpLegendDiastolic,
    'weeklyTitle': bpWeeklyAverageTitle,
    'hint': bpWeeklyHint(3),
    'basis': bpWeeklyBasis(7, 5),
    for (final c in BloodPressureCategory.values) 'category.${c.name}': c.label,
    for (final r in BloodPressureRange.values) 'range.${r.name}': r.label,
  };

  final forbidden = RegExp(
    r'\b(good|bad|healthy|unhealthy|dangerous)\b',
    caseSensitive: false,
  );
  final diagnosis = RegExp('diagnos', caseSensitive: false);

  for (final MapEntry(:key, :value) in copy.entries) {
    test('$key uses no valence or diagnosis wording', () {
      expect(forbidden.hasMatch(value), isFalse, reason: value);
      if (!approvedDiagnosisCopy.contains(value)) {
        expect(diagnosis.hasMatch(value), isFalse, reason: value);
      }
    });
  }

  test('category labels are the approved wording', () {
    expect(
      [for (final c in BloodPressureCategory.values) c.label],
      [
        'Optimal',
        'Normal',
        'High-normal',
        'Grade 1 (mild) hypertension range',
        'Grade 2 (moderate) hypertension range',
        'Grade 3 (severe) hypertension range',
      ],
    );
  });

  test('weekly hint and value formatting', () {
    expect(
      bpWeeklyHint(2),
      'Log readings on 5 of the last 7 days to see a weekly average. '
      '2 of 5 so far.',
    );
    expect(bpValues(129.6, 84.9), '129/84 mmHg');
  });
}
