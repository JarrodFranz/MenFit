import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: the label parser stays pure Dart.
///
/// Architecture rule 1 (`knowledge/architecture/architecture_overview.md`):
/// `domain/` imports no Flutter. It matters more than usual here. The
/// parser is the only part of the OCR feature that can be exercised
/// without a camera, a plugin or a device, and ADR 012 leaves Web and
/// Windows with **no** OCR path at all — so the day this file's rule is
/// broken is the day the heuristic stops being testable on the machine it
/// is developed on. A `package:flutter` import compiles perfectly well;
/// nothing but this test would notice.
///
/// The recognition engine is fenced off for the same reason and one more:
/// `OcrResult` and friends are domain-owned deliberately, so that
/// swapping ML Kit for Apple Vision or `Windows.Media.Ocr` is an adapter
/// change and not a parser change.
void main() {
  /// Both halves of the parser's own code: its heuristics, and the shared
  /// recognised-text value types it reads.
  ///
  /// `core/domain/ocr/` is scanned here rather than merely *allowed*.
  /// `OcrRect`/`OcrLine`/`OcrResult` moved there so that one declaration
  /// serves the platform adapter that produces them and the parser that
  /// consumes them (architecture rule 3: truly shared entities live in
  /// `core/domain`, never copied between layers). That import is legal —
  /// rule 1 forbids Flutter, not `core/domain` — but it would be a hole in
  /// this guard if the shared file were free to import what the parser
  /// cannot: a `dart:ui` `Rect` in `core/domain/ocr/` breaks the parser's
  /// testability just as thoroughly as one declared next to it.
  const scannedDirectories = [
    'lib/features/nutrition/domain/label_ocr',
    'lib/core/domain/ocr',
  ];

  /// Imports that would each break something specific:
  /// - Flutter and `dart:ui` make the parser untestable without a binding.
  /// - `dart:io` makes it unusable on Web.
  /// - an engine package would put a plugin inside the domain layer.
  /// - `core/platform` would invert the dependency the adapter exists for.
  const forbidden = <String, String>{
    'package:flutter': 'Flutter',
    'dart:ui': 'dart:ui',
    'dart:io': 'dart:io',
    'package:google_mlkit': 'an OCR engine package',
    'package:menfit_app/core/platform': 'a platform adapter',
  };

  test('nothing under label_ocr/ imports Flutter, dart:io or an engine', () {
    final files = <File>[];
    for (final path in scannedDirectories) {
      final directory = Directory(path);
      expect(directory.existsSync(), isTrue, reason: '$path should exist');
      files.addAll(
        directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
      );
    }
    expect(files, isNotEmpty, reason: 'the guard must have files to scan');

    final offenders = <String>[];
    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('///')) continue;
        for (final entry in forbidden.entries) {
          final pattern = RegExp(
            '''^\\s*(import|export)\\s+['"]${RegExp.escape(entry.key)}''',
          );
          if (pattern.hasMatch(line)) {
            offenders.add('$normalised:${i + 1} (${entry.value})');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'The label parser must stay pure Dart — it is the only part of '
          'this feature that can be tested without a device:\n'
          '${offenders.join('\n')}',
    );
  });
}
