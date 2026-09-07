import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The wrapper every modal bottom sheet must go through.
const _wrapperPath = 'lib/core/widgets/app_bottom_sheet.dart';

/// Guard: every modal bottom sheet goes through `showAppBottomSheet`.
///
/// Two device bugs, one mechanism (`lib/core/widgets/app_bottom_sheet.dart`):
///
/// * The shell tabs live in a `StatefulShellRoute`, so the default
///   `useRootNavigator: false` opens the sheet on the branch navigator -
///   clipped to the tab body above the `NavigationBar`, tabs still
///   tappable under the scrim, and left behind in the other branch's
///   stack on a tab switch. Seen 2026-09-02 (Wellbeing check-in sheet,
///   Cycle day sheet).
/// * Android draws edge-to-edge (mandatory on Android 15), so a sheet
///   that does not pad its content by `viewPadding.bottom` puts its last
///   row underneath the 3-button system navigation bar. Seen 2026-09-03
///   (the Wellbeing day sheet's "Mark as a recovery day").
///
/// A source scan rather than a widget test, like the other config-surface
/// guards: the failure only shows under the real shell on a real device,
/// so what is worth pinning is the call shape.
void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // Windows reports `lib\features\...`; _wrapperPath uses forward slashes.
  String normalise(File file) => file.path.replaceAll(RegExp(r'[\\/]'), '/');

  test('no file outside app_bottom_sheet.dart calls '
      'showModalBottomSheet directly', () {
    final offenders = <String>[];

    for (final file in dartFiles) {
      final path = normalise(file);
      if (path == _wrapperPath) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Only real calls: `showModalBottomSheet<T>(` or
        // `showModalBottomSheet(`; a dartdoc `[showModalBottomSheet]` is
        // not, and neither is a `///` line mentioning it.
        if (!RegExp(r'showModalBottomSheet(<[^>]*>)?\(').hasMatch(line) ||
            line.trimLeft().startsWith('///') ||
            line.trimLeft().startsWith('//')) {
          continue;
        }
        offenders.add('$path:${i + 1}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These sheets bypass showAppBottomSheet, so they get the branch '
          "navigator and/or no system nav-bar inset:\n${offenders.join('\n')}",
    );
  });

  test('showAppBottomSheet passes useRootNavigator and useSafeArea', () {
    final source = File(_wrapperPath).readAsStringSync();

    expect(
      source.contains('useRootNavigator: true'),
      isTrue,
      reason: 'Without it every sheet opens on the shell branch navigator.',
    );
    expect(
      source.contains('useSafeArea: true'),
      isTrue,
      reason: 'Without it a tall sheet runs under the status bar.',
    );
    // The bottom inset is the wrapper's own job - `useSafeArea` only
    // guards the top (`SafeArea(bottom: false)` inside Flutter's
    // `ModalBottomSheetRoute`).
    expect(
      source.contains('viewPadding.bottom'),
      isTrue,
      reason: 'The system navigation bar inset must be applied here.',
    );
    expect(
      source.contains('viewInsets.bottom'),
      isTrue,
      reason: 'The keyboard inset must be applied here.',
    );
  });
}
