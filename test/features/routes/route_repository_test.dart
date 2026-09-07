import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';

void main() {
  late db.AppDatabase database;
  late DriftRouteRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRouteRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  SavedRoute buildRoute({
    String id = 'route-1',
    String name = '5.0 km Run loop',
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.utc(2026, 8, 27, 8);
    return SavedRoute(
      id: id,
      name: name,
      activityType: ActivityType.run,
      distanceMeters: 5030.5,
      points: const [
        GeoPoint(latitude: 51.5074, longitude: -0.1278),
        GeoPoint(latitude: 51.5085, longitude: -0.1265),
        GeoPoint(latitude: 51.5074, longitude: -0.1278),
      ],
      source: RouteSource.suggested,
      estimatedDuration: const Duration(minutes: 30),
      ascentMeters: 42,
      descentMeters: 39.5,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'saveRoute/getRoute round-trips every field incl. the geometry codec',
    () async {
      final route = buildRoute();
      await repository.saveRoute(route);

      final loaded = await repository.getRoute(route.id);
      expect(loaded, isNotNull);
      expect(loaded!.id, route.id);
      expect(loaded.name, route.name);
      expect(loaded.activityType, ActivityType.run);
      expect(loaded.distanceMeters, route.distanceMeters);
      expect(loaded.source, RouteSource.suggested);
      expect(loaded.estimatedDuration, const Duration(minutes: 30));
      expect(loaded.ascentMeters, 42);
      // Descent is fetched from the routing provider and used to be
      // dropped on the floor between the suggestion and the row.
      expect(loaded.descentMeters, 39.5);
      // Geometry went through polyline-5 encode -> TEXT column -> decode;
      // the fixture's coordinates are all 5-decimal-or-coarser, so the
      // round-trip is exact.
      expect(loaded.points, route.points);

      // And it really is stored encoded, not as raw coordinates.
      final row = await database.select(database.routes).getSingle();
      expect(row.geometry, isNot(contains('51.5')));
      expect(row.geometry, isNotEmpty);
    },
  );

  test('watchRoutes emits non-deleted routes newest-createdAt first', () async {
    await repository.saveRoute(
      buildRoute(id: 'older', name: 'Older', createdAt: DateTime.utc(2026)),
    );
    await repository.saveRoute(
      buildRoute(
        id: 'newer',
        name: 'Newer',
        createdAt: DateTime.utc(2026, 6),
      ),
    );

    final routes = await repository.watchRoutes().first;
    expect(routes.map((r) => r.id), ['newer', 'older']);
  });

  test('saveRoute updates in place, preserving createdAt', () async {
    final route = buildRoute();
    await repository.saveRoute(route);
    final original = await repository.getRoute(route.id);

    await repository.saveRoute(route.copyWith(name: 'Renamed'));

    final updated = await repository.getRoute(route.id);
    expect(updated!.name, 'Renamed');
    expect(updated.createdAt, original!.createdAt);
    final rows = await database.select(database.routes).get();
    expect(rows, hasLength(1), reason: 'an update must not duplicate');
  });

  test('deleteRoute is a soft delete: hidden from reads, row kept', () async {
    final route = buildRoute();
    await repository.saveRoute(route);

    await repository.deleteRoute(route.id);

    expect(await repository.getRoute(route.id), isNull);
    expect(await repository.watchRoutes().first, isEmpty);
    expect(await repository.watchRoute(route.id).first, isNull);

    final rows = await database.select(database.routes).get();
    expect(rows, hasLength(1), reason: 'soft delete keeps the row');
    expect(rows.single.deletedAt, isNotNull);
  });

  test('deleteAllData hard-deletes every row, soft-deleted included', () async {
    await repository.saveRoute(buildRoute(id: 'a'));
    await repository.saveRoute(buildRoute(id: 'b'));
    await repository.deleteRoute('a');

    await repository.deleteAllData();

    final rows = await database.select(database.routes).get();
    expect(rows, isEmpty, reason: 'full wipe leaves nothing recoverable');
  });

  test('getRoute returns null for an unknown id', () async {
    expect(await repository.getRoute('nope'), isNull);
  });

  test(
    'elevation is optional: null ascent/descent round-trip as null',
    () async {
      final route = buildRoute();
      await repository.saveRoute(
        route.copyWith(ascentMeters: null, descentMeters: null),
      );

      final loaded = await repository.getRoute(route.id);
      expect(loaded!.ascentMeters, isNull);
      expect(loaded.descentMeters, isNull);
    },
  );

  test(
    'deleteRoute on an unknown id is a no-op, not an error, and touches '
    'nothing else',
    () async {
      await repository.saveRoute(buildRoute());

      // The screen fires this after a confirm dialog; a route already
      // deleted on another device (or a double tap) must not throw a
      // StorageException at the user.
      await expectLater(repository.deleteRoute('nope'), completes);

      expect(await repository.watchRoutes().first, hasLength(1));
      final rows = await database.select(database.routes).get();
      expect(rows, hasLength(1));
      expect(rows.single.deletedAt, isNull);
    },
  );
}
