import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the identity (`RecapPeriod.key`, `domain/recap_period.dart`)
/// of the last cycle-end and month-end recap shown, so
/// `domain/recap_trigger_evaluator.dart#evaluateRecapDue` knows what's
/// already been seen.
///
/// A pair of device-local strings — not diary/health data itself (only an
/// opaque period identity), so `shared_preferences` rather than the
/// database that "Delete my data" wipes, the same reasoning as
/// `features/nutrition/data/online_lookup_notice_store.dart`.
class RecapMarkerStore {
  const RecapMarkerStore(this._preferences);

  final SharedPreferences _preferences;

  static const String _lastShownCycleKeyKey = 'recaps_last_shown_cycle_key';
  static const String _lastShownMonthKeyKey = 'recaps_last_shown_month_key';

  /// The `RecapPeriod.key` of the last cycle-end recap shown, or `null` if
  /// none ever has been.
  String? getLastShownCycleKey() =>
      _preferences.getString(_lastShownCycleKeyKey);

  /// The `RecapPeriod.key` of the last month-end recap shown, or `null` if
  /// none ever has been.
  String? getLastShownMonthKey() =>
      _preferences.getString(_lastShownMonthKeyKey);

  /// Records [key] as the last cycle-end recap shown.
  Future<void> markCycleShown(String key) =>
      _writeString(_lastShownCycleKeyKey, key);

  /// Records [key] as the last month-end recap shown.
  Future<void> markMonthShown(String key) =>
      _writeString(_lastShownMonthKeyKey, key);

  /// Forgets both markers, so the next recap is offered as if none had ever
  /// been shown.
  ///
  /// Called by "Delete my data": these are not just UI state. A stored
  /// `RecapPeriod.key` is `cycle:<uuidv7>` — a cycle record's id, and a
  /// UUIDv7 carries the moment it was created in its first six bytes. Left
  /// behind, that is a readable timestamp of when a period was logged,
  /// surviving a wipe of the S3 table it came from
  /// (`knowledge/engineering/security_and_privacy.md`).
  Future<void> clear() async {
    final ok =
        await _preferences.remove(_lastShownCycleKeyKey) &&
        await _preferences.remove(_lastShownMonthKeyKey);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to clear the recap-shown markers',
      );
    }
  }

  Future<void> _writeString(String prefsKey, String value) async {
    // SharedPreferences reports platform-level failure by returning `false`
    // rather than throwing, and a raw `false` must not be read as silent
    // success (error_handling.md) - same discipline as
    // `online_lookup_notice_store.dart`.
    final ok = await _preferences.setString(prefsKey, value);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist the recap-shown marker',
      );
    }
  }
}
