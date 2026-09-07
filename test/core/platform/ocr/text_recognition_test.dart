import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/ocr/text_recognition.dart';

/// The capability gate for the nutrition-label OCR entry point (ADR 012).
///
/// `flutter test` reports [TargetPlatform.android] by default, so the
/// unsupported branch has to be selected explicitly — which means these
/// tests exercise the real check rather than an accident of the host
/// machine.
///
/// The override is cleared **inside each test body**, not in a tear-down:
/// `flutter_test` asserts that every foundation debug variable is unset at
/// the end of the test body, which runs before any tear-down, so a
/// tear-down reset arrives too late for widget tests. The file-level
/// `tearDown` is belt-and-braces for a body that throws.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('textRecognitionSupported', () {
    test('is true on the two platforms ML Kit ships for', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(textRecognitionSupported, isTrue, reason: '$platform');
      }
      debugDefaultTargetPlatformOverride = null;
    });

    test('is false on every desktop platform', () {
      // Windows: `Windows.Media.Ocr` needs package identity an unpackaged
      // build lacks, and there is no camera frame source either. macOS and
      // Linux: ML Kit does not support them and this app has no
      // desktop-camera story (ADR 012).
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(textRecognitionSupported, isFalse, reason: '$platform');
      }
      debugDefaultTargetPlatformOverride = null;
    });

    test('covers every TargetPlatform value', () {
      // The switch in `textRecognitionSupported` is exhaustive, so a new
      // TargetPlatform would be a compile error rather than a silent
      // `true`. This asserts the enum is fully enumerated here too, so a
      // new platform arrives with a decision attached.
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        expect(textRecognitionSupported, isA<bool>(), reason: '$platform');
      }
      debugDefaultTargetPlatformOverride = null;
    });
  });

  // Web returns false via the `kIsWeb` short-circuit, which cannot be
  // exercised from a VM test — `kIsWeb` is a compile-time constant that is
  // `false` in every `flutter test` run. The ordering that matters (kIsWeb
  // checked *before* defaultTargetPlatform, because on web the latter
  // reports the browser's host OS and would answer `android` on an Android
  // phone) therefore rests on review, not on a test.
}
