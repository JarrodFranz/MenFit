import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/presentation/route_suggest_controller.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

import 'route_suggest_screen_test.dart'
    show FakeLocationAdapter, FakeRouteSuggestionService;

/// [RouteSuggestController] driven directly (no widgets), which is the only
/// way to interleave two in-flight calls deterministically. The concurrency
/// rules under test:
///
/// 1. a response only ever lands against the inputs it was requested for;
/// 2. whoever raises `loading`/`isLocating` is always the one that lowers
///    it — including when it is superseded mid-await.
void main() {
  late db.AppDatabase database;
  late FakeRouteSuggestionService service;
  late FakeLocationAdapter adapter;
  late ProviderContainer container;
  late ProviderSubscription<RouteSuggestState> keepAlive;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    service = FakeRouteSuggestionService();
    adapter = FakeLocationAdapter();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        routeSuggestionServiceProvider.overrideWithValue(service),
        locationAdapterProvider.overrideWithValue(adapter),
      ],
    );
    // The controller is autoDispose; an explicit listener stands in for the
    // widget that would normally be watching it, so state survives across
    // the awaits below.
    keepAlive = container.listen(
      routeSuggestControllerProvider,
      (previous, next) {},
    );
  });

  tearDown(() async {
    keepAlive.close();
    container.dispose();
    await database.close();
  });

  RouteSuggestController controller() =>
      container.read(routeSuggestControllerProvider.notifier);
  RouteSuggestState read() => container.read(routeSuggestControllerProvider);

  const pointA = GeoPoint(latitude: 51.5074, longitude: -0.1278);
  // Deliberately not [FakeLocationAdapter.currentPosition]: some cases
  // below only fail correctly if a map tap and a resolved fix are
  // distinguishable.
  const pointB = GeoPoint(latitude: 40.4168, longitude: -3.7038);

  test(
    'moving the start point abandons an in-flight request: the older '
    'response never becomes the shown suggestions',
    () async {
      final gate = Completer<void>();
      service.gate = gate;
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('5');
      final request = controller().findRoutes(UnitSystem.metric);
      expect(service.requests.single.start, pointA);

      // The user moves the marker while the request is still in flight.
      controller().setStart(pointB);
      gate.complete();
      await request;

      expect(read().start, pointB);
      expect(
        read().suggestions,
        isEmpty,
        reason: 'those routes were computed for the previous start point',
      );
      expect(read().phase, SuggestPhase.input);
    },
  );

  test(
    'a failing useMyLocation resolves the phase of the findRoutes it '
    'orphans - no permanently stuck spinner',
    () async {
      final gate = Completer<void>();
      service.gate = gate;
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('5');
      final request = controller().findRoutes(UnitSystem.metric);
      expect(read().phase, SuggestPhase.loading);

      // "Use my location" supersedes the request, then itself fails.
      adapter.positionError = Exception('no fix');
      await controller().useMyLocation();
      gate.complete();
      await request;

      expect(read().locationError, isNotNull);
      expect(
        read().phase,
        SuggestPhase.input,
        reason:
            'the abandoned request can no longer clear `loading` itself, so '
            'whoever superseded it must - otherwise Find routes stays '
            'disabled behind a spinner forever',
      );
      expect(read().isLocating, isFalse);
    },
  );

  test('tapping the map supersedes an in-flight useMyLocation', () async {
    final locating = controller().useMyLocation();
    expect(read().isLocating, isTrue);

    controller().setStart(pointB);
    await locating;

    expect(read().isLocating, isFalse);
    expect(
      read().start,
      pointB,
      reason: 'the later map tap wins; the fix must not overwrite it',
    );
  });

  group('distance validation against the service bound', () {
    test('over the provider maximum: inline error, nothing sent', () async {
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('150'); // km, vs the 100 km bound

      await controller().findRoutes(UnitSystem.metric);

      expect(read().distanceError, contains('100 km'));
      expect(read().phase, SuggestPhase.input);
      expect(
        service.requests,
        isEmpty,
        reason: 'an out-of-range distance must not send the start point',
      );
    });

    test("the bound is quoted in the user's own unit", () async {
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('100'); // miles

      await controller().findRoutes(UnitSystem.imperial);

      expect(read().distanceError, contains('62 mi'));
      expect(service.requests, isEmpty);
    });

    test('exactly on the bound is accepted', () async {
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('100');

      await controller().findRoutes(UnitSystem.metric);

      expect(read().distanceError, isNull);
      expect(read().phase, SuggestPhase.loaded);
      expect(service.requests.single.targetMeters, 100000);
    });

    test('the bound comes from the service, not a hard-coded 100 km', () async {
      service.maxTargetMeters = 20 * 1000;
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('50');

      await controller().findRoutes(UnitSystem.metric);

      expect(read().distanceError, contains('20 km'));
      expect(service.requests, isEmpty);
    });
  });

  group('stale suggestions are invalidated when the inputs change', () {
    Future<void> loadSuggestions() async {
      controller()
        ..setStart(pointA)
        ..updateDistanceInput('5');
      await controller().findRoutes(UnitSystem.metric);
      expect(read().suggestions, hasLength(3));
    }

    test('editing the distance clears them', () async {
      await loadSuggestions();

      controller().updateDistanceInput('8');

      expect(read().suggestions, isEmpty);
      expect(read().phase, SuggestPhase.input);
    });

    test('changing the activity type clears them', () async {
      await loadSuggestions();

      controller().updateActivityType(ActivityType.ride);

      expect(read().suggestions, isEmpty);
      expect(read().phase, SuggestPhase.input);
    });

    test('moving the start point clears them', () async {
      await loadSuggestions();

      controller().setStart(pointB);

      expect(read().suggestions, isEmpty);
      expect(read().phase, SuggestPhase.input);
    });
  });

  test('saveSelected persists descent alongside ascent', () async {
    controller()
      ..setStart(pointA)
      ..updateDistanceInput('5');
    await controller().findRoutes(UnitSystem.metric);

    final id = await controller().saveSelected(
      name: 'Loop',
      unitSystem: UnitSystem.metric,
    );

    expect(id, isNotNull);
    final row = await database.select(database.routes).getSingle();
    expect(row.ascentMeters, service.results.first.ascentMeters);
    expect(
      row.descentMeters,
      service.results.first.descentMeters,
      reason: 'descent is fetched from the provider - it must not be dropped',
    );
  });

  test(
    'useMyLocation records position to routeLastRecordedLocationProvider',
    () async {
      expect(container.read(routeLastRecordedLocationProvider), isNull);

      await controller().useMyLocation();

      final recorded = container.read(routeLastRecordedLocationProvider);
      expect(recorded, isNotNull);
      expect(
        recorded!.latitude,
        closeTo(adapter.currentPosition.latitude, 0.0001),
      );
      expect(
        recorded.longitude,
        closeTo(adapter.currentPosition.longitude, 0.0001),
      );
    },
  );
}
