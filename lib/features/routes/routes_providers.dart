import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/device_locale.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/data/last_location_store.dart';
import 'package:menfit_app/features/routes/data/location_search_service.dart';
import 'package:menfit_app/features/routes/data/ors_route_service.dart';
import 'package:menfit_app/features/routes/domain/country_map_center.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_repository.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_providers.g.dart';

/// Composition surface for the `routes` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence/services: other features may import
/// this file, never `data/` or `presentation/` directly.
@Riverpod(keepAlive: true)
RouteRepository routeRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftRouteRepository(database);
}

/// The location/place search and geocoding service.
@Riverpod(keepAlive: true)
LocationSearchService locationSearchService(Ref ref) {
  return LocationSearchService(
    dio: Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    ),
    apiKey: AppEnv.instance.orsApiKey,
  );
}

/// The routing provider used for round-trip suggestions
/// (OpenRouteService).
@Riverpod(keepAlive: true)
RouteSuggestionService routeSuggestionService(Ref ref) {
  return OrsRouteService(
    dio: Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    ),
    apiKey: AppEnv.instance.orsApiKey,
  );
}

/// Whether this build carries an OpenRouteService API key
/// (`AppEnv.orsApiKey` — a compile-time constant, hence `keepAlive`).
///
/// The suggest screen gates on this to show a friendly setup card instead
/// of a doomed network call; a provider (rather than reading `AppEnv`
/// inline in the widget) so tests can exercise both branches — `AppEnv`
/// values can't be overridden at runtime.
@Riverpod(keepAlive: true)
bool routeSuggestionsConfigured(Ref ref) =>
    AppEnv.instance.orsApiKey.isNotEmpty;

/// The saved route with the given [id], or `null` when it doesn't exist
/// (or was deleted). Exposed on the composition surface because other
/// features render route chips ("Following: …" on the record screen,
/// "Route: …" on the activity detail — ADR 007 lets them reach it only
/// here).
@riverpod
Stream<SavedRoute?> routeById(Ref ref, String id) {
  return ref.watch(routeRepositoryProvider).watchRoute(id);
}

/// Store for persisting the last recorded location on device.
@Riverpod(keepAlive: true)
LastLocationStore lastLocationStore(Ref ref) {
  try {
    return LastLocationStore(ref.watch(sharedPreferencesProvider));
  } on ProviderException catch (error) {
    if (error.exception is! UnimplementedError) rethrow;
    return const LastLocationStore(null);
  }
}

/// The user's last recorded location (from GPS recording or "Use my location").
///
/// Updating this persists the new location to [LastLocationStore].
@Riverpod(keepAlive: true)
class RouteLastRecordedLocation extends _$RouteLastRecordedLocation {
  @override
  GeoPoint? build() {
    return ref.watch(lastLocationStoreProvider).getLastLocation();
  }

  Future<void> record(GeoPoint point) async {
    state = point;
    try {
      await ref.read(lastLocationStoreProvider).saveLastLocation(point);
    } on Object catch (_) {
      // Best-effort cache; saving errors should never interrupt user flows.
    }
  }
}

/// Initial camera center and zoom for route map views before a start point
/// is chosen.
///
/// If a location was previously recorded, returns that coordinate at local
/// neighbourhood zoom (14). Otherwise, defaults to the user's country center
/// based on device locale (defaulting to Australia if unrecognised).
@Riverpod(keepAlive: true)
MapCameraTarget routeInitialMapTarget(Ref ref) {
  final lastLocation = ref.watch(routeLastRecordedLocationProvider);
  if (lastLocation != null) {
    return MapCameraTarget(
      latitude: lastLocation.latitude,
      longitude: lastLocation.longitude,
      zoom: 14,
    );
  }
  final locale = ref.watch(deviceLocaleProvider);
  return countryMapCenterFor(locale.countryCode);
}
