import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/presentation/mindful_style_options.dart';

/// Guards the manual-entry mindful section's backwards-compatibility
/// contract: editing an activity that carries a style/focus-area label the
/// current [MindfulStyles] lists no longer offer must still show it,
/// selected, as an extra chip — never drop or remap it silently.
void main() {
  group('mindfulStyleChoices', () {
    test('returns MindfulStyles.yogaStyles unchanged for a current style', () {
      final choices = mindfulStyleChoices(ActivityType.yoga, 'Vinyasa');

      expect(choices, MindfulStyles.yogaStyles);
    });

    test('returns MindfulStyles.pilatesStyles for pilates', () {
      final choices = mindfulStyleChoices(
        ActivityType.pilates,
        'Mat Pilates',
      );

      expect(choices, MindfulStyles.pilatesStyles);
    });

    test(
      "appends a legacy style ('Restorative Yin') no longer in the list",
      () {
        final choices = mindfulStyleChoices(
          ActivityType.yoga,
          'Restorative Yin',
        );

        expect(choices, [...MindfulStyles.yogaStyles, 'Restorative Yin']);
      },
    );

    test('does not duplicate a legacy style already offered', () {
      final choices = mindfulStyleChoices(ActivityType.yoga, 'Hatha');

      expect(choices.where((s) => s == 'Hatha'), hasLength(1));
    });

    test('appends nothing for "no style" — a blank chip is not a choice', () {
      final choices = mindfulStyleChoices(ActivityType.yoga, '');

      expect(choices, MindfulStyles.yogaStyles);
      expect(choices, isNot(contains('')));
    });
  });

  group('mindfulStyleAfterTypeChange', () {
    test('drops a yoga style when the entry becomes Pilates', () {
      final style = mindfulStyleAfterTypeChange(
        current: 'Vinyasa',
        from: ActivityType.yoga,
        to: ActivityType.pilates,
      );

      expect(style, isEmpty, reason: 'Pilates never offered Vinyasa.');
    });

    test('drops a Pilates style when the entry becomes yoga', () {
      final style = mindfulStyleAfterTypeChange(
        current: 'Mat Pilates',
        from: ActivityType.pilates,
        to: ActivityType.yoga,
      );

      expect(style, isEmpty);
    });

    test('keeps a style the new type also offers', () {
      final style = mindfulStyleAfterTypeChange(
        current: 'Vinyasa',
        from: ActivityType.yoga,
        to: ActivityType.other,
      );

      expect(style, 'Vinyasa');
    });

    test('keeps a legacy label that belongs to neither vocabulary', () {
      final style = mindfulStyleAfterTypeChange(
        current: 'Restorative Yin',
        from: ActivityType.yoga,
        to: ActivityType.pilates,
      );

      expect(
        style,
        'Restorative Yin',
        reason: 'A value she typed or a label we retired is still hers.',
      );
    });

    test('leaves "no style" alone', () {
      final style = mindfulStyleAfterTypeChange(
        current: '',
        from: ActivityType.yoga,
        to: ActivityType.pilates,
      );

      expect(style, isEmpty);
    });
  });

  group('mindfulFocusAreaChoices', () {
    test('returns MindfulStyles.focusAreas unchanged for a current value', () {
      final choices = mindfulFocusAreaChoices('Full Body Flow');

      expect(choices, MindfulStyles.focusAreas);
    });

    test(
      "appends a legacy focus area ('Hips & Spine') no longer in the list",
      () {
        final choices = mindfulFocusAreaChoices('Hips & Spine');

        expect(choices, [...MindfulStyles.focusAreas, 'Hips & Spine']);
      },
    );

    test('appends nothing for "no focus area"', () {
      final choices = mindfulFocusAreaChoices('');

      expect(choices, MindfulStyles.focusAreas);
      expect(choices, isNot(contains('')));
    });
  });
}
