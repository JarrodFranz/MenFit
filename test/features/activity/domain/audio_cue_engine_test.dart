import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_cue_engine.dart';
import 'package:menfit_app/features/activity/domain/recording_session.dart';

void main() {
  group('AudioCueEngine - Split Announcements', () {
    test('announces first kilometer split with time and pace in metric', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(),
      );

      // Moving from 0 to 800m: no split yet
      final cues0 = engine.evaluateDistanceUpdate(
        distanceMeters: 800,
        movingTime: const Duration(minutes: 4),
      );
      expect(cues0, isEmpty);

      // Reaching 1,050m: crosses 1 km split
      final cues1 = engine.evaluateDistanceUpdate(
        distanceMeters: 1050,
        movingTime: const Duration(minutes: 5, seconds: 12),
      );
      expect(cues1, hasLength(1));
      expect(cues1.first.playChime, isTrue);
      expect(
        cues1.first.spokenText,
        contains('Split 1. 1 kilometer. Time: 5 minutes, 12 seconds.'),
      );
      expect(
        cues1.first.spokenText,
        contains('Split pace: 5 minutes, 12 seconds per kilometer.'),
      );

      // Progressing to 1,500m: still split 1, no duplicate cue
      final cuesMid = engine.evaluateDistanceUpdate(
        distanceMeters: 1500,
        movingTime: const Duration(minutes: 7),
      );
      expect(cuesMid, isEmpty);

      // Reaching 2,010m: crosses 2 km split
      final cues2 = engine.evaluateDistanceUpdate(
        distanceMeters: 2010,
        movingTime: const Duration(minutes: 10, seconds: 30),
      );
      expect(cues2, hasLength(1));
      expect(
        cues2.first.spokenText,
        contains('Split 2. 2 kilometers. Time: 5 minutes, 18 seconds.'),
      );
    });

    test('announces splits in miles when imperial unit system is active', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(),
        unitSystem: UnitSystem.imperial,
      );

      // 1 mile = 1609.344 meters
      final cues = engine.evaluateDistanceUpdate(
        distanceMeters: 1620,
        movingTime: const Duration(minutes: 8, seconds: 30),
      );

      expect(cues, hasLength(1));
      expect(
        cues.first.spokenText,
        contains('Split 1. 1 mile. Time: 8 minutes, 30 seconds.'),
      );
      expect(
        cues.first.spokenText,
        contains('Split pace: 8 minutes, 30 seconds per mile.'),
      );
    });

    test('respects custom distance interval (e.g. every 500m)', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(splitIntervalMeters: 500),
      );

      final cues = engine.evaluateDistanceUpdate(
        distanceMeters: 510,
        movingTime: const Duration(minutes: 2, seconds: 30),
      );

      expect(cues, hasLength(1));
      expect(cues.first.spokenText, contains('Split 1'));
    });

    test('omits pace when announcePace is disabled', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(announcePace: false),
      );

      final cues = engine.evaluateDistanceUpdate(
        distanceMeters: 1010,
        movingTime: const Duration(minutes: 5),
      );

      expect(cues, hasLength(1));
      expect(cues.first.spokenText, isNot(contains('Split pace')));
    });
  });

  group('AudioCueEngine - Milestones', () {
    test('celebrates 5k milestone when crossed', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(announceSplits: false),
      );

      final cues = engine.evaluateDistanceUpdate(
        distanceMeters: 5020,
        movingTime: const Duration(minutes: 26),
      );

      expect(cues, hasLength(1));
      expect(cues.first.spokenText, contains('5 kilometers reached!'));
    });
  });

  group('AudioCueEngine - Status Transitions', () {
    test('generates voice phrases for lifecycle status transitions', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(),
      );

      final startCue = engine.evaluateStatusChange(
        previousStatus: RecordingSessionStatus.ready,
        newStatus: RecordingSessionStatus.recording,
      );
      expect(startCue?.spokenText, 'Workout started.');

      final pauseCue = engine.evaluateStatusChange(
        previousStatus: RecordingSessionStatus.recording,
        newStatus: RecordingSessionStatus.paused,
      );
      expect(pauseCue?.spokenText, 'Workout paused.');

      final resumeCue = engine.evaluateStatusChange(
        previousStatus: RecordingSessionStatus.paused,
        newStatus: RecordingSessionStatus.recording,
      );
      expect(resumeCue?.spokenText, 'Workout resumed.');

      final autoPauseCue = engine.evaluateStatusChange(
        previousStatus: RecordingSessionStatus.recording,
        newStatus: RecordingSessionStatus.autoPaused,
      );
      expect(autoPauseCue?.spokenText, 'Workout auto-paused.');
    });

    test('generates finish announcement with total distance and time', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(),
      );

      final finishCue = engine.onSessionFinished(
        distanceMeters: 5200,
        movingTime: const Duration(minutes: 27, seconds: 15),
      );

      expect(finishCue, isNotNull);
      expect(finishCue!.spokenText, contains('Workout completed.'));
      expect(finishCue.spokenText, contains('Total distance: 5.2 kilometers.'));
      expect(
        finishCue.spokenText,
        contains('Total moving time: 27 minutes, 15 seconds.'),
      );
    });
  });

  group('AudioCueEngine - Sound Mode & Disabled', () {
    test('emits no cues when settings are disabled', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(enabled: false),
      );

      expect(
        engine.evaluateDistanceUpdate(
          distanceMeters: 2000,
          movingTime: const Duration(minutes: 10),
        ),
        isEmpty,
      );

      expect(
        engine.evaluateStatusChange(
          previousStatus: RecordingSessionStatus.ready,
          newStatus: RecordingSessionStatus.recording,
        ),
        isNull,
      );
    });

    test('disables chime when cueMode is voiceOnly', () {
      final engine = AudioCueEngine(
        settings: const AudioCoachingSettings(cueMode: AudioCueMode.voiceOnly),
      );

      final cue = engine.evaluateStatusChange(
        previousStatus: RecordingSessionStatus.ready,
        newStatus: RecordingSessionStatus.recording,
      );
      expect(cue?.playChime, isFalse);
    });
  });
}
