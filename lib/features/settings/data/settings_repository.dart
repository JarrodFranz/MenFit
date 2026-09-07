import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight user settings using [SharedPreferences].
///
/// Only knows how to read/write raw values - no business logic and no
/// widget/provider concerns live here, keeping it trivially unit-testable.
class SettingsRepository {
  const SettingsRepository(this._preferences);

  final SharedPreferences? _preferences;

  static const String _themeModeKey = 'theme_mode';
  static const String _showActivityEnergyKey = 'show_activity_energy_estimates';
  static const String _fitnessDeviceSyncKey = 'fitness_device_sync_enabled';

  /// Returns the persisted theme mode string (`system` | `light` | `dark`),
  /// defaulting to `system` when nothing has been saved yet.
  String getThemeMode() {
    return _preferences?.getString(_themeModeKey) ?? 'system';
  }

  /// Persists [value], which must be one of `system`, `light`, or `dark`.
  Future<void> setThemeMode(String value) async {
    final prefs = _preferences;
    if (prefs == null) return;
    final ok = await prefs.setString(_themeModeKey, value);
    if (!ok) {
      throw const StorageException(message: 'Failed to persist theme mode');
    }
  }

  /// Whether activity energy expenditure estimates are shown (opt-in,
  /// off by default).
  bool getShowActivityEnergyEstimates() {
    return _preferences?.getBool(_showActivityEnergyKey) ?? false;
  }

  /// Sets whether activity energy expenditure estimates are shown.
  Future<void> setShowActivityEnergyEstimates({required bool enabled}) async {
    final prefs = _preferences;
    if (prefs == null) return;
    final ok = await prefs.setBool(_showActivityEnergyKey, enabled);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist energy estimate setting',
      );
    }
  }

  /// Whether fitness device health platform sync is enabled.
  bool getFitnessDeviceSyncEnabled() {
    return _preferences?.getBool(_fitnessDeviceSyncKey) ?? false;
  }

  /// Sets whether fitness device sync is enabled.
  Future<void> setFitnessDeviceSyncEnabled({required bool enabled}) async {
    final prefs = _preferences;
    if (prefs == null) return;
    final ok = await prefs.setBool(_fitnessDeviceSyncKey, enabled);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist fitness device sync setting',
      );
    }
  }

  /// Clears all settings persisted by this repository.
  Future<void> clearAll() async {
    final prefs = _preferences;
    if (prefs == null) return;
    await prefs.remove(_themeModeKey);
    await prefs.remove(_showActivityEnergyKey);
    await prefs.remove(_fitnessDeviceSyncKey);
  }
}
