import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/ocr/label_capture.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/ocr_providers.dart';

import 'fake_ocr_adapter.dart';

/// Composition of the OCR adapter, and the override seam every feature test
/// will use.
///
/// The real `ocrAdapterProvider` is not read here: under `flutter test` the
/// host reports Android, so it would construct a real `MlKitOcrAdapter` and
/// the first `recognize` would reach a `MethodChannel` with no plugin
/// behind it. Adapter selection is covered by `text_recognition_test.dart`
/// (the flag) and `ml_kit_ocr_adapter_test.dart` (the implementation);
/// what is left to assert is that the wiring is overridable and that the
/// capture service takes whatever adapter the container holds.
void main() {
  test('labelCaptureService uses the container adapter', () async {
    final fake = FakeOcrAdapter(result: singleLineOcrResult('Sugars 4.2 g'));
    final container = ProviderContainer(
      overrides: [ocrAdapterProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final service = container.read(labelCaptureServiceProvider);

    expect(service, isA<LabelCaptureService>());
    expect(service.adapter, same(fake));
  });

  test('an overridden adapter is what recognition goes through', () async {
    final fake = FakeOcrAdapter(result: singleLineOcrResult('Energy 1234 kJ'));
    final container = ProviderContainer(
      overrides: [ocrAdapterProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(ocrAdapterProvider)
        .recognize(const OcrImage.file('/cache/label.jpg'));

    expect(result.fullText, 'Energy 1234 kJ');
    expect(fake.recognized, hasLength(1));
  });
}
