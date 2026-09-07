import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture Guard: Domain layer isolation.
///
/// Architecture rule (`knowledge/architecture/architecture_overview.md` & `CLAUDE.md`):
/// "domain/ has no Flutter imports; features depend only on other features' domain/;
/// platform code behind adapters."
///
/// Any domain logic must remain pure Dart and dependency-free.
void main() {
  test('domain layer files have zero package:flutter imports', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              f.path.replaceAll(r'\', '/').contains('/domain/'),
        );

    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('///')) continue;
        if (RegExp(
          r'''^\s*(import|export)\s+['"]package:flutter/''',
        ).hasMatch(line)) {
          offenders.add('$normalised:${i + 1}: $line');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Domain models and logic must not import package:flutter:\n'
          '${offenders.join('\n')}',
    );
  });
}
