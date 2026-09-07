import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:menfit_app/features/activity/domain/recording_session.dart';
import 'package:meta/meta.dart';

/// Represents a triggered audio cue event containing spoken words
/// and chime directives.
@immutable
class AudioCueEvent {
  const AudioCueEvent({
    required this.spokenText,
    required this.playChime,
  });

  /// The natural-sounding speech text to be announced by the TTS engine.
  final String spokenText;

  /// Whether the transition chime should precede the spoken cue.
  final bool playChime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioCueEvent &&
          runtimeType == other.runtimeType &&
          spokenText == other.spokenText &&
          playChime == other.playChime;

  @override
  int get hashCode => spokenText.hashCode ^ playChime.hashCode;

  @override
  String toString() => 'AudioCueEvent(text: "$spokenText", chime: $playChime)';
}

/// Pure-Dart evaluation engine for real-time audio coaching cues during
/// GPS activity recording.
///
/// Deterministically generates natural-sounding spoken English phrases for
/// splits, distance milestones, and status transitions without platform
/// dependencies.
class AudioCueEngine {
  AudioCueEngine({
    required this.settings,
    this.unitSystem = UnitSystem.metric,
  }) : _splitIntervalMeters =
           settings.splitIntervalMeters ??
           (unitSystem == UnitSystem.metric ? 1000.0 : 1609.344);

  final AudioCoachingSettings settings;
  final UnitSystem unitSystem;
  final double _splitIntervalMeters;

  int _lastAnnouncedSplitIndex = 0;
  Duration _lastSplitMovingTime = Duration.zero;
  final Set<double> _announcedMilestones = {};

  /// Significant standard distance milestones to celebrate (in metres).
  static const List<double> _standardMilestonesMeters = [
    5000.0, // 5k
    10000.0, // 10k
    15000.0, // 15k
    21097.5, // Half marathon
    42195.0, // Marathon
  ];

  /// Evaluates distance progress and returns any newly triggered audio cue
  /// events (such as split announcements or milestone celebrations).
  List<AudioCueEvent> evaluateDistanceUpdate({
    required double distanceMeters,
    required Duration movingTime,
    double? currentPaceSecondsPerKm,
  }) {
    if (!settings.enabled) return const [];
    final events = <AudioCueEvent>[];

    // 1. Periodic Split Announcements
    if (settings.announceSplits && _splitIntervalMeters > 0) {
      final currentSplitIndex = (distanceMeters / _splitIntervalMeters).floor();
      if (currentSplitIndex > _lastAnnouncedSplitIndex) {
        for (
          var i = _lastAnnouncedSplitIndex + 1;
          i <= currentSplitIndex;
          i++
        ) {
          final splitDuration = movingTime > _lastSplitMovingTime
              ? movingTime - _lastSplitMovingTime
              : movingTime;

          final phrase = _formatSplitPhrase(
            splitNumber: i,
            splitDuration: splitDuration,
            splitDistanceMeters: _splitIntervalMeters,
            unitSystem: unitSystem,
            includePace: settings.announcePace,
          );

          events.add(
            AudioCueEvent(
              spokenText: phrase,
              playChime:
                  settings.cueMode == AudioCueMode.voiceAndChime ||
                  settings.cueMode == AudioCueMode.chimeOnly,
            ),
          );

          _lastAnnouncedSplitIndex = i;
          _lastSplitMovingTime = movingTime;
        }
      }
    }

    // 2. Distance Milestones
    if (settings.announceMilestones) {
      for (final milestone in _standardMilestonesMeters) {
        if (distanceMeters >= milestone &&
            !_announcedMilestones.contains(milestone)) {
          _announcedMilestones.add(milestone);
          final phrase = _formatMilestonePhrase(milestone, unitSystem);
          events.add(
            AudioCueEvent(
              spokenText: phrase,
              playChime:
                  settings.cueMode == AudioCueMode.voiceAndChime ||
                  settings.cueMode == AudioCueMode.chimeOnly,
            ),
          );
        }
      }
    }

    return events;
  }

