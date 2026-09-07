import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/presentation/hub/mindful_custom_section.dart';

/// Guard for ADR 014 §5: the mindful style vocabulary lives in exactly one
/// place.
///
/// It did not, and the drift was user-visible: the hub's card offered three
/// chips labelled "Restorative / Yin", "Vinyasa Flow", "Hatha & Alignment"
/// and handed the tracker "Restorative Yin" / "Vinyasa Flow" / "Hatha
/// Yoga", none of which were in the tracker's own seven-item literal — so
/// arriving from a style chip always left the tracker with nothing
/// selected.
///
/// A source scan rather than a widget test: what has to stay true is that
/// no file *re-declares* the list, which a rendering test cannot see.
void main() {
  /// The one file allowed to name a style that appears nowhere else.
  const sourceOfTruth = 'lib/features/activity/domain/mindful_styles.dart';

  /// The per-style copy shown in the hub's style dialog. It mentions every
  /// style because it is keyed by them — the key-set assertion below is
  /// what stops it drifting into a second list.
  const descriptionCopy =
      'lib/features/activity/presentation/hub/mindful_custom_section.dart';

  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // Windows reports `lib\features\...`.
  String normalise(File file) => file.path.replaceAll(RegExp(r'[\\/]'), '/');

  test("'Kundalini' appears in lib/ only in mindful_styles.dart "
      'and the style-copy map', () {
    final offenders = <String>[];

    for (final file in dartFiles) {
      final path = normalise(file);
      if (path == sourceOfTruth || path == descriptionCopy) continue;
      if (file.readAsStringSync().contains('Kundalini')) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A style label outside $sourceOfTruth means a second copy of the '
          'list. Read MindfulStyles instead.',
    );
  });

  test("'Power Yoga' appears in lib/ only in mindful_styles.dart "
      'and the style-copy map', () {
    // The manual-entry form's mindful (yoga/pilates) section held a fourth
    // copy of the style list ('Vinyasa Flow', 'Restorative Yin', ... —
    // labels the hub and tracker no longer use) until it was switched to
    // read `MindfulStyles.stylesFor`. This guards against it (or another
    // screen) reintroducing a literal list.
    final offenders = <String>[];

    for (final file in dartFiles) {
      final path = normalise(file);
      if (path == sourceOfTruth || path == descriptionCopy) continue;
      if (file.readAsStringSync().contains('Power Yoga')) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A style label outside $sourceOfTruth means a second copy of the '
          'list. Read MindfulStyles instead.',
    );
  });

  test('the tracker and the hub screen hold no style literals', () {
    for (final path in const [
      'lib/features/activity/presentation/recording/mindful_tracker_screen.dart',
      'lib/features/activity/presentation/hub/exercise_hub_screen.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('Vinyasa'),
        isFalse,
        reason: '$path must read MindfulStyles, not spell styles out.',
      );
      expect(
        source.contains("'Yin'"),
        isFalse,
        reason: '$path must read MindfulStyles, not spell styles out.',
      );
    }
  });

  test('every offered style has copy, and the copy invents no styles', () {
    expect(
      mindfulStyleDescriptions.keys.toSet(),
      {...MindfulStyles.yogaStyles, ...MindfulStyles.pilatesStyles},
    );
  });

  test('yoga offers seven styles and pilates five', () {
    expect(MindfulStyles.yogaStyles, hasLength(7));
    expect(MindfulStyles.pilatesStyles, hasLength(5));
  });
}
