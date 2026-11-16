import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'AndroidManifest.xml declares the INTERNET permission',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      final internetPermission = RegExp(
        r'<uses-permission\s+android:name="android\.permission\.INTERNET"\s*/>',
      );

      expect(
        internetPermission.hasMatch(manifest),
        isTrue,
        reason:
            'android/app/src/main/AndroidManifest.xml must declare the '
            'INTERNET permission, otherwise release builds will silently '
            'fail to make any network request.',
      );
    },
  );

  group('GPS recording permissions (ADR 008)', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    for (final permission in [
      'ACCESS_FINE_LOCATION',
      'ACCESS_COARSE_LOCATION',
      'FOREGROUND_SERVICE',
      'FOREGROUND_SERVICE_LOCATION',
      'POST_NOTIFICATIONS',
    ]) {
      test('declares $permission', () {
        final pattern = RegExp(
          '<uses-permission\\s+android:name="android\\.permission\\.$permission"\\s*/>',
        );
        expect(
          pattern.hasMatch(manifest),
          isTrue,
          reason:
              'AndroidManifest.xml must declare android.permission.$permission '
              'for GPS activity recording (see '
              'knowledge/decisions/008_run_recording_stack.md).',
        );
      });
    }

    test('does NOT declare ACCESS_BACKGROUND_LOCATION', () {
      // ADR 008: deliberately not requested - a foreground service started
      // while the app is foregrounded keeps receiving location with the
      // screen off, and this permission would trigger Play's separate,
      // heavier background-location review form + demo video for no
      // benefit here. If this test starts failing because the permission
      // was added, that's a decision to make deliberately (and update the
      // ADR), not an accident.
      //
      // Matches ANY `<uses-permission ...>` element that references
      // ACCESS_BACKGROUND_LOCATION anywhere inside its attributes,
      // regardless of other attributes (e.g. `android:maxSdkVersion`) or
      // their ordering - not just the exact
      // `<uses-permission android:name="..."/>` shape, which a
      // differently-formatted or decorated element would slip past.
      final pattern = RegExp(
        r'<uses-permission\b[^>]*ACCESS_BACKGROUND_LOCATION[^>]*/?>',
      );
      expect(pattern.hasMatch(manifest), isFalse);
    });
  });

  group('Health Connect read permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    // Health Connect silently refuses to grant any permission the manifest
    // does not declare. READ_EXERCISE and READ_DISTANCE were missing once,
    // so Garmin/wearable workouts could never be granted or read while
    // steps kept working - the sync reported "up to date" with nothing in it.
    for (final permission in [
      'READ_STEPS',
      'READ_ACTIVE_CALORIES_BURNED',
      'READ_TOTAL_CALORIES_BURNED',
      'READ_EXERCISE',
      'READ_DISTANCE',
    ]) {
      test('declares health.$permission', () {
        final pattern = RegExp(
          '<uses-permission\\s+android:name="android\\.permission\\.health\\.$permission"\\s*/>',
        );
        expect(
          pattern.hasMatch(manifest),
          isTrue,
          reason:
              'AndroidManifest.xml must declare '
              'android.permission.health.$permission or Health Connect '
              'cannot grant it.',
        );
      });
    }
  });

  test('AndroidManifest.xml queries android.intent.action.TTS_SERVICE', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final pattern = RegExp(
      r'<action\s+android:name="android\.intent\.action\.TTS_SERVICE"\s*/>',
    );
    expect(
      pattern.hasMatch(manifest),
      isTrue,
      reason:
          'Android 11+ requires <queries> to discover text-to-speech engines '
          'for audio coaching cues.',
    );
  });
}