  /// Evaluates lifecycle status changes (start, pause, auto-pause, resume)
  /// and returns an audio cue event if enabled.
  AudioCueEvent? evaluateStatusChange({
    required RecordingSessionStatus previousStatus,
    required RecordingSessionStatus newStatus,
  }) {
    if (!settings.enabled || !settings.announceStatusChanges) return null;

    final phrase = switch (newStatus) {
      RecordingSessionStatus.recording
          when previousStatus == RecordingSessionStatus.ready =>
        'Workout started.',
      RecordingSessionStatus.recording
          when previousStatus == RecordingSessionStatus.paused =>
        'Workout resumed.',
      RecordingSessionStatus.recording
          when previousStatus == RecordingSessionStatus.autoPaused =>
        'Movement detected, workout resumed.',
      RecordingSessionStatus.paused => 'Workout paused.',
      RecordingSessionStatus.autoPaused => 'Workout auto-paused.',
      _ => null,
    };

    if (phrase == null) return null;

    return AudioCueEvent(
      spokenText: phrase,
      playChime:
          settings.cueMode == AudioCueMode.voiceAndChime ||
          settings.cueMode == AudioCueMode.chimeOnly,
    );
  }

  /// Formulates the workout finish announcement.
  AudioCueEvent? onSessionFinished({
    required double distanceMeters,
    required Duration movingTime,
  }) {
    if (!settings.enabled || !settings.announceStatusChanges) return null;

    final distanceStr = _formatDistanceSpoken(distanceMeters, unitSystem);
    final timeStr = formatDurationSpoken(movingTime);
    final phrase =
        'Workout completed. Total distance: $distanceStr. '
        'Total moving time: $timeStr.';

    return AudioCueEvent(
      spokenText: phrase,
      playChime:
          settings.cueMode == AudioCueMode.voiceAndChime ||
          settings.cueMode == AudioCueMode.chimeOnly,
    );
  }

  /// Formats a natural spoken split announcement phrase.
  /// Example: "Split 1. 1 kilometer. Time: 5 minutes, 12 seconds.
  /// Split pace: 5 minutes 12 seconds per kilometer."
  static String _formatSplitPhrase({
    required int splitNumber,
    required Duration splitDuration,
    required double splitDistanceMeters,
    required UnitSystem unitSystem,
    required bool includePace,
  }) {
    final unitLabel = unitSystem == UnitSystem.metric ? 'kilometer' : 'mile';
    final durationStr = formatDurationSpoken(splitDuration);

    final sb = StringBuffer()
      ..write('Split $splitNumber. ')
      ..write('$splitNumber $unitLabel');
    if (splitNumber > 1) sb.write('s');
    sb.write('. Time: $durationStr.');

    if (includePace && splitDistanceMeters > 0) {
      final distanceInUnits = unitSystem == UnitSystem.metric
          ? splitDistanceMeters / 1000.0
          : splitDistanceMeters / 1609.344;
      final paceSeconds = splitDuration.inSeconds / distanceInUnits;
      final paceDuration = Duration(seconds: paceSeconds.round());
      final paceStr = formatDurationSpoken(paceDuration);
      sb.write(' Split pace: $paceStr per $unitLabel.');
    }

    return sb.toString();
  }

  /// Formats a milestone celebration phrase.
  static String _formatMilestonePhrase(
    double milestoneMeters,
    UnitSystem unitSystem,
  ) {
    if ((milestoneMeters - 21097.5).abs() < 10) {
      return 'Half marathon distance completed! Outstanding effort!';
    }
    if ((milestoneMeters - 42195.0).abs() < 10) {
      return 'Full marathon distance reached! You are unstoppable!';
    }

    final distanceStr = _formatDistanceSpoken(milestoneMeters, unitSystem);
    return '$distanceStr reached! Amazing work!';
  }

  /// Formats a distance into a spoken string like
  /// "5 kilometers" or "3.1 miles".
  static String _formatDistanceSpoken(double meters, UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.metric) {
      final km = meters / 1000.0;
      final rounded = km == km.roundToDouble()
          ? km.toStringAsFixed(0)
          : km.toStringAsFixed(1);
      return '$rounded kilometer${km == 1.0 ? '' : 's'}';
    } else {
      final miles = meters / 1609.344;
      final rounded = miles == miles.roundToDouble()
          ? miles.toStringAsFixed(0)
          : miles.toStringAsFixed(1);
      return '$rounded mile${miles == 1.0 ? '' : 's'}';
    }
  }

  /// Formats a [Duration] into natural spoken English.
  /// Examples:
  /// - `Duration(seconds: 45)` -> "45 seconds"
  /// - `Duration(minutes: 5, seconds: 12)` -> "5 minutes, 12 seconds"
  /// - `Duration(hours: 1, minutes: 2, seconds: 5)` ->
  ///   "1 hour, 2 minutes, 5 seconds"
  static String formatDurationSpoken(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours hour${hours == 1 ? '' : 's'}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds second${seconds == 1 ? '' : 's'}');
    }

    return parts.join(', ');
  }
}
