import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/speech/speech_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/recording/audio_cues_settings_sheet.dart';
import 'package:menfit_app/features/activity/presentation/recording/record_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';

import '../../../../core/platform/audio/fake_audio_cue_player.dart';
import '../../../../core/platform/speech/fake_speech_adapter.dart';

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

class _StubLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

void main() {
  late FakeSpeechAdapter fakeSpeech;
  late FakeAudioCuePlayer fakePlayer;

  setUp(() {
    fakeSpeech = FakeSpeechAdapter();
    fakePlayer = FakeAudioCuePlayer();
  });

  Widget buildScreen({
    RecordingControllerState state = const RecordingControllerState(),
  }) {
    return ProviderScope(
      overrides: [
        mapTileProviderProvider.overrideWithValue(_FakeTileProvider()),
        locationAdapterProvider.overrideWithValue(_StubLocationAdapter()),
        speechAdapterProvider.overrideWithValue(fakeSpeech),
        audioCuePlayerProvider.overrideWithValue(fakePlayer),
        recordingControllerProvider.overrideWith(
          () => _TestRecordingController(state),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const RecordScreen(),
      ),
    );
  }

  group('RecordScreen audio coaching cues', () {
    testWidgets('renders audio coaching button in pre-start view and AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recordAudioCuesButton')), findsOneWidget);
      expect(find.byKey(const Key('recordAudioCuesAction')), findsOneWidget);
      expect(find.text('Audio Coaching Cues'), findsOneWidget);
    });

    testWidgets('renders audio coaching button in pre-start view and AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recordAudioCuesButton')), findsOneWidget);
      expect(find.byKey(const Key('recordAudioCuesAction')), findsOneWidget);
      expect(find.text('Audio Coaching Cues'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('tapping Audio Coaching Cues button opens settings sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('recordAudioCuesButton')));
      await tester.pumpAndSettle();

      expect(find.byType(AudioCuesSettingsSheet), findsOneWidget);
      expect(find.text('Audio Coaching Cues'), findsWidgets);
      expect(find.text('Voice & Chime'), findsOneWidget);
      expect(find.text('Split Announcements'), findsOneWidget);
      expect(find.text('Test Voice'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('tapping Test Voice speaks preview phrase', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('recordAudioCuesButton')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Test Voice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Voice'));
      await tester.pump();

      expect(fakeSpeech.spokenUtterances, isNotEmpty);
      expect(fakeSpeech.spokenUtterances.first, contains('Split 1'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'recording view renders audio mute button and toggles mute state',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          buildScreen(
            state: const RecordingControllerState(
              lifecycle: RecordingLifecycle.recording,
              activityType: ActivityType.run,
            ),
          ),
        );
        await tester.pump();

        final muteButton = find.byKey(const Key('recordAudioMuteToggle'));
        expect(muteButton, findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);

        await tester.tap(muteButton);
        await tester.pump();

        expect(find.byIcon(Icons.volume_off), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });
}

class _TestRecordingController extends RecordingController {
  _TestRecordingController(this._initial);

  final RecordingControllerState _initial;

  @override
  RecordingControllerState build() => _initial;
}
