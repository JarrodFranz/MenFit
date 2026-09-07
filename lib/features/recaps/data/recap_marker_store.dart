import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the identity (`RecapPeriod.key`, `domain/recap_period.dart`)
/// of the last month-end recap shown, so
/// `domain/recap_trigger_evaluator.dart#evaluateRecapDue` knows what's
/// already been seen.
///
/// A device-local string — not diary/health data itself (only an opaque
/// period identity), so `shared_preferences` rather than the database that
/// "Delete my data" wipes, the same reasoning as
/// `features/nutrition/data/online_lookup_notice_store.dart`.
class RecapMarkerStore {
  const RecapMarkerStore(this._preferences);

  final SharedPreferences _preferences;

  static const String _lastShownMonthKeyKey = 'recaps_last_shown_month_key';

  /// The `RecapPeriod.key` of the last month-end recap shown, or `null` if
  /// none ever has been.
  String? getLastShownMonthKey() =>
      _preferences.getString(_lastShownMonthKeyKey);

  /// Records [key] as the last month-end recap shown.
  Future<void> markMonthShown(String key) =>
      _writeString(_lastShownMonthKeyKey, key);

  /// Forgets the marker, so the next recap is offered as if none had ever
  /// been shown.
  ///
  /// Called by "Delete my data": this is not just UI state, but is kept
  /// device-local rather than in the S3-backed store that "Delete my data"
  /// wipes, so it is cleared here explicitly too.
  Future<void> clear() async {
    final ok = await _preferences.remove(_lastShownMonthKeyKey);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to clear the recap-shown marker',
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
