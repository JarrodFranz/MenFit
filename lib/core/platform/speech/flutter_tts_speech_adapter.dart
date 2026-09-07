import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:menfit_app/core/platform/speech/speech_adapter.dart';

/// Real implementation of [SpeechAdapter] backed by `package:flutter_tts`.
///
/// Handles audio focus and background music ducking on Android and iOS:
/// - iOS: Configures audio category `playback` with options `duckOthers` and
///   `mixWithOthers` so spoken coaching cues duck music/podcasts rather than
///   cutting them off.
/// - Android: Handled through the TTS engine audio attributes.
///
/// As mandated by [SpeechAdapter]'s contract, native failures are caught and
/// swallowed rather than crashing an active run.
class FlutterTtsSpeechAdapter implements SpeechAdapter {
  FlutterTtsSpeechAdapter({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _initialized = false;
  bool _unavailable = false;
  bool _disposed = false;

  Future<void> _ensureInitialized() async {
    if (_initialized || _unavailable || _disposed) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1);
      _initialized = true;
    } on Object catch (_) {
      _unavailable = true;
      debugPrint('FlutterTtsSpeechAdapter: native TTS init failed; silencing.');
    }
  }

  @override
  Future<void> speak(String text) async {
    if (_disposed || _unavailable) return;
    try {
      await _ensureInitialized();
      if (_unavailable) return;
      await _tts.speak(text);
    } on Object catch (_) {
      _unavailable = true;
      debugPrint('FlutterTtsSpeechAdapter: speak failed; silencing.');
    }
  }

  @override
  Future<void> stop() async {
    if (_disposed || _unavailable) return;
    try {
      await _tts.stop();
    } on Object catch (_) {
      // Swallowed by contract.
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    if (_disposed || _unavailable) return;
    try {
      await _ensureInitialized();
      await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
    } on Object catch (_) {
      // Swallowed by contract.
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_disposed || _unavailable) return;
    try {
      await _ensureInitialized();
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    } on Object catch (_) {
      // Swallowed by contract.
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    try {
      await _tts.stop();
    } on Object catch (_) {
      // Swallowed by contract.
    }
  }
}
