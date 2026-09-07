import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the user's last recorded/known geographic location on device.
///
/// Kept in [SharedPreferences] rather than the database: this is a device-level
/// cache for initializing map viewports, not user training data. "Delete my
/// data" does not wipe it and an export does not carry it.
///
/// The [SharedPreferences] may be null, matching `ScreenAwakePreferenceStore`:
/// tests that pump screens without overriding `sharedPreferencesProvider`
/// degrade gracefully to returning null and no-op writes rather than failing on
/// `UnimplementedError`.
class LastLocationStore {
  const LastLocationStore(this._preferences);

  final SharedPreferences? _preferences;

  static const String _latKey = 'routes_last_location_lat';
  static const String _lngKey = 'routes_last_location_lng';

  /// The last recorded location, or `null` if none has been saved yet.
  GeoPoint? getLastLocation() {
    final preferences = _preferences;
    if (preferences == null) return null;

    final lat = preferences.getDouble(_latKey);
    final lng = preferences.getDouble(_lngKey);
    if (lat == null || lng == null) return null;
    if (!lat.isFinite || !lng.isFinite) return null;

    return GeoPoint(latitude: lat, longitude: lng);
  }

  /// Persists [point] as the last recorded location.
  Future<void> saveLastLocation(GeoPoint point) async {
    final preferences = _preferences;
    if (preferences == null) return;

    final okLat = await preferences.setDouble(_latKey, point.latitude);
    final okLng = await preferences.setDouble(_lngKey, point.longitude);
    if (!okLat || !okLng) {
      throw const StorageException(
        message: 'Failed to save the last recorded location',
      );
    }
  }

  /// Clears the recorded location.
  Future<void> clear() async {
    final preferences = _preferences;
    if (preferences == null) return;

    await preferences.remove(_latKey);
    await preferences.remove(_lngKey);
  }
}
