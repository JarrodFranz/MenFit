import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/widgets/map_tile_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'map_tile_settings.g.dart';

const String mapTileSourcePrefKey = 'map_tile_source';

/// Manages the user's selected [MapTileSource].
@Riverpod(keepAlive: true)
class MapTileSettingsController extends _$MapTileSettingsController {
  SharedPreferences? _prefs;

  @override
  MapTileSource build() {
    try {
      _prefs = ref.watch(sharedPreferencesProvider);
      final raw = _prefs?.getString(mapTileSourcePrefKey);
      if (raw != null) {
        return MapTileSource.values.firstWhere(
          (s) => s.name == raw,
          orElse: () => MapTileSource.openStreetMap,
        );
      }
    } on Object catch (_) {
      // Degrades cleanly when SharedPreferences is absent in unit tests.
    }
    return MapTileSource.openStreetMap;
  }

  /// Sets the active map tile source.
  Future<void> setTileSource(MapTileSource source) async {
    state = source;
    try {
      await _prefs?.setString(mapTileSourcePrefKey, source.name);
    } on Object catch (_) {}
  }
}

/// Provides the active map tile URL template.
@Riverpod(keepAlive: true)
String mapTileUrl(Ref ref) {
  final source = ref.watch(mapTileSettingsControllerProvider);
  return source.urlTemplate;
}

/// Provides the active map attribution copy.
@Riverpod(keepAlive: true)
String mapTileAttribution(Ref ref) {
  final source = ref.watch(mapTileSettingsControllerProvider);
  return source.attribution;
}
