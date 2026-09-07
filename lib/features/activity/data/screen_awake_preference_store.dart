import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/screen_awake_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the per-[ActivityType] "keep screen awake" choice on the device.
///
/// `shared_preferences` rather than the database, and for the same reason
/// as `nutrition/data/food_search_region_store.dart`: it is a device
/// preference, not user data, so "Delete my data" must not wipe it and an
/// export must not carry it (see `domain/screen_awake_preference.dart` for
/// the full rationale).
///
/// One key per type — `screen_awake_<type>` off
/// [ActivityType.toStorage] — rather than one encoded blob, so a type added
/// to the enum later needs no migration and simply reads as the default.
///
/// The `SharedPreferences` may be null, exactly as
/// `accessibility/data/accessibility_repository.dart` allows: every tracker
/// in the app now reaches this store on start, and a widget test that
/// pumps a tracker without overriding `sharedPreferencesProvider` would
/// otherwise die on that provider's deliberate `UnimplementedError`
/// instead of testing what it came to test. With no store, every type
/// reads as the default and a write is a no-op — a state that is
/// unreachable in the app itself, where `bootstrap.dart` always supplies
/// one.
class ScreenAwakePreferenceStore {
  const ScreenAwakePreferenceStore(this._preferences);

  final SharedPreferences? _preferences;

  static String _keyFor(ActivityType type) =>
      'screen_awake_${type.toStorage()}';

  /// Whether [type]'s tracker should hold the screen on.
  ///
  /// Missing reads as [screenAwakeDefaultEnabled] (true): nothing stored
  /// means she has never chosen, and the app's default is on.
  bool isEnabled(ActivityType type) =>
      _preferences?.getBool(_keyFor(type)) ?? screenAwakeDefaultEnabled;

  /// Persists [enabled] for [type].
  /// A no-op when there is no store — see the class doc.
  Future<void> setEnabled(
    ActivityType type, {
    required bool enabled,
  }) async {
    final preferences = _preferences;
    if (preferences == null) return;

    // SharedPreferences signals platform-level failure with a `false`
    // return rather than an exception, and a raw `false` must not be read
    // as silent success (`knowledge/engineering/error_handling.md`).
    final ok = await preferences.setBool(_keyFor(type), enabled);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to save the keep-screen-awake setting',
      );
    }
  }
}
