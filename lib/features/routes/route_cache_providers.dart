import 'dart:async';

import 'package:dio/dio.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/widgets/map_tile_settings.dart';
import 'package:menfit_app/features/routes/data/route_tile_cache_service.dart';
import 'package:menfit_app/features/routes/data/tile_storage.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'route_cache_providers.g.dart';

/// Injects the singleton [TileStorage] instance.
@Riverpod(keepAlive: true)
TileStorage tileStorage(Ref ref) {
  final storage = TileStorage();
  unawaited(storage.init());
  return storage;
}

/// Injects the [RouteTileCacheService].
@Riverpod(keepAlive: true)
RouteTileCacheService routeTileCacheService(Ref ref) {
  final storage = ref.watch(tileStorageProvider);
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } on Object catch (_) {}

  return RouteTileCacheService(
    storage: storage,
    dio: Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
    prefs: prefs,
  );
}

/// Watches cached metadata for a specific route.
@Riverpod(keepAlive: true)
class RouteCacheMetadataNotifier extends _$RouteCacheMetadataNotifier {
  @override
  RouteCacheMetadata? build(String routeId) {
    final service = ref.watch(routeTileCacheServiceProvider);
    return service.getMetadata(routeId);
  }

  /// Refreshes the cached metadata from disk.
  void refresh() {
    final service = ref.read(routeTileCacheServiceProvider);
    state = service.getMetadata(routeId);
  }
}

/// Controls active tile downloads for a route.
@Riverpod(keepAlive: true)
class RouteTileDownloadController extends _$RouteTileDownloadController {
  CancelToken? _cancelToken;

  @override
  Map<String, RouteTileDownloadProgress> build() => {};

  /// Initiates tile caching along [points] for [routeId].
  Future<void> startDownload({
    required String routeId,
    required List<GeoPoint> points,
  }) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final service = ref.read(routeTileCacheServiceProvider);
    final urlTemplate = ref.read(mapTileUrlProvider);

    await for (final progress in service.downloadRouteTiles(
      routeId: routeId,
      points: points,
      urlTemplate: urlTemplate,
      cancelToken: _cancelToken,
    )) {
      state = {...state, routeId: progress};
      if (progress.status == RouteTileDownloadStatus.completed) {
        ref.invalidate(routeCacheMetadataProvider(routeId));
      }
    }
  }

  /// Cancels an ongoing download.
  void cancelDownload(String routeId) {
    _cancelToken?.cancel();
    _cancelToken = null;
    final current = state[routeId];
    if (current != null) {
      state = {
        ...state,
        routeId: RouteTileDownloadProgress(
          routeId: routeId,
          totalTiles: current.totalTiles,
          downloadedTiles: current.downloadedTiles,
          status: RouteTileDownloadStatus.cancelled,
        ),
      };
    }
  }

  /// Deletes the offline tile cache for [routeId].
  Future<void> deleteCache({
    required String routeId,
    required List<GeoPoint> points,
  }) async {
    final service = ref.read(routeTileCacheServiceProvider);
    await service.deleteRouteCache(routeId, points);
    state = {...state}..remove(routeId);
    ref.invalidate(routeCacheMetadataProvider(routeId));
  }
}
