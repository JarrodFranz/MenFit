import 'package:flutter/widgets.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_player.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_support.dart';
import 'package:menfit_app/core/platform/audio/audioplayers_cue_player.dart';
import 'package:menfit_app/core/platform/audio/silent_cue_player.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_cue_providers.g.dart';

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
@Riverpod(keepAlive: true)
AudioCuePlayer audioCuePlayer(Ref ref) {
  if (!audioCueSupport) return const SilentCuePlayer();
  try {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return const SilentCuePlayer();
    }
  } on Object catch (_) {
    return const SilentCuePlayer();
  }
  final player = AudioplayersCuePlayer();
  ref.onDispose(player.dispose);
  return player;
}
