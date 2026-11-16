import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard test for the app's permanent identity and release-signing wiring
/// (config-only surfaces get guard tests per
/// `knowledge/engineering/coding_standards.md`).
///
/// `com.jarrodfranz.menfit` was chosen on 2026-09-05 and is registered with
/// Apple (TestFlight via Codemagic) and Firebase (App Distribution). It must
/// stay identical on every platform: a drift between the Android
/// applicationId, the Gradle namespace, the Kotlin package path, the iOS
/// bundle id and the Codemagic signing block silently produces a build that
/// installs as a *different app* - testers cannot update in place and lose
/// their local health data. See
/// `knowledge/engineering/release_and_distribution.md`.
void main() {
  const appId = 'com.jarrodfranz.menfit';
  const placeholder = 'com.example';

  group('Android', () {
    final gradle = File('android/app/build.gradle.kts');
    late String source;

    setUpAll(() {
      expect(gradle.existsSync(), isTrue);
      source = gradle.readAsStringSync();
    });

    test('applicationId and namespace are the permanent app id', () {
      expect(source, contains('applicationId = "$appId"'));
      expect(source, contains('namespace = "$appId"'));
      expect(
        source,
        isNot(contains(placeholder)),
        reason: 'The bootstrap placeholder must never come back.',
      );
    });

    test('MainActivity lives at the package path matching the namespace', () {
      final activity = File(
        'android/app/src/main/kotlin/${appId.replaceAll('.', '/')}/'
        'MainActivity.kt',
      );
      expect(activity.existsSync(), isTrue);
      expect(activity.readAsStringSync(), contains('package $appId'));
      expect(
        Directory('android/app/src/main/kotlin/com/example').existsSync(),
        isFalse,
        reason: 'The old package directory must be gone, not duplicated.',
      );
    });

    test('release builds sign with the upload keystore when present', () {
      expect(source, contains('rootProject.file("key.properties")'));
      expect(source, contains('signingConfigs.getByName("release")'));
      expect(
        source,
        contains('storeFile = file(keystoreProperties["storeFile"]'),
      );
      // The fallback must warn loudly rather than silently ship debug-signed.
      expect(source, contains('DEBUG-SIGNED'));
    });

    test('keystore material is gitignored', () {
      final ignore = File('android/.gitignore').readAsStringSync();
      expect(ignore, contains('key.properties'));
      expect(ignore, contains('**/*.jks'));
      expect(ignore, contains('**/*.keystore'));
      expect(
        File('android/key.properties').existsSync() &&
            Process.runSync('git', [
                  'ls-files',
                  '--error-unmatch',
                  'android/key.properties',
                ]).exitCode ==
                0,
        isFalse,
        reason: 'android/key.properties must never be tracked by git.',
      );
    });
  });

  group('iOS', () {
    test('every Runner build configuration uses the permanent bundle id', () {
      final pbxproj = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      final ids = RegExp(
        'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);',
      ).allMatches(pbxproj).map((m) => m.group(1)!).toSet();
      expect(ids, {appId, '$appId.RunnerTests'});
      expect(pbxproj, isNot(contains(placeholder)));
    });

    test('display name is the product name, not the Dart package name', () {
      final plist = File('ios/Runner/Info.plist')
          .readAsStringSync()
          .replaceAll('\r\n', '\n')
          .replaceAll('\t', '');
      expect(
        plist,
        contains('<key>CFBundleDisplayName</key>\n<string>MenFit</string>'),
      );
      expect(plist, isNot(contains('menfit_app')));
    });

    test(
      "declares the Always-location purpose string Apple's upload check "
      '(ITMS-90683) requires, without requesting Always authorization',
      () {
        final plist = File('ios/Runner/Info.plist').readAsStringSync();
        final always = RegExp(
          r'<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>\s*'
          '<string>([^<]+)</string>',
        ).firstMatch(plist);
        expect(
          always,
          isNotNull,
          reason:
              'NSLocationAlwaysAndWhenInUseUsageDescription is missing - '
              "Apple's upload check (ITMS-90683) flags the geolocator "
              "plugin's reference to the Always-location API without it. "
              'See knowledge/decisions/008_run_recording_stack.md.',
        );
        expect(always!.group(1)!.trim(), isNotEmpty);
        // ADR 008 stands: the app never requests Always authorization.
        expect(
          plist,
          isNot(contains('requestPermission(LocationPermission.always')),
        );
      },
    );

    test('declares the export-compliance exemption for HTTPS-only crypto', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(
        plist,
        matches(r'<key>ITSAppUsesNonExemptEncryption</key>\s*<false/>'),
        reason:
            'ITSAppUsesNonExemptEncryption must be false so App Store '
            'Connect stops prompting "Missing Compliance" on every build.',
      );
    });

    test('still declares both HealthKit purpose strings', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('<key>NSHealthShareUsageDescription</key>'));
      expect(plist, contains('<key>NSHealthUpdateUsageDescription</key>'));
    });

    test(
      'Runner.entitlements exists and grants HealthKit',
      () {
        final file = File('ios/Runner/Runner.entitlements');
        expect(
          file.existsSync(),
          isTrue,
          reason:
              'Without an entitlements file the app is not entitled for '
              'HealthKit even though the App ID and profile carry the '
              'capability.',
        );
        final entitlements = file.readAsStringSync();
        expect(
          entitlements,
          matches(r'<key>com.apple.developer.healthkit</key>\s*<true/>'),
        );
        expect(
          entitlements,
          contains('<key>com.apple.developer.healthkit.access</key>'),
        );
      },
    );

    test(
      'pbxproj wires CODE_SIGN_ENTITLEMENTS into exactly the three Runner '
      'target build configurations',
      () {
        final pbxproj = File(
          'ios/Runner.xcodeproj/project.pbxproj',
        ).readAsStringSync();
        expect(
          pbxproj,
          contains(
            '/* Runner.entitlements */ = {isa = PBXFileReference; '
            'lastKnownFileType = text.plist.entitlements; '
            'path = Runner.entitlements; sourceTree = "<group>"; };',
          ),
        );
        final occurrences =
            'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'
                .allMatches(pbxproj)
                .length;
        expect(
          occurrences,
          3,
          reason:
              'Debug (97C147061CF9000F007C117D), Release '
              '(97C147071CF9000F007C117D) and Profile '
              '(249021D4217E4FDB00AE95B9) must each carry the entitlements '
              'file - RunnerTests and project-level configurations must not.',
        );
      },
    );

    test('every object id defined in the pbxproj is unique', () {
      final pbxproj = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      // An id legitimately appears many times in a pbxproj - once where the
      // object is defined, and again everywhere it is referenced (group
      // children, build phase file lists, configuration lists, ...). Only
      // the *definition* line - "<id> /* comment */ = {" - identifies a
      // real object; two definitions sharing an id would mean two different
      // objects collided on the same identifier, which corrupts the file.
      final definitions = RegExp(
        r'^\s*([0-9A-F]{24}) /\*[^\n]*\*/ = \{',
        multiLine: true,
      ).allMatches(pbxproj).map((m) => m.group(1)!).toList();
      final unique = definitions.toSet();
      expect(
        definitions.length,
        unique.length,
        reason:
            'Duplicate object id definitions found: '
            '${{
              for (final id in unique)
                if (definitions.where((d) => d == id).length > 1) id,
            }}',
      );
    });
  });

  group('codemagic.yaml', () {
    final file = File('codemagic.yaml');
    late String yaml;

    setUpAll(() {
      expect(file.existsSync(), isTrue);
      yaml = file.readAsStringSync();
    });

    test('signs the same bundle id', () {
      expect(yaml, contains('bundle_identifier: $appId'));
      expect(yaml, contains('BUNDLE_ID: $appId'));
    });

    test('pins the Flutter version the repo is validated against', () {
      // Codemagic's `flutter: stable` would drift from the local toolchain
      // (and the analyzer-9 window handoff/HANDOFF.md warns about).
      expect(
        RegExp(r'^\s+flutter: \d+\.\d+\.\d+$', multiLine: true).hasMatch(yaml),
        isTrue,
      );
    });

    test('contains no credentials or personal addresses', () {
      expect(yaml, isNot(contains('@')));
      for (final needle in const ['-----BEGIN', 'AuthKey_', 'password:']) {
        expect(yaml, isNot(contains(needle)));
      }
    });
  });

  group('web/', () {
    // The web shell is the one surface no Dart test renders, so a stale
    // FemFit string here survives every widget test and ships to whoever
    // opens the PWA. `web/manifest.json` is what an installed home-screen
    // icon is named from.
    const forkLeftovers = ['women', 'femfit'];

    for (final path in const ['web/index.html', 'web/manifest.json']) {
      test('$path names MenFit and carries no FemFit copy', () {
        final file = File(path);
        expect(file.existsSync(), isTrue);
        final source = file.readAsStringSync();
        expect(source, contains('MenFit'));
        final lowered = source.toLowerCase();
        for (final needle in forkLeftovers) {
          expect(
            lowered,
            isNot(contains(needle)),
            reason: '$path still carries the forked-from copy "$needle".',
          );
        }
      });
    }
  });

  group('distribution/android.json', () {
    test('holds only the public Firebase app id and tester groups', () {
      final file = File('distribution/android.json');
      expect(file.existsSync(), isTrue);
      final raw = file.readAsStringSync();
      // A Firebase Android app id looks like 1:<digits>:android:<hex>.
      // Service-account JSON or CLI tokens would carry these instead.
      expect(raw, isNot(contains('private_key')));
      expect(raw, isNot(contains('refresh_token')));
      expect(raw, isNot(contains('client_secret')));
    });
  });
}
