import 'package:flutter/widgets.dart';
import 'package:menfit_app/core/platform/speech/flutter_tts_speech_adapter.dart';
import 'package:menfit_app/core/platform/speech/silent_speech_adapter.dart';
import 'package:menfit_app/core/platform/speech/speech_adapter.dart';
import 'package:menfit_app/core/platform/speech/speech_support.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_providers.g.dart';

/// Provides the app's single [SpeechAdapter]: real [FlutterTtsSpeechAdapter]
/// on supported platforms (Android, iOS) and [SilentSpeechAdapter] on Web/Windows
/// or when speech is unsupported / running in test environments.
///
/// Kept alive across screens so TTS engine initialization is preserved during
/// run recordings.
@Riverpod(keepAlive: true)
SpeechAdapter speechAdapter(Ref ref) {
  if (!speechSupport) return const SilentSpeechAdapter();
  try {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return const SilentSpeechAdapter();
    }
  } on Object catch (_) {
    return const SilentSpeechAdapter();
  }
  try {
    final adapter = FlutterTtsSpeechAdapter();
    ref.onDispose(adapter.dispose);
    return adapter;
  } on Object catch (_) {
    return const SilentSpeechAdapter();
  }
}
