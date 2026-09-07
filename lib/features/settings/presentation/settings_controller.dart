import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// The repository used to persist user-facing settings.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SettingsRepository(prefs);
  } on Object catch (_) {
    return const SettingsRepository(null);
  }
}

/// Controller for the app's theme mode.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final modeStr = repository.getThemeMode();
    return ThemeMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = AsyncData(mode);
    try {
      await repository.setThemeMode(mode.name);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> clearAll() async {
    final repository = ref.read(settingsRepositoryProvider);
    state = const AsyncData(ThemeMode.system);
    try {
      await repository.clearAll();
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Controller for whether workout energy expenditure estimates are shown.
@Riverpod(keepAlive: true)
class ActivityEnergyEstimatesController
    extends _$ActivityEnergyEstimatesController {
  @override
  bool build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getShowActivityEnergyEstimates();
  }

  Future<void> toggle({required bool enabled}) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = enabled;
    await repository.setShowActivityEnergyEstimates(enabled: enabled);
  }
}

/// Controller for whether fitness device synchronization is enabled.
@Riverpod(keepAlive: true)
class FitnessDeviceSyncController extends _$FitnessDeviceSyncController {
  @override
  bool build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getFitnessDeviceSyncEnabled();
  }

  Future<void> toggle({required bool enabled}) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = enabled;
    await repository.setFitnessDeviceSyncEnabled(enabled: enabled);
  }
}
