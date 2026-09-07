import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [AudioCoachingSettings] in [SharedPreferences].
class AudioCoachingRepository {
  const AudioCoachingRepository(this._preferences);

  final SharedPreferences? _preferences;

  static const String _enabledKey = 'audio_coaching_enabled';
  static const String _unitSystemKey = 'audio_coaching_unit_system';
  static const String _modeKey = 'audio_coaching_mode';
  static const String _splitIntervalKey = 'audio_coaching_split_interval';
  static const String _announceSplitsKey = 'audio_coaching_announce_splits';
  static const String _announcePaceKey = 'audio_coaching_announce_pace';
  static const String _announceStatusKey = 'audio_coaching_announce_status';
  static const String _announceMilestonesKey =
      'audio_coaching_announce_milestones';
  static const String _speechRateKey = 'audio_coaching_speech_rate';
  static const String _volumeKey = 'audio_coaching_volume';

  /// Loads persisted audio coaching settings.
  AudioCoachingSettings getSettings() {
    final prefs = _preferences;
    if (prefs == null) return const AudioCoachingSettings();

    final modeStr = prefs.getString(_modeKey);
    final mode = AudioCueMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => AudioCueMode.voiceAndChime,
    );

    final unitSystemStr = prefs.getString(_unitSystemKey);
    final unitSystem = unitSystemStr != null
        ? UnitSystem.fromStorage(unitSystemStr)
        : UnitSystem.metric;

    return AudioCoachingSettings(
      enabled: prefs.getBool(_enabledKey) ?? true,
      unitSystem: unitSystem,
      cueMode: mode,
      splitIntervalMeters: prefs.getDouble(_splitIntervalKey),
      announceSplits: prefs.getBool(_announceSplitsKey) ?? true,
      announcePace: prefs.getBool(_announcePaceKey) ?? true,
      announceStatusChanges: prefs.getBool(_announceStatusKey) ?? true,
      announceMilestones: prefs.getBool(_announceMilestonesKey) ?? true,
      speechRate: prefs.getDouble(_speechRateKey) ?? 0.5,
      volume: prefs.getDouble(_volumeKey) ?? 1.0,
    );
  }

  /// Persists [settings].
  Future<void> setSettings(AudioCoachingSettings settings) async {
    final prefs = _preferences;
    if (prefs == null) return;

    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setString(_unitSystemKey, settings.unitSystem.toStorage());
    await prefs.setString(_modeKey, settings.cueMode.name);
    if (settings.splitIntervalMeters != null) {
      await prefs.setDouble(_splitIntervalKey, settings.splitIntervalMeters!);
    } else {
      await prefs.remove(_splitIntervalKey);
    }
    await prefs.setBool(_announceSplitsKey, settings.announceSplits);
    await prefs.setBool(_announcePaceKey, settings.announcePace);
    await prefs.setBool(_announceStatusKey, settings.announceStatusChanges);
    await prefs.setBool(_announceMilestonesKey, settings.announceMilestones);
    await prefs.setDouble(_speechRateKey, settings.speechRate);
    await prefs.setDouble(_volumeKey, settings.volume);
  }
}
