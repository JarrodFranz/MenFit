// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_cue_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [AudioCuePlayer]: a real one where [audioCueSupport] says
/// the platform can play, [SilentCuePlayer] otherwise.
///
/// `keepAlive` because the point of the seam is one long-lived player holding
/// one decoded clip — an autoDispose provider would rebuild it between
/// screens and put the decode back on the first cue. Disposal is wired to the
/// provider's own, so the native handle goes when the container does.
///
/// Tests override it with `test/core/platform/audio/fake_audio_cue_player.dart`
/// or fall back cleanly to [SilentCuePlayer] when unmocked under test bindings.

@ProviderFor(audioCuePlayer)
final audioCuePlayerProvider = AudioCuePlayerProvider._();

/// The app's single [AudioCuePlayer]: a real one where [audioCueSupport] says
/// the platform can play, [SilentCuePlayer] otherwise.
///
/// `keepAlive` because the point of the seam is one long-lived player holding
/// one decoded clip — an autoDispose provider would rebuild it between
/// screens and put the decode back on the first cue. Disposal is wired to the
/// provider's own, so the native handle goes when the container does.
///
/// Tests override it with `test/core/platform/audio/fake_audio_cue_player.dart`
/// or fall back cleanly to [SilentCuePlayer] when unmocked under test bindings.

final class AudioCuePlayerProvider
    extends $FunctionalProvider<AudioCuePlayer, AudioCuePlayer, AudioCuePlayer>
    with $Provider<AudioCuePlayer> {
  /// The app's single [AudioCuePlayer]: a real one where [audioCueSupport] says
  /// the platform can play, [SilentCuePlayer] otherwise.
  ///
  /// `keepAlive` because the point of the seam is one long-lived player holding
  /// one decoded clip — an autoDispose provider would rebuild it between
  /// screens and put the decode back on the first cue. Disposal is wired to the
  /// provider's own, so the native handle goes when the container does.
  ///
  /// Tests override it with `test/core/platform/audio/fake_audio_cue_player.dart`
  /// or fall back cleanly to [SilentCuePlayer] when unmocked under test bindings.
  AudioCuePlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioCuePlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioCuePlayerHash();

  @$internal
  @override
  $ProviderElement<AudioCuePlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioCuePlayer create(Ref ref) {
    return audioCuePlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioCuePlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioCuePlayer>(value),
    );
  }
}

String _$audioCuePlayerHash() => r'3aec6820670b556a43e9291d38bfa756528ec0f6';
