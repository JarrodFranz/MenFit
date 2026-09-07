/// Presets for map tile layers across the application.
enum MapTileSource {
  openStreetMap,
  googleStandard,
  googleTerrain,
  openTopoMap,
  cartoVoyager;

  /// Human-readable label for settings and selectors.
  String get label => switch (this) {
    MapTileSource.openStreetMap => 'OpenStreetMap',
    MapTileSource.googleStandard => 'Google Standard',
    MapTileSource.googleTerrain => 'Google Terrain',
    MapTileSource.openTopoMap => 'OpenTopoMap (Trails)',
    MapTileSource.cartoVoyager => 'CartoDB Voyager',
  };

  /// XYZ tile template URL for flutter_map `TileLayer`.
  String get urlTemplate => switch (this) {
    MapTileSource.openStreetMap =>
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    MapTileSource.googleStandard =>
      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
    MapTileSource.googleTerrain =>
      'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
    MapTileSource.openTopoMap => 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    MapTileSource.cartoVoyager =>
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  };

  /// Maximum supported zoom level for this source.
  int get maxZoom => switch (this) {
    MapTileSource.openTopoMap => 17,
    _ => 18,
  };

  /// Minimum supported zoom level for this source.
  int get minZoom => 1;

  /// Attribution copy required by the tile provider's license.
  String get attribution => switch (this) {
    MapTileSource.openStreetMap => '© OpenStreetMap contributors',
    MapTileSource.googleStandard ||
    MapTileSource.googleTerrain => '© Google Maps',
    MapTileSource.openTopoMap =>
      '© OpenTopoMap (CC-BY-SA), © OpenStreetMap contributors',
    MapTileSource.cartoVoyager => '© CARTO, © OpenStreetMap contributors',
  };
}
