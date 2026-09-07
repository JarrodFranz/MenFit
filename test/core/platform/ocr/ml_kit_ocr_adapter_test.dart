import 'dart:math' show Point;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:menfit_app/core/platform/ocr/ml_kit_ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';

/// The ML Kit mapping, exercised against real ML Kit objects.
///
/// `TextBlock`, `TextLine` and `TextElement` all have public generative
/// constructors, so there is no need for a stand-in shape that could drift
/// from the one the plugin actually produces. Only the `MethodChannel` is
/// faked, and only where the recogniser's lifecycle is under test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TextElement element(String text, Rect box, {double? confidence}) =>
      TextElement(
        text: text,
        symbols: const [],
        boundingBox: box,
        recognizedLanguages: const ['en'],
        cornerPoints: const <Point<int>>[],
        confidence: confidence,
        angle: null,
      );

  TextLine line(
    String text,
    Rect box,
    List<TextElement> elements, {
    double? confidence,
  }) => TextLine(
    text: text,
    elements: elements,
    boundingBox: box,
    recognizedLanguages: const ['en'],
    cornerPoints: const <Point<int>>[],
    confidence: confidence,
    angle: null,
  );

  TextBlock block(String text, Rect box, List<TextLine> lines) => TextBlock(
    text: text,
    lines: lines,
    boundingBox: box,
    recognizedLanguages: const ['en'],
    cornerPoints: const <Point<int>>[],
  );

  group('mapRecognizedText', () {
    test('carries text, boxes and nesting through all three levels', () {
      const elementBox = Rect.fromLTRB(10, 100, 60, 120);
      const lineBox = Rect.fromLTRB(10, 100, 200, 120);
      const blockBox = Rect.fromLTRB(8, 96, 320, 400);

      final result = mapRecognizedText(
        RecognizedText(
          text: 'Energy 1234 kJ',
          blocks: [
            block('Energy 1234 kJ', blockBox, [
              line('Energy 1234 kJ', lineBox, [
                element('Energy', elementBox),
              ]),
            ]),
          ],
        ),
      );

      expect(result.fullText, 'Energy 1234 kJ');
      expect(result.outcome, OcrOutcome.recognised);
      expect(result.isUnsupported, isFalse);
      expect(result.blocks, hasLength(1));

      final mappedBlock = result.blocks.single;
      expect(mappedBlock.text, 'Energy 1234 kJ');
      expect(
        mappedBlock.box,
        const OcrRect(left: 8, top: 96, right: 320, bottom: 400),
      );

      final mappedLine = mappedBlock.lines.single;
      expect(
        mappedLine.box,
        const OcrRect(left: 10, top: 100, right: 200, bottom: 120),
      );

      final mappedElement = mappedLine.elements.single;
      expect(mappedElement.text, 'Energy');
      expect(
        mappedElement.box,
        const OcrRect(left: 10, top: 100, right: 60, bottom: 120),
      );
    });

    test('preserves a null confidence instead of substituting a number', () {
      // The whole point: ML Kit returns null here on iOS by documentation
      // and often on Android in practice. A default of 0.0 would read as
      // "measured, and terrible"; a default of 1.0 as "measured, and
      // certain". Neither is true and the parser must be able to tell.
      final result = mapRecognizedText(
        RecognizedText(
          text: 'Protein',
          blocks: [
            block('Protein', const Rect.fromLTRB(0, 0, 10, 10), [
              line('Protein', const Rect.fromLTRB(0, 0, 10, 10), [
                element('Protein', const Rect.fromLTRB(0, 0, 10, 10)),
              ]),
            ]),
          ],
        ),
      );

      expect(result.blocks.single.lines.single.confidence, isNull);
      expect(
        result.blocks.single.lines.single.elements.single.confidence,
        isNull,
      );
    });

    test('passes a real confidence through unchanged', () {
      final result = mapRecognizedText(
        RecognizedText(
          text: 'Sugars',
          blocks: [
            block('Sugars', const Rect.fromLTRB(0, 0, 10, 10), [
              line(
                'Sugars',
                const Rect.fromLTRB(0, 0, 10, 10),
                [
                  element(
                    'Sugars',
                    const Rect.fromLTRB(0, 0, 10, 10),
                    confidence: 0.87,
                  ),
                ],
                confidence: 0.91,
              ),
            ]),
          ],
        ),
      );

      final mappedLine = result.blocks.single.lines.single;
      expect(mappedLine.confidence, 0.91);
      expect(mappedLine.elements.single.confidence, 0.87);
    });

    test('maps an empty recognition to an empty but recognised result', () {
      final result = mapRecognizedText(RecognizedText(text: '', blocks: []));

      // Empty is NOT unsupported: the user pointed the camera at something
      // illegible and should be told to retake, not that the feature does
      // not exist here.
      expect(result.blocks, isEmpty);
      expect(result.isUnsupported, isFalse);
    });
  });

  group('toInputImage', () {
    test('a file image becomes a file InputImage', () {
      final input = toInputImage(const OcrImage.file('/cache/label.jpg'));

      expect(input.type, InputImageType.file);
      expect(input.filePath, '/cache/label.jpg');
      expect(input.bytes, isNull);
    });

    test('raw RGBA becomes a bitmap InputImage with its dimensions', () {
      final bytes = Uint8List(4 * 3 * 2);
      final input = toInputImage(
        OcrImage.rawRgba(
          bytes: bytes,
          width: 3,
          height: 2,
          rotationDegrees: 90,
        ),
      );

      expect(input.type, InputImageType.bitmap);
      expect(input.bitmapData, same(bytes));
      expect(input.rotation, 90);
      expect(input.metadata?.size.width, 3);
      expect(input.metadata?.size.height, 2);
      // 4 bytes per RGBA pixel; the plugin derives this and a wrong value
      // is a garbled recognition rather than an error.
      expect(input.metadata?.bytesPerRow, 12);
    });
  });

  group('MlKitOcrAdapter', () {
    const channel = MethodChannel('google_mlkit_text_recognizer');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'vision#startTextRecognizer') {
              return <dynamic, dynamic>{
                'text': 'Per 100 g',
                'blocks': <dynamic>[
                  <dynamic, dynamic>{
                    'text': 'Per 100 g',
                    'rect': <dynamic, dynamic>{
                      'left': 4,
                      'top': 8,
                      'right': 120,
                      'bottom': 30,
                    },
                    'recognizedLanguages': <dynamic>['en'],
                    'points': <dynamic>[],
                    'lines': <dynamic>[
                      <dynamic, dynamic>{
                        'text': 'Per 100 g',
                        'rect': <dynamic, dynamic>{
                          'left': 4,
                          'top': 8,
                          'right': 120,
                          'bottom': 30,
                        },
                        'recognizedLanguages': <dynamic>['en'],
                        'points': <dynamic>[],
                        'confidence': null,
                        'angle': null,
                        'elements': <dynamic>[],
                      },
                    ],
                  },
                ],
              };
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('reports itself supported', () {
      expect(MlKitOcrAdapter().isSupported, isTrue);
    });

    test('recognises through the channel and maps the reply', () async {
      final result = await MlKitOcrAdapter().recognize(
        const OcrImage.file('/cache/label.jpg'),
      );

      expect(result.fullText, 'Per 100 g');
      expect(result.lines.single.text, 'Per 100 g');
      expect(
        result.blocks.single.box,
        const OcrRect(left: 4, top: 8, right: 120, bottom: 30),
      );

      final start = calls.single;
      expect(start.method, 'vision#startTextRecognizer');
      final args = start.arguments as Map<dynamic, dynamic>;
      expect(args['script'], TextRecognitionScript.latin.index);
      final imageData = args['imageData'] as Map<dynamic, dynamic>;
      expect(imageData['path'], '/cache/label.jpg');
    });

    test('dispose closes the native recogniser', () async {
      // A leaked recogniser holds a native detector open; the provider owns
      // this call, so if it stops happening nothing else will notice.
      await MlKitOcrAdapter().dispose();

      expect(calls.single.method, 'vision#closeTextRecognizer');
    });
  });
}
