import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: the OCR plugins live behind `OcrAdapter` and nowhere else.
///
/// Architecture rule 4 (`knowledge/architecture/architecture_overview.md`):
/// nothing outside `core/platform/` may import a plugin-specific API. Two
/// reasons this one needs a mechanical guard rather than review:
///
/// - `google_mlkit_text_recognition` exists on two of the app's four
///   platforms. An import in a feature widget compiles perfectly well and
///   only shows up as a bug on Windows or the web — and, because
///   `google_mlkit_commons` imports `dart:io` unconditionally, it shows up
///   on the web as a *compile* failure in a build nobody runs on this
///   machine by default.
/// - `image_picker` is the only thing in the app that can put a photo of a
///   user's food on the filesystem. Keeping its every use in one file is
///   what makes "the photo is deleted immediately" a checkable claim
///   instead of a hope (ADR 012, security_and_privacy.md S2).
///
/// Mirrors `test/core/platform/sharing/share_plus_import_guard_test.dart`.
void main() {
  // Trailing slash: without it the prefix test would also exempt a
  // sibling directory whose name merely starts with 'ocr'.
  const allowedDirectory = 'lib/core/platform/ocr/';

  const guarded = [
    'package:google_mlkit_text_recognition',
    'package:google_mlkit_commons',
    'package:image_picker',
  ];

  for (final package in guarded) {
    test('only $allowedDirectory imports $package', () {
      final offenders = <String>[];
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final pattern = RegExp(
        '''^\\s*(import|export)\\s+['"]${RegExp.escape(package)}''',
      );

      for (final file in files) {
        final normalised = file.path.replaceAll(r'\', '/');
        if (normalised.startsWith(allowedDirectory)) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('///')) continue;
          if (pattern.hasMatch(line)) offenders.add('$normalised:${i + 1}');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            '$package belongs behind OcrAdapter '
            '($allowedDirectory), not in feature code:\n'
            '${offenders.join('\n')}',
      );
    });
  }

  test('the shared recognised-text types are declared exactly once', () {
    // They were briefly declared twice — once beside the adapter that
    // produces them, once beside the parser that reads them — because
    // neither layer may import the other. The answer was `core/domain/ocr`
    // (architecture rule 3), not a second copy: two structurally identical
    // types with different APIs drift apart silently, and the drift only
    // surfaces as a mapping that compiles and reads the wrong field. This
    // asserts the single declaration site rather than trusting review.
    const declaredIn = 'lib/core/domain/ocr/ocr_text.dart';
    const shared = [
      'OcrRect',
      'OcrElement',
      'OcrLine',
      'OcrBlock',
      'OcrResult',
    ];

    final declarations = <String, List<String>>{
      for (final type in shared) type: <String>[],
    };
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final type in shared) {
          if (RegExp('^\\s*(final |base |sealed )?class $type\\b')
              .hasMatch(lines[i])) {
            declarations[type]!.add('$normalised:${i + 1}');
          }
        }
      }
    }

    for (final type in shared) {
      expect(
        declarations[type],
        hasLength(1),
        reason:
            '$type must be declared only in $declaredIn:\n'
            '${declarations[type]!.join('\n')}',
      );
      expect(declarations[type]!.single, startsWith(declaredIn));
    }
  });

  test('only the seam files reach the ML Kit adapter', () {
    // `ml_kit_ocr_adapter.dart` cannot be compiled for web
    // (`google_mlkit_commons` imports `dart:io`), so it may only be reached
    // through the conditional export in `ocr_platform.dart`. An import from
    // anywhere else — including elsewhere inside `core/platform/ocr/` —
    // puts `dart:io` back into the web compile and breaks
    // `flutter build web` on a machine that only builds Windows.
    const allowedImporters = {
      'lib/core/platform/ocr/ocr_platform_io.dart',
      'lib/core/platform/ocr/ml_kit_ocr_adapter.dart',
    };

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final normalised = file.path.replaceAll(r'\', '/');
      if (allowedImporters.contains(normalised)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('///')) continue;
        if (RegExp(
          r'''^\s*(import|export)\s+['"].*ml_kit_ocr_adapter\.dart''',
        ).hasMatch(line)) {
          offenders.add('$normalised:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'ml_kit_ocr_adapter.dart is reachable only through '
          'ocr_platform.dart:\n${offenders.join('\n')}',
    );
  });
}
