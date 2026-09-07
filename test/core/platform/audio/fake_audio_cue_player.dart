import 'package:menfit_app/core/platform/audio/audio_cue_player.dart';

/// Records the cues a surface asked for, and plays nothing.
///
/// Lives under `test/` rather than beside the port it doubles, matching
/// `test/core/platform/sharing/fake_sharing_adapter.dart`: a test double in
/// the app binary is a test double that eventually gets wired to a screen.
/// (`SilentCuePlayer` in `lib/` is not this — it is the real behaviour on a
/// platform that cannot play, and it deliberately records nothing.)
class FakeAudioCuePlayer implements AudioCuePlayer {
  FakeAudioCuePlayer({this.throwOnPlay = false});

  /// When true, [playTransitionChime] throws — so a caller that forgets the
  /// port's "failures are swallowed" contract is caught by its own test.
  final bool throwOnPlay;

  int preloadCount = 0;
  int chimeCount = 0;
  int disposeCount = 0;

  @override
  Future<void> preload() async => preloadCount++;

  @override
  Future<void> playTransitionChime() async {
    chimeCount++;
    if (throwOnPlay) throw StateError('fake playback failure');
  }

  @override
  Future<void> dispose() async => disposeCount++;
}
