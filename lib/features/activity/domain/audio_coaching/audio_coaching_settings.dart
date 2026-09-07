import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/units.dart';

part 'audio_coaching_settings.freezed.dart';
part 'audio_coaching_settings.g.dart';

/// Presentation mode for audio cues during workout recording.
enum AudioCueMode {
  /// Both spoken voice announcements and cue chimes.
  voiceAndChime,

  /// Spoken voice announcements only.
  voiceOnly,

  /// Chime tones only (no spoken words).
  chimeOnly;

  String get label => switch (this) {
    AudioCueMode.voiceAndChime => 'Voice & Chime',
    AudioCueMode.voiceOnly => 'Voice Only',
    AudioCueMode.chimeOnly => 'Chime Only',
  };
}

/// User settings for audio coaching cues during GPS activity recording.
@freezed
abstract class AudioCoachingSettings with _$AudioCoachingSettings {
  const factory AudioCoachingSettings({
    /// Whether audio coaching cues are enabled globally for recordings.
    @Default(true) bool enabled,

    /// Preferred unit system for spoken announcements.
    @Default(UnitSystem.metric) UnitSystem unitSystem,

    /// Sound mode: voice + chime, voice only, or chime only.
    @Default(AudioCueMode.voiceAndChime) AudioCueMode cueMode,

    /// Distance interval in metres between periodic split announcements.
    /// If null, defaults to 1,000 m (1 km) or 1,609.344 m (1 mile) based on
    /// the user's unit system.
    double? splitIntervalMeters,

    /// Whether to announce periodic split milestones (e.g. at every km/mile).
    @Default(true) bool announceSplits,

    /// Whether split announcements include the split pace.
    @Default(true) bool announcePace,

    /// Whether to announce workout status changes (start, pause, resume).
    @Default(true) bool announceStatusChanges,

    /// Whether to announce distance milestones (e.g. 5k, 10k).
    @Default(true) bool announceMilestones,

    /// Speech rate between 0.0 and 1.0 (default 0.5 for natural pacing).
    @Default(0.5) double speechRate,

    /// Speech volume between 0.0 and 1.0.
    @Default(1.0) double volume,
  }) = _AudioCoachingSettings;

  factory AudioCoachingSettings.fromJson(Map<String, dynamic> json) =>
      _$AudioCoachingSettingsFromJson(json);
}
