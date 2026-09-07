import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/location_search_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_suggest_controller.freezed.dart';
part 'route_suggest_controller.g.dart';

/// Which stage of the suggest flow the screen is showing.
enum SuggestPhase {
  /// Gathering inputs; no request in flight and no results yet.
  input,

  /// A suggestion request is in flight.
  loading,

  /// Suggestions arrived; cards + selected polyline are showing.
  loaded,

  /// The suggestion request failed — [RouteSuggestState.error] carries the
  /// user-facing message; retry re-runs the same inputs.
  error,
}

/// State of the route-suggest flow, watched by `route_suggest_screen.dart`.
@freezed
abstract class RouteSuggestState with _$RouteSuggestState {
  const factory RouteSuggestState({
    @Default(SuggestPhase.input) SuggestPhase phase,
    @Default('') String distanceInput,
    @Default(ActivityType.run) ActivityType activityType,
    @Default(RouteShapePreference.loop) RouteShapePreference shapePreference,

    /// The chosen start point (map tap, place search, or "Use my location").
    GeoPoint? start,

    /// Optional readable address or landmark for the start point.
    String? startAddress,

    /// Current location search query.
    @Default('') String searchQuery,

    /// Search results from place/address search.
    @Default(<LocationSearchResult>[]) List<LocationSearchResult> searchResults,

    /// True while searching places.
    @Default(false) bool isSearching,

    /// Error from place search.
    String? searchError,

    @Default(<SuggestedRoute>[]) List<SuggestedRoute> suggestions,
    @Default(0) int selectedIndex,

    /// Inline validation message for the distance field.
    String? distanceError,

    /// Inline hint when "Find routes" was pressed without a start point.
    String? startError,

    /// User-facing message for a failed suggestion request
    /// ([SuggestPhase.error]).
    String? error,

    /// True while "Use my location" is resolving.
    @Default(false) bool isLocating,

    /// User-facing message when "Use my location" failed (permission
    /// denied, services off, plugin error) — the map-tap path remains
    /// available throughout.
    String? locationError,

    /// True while a save is in flight.
    @Default(false) bool isSaving,

    /// User-facing message for a failed save.
    String? saveError,
  }) = _RouteSuggestState;

  const RouteSuggestState._();

  /// The currently selected suggestion, or `null` before any are loaded.
  SuggestedRoute? get selected =>
      suggestions.isEmpty ? null : suggestions[selectedIndex];
}

/// Drives the route-suggest flow (`/activity/routes/suggest`): inputs ->
/// suggestion request -> selection -> explicit save.
@riverpod
class RouteSuggestController extends _$RouteSuggestController {
  /// Bumped by [_beginRequest] so a superseded call abandons after its
  /// awaits instead of clobbering newer state.
  int _epoch = 0;

  @override
  RouteSuggestState build() => const RouteSuggestState();

  void initParams({
    ActivityType? activityType,
    String? distance,
    GeoPoint? startPoint,
    String? startAddress,
  }) {
    state = state.copyWith(
      activityType: activityType ?? state.activityType,
      distanceInput: distance ?? state.distanceInput,
      start: startPoint ?? state.start,
      startAddress: startAddress ?? state.startAddress,
    );
  }

  void updateDistanceInput(String value) {
    _beginRequest();
    state = state.copyWith(distanceInput: value, distanceError: null);
  }

  void updateActivityType(ActivityType value) {
    _beginRequest();
    state = state.copyWith(activityType: value);
  }

  void updateShapePreference(RouteShapePreference value) {
    _beginRequest();
    state = state.copyWith(shapePreference: value);
  }

  /// Sets the start point (map tap, coordinate entry).
  void setStart(GeoPoint point, {String? address}) {
    _beginRequest();
    _applyStart(point, address: address);
  }

