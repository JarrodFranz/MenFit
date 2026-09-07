import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_player.dart';

/// The one file in the app allowed to import `audioplayers`
/// (`test/core/platform/audio/audioplayers_import_guard_test.dart`).
///
/// Everything platform-shaped about playing a cue lives here: the audio
/// session contract per platform, the web gesture rule, and the decision
/// that a failure is silence rather than an exception.
///
/// ## One long-lived player, loaded once
///
/// The clip is set as the player's source in [preload] and never again.
/// [playTransitionChime] only rewinds and restarts it, so nothing on the
/// transition path decodes a file — a decode there is tens of milliseconds
/// of drift between the phase changing and the sound arriving, on the one
/// event whose whole job is to be on time.
///
/// ## Audio session (ADR 014)
///
/// * **Android** — `gainTransientMayDuck`: her music dips under the chime
///   and comes back by itself. `AndroidContentType.sonification` +
///   `AndroidUsageType.assistanceSonification` describe what this actually
///   is, so the system routes and attenuates it as a cue rather than as
///   media.
/// * **iOS** — `ambient`, with **no** explicit options. Ambient respects
///   the hardware silent switch and mixes with other apps rather than
///   interrupting them, which is the contract ADR 014 chose: if she has
///   silenced her phone on the mat, the app is not the one to override
///   that. `mixWithOthers` is deliberately *not* passed even though it is
///   the behaviour we want — `AudioContextIOS` asserts that the option may
///   only be set explicitly under `playback`/`playAndRecord`/`multiRoute`,
///   and iOS turns it on implicitly for `ambient` anyway. Passing it would
///   be an assertion failure in debug, not a stricter setting.
/// * **Web and Windows** — `AudioContext.toJson()` returns an empty map off
///   Android and iOS, so the context is inert there; the cue simply plays
///   over whatever else is sounding.
///
/// ## Failures are silence, never a throw
///
/// Every platform call is inside a guard that swallows what it catches
/// (see [AudioCuePlayer]'s contract). The messages are **static strings**:
/// a platform exception quotes its arguments, and the app's logging rules
/// (`knowledge/engineering/security_and_privacy.md`) do not permit those to
/// reach a log unexamined. There is nothing in a chime failure that is worth
/// more than "playback unavailable" anyway.
///
/// Note that `AudioPlayer`'s constructor does its native `create` call
/// asynchronously, so a device that cannot make a player at all — Windows N
/// and KN without the Media Feature Pack, see
/// `audio_cue_support.dart` — does not throw at construction; it fails on the
/// first awaited operation, which is [preload]. That is why [preload] sets
/// [_unavailable] and later cues stop trying.
class AudioplayersCuePlayer implements AudioCuePlayer {
  AudioplayersCuePlayer();

  /// Path relative to `assets/`, as `AssetSource` expects — it prefixes
  /// `assets/` itself.
  static const String _chimeAssetPath = 'audio/transition_chime.wav';

  AudioPlayer? _player;

  /// Set when the platform has proved it cannot play, so a 40-pose sequence
  /// does not repeat a failing native round trip 40 times.
  bool _unavailable = false;

  bool _disposed = false;

  @override
  Future<void> preload() async {
    if (_disposed || _unavailable) return;
    try {
      final player = _player ??= AudioPlayer();
      // `stop` rather than the default `release`: releasing on completion
      // would throw the decoded clip away and make the next cue reload it.
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(_cueAudioContext);
      await player.setSource(AssetSource(_chimeAssetPath));
    } on Object catch (_) {
      _unavailable = true;
      _reportUnavailable();
    }
  }

  @override
  Future<void> playTransitionChime() async {
    if (_disposed || _unavailable) return;
    final player = _player;
    // preload() is part of the contract; without it there is no loaded
    // source to restart, and loading one here would put a file decode on
    // the transition path.
    if (player == null) return;
    try {
      // `stop()` then `resume()` rather than `seek(Duration.zero)`: under
      // ReleaseMode.stop, stop rewinds to 0 and keeps the buffer — the same
      // effect — while `AudioPlayer.seek` awaits an `onSeekComplete` event
      // with a 30-second timeout, and a platform that never emits one would
      // hang the cue for half a minute.
      await player.stop();
      await player.resume();
    } on Object catch (_) {
      _reportUnavailable();
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.dispose();
    } on Object catch (_) {
      _reportUnavailable();
    }
  }

  void _reportUnavailable() {
    if (kDebugMode) {
      debugPrint('AudioCuePlayer: cue playback unavailable on this device.');
    }
  }

  /// Built per call rather than held as a `const`: `AudioContext` is not
  /// const-constructible (its iOS half is a `late final`).
  AudioContext get _cueAudioContext => AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );
}
