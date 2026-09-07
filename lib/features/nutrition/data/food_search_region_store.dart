import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the food-database region the user chose in Settings.
///
/// One device-local string, stored the same way and for the same reason as
/// `online_lookup_notice_store.dart`: it is a device preference, not diary
/// data, so it belongs in `shared_preferences` rather than in the database
/// that "Delete my data" wipes.
///
/// **Absent means "not chosen", not "Anywhere".** Reads return `null` when
/// nothing has been saved so the caller can fall back to the device locale
/// (`nutrition_providers.dart`); writing a default at first read would freeze
/// whatever country the phone happened to report on install and stop the
/// default ever following the device again.
class FoodSearchRegionStore {
  const FoodSearchRegionStore(this._preferences);

  final SharedPreferences _preferences;

  static const String _regionKey = 'nutrition_food_search_region';

  /// The user's chosen region, or `null` when they have never chosen one.
  FoodSearchRegion? readRegion() {
    return FoodSearchRegion.fromStorageValue(
      _preferences.getString(_regionKey),
    );
  }

  /// Persists [region] as an explicit choice.
  Future<void> setRegion(FoodSearchRegion region) async {
    // SharedPreferences signals platform-level failure with a `false` return
    // rather than an exception, and a raw `false` must not be read as silent
    // success (`knowledge/engineering/error_handling.md`).
    final ok = await _preferences.setString(_regionKey, region.storageValue);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist the food database region',
      );
    }
  }
}
