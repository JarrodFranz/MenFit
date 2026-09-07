import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';

void main() {
  group('MindfulStyles', () {
    const lists = {
      'yogaStyles': MindfulStyles.yogaStyles,
      'pilatesStyles': MindfulStyles.pilatesStyles,
      'focusAreas': MindfulStyles.focusAreas,
    };

    for (final entry in lists.entries) {
      test('${entry.key} is non-empty, unique, and has no blank labels', () {
        expect(entry.value, isNotEmpty);
        expect(
          entry.value.toSet(),
          hasLength(entry.value.length),
          reason: 'a duplicated label would render twice in a chip row',
        );
        expect(entry.value.every((label) => label.trim().isNotEmpty), isTrue);
      });
    }

    test('the yoga and pilates vocabularies do not overlap', () {
      expect(
        MindfulStyles.yogaStyles.toSet().intersection(
          MindfulStyles.pilatesStyles.toSet(),
        ),
        isEmpty,
      );
    });

    group('stylesFor', () {
      test('pilates gets the pilates vocabulary', () {
        expect(
          MindfulStyles.stylesFor(ActivityType.pilates),
          MindfulStyles.pilatesStyles,
        );
      });

      test('yoga gets the yoga vocabulary', () {
        expect(
          MindfulStyles.stylesFor(ActivityType.yoga),
          MindfulStyles.yogaStyles,
        );
      });

      test('every other type falls back to the yoga vocabulary', () {
        for (final type in ActivityType.values) {
          if (type == ActivityType.pilates) continue;
          expect(
            MindfulStyles.stylesFor(type),
            MindfulStyles.yogaStyles,
            reason: '${type.name} must still get a usable list, never null',
          );
        }
      });
    });
  });
}
