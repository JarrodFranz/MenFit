import 'package:menfit_app/core/platform/speech/speech_adapter.dart';

/// A no-op [SpeechAdapter] used on platforms without native speech support
/// (Web, Windows) and as the default in production when speech is disabled.
class SilentSpeechAdapter implements SpeechAdapter {
  const SilentSpeechAdapter();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {}
}
