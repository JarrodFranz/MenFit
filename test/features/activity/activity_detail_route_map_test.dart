import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_screen.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';

/// A [TileProvider] that never touches the network - see
/// `route_map_test.dart` for the fuller explanation. Every widget test that
/// pumps [ActivityDetailScreen] for a `recorded` activity MUST override
/// [mapTileProviderProvider] with a fake like this one.
class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

Activity _buildActivity({required ActivitySource source}) {
  final now = DateTime.utc(2026);
  return Activity(
    id: EntityId.generate(),
    activityType: ActivityType.run,
    title: 'Morning Run',
    startedAt: now,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: 5000,
    source: source,
    createdAt: now,
    updatedAt: now,
  );
}

List<ActivitySample> _buildSamples(String activityId) {
  final base = DateTime.utc(2026, 1, 1, 8);
  return [
    for (var i = 0; i < 5; i++)
      ActivitySample(
        id: 'sample-$i',
        activityId: activityId,
        timestamp: base.add(Duration(seconds: i * 10)),
        latitude: 51.500 + i * 0.001,
        longitude: -0.140 + i * 0.001,
      ),
  ];
}

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget wrap(String activityId) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mapTileProviderProvider.overrideWithValue(_FakeTileProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: ActivityDetailScreen(activityId: activityId),
      ),
    );
  }

  testWidgets('recorded activity with samples shows the route map', (
    tester,
  ) async {
    final repository = DriftActivityRepository(database);
    final activity = _buildActivity(source: ActivitySource.recorded);
    await repository.saveActivity(activity);
    await repository.insertSamples(_buildSamples(activity.id));

    await tester.pumpWidget(wrap(activity.id));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.textContaining('No route data'), findsNothing);

    // Flush the drift stream-cleanup Timer scheduled on provider disposal
    // (see `knowledge/flutter/flutter_patterns.md` Phase C wave 1 entry) so
    // flutter_test's end-of-test invariant check doesn't false-fail.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'recorded activity with zero samples shows "No route data"',
    (tester) async {
      final repository = DriftActivityRepository(database);
      final activity = _buildActivity(source: ActivitySource.recorded);
      await repository.saveActivity(activity);
      // No insertSamples call - a recording with no GPS points at all.

      await tester.pumpWidget(wrap(activity.id));
      await tester.pumpAndSettle();

      expect(find.textContaining('No route data'), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('manual activity shows neither a map nor a route placeholder', (
    tester,
  ) async {
    final repository = DriftActivityRepository(database);
    final activity = _buildActivity(source: ActivitySource.manual);
    await repository.saveActivity(activity);

    await tester.pumpWidget(wrap(activity.id));
    await tester.pumpAndSettle();

    expect(find.text('Route'), findsNothing);
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.textContaining('No route data'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
