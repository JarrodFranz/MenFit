import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: `audioplayers` is a platform plugin and lives behind an adapter.
///
/// Architecture rule 4 (`knowledge/architecture/architecture_overview.md`):
/// nothing outside `core/platform/` may import a plugin-specific API. Audio
/// has four materially different platform behaviours — Android ducks, iOS
/// obeys the silent switch and mixes, the web refuses to play without a
/// user gesture, and Windows N has no Media Foundation — and each one only
/// stays handled in one place if there is only one place. A source scan,
/// like the sibling `share_plus` guard, because an `import
/// 'package:audioplayers/...'` in a feature widget compiles perfectly well
/// and only shows up as a bug on one platform.
void main() {
  test('only audioplayers_cue_player.dart imports audioplayers', () {
    const allowedFile = 'lib/core/platform/audio/audioplayers_cue_player.dart';

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
          r'''^\s*(import|export)\s+['"]package:audioplayers''',
        ).hasMatch(line)) {
          offenders.add('$normalised:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'audioplayers belongs behind AudioCuePlayer ($allowedFile), not '
          'in feature code:\n${offenders.join('\n')}',
    );
  });
}
