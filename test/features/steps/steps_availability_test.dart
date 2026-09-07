import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

import 'fake_health_platform_adapter.dart';

void main() {
  late FakeHealthPlatformAdapter adapter;

  setUp(() => adapter = FakeHealthPlatformAdapter());

  // Safety net only. Every case below also clears the override inside its
  // own body, so a failing expectation cannot leak a platform into the next
  // test (same convention as test/core/platform/ocr/text_recognition_test.dart).
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  ProviderContainer makeContainer({required bool syncEnabled}) {
    final container = ProviderContainer(
      overrides: [
        healthPlatformAdapterProvider.overrideWithValue(adapter),
        fitnessDeviceSyncControllerProvider.overrideWithValue(syncEnabled),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Runs [body] with [debugDefaultTargetPlatformOverride] set, clearing it
  /// inside the body's own scope so an expectation failure still restores it.
  Future<T> onPlatform<T>(
    TargetPlatform platform,
    Future<T> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      return await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  /// Resolves the asynchronous permission answer, keeping it subscribed so
  /// it is not disposed and restarted between the two reads.
  Future<StepsAvailability> settledAvailability(
    ProviderContainer container,
  ) async {
    container.listen(stepsPermissionProvider, (_, _) {});
    await container.read(stepsPermissionProvider.future);
    return container.read(stepsAvailabilityProvider);
  }

  group('no health platform on this device', () {
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ]) {
      test('$platform reports unsupportedPlatform', () async {
        await onPlatform(platform, () async {
          final container = makeContainer(syncEnabled: true);
          expect(
            container.read(stepsAvailabilityProvider),
            StepsAvailability.unsupportedPlatform,
          );
          expect(
            adapter.permissionCallCount,
            0,
            reason:
                'the platform question is answered without touching the '
                'health platform at all',
          );
        });
      });
    }

    test('the toggle being on does not make a desktop supported', () async {
      // The order matters: platform is asked first, so a user who left the
      // toggle on before switching to a desktop build still sees the honest
      // "not available here" rather than "turn sync on".
      await onPlatform(TargetPlatform.windows, () async {
        final container = makeContainer(syncEnabled: true);
        expect(
          container.read(stepsAvailabilityProvider),
          StepsAvailability.unsupportedPlatform,
        );
      });
    });
  });

  group('sync toggle off', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      test('$platform with sync off reports syncOff', () async {
        await onPlatform(platform, () async {
          final container = makeContainer(syncEnabled: false);
          expect(
            container.read(stepsAvailabilityProvider),
            StepsAvailability.syncOff,
          );
          expect(
            adapter.permissionCallCount,
            0,
            reason:
                'her stated preference short-circuits the permission check, '
                'so a user with sync off is never asked about health access',
          );
        });
      });
    }
  });

  group('permission', () {
    test(
      'sync on but permission not granted reports permissionNeeded',
      () async {
        adapter.stepsPermissionGranted = false;
        await onPlatform(TargetPlatform.android, () async {
          final container = makeContainer(syncEnabled: true);
          expect(
            await settledAvailability(container),
            StepsAvailability.permissionNeeded,
          );
        });
      },
    );

    test('sync on and permission granted reports available', () async {
      await onPlatform(TargetPlatform.android, () async {
        final container = makeContainer(syncEnabled: true);
        expect(
          await settledAvailability(container),
          StepsAvailability.available,
        );
      });
    });

    test('iOS reaches available the same way', () async {
      await onPlatform(TargetPlatform.iOS, () async {
        final container = makeContainer(syncEnabled: true);
        expect(
          await settledAvailability(container),
          StepsAvailability.available,
        );
      });
    });

    test(
      'an energy-only grant reports permissionNeeded, not available',
      () async {
        // `hasPermissions` is an OR across steps and the two energy types, so
        // this configuration passes it. Reading availability off that OR would
        // promise a step chart the grant cannot fill, and the empty result
        // would look like her data was missing rather than the permission.
        adapter = FakeHealthPlatformAdapter.energyOnly();
        await onPlatform(TargetPlatform.android, () async {
          final container = makeContainer(syncEnabled: true);
          expect(await adapter.hasPermissions(), isTrue);
          expect(
            await settledAvailability(container),
            StepsAvailability.permissionNeeded,
          );
          expect(
            adapter.stepsPermissionCallCount,
            greaterThan(0),
            reason: 'availability asks the steps-specific question',
          );
        });
      },
    );

    test('a permission check that throws is never read as available', () async {
      adapter.throwOnPermissions = true;
      await onPlatform(TargetPlatform.android, () async {
        final container = makeContainer(syncEnabled: true);
        expect(
          await settledAvailability(container),
          StepsAvailability.permissionNeeded,
          reason:
              'if the app cannot establish that it was granted access to her '
              'health data, it must not behave as though it was',
        );
      });
    });

    test('reads permissionNeeded while the platform is still answering', () {
      // The pre-resolution value is deliberately the cautious one: a moment
      // of "we need permission" that resolves itself is harmless, whereas
      // defaulting to available would have the UI ask for step data the app
      // may have no right to.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final container = makeContainer(syncEnabled: true);
        expect(
          container.read(stepsAvailabilityProvider),
          StepsAvailability.permissionNeeded,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('stepsTargetProvider', () {
    test('answers the single default target', () {
      final container = makeContainer(syncEnabled: true);
      expect(container.read(stepsTargetProvider), defaultDailyStepTarget);
      expect(defaultDailyStepTarget, 7500);
    });
  });
}
