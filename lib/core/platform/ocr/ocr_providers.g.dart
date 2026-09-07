// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [OcrAdapter]: ML Kit on Android and iOS, an
/// [OcrResult.unsupported]-returning stand-in everywhere else. Tests
/// override it with `test/core/platform/ocr/fake_ocr_adapter.dart` — no
/// test should ever reach a real recogniser.
///
/// `keepAlive` because the native recogniser is expensive to spin up and
/// the user will photograph several labels in a sitting; [OcrAdapter.dispose]
/// is wired to the provider's own disposal so the native handle is not
/// leaked when the container goes.

@ProviderFor(ocrAdapter)
final ocrAdapterProvider = OcrAdapterProvider._();

/// The app's single [OcrAdapter]: ML Kit on Android and iOS, an
/// [OcrResult.unsupported]-returning stand-in everywhere else. Tests
/// override it with `test/core/platform/ocr/fake_ocr_adapter.dart` — no
/// test should ever reach a real recogniser.
///
/// `keepAlive` because the native recogniser is expensive to spin up and
/// the user will photograph several labels in a sitting; [OcrAdapter.dispose]
/// is wired to the provider's own disposal so the native handle is not
/// leaked when the container goes.

final class OcrAdapterProvider
    extends $FunctionalProvider<OcrAdapter, OcrAdapter, OcrAdapter>
    with $Provider<OcrAdapter> {
  /// The app's single [OcrAdapter]: ML Kit on Android and iOS, an
  /// [OcrResult.unsupported]-returning stand-in everywhere else. Tests
  /// override it with `test/core/platform/ocr/fake_ocr_adapter.dart` — no
  /// test should ever reach a real recogniser.
  ///
  /// `keepAlive` because the native recogniser is expensive to spin up and
  /// the user will photograph several labels in a sitting; [OcrAdapter.dispose]
  /// is wired to the provider's own disposal so the native handle is not
  /// leaked when the container goes.
  OcrAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrAdapterHash();

  @$internal
  @override
  $ProviderElement<OcrAdapter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OcrAdapter create(Ref ref) {
    return ocrAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OcrAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OcrAdapter>(value),
    );
  }
}

String _$ocrAdapterHash() => r'cb1a2c9030c2ba9b9b84b1c8ad797ed875308456';

/// Camera capture plus recognition, with the photo deleted afterwards.

@ProviderFor(labelCaptureService)
final labelCaptureServiceProvider = LabelCaptureServiceProvider._();

/// Camera capture plus recognition, with the photo deleted afterwards.

final class LabelCaptureServiceProvider
    extends
        $FunctionalProvider<
          LabelCaptureService,
          LabelCaptureService,
          LabelCaptureService
        >
    with $Provider<LabelCaptureService> {
  /// Camera capture plus recognition, with the photo deleted afterwards.
  LabelCaptureServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelCaptureServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelCaptureServiceHash();

  @$internal
  @override
  $ProviderElement<LabelCaptureService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LabelCaptureService create(Ref ref) {
    return labelCaptureService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LabelCaptureService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LabelCaptureService>(value),
    );
  }
}

String _$labelCaptureServiceHash() =>
    r'b1c8f7af284f65a3699f7426817948f2cc439069';
