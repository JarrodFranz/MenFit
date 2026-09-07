// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `routes` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence/services: other features may import
/// this file, never `data/` or `presentation/` directly.

@ProviderFor(routeRepository)
final routeRepositoryProvider = RouteRepositoryProvider._();

/// Composition surface for the `routes` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence/services: other features may import
/// this file, never `data/` or `presentation/` directly.

final class RouteRepositoryProvider
    extends
        $FunctionalProvider<RouteRepository, RouteRepository, RouteRepository>
    with $Provider<RouteRepository> {
  /// Composition surface for the `routes` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root) to
  /// reach this feature's persistence/services: other features may import
  /// this file, never `data/` or `presentation/` directly.
  RouteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeRepositoryHash();

  @$internal
  @override
  $ProviderElement<RouteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RouteRepository create(Ref ref) {
    return routeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteRepository>(value),
    );
  }
}

String _$routeRepositoryHash() => r'df737a39b23beabfdb4a69b2c4f13df1d2a3eec3';

/// The location/place search and geocoding service.

@ProviderFor(locationSearchService)
final locationSearchServiceProvider = LocationSearchServiceProvider._();

/// The location/place search and geocoding service.

final class LocationSearchServiceProvider
    extends
        $FunctionalProvider<
          LocationSearchService,
          LocationSearchService,
          LocationSearchService
        >
    with $Provider<LocationSearchService> {
  /// The location/place search and geocoding service.
  LocationSearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationSearchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationSearchServiceHash();

  @$internal
  @override
  $ProviderElement<LocationSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationSearchService create(Ref ref) {
    return locationSearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationSearchService>(value),
    );
  }
}

String _$locationSearchServiceHash() =>
    r'81cb59a9538bfceef6459c3c184fa8f383157984';

/// The routing provider used for round-trip suggestions
/// (OpenRouteService).

@ProviderFor(routeSuggestionService)
final routeSuggestionServiceProvider = RouteSuggestionServiceProvider._();

/// The routing provider used for round-trip suggestions
/// (OpenRouteService).

final class RouteSuggestionServiceProvider
    extends
        $FunctionalProvider<
          RouteSuggestionService,
          RouteSuggestionService,
          RouteSuggestionService
        >
    with $Provider<RouteSuggestionService> {
  /// The routing provider used for round-trip suggestions
  /// (OpenRouteService).
  RouteSuggestionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeSuggestionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeSuggestionServiceHash();

  @$internal
  @override
  $ProviderElement<RouteSuggestionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RouteSuggestionService create(Ref ref) {
    return routeSuggestionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteSuggestionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteSuggestionService>(value),
    );
  }
}

String _$routeSuggestionServiceHash() =>
    r'1eb46fc8f29f1ae3f126972c9384e3dd1f151f74';

/// Whether this build carries an OpenRouteService API key
/// (`AppEnv.orsApiKey` — a compile-time constant, hence `keepAlive`).
///
/// The suggest screen gates on this to show a friendly setup card instead
/// of a doomed network call; a provider (rather than reading `AppEnv`
/// inline in the widget) so tests can exercise both branches — `AppEnv`
/// values can't be overridden at runtime.

@ProviderFor(routeSuggestionsConfigured)
final routeSuggestionsConfiguredProvider =
    RouteSuggestionsConfiguredProvider._();

/// Whether this build carries an OpenRouteService API key
/// (`AppEnv.orsApiKey` — a compile-time constant, hence `keepAlive`).
///
/// The suggest screen gates on this to show a friendly setup card instead
/// of a doomed network call; a provider (rather than reading `AppEnv`
/// inline in the widget) so tests can exercise both branches — `AppEnv`
/// values can't be overridden at runtime.

final class RouteSuggestionsConfiguredProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this build carries an OpenRouteService API key
  /// (`AppEnv.orsApiKey` — a compile-time constant, hence `keepAlive`).
  ///
  /// The suggest screen gates on this to show a friendly setup card instead
  /// of a doomed network call; a provider (rather than reading `AppEnv`
  /// inline in the widget) so tests can exercise both branches — `AppEnv`
  /// values can't be overridden at runtime.
  RouteSuggestionsConfiguredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeSuggestionsConfiguredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeSuggestionsConfiguredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return routeSuggestionsConfigured(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$routeSuggestionsConfiguredHash() =>
    r'1ce73ae7261d71b6af25377aaf68a98075cb5a27';

/// The saved route with the given [id], or `null` when it doesn't exist
/// (or was deleted). Exposed on the composition surface because other
/// features render route chips ("Following: …" on the record screen,
/// "Route: …" on the activity detail — ADR 007 lets them reach it only
/// here).

@ProviderFor(routeById)
final routeByIdProvider = RouteByIdFamily._();

/// The saved route with the given [id], or `null` when it doesn't exist
/// (or was deleted). Exposed on the composition surface because other
/// features render route chips ("Following: …" on the record screen,
/// "Route: …" on the activity detail — ADR 007 lets them reach it only
/// here).

final class RouteByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedRoute?>,
          SavedRoute?,
          Stream<SavedRoute?>
        >
    with $FutureModifier<SavedRoute?>, $StreamProvider<SavedRoute?> {
  /// The saved route with the given [id], or `null` when it doesn't exist
  /// (or was deleted). Exposed on the composition surface because other
  /// features render route chips ("Following: …" on the record screen,
  /// "Route: …" on the activity detail — ADR 007 lets them reach it only
  /// here).
  RouteByIdProvider._({
    required RouteByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routeByIdHash();

  @override
  String toString() {
    return r'routeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SavedRoute?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SavedRoute?> create(Ref ref) {
    final argument = this.argument as String;
    return routeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RouteByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routeByIdHash() => r'70638be69fe737c1f7fb8402f4b4e950e74b7bde';

/// The saved route with the given [id], or `null` when it doesn't exist
/// (or was deleted). Exposed on the composition surface because other
/// features render route chips ("Following: …" on the record screen,
/// "Route: …" on the activity detail — ADR 007 lets them reach it only
/// here).

final class RouteByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SavedRoute?>, String> {
  RouteByIdFamily._()
    : super(
        retry: null,
        name: r'routeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The saved route with the given [id], or `null` when it doesn't exist
  /// (or was deleted). Exposed on the composition surface because other
  /// features render route chips ("Following: …" on the record screen,
  /// "Route: …" on the activity detail — ADR 007 lets them reach it only
  /// here).

  RouteByIdProvider call(String id) =>
      RouteByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'routeByIdProvider';
}

/// Store for persisting the last recorded location on device.

@ProviderFor(lastLocationStore)
final lastLocationStoreProvider = LastLocationStoreProvider._();

/// Store for persisting the last recorded location on device.

final class LastLocationStoreProvider
    extends
        $FunctionalProvider<
          LastLocationStore,
          LastLocationStore,
          LastLocationStore
        >
    with $Provider<LastLocationStore> {
  /// Store for persisting the last recorded location on device.
  LastLocationStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastLocationStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastLocationStoreHash();

  @$internal
  @override
  $ProviderElement<LastLocationStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LastLocationStore create(Ref ref) {
    return lastLocationStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LastLocationStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LastLocationStore>(value),
    );
  }
}

String _$lastLocationStoreHash() => r'89df01a22ff818a9ae56429a6bcba7aeb4689931';

/// The user's last recorded location (from GPS recording or "Use my location").
///
/// Updating this persists the new location to [LastLocationStore].

@ProviderFor(RouteLastRecordedLocation)
final routeLastRecordedLocationProvider = RouteLastRecordedLocationProvider._();

/// The user's last recorded location (from GPS recording or "Use my location").
///
/// Updating this persists the new location to [LastLocationStore].
final class RouteLastRecordedLocationProvider
    extends $NotifierProvider<RouteLastRecordedLocation, GeoPoint?> {
  /// The user's last recorded location (from GPS recording or "Use my location").
  ///
  /// Updating this persists the new location to [LastLocationStore].
  RouteLastRecordedLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeLastRecordedLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeLastRecordedLocationHash();

  @$internal
  @override
  RouteLastRecordedLocation create() => RouteLastRecordedLocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeoPoint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeoPoint?>(value),
    );
  }
}

String _$routeLastRecordedLocationHash() =>
    r'657a00cdeea859eba6f0dd12f373ef1271ac6549';

/// The user's last recorded location (from GPS recording or "Use my location").
///
/// Updating this persists the new location to [LastLocationStore].

abstract class _$RouteLastRecordedLocation extends $Notifier<GeoPoint?> {
  GeoPoint? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GeoPoint?, GeoPoint?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GeoPoint?, GeoPoint?>,
              GeoPoint?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Initial camera center and zoom for route map views before a start point
/// is chosen.
///
/// If a location was previously recorded, returns that coordinate at local
/// neighbourhood zoom (14). Otherwise, defaults to the user's country center
/// based on device locale (defaulting to Australia if unrecognised).

@ProviderFor(routeInitialMapTarget)
final routeInitialMapTargetProvider = RouteInitialMapTargetProvider._();

/// Initial camera center and zoom for route map views before a start point
/// is chosen.
///
/// If a location was previously recorded, returns that coordinate at local
/// neighbourhood zoom (14). Otherwise, defaults to the user's country center
/// based on device locale (defaulting to Australia if unrecognised).

final class RouteInitialMapTargetProvider
    extends
        $FunctionalProvider<MapCameraTarget, MapCameraTarget, MapCameraTarget>
    with $Provider<MapCameraTarget> {
  /// Initial camera center and zoom for route map views before a start point
  /// is chosen.
  ///
  /// If a location was previously recorded, returns that coordinate at local
  /// neighbourhood zoom (14). Otherwise, defaults to the user's country center
  /// based on device locale (defaulting to Australia if unrecognised).
  RouteInitialMapTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeInitialMapTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeInitialMapTargetHash();

  @$internal
  @override
  $ProviderElement<MapCameraTarget> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapCameraTarget create(Ref ref) {
    return routeInitialMapTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapCameraTarget value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapCameraTarget>(value),
    );
  }
}

String _$routeInitialMapTargetHash() =>
    r'031f478d94c413f53a7664f2b21b90f4fef756a6';
