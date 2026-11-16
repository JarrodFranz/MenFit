import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reference.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';

void main() {
  // Approved sentences that may name diagnosis or diabetes: the scope line,
  // the not-a-diagnosis line and the source line.
  const approved = {glucoseScopeLine, glucoseNotADiagnosis, glucoseSourceLine};

  final copy = <String, String>{
    'sectionTitle': glucoseSectionTitle,
    'addReading': glucoseAddReading,
    'empty': glucoseEmptyState,
    'rangeEmpty': glucoseRangeEmpty,
    'tooFew': glucoseChartTooFew,
    'referenceTitle': glucoseReferenceTitle,
    'contextHint': glucoseContextHint,
    'fastingMmol': glucoseRangeFastingMmol,
    'fastingMgDl': glucoseRangeFastingMgDl,
    'afterMealMmol': glucoseRangeAfterMealMmol,
    'afterMealMgDl': glucoseRangeAfterMealMgDl,
    'noRange': glucoseNoRange,
    'source': glucoseSourceLine,
    'notADiagnosis': glucoseNotADiagnosis,
    'scope': glucoseScopeLine,
    'meter': glucoseMeterLine,
    'above': glucoseAboveLine,
    'below': glucoseBelowLine,
    'urgent': glucoseUrgentLine,
    for (final p in ReferencePosition.values) 'position.${p.name}': p.label,
    for (final c in GlucoseContext.values) 'context.${c.name}': c.label,
  };

  final forbidden = RegExp(
    r'\b(normal|abnormal|good|bad|healthy|unhealthy|dangerous)\b',
    caseSensitive: false,
  );
  final restricted = RegExp('diagnos|diabet', caseSensitive: false);

  for (final MapEntry(:key, :value) in copy.entries) {
    test('$key uses no valence, diagnosis or diabetes wording', () {
      expect(forbidden.hasMatch(value), isFalse, reason: value);
      if (!approved.contains(value)) {
        expect(restricted.hasMatch(value), isFalse, reason: value);
      }
    });
  }

  test('the unimplemented lines are absent', () {
    for (final text in copy.values) {
      expect(text, isNot(contains('15.0')));
      expect(text, isNot(contains('under 4.0')));
    }
  });

  test('mg/dL range lines agree with the 1 dp comparison rule', () {
    // The outermost whole mg/dL values the rule counts as within.
    String bounds(GlucoseContext context) {
      final ref = bloodMarkerReferenceFor(BloodMarker.glucose, context)!;
      final within = [
        for (var mg = 1; mg <= 300; mg++)
          if (positionInReference(
                ref,
                mg.toDouble(),
                BloodMarkerUnit.mgPerDl,
              ) ==
              ReferencePosition.within)
            mg,
      ];
      return 'about ${within.first}–${within.last} mg/dL';
    }

    expect(bounds(GlucoseContext.fasting), 'about 54–98 mg/dL');
    expect(glucoseRangeFastingMgDl, endsWith(bounds(GlucoseContext.fasting)));
    expect(
      glucoseRangeAfterMealMgDl,
      endsWith(bounds(GlucoseContext.afterMeal)),
    );
  });

  test('above line does not reassure', () {
    expect(
      glucoseAboveLine,
      'If your readings are often above the range, mention it to a health '
      'professional. They can arrange a laboratory test.',
    );
    expect(glucoseAboveLine, isNot(contains('common')));
  });

  test('value formatting keeps the entered unit', () {
    expect(glucoseValue(5.2, BloodMarkerUnit.mmolPerL), '5.2 mmol/L');
    expect(glucoseValue(5, BloodMarkerUnit.mmolPerL), '5.0 mmol/L');
    expect(glucoseValue(94, BloodMarkerUnit.mgPerDl), '94 mg/dL');
    expect(glucoseValue(94.5, BloodMarkerUnit.mgPerDl), '94.5 mg/dL');
  });

  test('after-meal label states the 2 hour qualifier', () {
    expect(GlucoseContext.afterMeal.label, 'After a meal (2 h or more)');
    expect(GlucoseContext.afterMeal.toStorage(), 'afterMeal');
  });
}
