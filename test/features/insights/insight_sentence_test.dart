import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';
import 'package:menfit_app/features/insights/presentation/insight_sentence.dart';

PersonalInsight _insight({
  InsightKind kind = InsightKind.proteinTargetNextDayOutput,
  InsightMetric metric = InsightMetric.strengthTonnageKg,
  InsightGroup higherGroup = InsightGroup.proteinTargetMet,
  InsightGroup lowerGroup = InsightGroup.proteinTargetNotMet,
  double relativeDifference = 0.14,
  int pairedObservations = 24,
  InsightConfidence confidence = InsightConfidence.emerging,
}) {
  return PersonalInsight(
    kind: kind,
    metric: metric,
    higherGroup: higherGroup,
    lowerGroup: lowerGroup,
    higherTypicalValue: 2280,
    lowerTypicalValue: 2000,
    higherGroupCount: 13,
    lowerGroupCount: 11,
    relativeDifference: relativeDifference,
    effectSize: 0.41,
    pairedObservations: pairedObservations,
    confidence: confidence,
    rangeStart: LocalDate(2026, 4, 2),
    rangeEnd: LocalDate(2026, 6, 28),
  );
}

/// Words that would turn a description into a cause, a prescription, or a
/// claim about anyone other than the user herself.
const List<String> _forbiddenWords = [
  'because',
  'should',
  'causes',
  'caused',
  'improves',
  'try ',
  'aim for',
  'women',
  'most people',
  'recommend',
];

void main() {
  group('composeInsightSentence', () {
    test('composes the protein/next-day sentence exactly', () {
      expect(
        composeInsightSentence(_insight()),
        'Across 24 logged days, your lifting volume was 14% higher on '
        'days after you hit your protein target than on days after you '
        "didn't hit your protein target.",
      );
    });

    test('composes a sleep sentence', () {
      expect(
        composeInsightSentence(
          _insight(
            kind: InsightKind.sleepScoreSameDayOutput,
            metric: InsightMetric.runDistanceMeters,
            higherGroup: InsightGroup.higherSleepScore,
            lowerGroup: InsightGroup.lowerSleepScore,
            relativeDifference: 0.185,
            pairedObservations: 18,
          ),
        ),
        'Across 18 logged days, your run distance was 19% higher on '
        'days you rated your sleep higher than on days you rated your '
        'sleep lower.',
      );
    });

    test('always carries its own sample size', () {
      for (final metric in InsightMetric.values) {
        final sentence = composeInsightSentence(_insight(metric: metric));
        expect(sentence, contains('logged days'));
        expect(sentence, contains('24'));
      }
    });

    test('never states a cause, a prescription, or a population claim', () {
      final sentences = <String>[
        for (final kind in InsightKind.values)
          for (final metric in InsightMetric.values)
            composeInsightSentence(_insight(kind: kind, metric: metric)),
        for (final group in InsightGroup.values)
          composeInsightSentence(_insight(higherGroup: group)),
      ];

      for (final sentence in sentences) {
        final lowercase = sentence.toLowerCase();
        for (final word in _forbiddenWords) {
          expect(
            lowercase,
            isNot(contains(word)),
            reason: '"$word" would make this more than a description',
          );
        }
      }
    });
  });

  group('composeInsightFootnote', () {
    test('names the confidence word and the span, never a probability', () {
      expect(
        composeInsightFootnote(_insight()),
        'Emerging pattern · Apr 2 – Jun 28',
      );
      expect(
        composeInsightFootnote(_insight(confidence: InsightConfidence.clear)),
        startsWith('Clear pattern'),
      );
      expect(composeInsightFootnote(_insight()), isNot(contains('%')));
      expect(composeInsightFootnote(_insight()), isNot(contains('p =')));
    });
  });
}
