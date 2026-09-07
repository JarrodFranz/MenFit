import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard tests for `ios/Runner/Info.plist` GPS-recording entries (ADR 008).
/// Info.plist keys are invisible to debug-mode development, same pitfall
/// class as the Android manifest guard test - see
/// `D:\Documents\Claude\Flutter development knowledge\testing-pitfalls.md`.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  test('declares NSLocationWhenInUseUsageDescription', () {
    expect(
      plist,
      contains('<key>NSLocationWhenInUseUsageDescription</key>'),
      reason:
          'Without this key, requesting location permission crashes the '
          'app on iOS at runtime rather than showing the OS permission '
          'dialog.',
    );
  });

  test('declares the "location" UIBackgroundModes entry', () {
    // A loose substring check (not a strict array-position assertion) -
    // robust to other background modes being added later alongside it.
    final backgroundModesBlock = RegExp(
      r'<key>UIBackgroundModes</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);

    expect(
      backgroundModesBlock,
      isNotNull,
      reason: 'Info.plist must declare a UIBackgroundModes array.',
    );
    expect(
      backgroundModesBlock!.group(1),
      contains('<string>location</string>'),
      reason:
          'Without the "location" background mode, GPS recording stops '
          'receiving updates as soon as the screen turns off (ADR 008).',
    );
  });

  test('does NOT declare the NSLocationAlwaysUsageDescription key', () {
    // ADR 008: when-in-use auth is sufficient for a foreground-started
    // recording session with allowsBackgroundLocationUpdates; Always
    // authorization is deliberately not requested. A deliberate future
    // change here should also update the ADR, not silently add the key.
    // Checked as an actual `<key>` entry (not a bare substring) so the
    // explanatory comment above, which names the key in prose, doesn't
    // trip this assertion.
    expect(
      plist,
      isNot(contains('<key>NSLocationAlwaysUsageDescription</key>')),
    );
  });

  test(
    'declares NSLocationAlwaysAndWhenInUseUsageDescription with a string '
    'that says Always access is never requested',
    () {
      // Reversed on 2026-09-06 (ADR 008 amendment): Apple's upload check
      // ITMS-90683 requires a purpose string for every location API the
      // linked geolocator plugin references, including the Always variant,
      // whether or not the app ever asks for it. The key therefore exists,
      // but ADR 008 still stands - the app only requests when-in-use, and
      // app_identity_guard_test asserts no code path requests Always. The
      // string must tell the user that truth.
      final start = plist.indexOf(
        '<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>',
      );
      expect(start, isNot(-1), reason: 'ITMS-90683: key must be declared');
      final value = plist
          .substring(start)
          .split('<string>')[1]
          .split('</string>')[0];
      expect(value.trim(), isNotEmpty);
      expect(
        value.toLowerCase(),
        anyOf(contains('never'), contains('only')),
        reason: 'The string must make clear Always access is not requested.',
      );
    },
  );
}
