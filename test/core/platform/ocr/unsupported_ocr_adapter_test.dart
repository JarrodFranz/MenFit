import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/unsupported_ocr_adapter.dart';

/// What web, Windows, macOS and Linux get (ADR 012).
void main() {
  group('UnsupportedOcrAdapter', () {
    test('says so rather than pretending', () {
      expect(const UnsupportedOcrAdapter().isSupported, isFalse);
    });

    test('answers every image with the unsupported result, not a throw', () {
      // A throw here would turn a designed-for platform gap into a crash and
      // force a try/catch into every call site to say what the result value
      // already says.
      const adapter = UnsupportedOcrAdapter();
      final images = [
        const OcrImage.file('/anywhere/label.jpg'),
        OcrImage.rawRgba(bytes: Uint8List(4), width: 1, height: 1),
      ];

      for (final image in images) {
        expect(
          adapter.recognize(image),
          completion(
            isA<OcrResult>()
                .having((r) => r.isUnsupported, 'isUnsupported', isTrue)
                .having((r) => r.outcome, 'outcome', OcrOutcome.unsupported)
                .having((r) => r.blocks, 'blocks', isEmpty)
                .having((r) => r.fullText, 'fullText', isEmpty),
          ),
        );
      }
    });

    test('dispose is a no-op that does not throw', () {
      expect(const UnsupportedOcrAdapter().dispose(), completes);
    });
  });
}
