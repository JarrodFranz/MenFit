import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/ocr/ocr_text.dart';

/// The geometry the label parser reads (ADR 012): rows are clustered by
/// [OcrRect.centerY] and columns bucketed by [OcrRect.centerX], so these
/// getters are the parser's coordinate system rather than conveniences.
///
/// These types are shared by the platform adapter that produces them and
/// the nutrition parser that consumes them; the two halves of the API
/// below (outcome/`unsupported` from the adapter side, `union`/`empty`
/// from the parser side) were briefly two separate declarations. See the
/// library doc on `lib/core/domain/ocr/ocr_text.dart`.
void main() {
  group('OcrRect', () {
    test('derives size and centre from its edges', () {
      const rect = OcrRect(left: 10, top: 20, right: 110, bottom: 60);

      expect(rect.width, 100);
      expect(rect.height, 40);
      expect(rect.centerX, 60);
      expect(rect.centerY, 40);
    });

    test('centre is the midpoint even for a zero-height box', () {
      // ML Kit occasionally returns a degenerate box for a single glyph;
      // the parser must not divide by a height it assumes is non-zero.
      const rect = OcrRect(left: 5, top: 30, right: 5, bottom: 30);

      expect(rect.width, 0);
      expect(rect.height, 0);
      expect(rect.centerX, 5);
      expect(rect.centerY, 30);
    });

    test('equal edges mean equal rects', () {
      const a = OcrRect(left: 1, top: 2, right: 3, bottom: 4);
      const b = OcrRect(left: 1, top: 2, right: 3, bottom: 4);
      const c = OcrRect(left: 1, top: 2, right: 3, bottom: 5);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('union is the smallest box containing both', () {
      // What glues a split token back together
      // (`domain/label_ocr/label_rows.dart`): the merged element has to
      // span both halves or the row clustering loses it.
      const left = OcrRect(left: 10, top: 20, right: 30, bottom: 40);
      const right = OcrRect(left: 25, top: 15, right: 60, bottom: 35);

      expect(
        left.union(right),
        const OcrRect(left: 10, top: 15, right: 60, bottom: 40),
      );
      // Order does not matter, and a box unioned with itself is itself.
      expect(right.union(left), left.union(right));
      expect(left.union(left), left);
    });
  });

  group('OcrResult', () {
    const box = OcrRect(left: 0, top: 0, right: 10, bottom: 10);

    OcrLine lineOf(String text) => OcrLine(text: text, box: box);

    test('lines flattens blocks in order', () {
      final result = OcrResult(
        fullText: 'a b c',
        blocks: [
          OcrBlock(text: 'a b', box: box, lines: [lineOf('a'), lineOf('b')]),
          OcrBlock(text: 'c', box: box, lines: [lineOf('c')]),
        ],
      );

      expect(result.lines.map((l) => l.text), ['a', 'b', 'c']);
    });

    test('the unsupported result carries nothing', () {
      const unsupported = OcrResult.unsupported();

      expect(unsupported.isUnsupported, isTrue);
      expect(unsupported.outcome, OcrOutcome.unsupported);
      expect(unsupported.blocks, isEmpty);
      expect(unsupported.fullText, isEmpty);
      expect(unsupported.lines, isEmpty);
    });

    test('an empty recognition is recognised, not unsupported', () {
      // The distinction the review form depends on: "retake the photo" and
      // "this platform cannot do this" are different sentences.
      expect(OcrResult.empty.isUnsupported, isFalse);
      expect(OcrResult.empty.outcome, OcrOutcome.recognised);
      expect(OcrResult.empty.blocks, isEmpty);
      expect(OcrResult.empty.fullText, isEmpty);
    });
  });
}
