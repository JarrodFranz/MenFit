import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard tests for the native configuration on-device OCR needs (ADR 012).
///
/// None of this can be compiled on the Windows dev machine — the iOS target
/// needs a Mac — so these are the only thing standing between a wrong value
/// and a Mac session losing an afternoon to a `pod install` error with no
/// obvious cause. Same pitfall class as the sibling Info.plist and Android
/// manifest guards.
void main() {
  group('iOS deployment target', () {
    test('the Podfile pins the platform to 15.5', () {
      // Committed deliberately: the Flutter-generated Podfile leaves this
      // line commented and CocoaPods then infers the platform from the
      // Xcode project, which silently disagrees the moment a pod raises the
      // floor. `google_mlkit_text_recognition` 0.17.1 requires 15.5.
      final podfile = File('ios/Podfile');

      expect(
        podfile.existsSync(),
        isTrue,
        reason: 'ios/Podfile is committed, not generated (ADR 012).',
      );
      expect(
        podfile.readAsLinesSync(),
        contains("platform :ios, '15.5'"),
        reason:
            'Uncommented and exactly 15.5 — a commented-out line here is '
            'the default and does nothing.',
      );
    });

    test('every Runner build configuration targets at least 15.5', () {
      final pbxproj = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();

      final targets = RegExp(
        r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);',
      ).allMatches(pbxproj).map((m) => m.group(1)!).toList();

      expect(
        targets,
        isNotEmpty,
        reason: 'the project must state a deployment target at all',
      );
      for (final target in targets) {
        expect(
          double.parse(target),
          greaterThanOrEqualTo(15.5),
          reason:
              'ML Kit text recognition needs iOS 15.5; a lower value in '
              'any configuration fails at pod install, not at run time.',
        );
      }
    });
  });

  group('camera permission', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    test('declares NSCameraUsageDescription', () {
      // Without it, opening the camera does not prompt — it terminates the
      // app. One key covers both the barcode scanner and the label photo,
      // because iOS allows only one.
      expect(plist, contains('<key>NSCameraUsageDescription</key>'));
    });

    test('the camera string tells the truth about the label photo', () {
      final value = RegExp(
        r'<key>NSCameraUsageDescription</key>\s*<string>(.*?)</string>',
        dotAll: true,
      ).firstMatch(plist)?.group(1);

      expect(value, isNotNull);
      // The three claims the implementation actually keeps: nutrition
      // label, on-device, discarded. If a future change breaks one of
      // them, the string is what has to change.
      expect(value, contains('nutrition label'));
      expect(value, contains('on your device'));
      expect(value, contains('discarded'));
    });

    test('does not request photo-library access', () {
      // Capture is `ImageSource.camera` with `requestFullMetadata: false`.
      // A photo-library key appearing here would mean someone added a
      // "pick an existing photo" path, which reaches the user's whole
      // camera roll and needs its own decision (ADR 012 scoped to camera).
      expect(
        plist,
        isNot(contains('<key>NSPhotoLibraryUsageDescription</key>')),
      );
    });
  });

  group('pubspec pins', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();

    test('google_mlkit_text_recognition is pinned exactly', () {
      // Exact pins for platform plugins, as with mobile_scanner and
      // share_plus: a caret range here can move a native SDK floor on a
      // machine that cannot compile the target.
      expect(
        pubspec.map((l) => l.trim()),
        contains('google_mlkit_text_recognition: 0.17.1'),
      );
    });

    test('image_picker is pinned exactly', () {
      expect(pubspec.map((l) => l.trim()), contains('image_picker: 1.2.3'));
    });
  });

  test('Android minSdk clears the ML Kit floor of 21', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final minSdk = RegExp(r'minSdk\s*=\s*(\d+)').firstMatch(gradle)?.group(1);

    expect(minSdk, isNotNull);
    expect(int.parse(minSdk!), greaterThanOrEqualTo(21));
  });
}
