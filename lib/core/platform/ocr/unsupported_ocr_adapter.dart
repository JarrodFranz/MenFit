import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';

/// The adapter every platform without on-device text recognition gets:
/// web, Windows, macOS, Linux (ADR 012).
///
/// It answers rather than throws. A `throw` here would turn a known,
/// designed-for platform gap into a crash at the one moment the user is
/// least able to do anything about it, and would push a try/catch into
/// every call site to say what [OcrResult.unsupported] already says. The
/// entry point should never have been visible on these platforms anyway —
/// `textRecognitionSupported` gates it — so this is the second line of
/// defence, not the first.
final class UnsupportedOcrAdapter implements OcrAdapter {
  const UnsupportedOcrAdapter();

  @override
  bool get isSupported => false;

  @override
  Future<OcrResult> recognize(OcrImage image) async =>
      const OcrResult.unsupported();

  @override
  Future<void> dispose() async {}
}
