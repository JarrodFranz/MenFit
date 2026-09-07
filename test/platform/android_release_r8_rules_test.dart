import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard test for the Android **release** R8/proguard configuration ADR 012's
/// on-device OCR needs.
///
/// `google_mlkit_text_recognition`'s Android plugin references the optional
/// Chinese / Devanagari / Japanese / Korean recogniser classes so a host app
/// can opt into those scripts. FemFit ships only the bundled Latin model
/// (ADR 012), so those classes are absent on purpose and R8 (full mode)
/// reports them as "Missing class ..." errors during
/// `:app:minifyReleaseWithR8`.
///
/// **Debug builds do not minify, so this only breaks `flutter build apk
/// --release`** — every debug smoke build passes cleanly, which is exactly
/// why this needs a guard test rather than relying on someone noticing: the
/// -dontwarn lines and the `proguardFiles` wiring look unused/dead to a quick
/// read and are an easy "cleanup" to delete, but doing so reintroduces this
/// release-only R8 failure.
void main() {
  group('android/app/proguard-rules.pro', () {
    final file = File('android/app/proguard-rules.pro');

    test('exists', () {
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'Committed release R8 rules file for the ML Kit "Missing class" '
            'fix — see file header and '
            'knowledge/troubleshooting/android_build.md (2026-09-03).',
      );
    });

    test('suppresses R8 warnings for all four unbundled ML Kit scripts', () {
      final lines = file.readAsLinesSync();

      for (final script in [
        'chinese',
        'devanagari',
        'japanese',
        'korean',
      ]) {
        expect(
          lines,
          contains('-dontwarn com.google.mlkit.vision.text.$script.**'),
          reason:
              'Without this line, :app:minifyReleaseWithR8 fails with '
              '"Missing class com.google.mlkit.vision.text.$script..." '
              'because FemFit deliberately does not bundle that script '
              '(ADR 012, Latin only).',
        );
      }
    });
  });

  test(
    'android/app/build.gradle.kts wires proguard-rules.pro into the release '
    'build type',
    () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      // Scope the search to the release block so this doesn't pass on a
      // reference anywhere else in the file.
      final releaseBlockMatch = RegExp(
        r'release\s*\{([\s\S]*?)\n\s{4}\}',
      ).firstMatch(gradle);

      expect(
        releaseBlockMatch,
        isNotNull,
        reason: 'expected a `release { ... }` build type block',
      );
      final releaseBlock = releaseBlockMatch!.group(1)!;

      expect(
        releaseBlock,
        contains('proguardFiles'),
        reason:
            'the release build type must call proguardFiles(...) so R8 '
            'actually runs with our rules',
      );
      expect(
        releaseBlock,
        contains('proguard-rules.pro'),
        reason:
            'proguardFiles(...) must reference proguard-rules.pro — without '
            'it the -dontwarn rules above are never applied, and '
            ':app:minifyReleaseWithR8 fails again.',
      );
    },
  );
}
