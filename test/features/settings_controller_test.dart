import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeModeController', () {
    test('defaults to system when nothing has been persisted', () async {
      // NOTE: setMockInitialValues must be called exactly once per test -
      // calling it a second time silently resets the in-memory store.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final mode = await container.read(themeModeControllerProvider.future);

      expect(mode, ThemeMode.system);
    });

    test('loads a persisted value on build', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final mode = await container.read(themeModeControllerProvider.future);

      expect(mode, ThemeMode.dark);
    });

    test(
      'setThemeMode updates state and persists across a second container '
      'sharing the same prefs backing store',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final firstContainer = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(firstContainer.dispose);

        // Ensure the controller has finished its initial build.
        await firstContainer.read(themeModeControllerProvider.future);

        await firstContainer
            .read(themeModeControllerProvider.notifier)
            .setThemeMode(ThemeMode.light);

        expect(
          firstContainer.read(themeModeControllerProvider).value,
          ThemeMode.light,
        );

        // A brand new container, backed by the same SharedPreferences
        // instance, should observe the persisted value rather than the
        // 'system' default.
        final secondContainer = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(secondContainer.dispose);

        final persistedMode = await secondContainer.read(
          themeModeControllerProvider.future,
        );

        expect(persistedMode, ThemeMode.light);
      },
    );
  });
}
