import 'package:flutter_map/flutter_map.dart';
import 'package:menfit_app/core/widgets/cached_tile_provider.dart';
import 'package:menfit_app/features/routes/route_cache_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_tile_provider.g.dart';

/// The [TileProvider] every flutter_map tile layer in the app fetches
/// through.
///
/// A `@Riverpod(keepAlive: true)` provider (rather than a constructor
/// parameter threaded through each map widget) is the seam widget tests
/// substitute a no-network fake through, overridden in a `ProviderScope`
/// — the same pattern as `locationAdapterProvider`
/// (`core/platform/location/location_providers.dart`). Defaults to
/// [CachedTileProvider], which checks the on-device offline tile store
/// before falling back to network requests: tests MUST override this
/// provider (see `test/features/activity/route_map_test.dart` for the
/// no-network fake).
///
/// Lives in `core/widgets/` (not a feature's presentation layer) because
/// multiple features' maps share it — `activity`'s `RouteMap` and the
/// `routes` feature's suggest/detail maps — and ADR 007 forbids one
/// feature importing another's presentation code.
@Riverpod(keepAlive: true)
TileProvider mapTileProvider(Ref ref) {
  final storage = ref.watch(tileStorageProvider);
  return CachedTileProvider(storage: storage);
}
