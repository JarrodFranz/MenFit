import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';

/// Records what was handed to the recogniser, and scripts what comes back.
///
/// Lives under `test/` rather than beside the adapter it doubles, matching
/// `test/core/platform/sharing/fake_sharing_adapter.dart`: a test double in
/// the app binary is a test double that eventually gets wired to a screen.
class FakeOcrAdapter implements OcrAdapter {
  FakeOcrAdapter({
    OcrResult? result,
    this.isSupported = true,
    this.throwOnRecognize,
  }) : result = result ?? OcrResult.empty;

  /// What [recognize] returns when [throwOnRecognize] is null.
  OcrResult result;

  /// When set, [recognize] throws this instead of returning. Exists so the
  /// failure paths — which is where a captured photo would leak — can be
  /// driven deliberately.
  Object? throwOnRecognize;

  @override
  bool isSupported;

  /// Every image passed to [recognize], in order.
  final List<OcrImage> recognized = [];

  int disposeCount = 0;

  @override
  Future<OcrResult> recognize(OcrImage image) async {
    recognized.add(image);
    final failure = throwOnRecognize;
    // Deliberately `Object`, not `Exception`: on a device this throws
    // whatever the platform channel throws, and a fake that can only
    // produce well-behaved exceptions would not be able to reproduce that.
    // ignore: only_throw_errors
    if (failure != null) throw failure;
    return result;
  }

  @override
  Future<void> dispose() async => disposeCount++;
}

/// A one-line, one-word [OcrResult] — enough structure for a caller that
/// only needs "something came back".
OcrResult singleLineOcrResult(String text) {
  const box = OcrRect(left: 0, top: 0, right: 100, bottom: 20);
  return OcrResult(
    fullText: text,
    blocks: [
      OcrBlock(
        text: text,
        box: box,
        lines: [
          OcrLine(
            text: text,
            box: box,
            elements: [OcrElement(text: text, box: box)],
          ),
        ],
      ),
    ],
  );
}
