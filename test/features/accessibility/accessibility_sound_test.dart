import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/platform/audio/fake_audio_cue_player.dart';

/// The Sound Cues switch makes two promises, and this holds both: the chime
/// happens when it is on, and *nothing* happens when it is off - not a
/// quieter chime, not an audio session touched on their behalf.
///
/// Routed through a widget because [AccessibilitySound] takes a `WidgetRef`,
/// which is the shape every cue call site will have.
void main() {
  /// Pumps a widget that fires one chime per tap and returns the fake it
  /// played through.
  Future<FakeAudioCuePlayer> pumpChimeButton(
    WidgetTester tester, {
    Map<String, Object> initialPrefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final preferences = await SharedPreferences.getInstance();
    final player = FakeAudioCuePlayer();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          audioCuePlayerProvider.overrideWithValue(player),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Column(
                children: [
                  TextButton(
                    onPressed: () => AccessibilitySound.transitionChime(ref),
                    child: const Text('chime'),
                  ),
                  TextButton(
                    onPressed: () => AccessibilitySound.preload(ref),
                    child: const Text('preload'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return player;
  }

  testWidgets('plays the chime when sound cues are on', (tester) async {
    final player = await pumpChimeButton(
      tester,
      initialPrefs: {'accessibility_sound_cues': true},
    );

    await tester.tap(find.text('chime'));
    await tester.pump();

    expect(player.chimeCount, 1);
  });

  testWidgets('plays nothing when sound cues are off', (tester) async {
    final player = await pumpChimeButton(
      tester,
      initialPrefs: {'accessibility_sound_cues': false},
    );

    await tester.tap(find.text('chime'));
    await tester.pump();

    expect(player.chimeCount, 0);
  });

  testWidgets('does not even preload when sound cues are off', (tester) async {
    // Preloading opens an audio session and, on iOS, can change what the
    // silent switch does to other apps. A user who turned cues off should
    // not have that happen on their behalf.
    final player = await pumpChimeButton(
      tester,
      initialPrefs: {'accessibility_sound_cues': false},
    );

    await tester.tap(find.text('preload'));
    await tester.pump();

    expect(player.preloadCount, 0);
  });

  testWidgets('plays for an install that predates the setting', (
    tester,
  ) async {
    // The key is absent for everyone who installed before ADR 014. A
    // missing key must read as ON, or the feature ships silent for every
    // existing user and looks broken rather than off.
    final player = await pumpChimeButton(tester);

    await tester.tap(find.text('chime'));
    await tester.pump();

    expect(player.chimeCount, 1);
  });

  test('a missing preference key reads as sound cues on', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    expect(
      AccessibilityRepository(preferences).getPreferences().soundCues,
      isTrue,
    );
    expect(AccessibilityPreferences.defaults.soundCues, isTrue);
  });
}
