import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/domain/weight_validation.dart';
import 'package:menfit_app/features/weight/presentation/weight_copy.dart';

import 'weight_test_vocabulary.dart';

/// Copy gate for the most ED-sensitive surface in the app.
///
/// Same shape as `features/insights/insight_sentence_test.dart`'s
/// forbidden-word assertions. The vocabulary itself lives in
/// `weight_test_vocabulary.dart`, shared with `weight_screen_test.dart`'s
/// widget-level sweep so the two gates cannot drift apart.
void main() {
  final allCopy = <String, String>{
    'sectionTitle': weightSectionTitle,
    'latestLabel': weightLatestLabel,
    'emptyState': weightEmptyStateMessage,
    'rangeEmpty': weightRangeEmptyMessage,
    'minimumData': weightMinimumDataNote,
    'fluidNote.metric': weightFluidNote(UnitSystem.metric),
    'fluidNote.imperial': weightFluidNote(UnitSystem.imperial),
    for (final direction in WeightTrendDirection.values)
      'direction.${direction.name}': weightTrendSentence(direction),
  };

  Map<String, String> validationMessages() {
    final today = LocalDate(2026, 9, 1);
    final messages = <String, String>{};
    void add(String key, String? message) {
      if (message != null) messages[key] = message;
    }

    add(
      'blankWeight',
      validateWeightLog(
        today: today,
        day: today,
        rawWeightInput: '',
      ).weightError,
    );
    add(
      'unparseableWeight',
      validateWeightLog(
        today: today,
        day: today,
        rawWeightInput: 'sixty',
      ).weightError,
    );
    add(
      'outOfRange.metric',
      validateWeightLog(today: today, day: today, weightKg: 900).weightError,
    );
    add(
      'outOfRange.imperial',
      validateWeightLog(
        today: today,
        day: today,
        weightKg: 900,
        unitSystem: UnitSystem.imperial,
      ).weightError,
    );
    add(
      'futureDay',
      validateWeightLog(
        today: today,
        day: today.addDays(1),
        weightKg: 62,
      ).dayError,
    );
    add(
      'longNote',
      validateWeightLog(
        today: today,
        day: today,
        weightKg: 62,
        notes: 'x' * 900,
      ).notesError,
    );
    return messages;
  }

  group('every user-facing string', () {
    test('avoids the judgement vocabulary', () {
      for (final entry in {...allCopy, ...validationMessages()}.entries) {
        expectNoJudgementVocabulary(entry.value, source: entry.key);
      }
    });

    test('never quotes a weight value', () {
      // S2: the copy is fixed text. The reading is rendered separately by
      // `weight_format.dart`, so nothing here may carry a number that
      // came from the user.
      for (final entry in allCopy.entries) {
        if (entry.key == 'minimumData') continue; // quotes a fixed constant
        expect(
          entry.value,
          isNot(matches(RegExp(r'\d'))),
          reason: '${entry.key} contains a digit',
        );
      }
    });
  });

  group('direction sentences', () {
    test('name a direction and stop there', () {
      expect(
        weightTrendSentence(WeightTrendDirection.rising),
        'Trending upward across this range.',
      );
      expect(
        weightTrendSentence(WeightTrendDirection.falling),
        'Trending downward across this range.',
      );
      expect(
        weightTrendSentence(WeightTrendDirection.steady),
        'Holding steady across this range.',
      );
    });

    test('say "not enough yet" rather than "flat" when undetermined', () {
      final sentence = weightTrendSentence(
        WeightTrendDirection.undetermined,
      ).toLowerCase();

      expect(sentence, contains('not enough'));
      expect(sentence, isNot(contains('steady')));
      expect(sentence, isNot(contains('flat')));
    });

    test('are distinct from one another', () {
      final sentences = {
        for (final direction in WeightTrendDirection.values)
          weightTrendSentence(direction),
      };

      expect(sentences, hasLength(WeightTrendDirection.values.length));
    });
  });

  group('the fluid-shift explainer', () {
    test('attributes day-to-day movement to fluid', () {
      expect(
        weightFluidNote(UnitSystem.metric).toLowerCase(),
        contains('fluid'),
      );
    });

    test('names the magnitude in the unit the user reads', () {
      expect(weightFluidNote(UnitSystem.metric), contains('kilogram'));
      expect(weightFluidNote(UnitSystem.imperial), contains('pound'));
      expect(
        weightFluidNote(UnitSystem.imperial),
        isNot(contains('kilogram')),
      );
    });
  });

  test('the empty state invites without setting a target', () {
    final message = weightEmptyStateMessage.toLowerCase();

    expect(message, contains('whenever'));
    expect(message, isNot(contains('start tracking')));
    expect(message, isNot(contains('every day')));
  });

  group('the range-empty message', () {
    test('is a different sentence from the never-logged one', () {
      // Telling a user with months of history that they have "no weight
      // readings yet" is false, and reads as a prompt to log one now.
      expect(weightRangeEmptyMessage, isNot(weightEmptyStateMessage));
      expect(
        weightRangeEmptyMessage.toLowerCase(),
        isNot(contains('no weight readings yet')),
      );
    });

    test('says the window is empty, not the history', () {
      final message = weightRangeEmptyMessage.toLowerCase();

      expect(message, contains('nothing was logged'));
      expect(message, contains('still'));
    });

    test('points at the control that fixes it', () {
      expect(weightRangeEmptyMessage.toLowerCase(), contains('range'));
    });

    test('does not invite them to log one now', () {
      final message = weightRangeEmptyMessage.toLowerCase();

      expect(message, isNot(contains('log ')));
      expect(message, isNot(contains('add ')));
    });
  });
}
