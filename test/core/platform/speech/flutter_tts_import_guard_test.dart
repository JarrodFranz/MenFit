import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: `flutter_tts` is a platform plugin and lives behind an adapter.
///
/// Architecture rule 4 (`knowledge/architecture/architecture_overview.md`):
/// nothing outside `core/platform/speech/` may import `package:flutter_tts`.
void main() {
  test('only flutter_tts_speech_adapter.dart imports flutter_tts', () {
    const allowedFile =
        'lib/core/platform/speech/flutter_tts_speech_adapter.dart';

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
          r'''^\s*(import|export)\s+['"]package:flutter_tts''',
        ).hasMatch(line)) {
          offenders.add('$normalised:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'flutter_tts belongs behind SpeechAdapter ($allowedFile), not '
          'in feature code:\n${offenders.join('\n')}',
    );
  });
}
