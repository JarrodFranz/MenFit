import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/barcode_scanning.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/presentation/barcode_scan_screen.dart';

/// What a widget test can honestly cover here is the *unsupported* half of
/// [BarcodeScanScreen]. The supported half needs a camera texture, a platform
/// channel and a real decoder; faking those would only assert that the fake
/// behaves like the fake, so it is left to manual verification on a device
/// (and noted as such in the wave report) rather than tested hollowly.
///
/// `flutter test` reports [TargetPlatform.android] by default, so the
/// unsupported branch has to be selected explicitly — which is fortunate,
/// because it also means these tests exercise the real capability check
/// rather than an accident of the host machine.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light(), home: child);

  /// Runs [body] with [debugDefaultTargetPlatformOverride] set, clearing it
  /// **inside the test body**.
  ///
  /// A `setUp`/`tearDown` pair cannot do this: `flutter_test` asserts that
  /// every foundation debug variable is unset at the end of the test *body*
  /// (`_verifyInvariants`), which runs before any tear-down — so a
  /// tear-down reset always arrives too late and every widget test fails
  /// with "The value of a foundation debug variable was changed by the
  /// test." The plain `test()` cases below have no such check and the
  /// file-level `tearDown` is enough for them.
  ///
  /// The `finally` earns its place independently: without it a failing
  /// expectation would skip the reset and leak the override into unrelated
  /// tests, turning one red test into a cascade.
  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  group('barcodeScanningSupported', () {
    test('is true on the two platforms with a working camera stack', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(barcodeScanningSupported, isTrue, reason: '$platform');
      }
    });

    test('is false on every desktop platform', () {
      // Windows has no `startImageStream`, so there is no frame source to
      // decode; macOS and Linux have no camera story in this app at all.
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(barcodeScanningSupported, isFalse, reason: '$platform');
      }
    });
  });

  group('BarcodeScanScreen on an unsupported platform', () {
    testWidgets('shows the unsupported state instead of a preview', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.windows, () async {
        await tester.pumpWidget(wrap(const BarcodeScanScreen()));

        expect(find.text('Scanning needs a phone camera'), findsOneWidget);
        expect(find.text('Type it in instead'), findsOneWidget);
      });
    });

    testWidgets('builds no scanner controller and no camera chrome', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.windows, () async {
        await tester.pumpWidget(wrap(const BarcodeScanScreen()));

        // Constructing a MobileScannerController on a platform with no
        // registered implementation throws `UnimplementedError`, so a clean
        // pump is itself part of the assertion. The two widgets below exist
        // only on the camera branch: the torch action in the app bar (built
        // only when a controller exists) and the on-device privacy note that
        // sits under the preview. Asserted through their icons rather than by
        // importing `package:mobile_scanner` — this test deliberately keeps
        // that package confined to the one screen file.
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.flashlight_off), findsNothing);
        expect(find.byIcon(Icons.flashlight_on), findsNothing);
        expect(find.byIcon(Icons.lock_outline), findsNothing);
      });
    });

    testWidgets('"Type it in instead" pops null, the same as cancelling', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.windows, () async {
        String? result = 'not popped yet';

        await tester.pumpWidget(
          wrap(
            Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (_) => const BarcodeScanScreen(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byType(BarcodeScanScreen), findsOneWidget);

        await tester.tap(find.text('Type it in instead'));
        await tester.pumpAndSettle();

        expect(find.byType(BarcodeScanScreen), findsNothing);
        expect(result, isNull);
      });
    });
  });
}
