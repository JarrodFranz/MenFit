import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: `wakelock_plus` is a platform plugin and lives behind an adapter.
///
/// Architecture rule 4 (`knowledge/architecture/architecture_overview.md`).
/// The specific hazard this port exists to contain is an *unbalanced* lock:
/// a screen kept awake by a screen that has been popped is a flat battery,
/// and it is invisible on the dev machine. That only stays containable while
/// there is exactly one place that can take the lock. A source scan, like
/// the sibling `share_plus` and `audioplayers` guards.
void main() {
  test('only wakelock_plus_screen_awake.dart imports wakelock_plus', () {
    const allowedFile =
        'lib/core/platform/wakelock/wakelock_plus_screen_awake.dart';

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      if (normalised == allowedFile) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('///')) continue;
        if (RegExp(
          r'''^\s*(import|export)\s+['"]package:wakelock_plus''',
        ).hasMatch(line)) {
          offenders.add('$normalised:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'wakelock_plus belongs behind ScreenAwake ($allowedFile), not in '
          'feature code:\n${offenders.join('\n')}',
    );
  });
}
