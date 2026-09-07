// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app's single [SpeechAdapter]: real [FlutterTtsSpeechAdapter]
/// on supported platforms (Android, iOS) and [SilentSpeechAdapter] on Web/Windows
/// or when speech is unsupported / running in test environments.
///
/// Kept alive across screens so TTS engine initialization is preserved during
/// run recordings.

@ProviderFor(speechAdapter)
final speechAdapterProvider = SpeechAdapterProvider._();

/// Provides the app's single [SpeechAdapter]: real [FlutterTtsSpeechAdapter]
/// on supported platforms (Android, iOS) and [SilentSpeechAdapter] on Web/Windows
/// or when speech is unsupported / running in test environments.
///
/// Kept alive across screens so TTS engine initialization is preserved during
/// run recordings.

final class SpeechAdapterProvider
    extends $FunctionalProvider<SpeechAdapter, SpeechAdapter, SpeechAdapter>
    with $Provider<SpeechAdapter> {
  /// Provides the app's single [SpeechAdapter]: real [FlutterTtsSpeechAdapter]
  /// on supported platforms (Android, iOS) and [SilentSpeechAdapter] on Web/Windows
  /// or when speech is unsupported / running in test environments.
  ///
  /// Kept alive across screens so TTS engine initialization is preserved during
  /// run recordings.
  SpeechAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechAdapterHash();

  @$internal
  @override
  $ProviderElement<SpeechAdapter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechAdapter create(Ref ref) {
    return speechAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechAdapter>(value),
    );
  }
}

String _$speechAdapterHash() => r'bc9f7260b92bb1bab679cd6caa8f7723293d5335';