  /// Searches for places/addresses matching [query].
  Future<void> searchPlaces(String query) async {
    final trimmed = query.trim();
    state = state.copyWith(searchQuery: query, searchError: null);
    if (trimmed.length < 2) {
      state = state.copyWith(
        searchResults: const [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true);
    final searchService = ref.read(locationSearchServiceProvider);
    try {
      final results = await searchService.search(
        trimmed,
        proximity: state.start,
      );
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isSearching: false,
        searchError: userMessageFor(error),
      );
    }
  }

  /// Selects a search result as the start point.
  void selectSearchResult(LocationSearchResult result) {
    _beginRequest();
    state = state.copyWith(
      start: result.point,
      startAddress: result.secondaryText != null
          ? '${result.name}, ${result.secondaryText}'
          : result.name,
      searchResults: const [],
      searchQuery: result.name,
      startError: null,
      locationError: null,
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: const [],
      searchError: null,
    );
  }

  /// Resolves the device's current position into the start point.
  ///
  /// Runs the permission flow first (mirroring
  /// `RecordingController.start`); every failure lands in
  /// [RouteSuggestState.locationError] with the map-tap path untouched.
  Future<void> useMyLocation() async {
    final epoch = _beginRequest();
    state = state.copyWith(isLocating: true, locationError: null);
    final adapter = ref.read(locationAdapterProvider);
    try {
      var permission = await adapter.checkPermission();
      if (epoch != _epoch) return;
      if (permission != LocationPermissionResult.granted) {
        permission = await adapter.requestPermission();
        if (epoch != _epoch) return;
      }
      if (permission != LocationPermissionResult.granted) {
        state = state.copyWith(
          isLocating: false,
          locationError: _permissionMessage(permission),
        );
        return;
      }

      final fix = await adapter.getCurrentPosition();
      if (epoch != _epoch) return;
      // `_applyStart`, not `setStart`: this call already owns the epoch it
      // took out above, and re-bumping it here would leave the token stale
      // for anything added after this point.
      final point = GeoPoint(latitude: fix.latitude, longitude: fix.longitude);
      _applyStart(
        point,
        address: 'Current Location',
      );
      await ref.read(routeLastRecordedLocationProvider.notifier).record(point);
      state = state.copyWith(isLocating: false);
    } on Object catch (error) {
      if (epoch != _epoch) return;
      state = state.copyWith(
        isLocating: false,
        locationError: userMessageFor(error),
      );
    }
  }

  /// Validates the inputs and requests suggestions. [unitSystem] governs
  /// how [RouteSuggestState.distanceInput] is parsed (km vs mi — same
  /// convention as manual entry); the request itself is always metric.
  Future<void> findRoutes(UnitSystem unitSystem) async {
    final service = ref.read(routeSuggestionServiceProvider);
    final targetMeters = _parsedTargetMeters(unitSystem);
    final start = state.start;
    // Checked here, not only in the service: an out-of-range distance would
    // otherwise send the (home-adjacent) start point over the network just
    // to come back as the generic "check the highlighted fields" message
    // with nothing actually highlighted, and Retry would resend it forever.
    final distanceError = switch (targetMeters) {
      null => 'Enter a distance greater than zero.',
      final meters when meters > service.maxTargetMeters => _tooFarMessage(
        service.maxTargetMeters,
        unitSystem,
      ),
      _ => null,
    };
    state = state.copyWith(
      distanceError: distanceError,
      startError: start == null
          ? 'Choose a start point on the map (or use your location).'
          : null,
    );
    if (targetMeters == null || distanceError != null || start == null) return;

    final epoch = _beginRequest();
    state = state.copyWith(
      phase: SuggestPhase.loading,
      error: null,
      suggestions: const [],
      selectedIndex: 0,
    );
    try {
      final suggestions = await service.suggestRoundTrips(
        start: start,
        targetMeters: targetMeters,
        activityType: state.activityType,
        shapePreference: state.shapePreference,
      );
      if (epoch != _epoch) return;
      state = state.copyWith(
        phase: SuggestPhase.loaded,
        suggestions: suggestions,
      );
    } on Object catch (error) {
      if (epoch != _epoch) return;
      state = state.copyWith(
        phase: SuggestPhase.error,
        error: userMessageFor(error),
      );
    }
  }

  void select(int index) {
    if (index < 0 || index >= state.suggestions.length) return;
    state = state.copyWith(selectedIndex: index);
  }

  /// Persists the currently selected suggestion under [name] (falling back
  /// to [defaultRouteName]'s form when blank) and returns the new route's
  /// id, or `null` when there's no selection or the save failed (with
  /// [RouteSuggestState.saveError] set).
  Future<String?> saveSelected({
    required String name,
    required UnitSystem unitSystem,
  }) async {
    final suggestion = state.selected;
    if (suggestion == null || state.isSaving) return null;

    final trimmed = name.trim();
    final routeName = trimmed.isEmpty
        ? defaultRouteName(suggestion, state.activityType, unitSystem)
        : trimmed;

    state = state.copyWith(isSaving: true, saveError: null);
    final now = DateTime.now().toUtc();
    final route = SavedRoute(
      id: EntityId.generate(),
      name: routeName,
      activityType: state.activityType,
      distanceMeters: suggestion.distanceMeters,
      points: suggestion.points,
      source: RouteSource.suggested,
      estimatedDuration: suggestion.estimatedDuration,
      ascentMeters: suggestion.ascentMeters,
      descentMeters: suggestion.descentMeters,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await ref.read(routeRepositoryProvider).saveRoute(route);
      state = state.copyWith(isSaving: false);
      return route.id;
    } on Object catch (error) {
      state = state.copyWith(isSaving: false, saveError: userMessageFor(error));
      return null;
    }
  }

  /// Takes out the next request token and clears everything the *previous*
  /// in-flight call owned but can no longer resolve: results computed for
  /// the now-superseded inputs, and the `loading`/`isLocating` flags whose
  /// owning call is about to be discarded by the epoch guard.
  ///
  /// Every entry point that starts, or invalidates, a request goes through
  /// here — that's what makes "the caller that raised a flag always ends up
  /// responsible for lowering it" true even when the caller is abandoned
  /// mid-await (otherwise a failed `useMyLocation` orphans a concurrent
  /// `findRoutes` and the spinner never stops).
  int _beginRequest() {
    _epoch++;
    state = state.copyWith(
      phase: SuggestPhase.input,
      suggestions: const [],
      selectedIndex: 0,
      error: null,
      saveError: null,
      isLocating: false,
    );
    return _epoch;
  }

  /// Applies a resolved start point without touching the request epoch —
  /// for callers that already took one out (see [useMyLocation]).
  void _applyStart(GeoPoint point, {String? address}) {
    final defaultLabel =
        '${point.latitude.toStringAsFixed(4)}, '
        '${point.longitude.toStringAsFixed(4)}';
    state = state.copyWith(
      start: point,
      startAddress: address ?? defaultLabel,
      startError: null,
      locationError: null,
    );
  }

  /// The upper-bound message, in whichever unit the user types in. Rounded
  /// down to a whole unit so the quoted limit is always actually accepted.
  String _tooFarMessage(double maxMeters, UnitSystem unitSystem) {
    final km = maxMeters / 1000;
    final display = unitSystem == UnitSystem.imperial
        ? '${UnitConversions.kmToMi(km).floor()} mi'
        : '${km.floor()} km';
    return 'That is further than we can plan a loop for. Enter $display or '
        'less.';
  }

  double? _parsedTargetMeters(UnitSystem unitSystem) {
    final parsed = double.tryParse(state.distanceInput.trim());
    if (parsed == null || !parsed.isFinite || parsed <= 0) return null;
    final km = unitSystem == UnitSystem.imperial
        ? UnitConversions.miToKm(parsed)
        : parsed;
    return km * 1000;
  }

  String _permissionMessage(LocationPermissionResult result) =>
      switch (result) {
        LocationPermissionResult.denied =>
          'Location permission is needed to use your current position. Tap '
              'the map to choose a start point instead.',
        LocationPermissionResult.deniedForever =>
          'Location permission was denied. Enable it in your device '
              'settings, or tap the map to choose a start point.',
        LocationPermissionResult.servicesDisabled =>
          'Turn on location services, or tap the map to choose a start '
              'point.',
        LocationPermissionResult.granted => '',
      };
}

/// Default name for a saved suggestion: "5.03 km Run loop" (unit-aware).
String defaultRouteName(
  SuggestedRoute suggestion,
  ActivityType activityType,
  UnitSystem unitSystem,
) {
  final km = suggestion.distanceMeters / 1000;
  final display = unitSystem == UnitSystem.imperial
      ? '${UnitConversions.kmToMi(km).toStringAsFixed(1)} mi'
      : '${km.toStringAsFixed(1)} km';
  return '$display ${activityType.label} loop';
}
