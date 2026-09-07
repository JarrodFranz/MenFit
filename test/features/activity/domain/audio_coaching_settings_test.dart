import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/data/audio_coaching_repository.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioCoachingSettings serialization', () {
    test('round-trips through json', () {
      const original = AudioCoachingSettings(
        splitIntervalMeters: 1000,
        announcePace: false,
        speechRate: 0.6,
        volume: 0.9,
      );

      final json = original.toJson();
      final restored = AudioCoachingSettings.fromJson(json);

      expect(restored, original);
    });
  });

  group('AudioCoachingRepository', () {
    test('reads default settings when preferences are empty', () {
      SharedPreferences.setMockInitialValues({});
      const repo = AudioCoachingRepository(null);

      final settings = repo.getSettings();
      expect(settings.enabled, isTrue);
      expect(settings.cueMode, AudioCueMode.voiceAndChime);
      expect(settings.splitIntervalMeters, isNull);
      expect(settings.announceSplits, isTrue);
    });

    test('persists and reloads custom settings', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = AudioCoachingRepository(prefs);

      const custom = AudioCoachingSettings(
        enabled: false,
        cueMode: AudioCueMode.voiceOnly,
        splitIntervalMeters: 500,
        announcePace: false,
        announceStatusChanges: false,
        speechRate: 0.8,
        volume: 0.7,
      );

      await repo.setSettings(custom);
      final reloaded = repo.getSettings();

      expect(reloaded.enabled, isFalse);
      expect(reloaded.cueMode, AudioCueMode.voiceOnly);
      expect(reloaded.splitIntervalMeters, 500);
      expect(reloaded.announcePace, isFalse);
      expect(reloaded.announceStatusChanges, isFalse);
      expect(reloaded.speechRate, 0.8);
      expect(reloaded.volume, 0.7);
    });
  });
}
