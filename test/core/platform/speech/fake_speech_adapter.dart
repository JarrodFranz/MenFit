import 'package:menfit_app/core/platform/speech/speech_adapter.dart';

/// Test double recording speech calls without playing sound or contacting
/// native TTS engines.
class FakeSpeechAdapter implements SpeechAdapter {
  FakeSpeechAdapter({this.throwOnSpeak = false});

  final bool throwOnSpeak;
  final List<String> spokenUtterances = [];
  int stopCount = 0;
  int disposeCount = 0;
  double currentRate = 0.5;
  double currentVolume = 1;

  @override
  Future<void> speak(String text) async {
    spokenUtterances.add(text);
    if (throwOnSpeak) throw StateError('fake speech failure');
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    currentRate = rate;
  }

  @override
  Future<void> setVolume(double volume) async {
    currentVolume = volume;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
  }
}
