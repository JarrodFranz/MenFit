import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/speech/silent_speech_adapter.dart';

import 'fake_speech_adapter.dart';

void main() {
  group('SilentSpeechAdapter', () {
    test('completes all operations silently without throwing', () async {
      const adapter = SilentSpeechAdapter();
      await adapter.speak('Hello runner');
      await adapter.stop();
      await adapter.setSpeechRate(0.5);
      await adapter.setVolume(1);
      await adapter.dispose();
    });
  });

  group('FakeSpeechAdapter', () {
    test('records utterances and rate/volume changes', () async {
      final adapter = FakeSpeechAdapter();
      await adapter.setSpeechRate(0.6);
      await adapter.setVolume(0.8);
      await adapter.speak('Split 1');
      await adapter.speak('Split 2');
      await adapter.stop();
      await adapter.dispose();

      expect(adapter.spokenUtterances, ['Split 1', 'Split 2']);
      expect(adapter.currentRate, 0.6);
      expect(adapter.currentVolume, 0.8);
      expect(adapter.stopCount, 1);
      expect(adapter.disposeCount, 1);
    });

    test('throws when throwOnSpeak is enabled', () {
      final adapter = FakeSpeechAdapter(throwOnSpeak: true);
      expect(() => adapter.speak('Test'), throwsStateError);
    });
  });
}
