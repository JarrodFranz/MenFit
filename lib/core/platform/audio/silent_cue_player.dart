import 'package:menfit_app/core/platform/audio/audio_cue_player.dart';

/// The [AudioCuePlayer] used where audio is unavailable, and in every test.
///
/// Not a placeholder for something better: a platform without playback is
/// supposed to fall back to the haptic and visual channels, which carry the
/// same boundary (ADR 014). Silence here is the designed behaviour, so this
/// records nothing and reports nothing.
class SilentCuePlayer implements AudioCuePlayer {
  const SilentCuePlayer();

  @override
  Future<void> preload() async {}

  @override
  Future<void> playTransitionChime() async {}

  @override
  Future<void> dispose() async {}
}
