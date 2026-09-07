import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: `share_plus` is a platform plugin and lives behind an adapter.
///
/// Architecture rule 4 (`knowledge/architecture/architecture_overview.md`):
/// nothing outside `core/platform/` may import a plugin-specific API. The
/// share sheet has four materially different platform behaviours — no
/// result on Windows, no Web Share API in desktop Firefox, an iPad
/// popover origin, no file share on Linux — and each one only stays
/// handled in one place if there is only one place. A source scan, like
/// the other config-surface guards, because an import in a feature widget
/// compiles perfectly well and only shows up as a bug on one platform.
void main() {
  test('only core/platform/sharing imports share_plus', () {
    const allowedDirectory = 'lib/core/platform/sharing';

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      if (normalised.startsWith(allowedDirectory)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('///')) continue;
        if (RegExp(r'''^\s*(import|export)\s+['"]package:share_plus''')
            .hasMatch(line)) {
          offenders.add('$normalised:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'share_plus belongs behind SharingAdapter '
          '($allowedDirectory), not in feature code:\n${offenders.join('\n')}',
    );
  });
}
