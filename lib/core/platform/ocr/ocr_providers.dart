import 'package:menfit_app/core/platform/ocr/label_capture.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/ocr_platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_providers.g.dart';

/// The app's single [OcrAdapter]: ML Kit on Android and iOS, an
/// [OcrResult.unsupported]-returning stand-in everywhere else. Tests
/// override it with `test/core/platform/ocr/fake_ocr_adapter.dart` — no
/// test should ever reach a real recogniser.
///
/// `keepAlive` because the native recogniser is expensive to spin up and
/// the user will photograph several labels in a sitting; [OcrAdapter.dispose]
/// is wired to the provider's own disposal so the native handle is not
/// leaked when the container goes.
@Riverpod(keepAlive: true)
OcrAdapter ocrAdapter(Ref ref) {
  final adapter = createOcrAdapter();
  ref.onDispose(adapter.dispose);
  return adapter;
}

/// Camera capture plus recognition, with the photo deleted afterwards.
@Riverpod(keepAlive: true)
LabelCaptureService labelCaptureService(Ref ref) =>
    LabelCaptureService(adapter: ref.watch(ocrAdapterProvider));
