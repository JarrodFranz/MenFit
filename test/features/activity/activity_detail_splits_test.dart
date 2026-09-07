import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_screen.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

/// A [TileProvider] that never touches the network (same fake as
/// `activity_detail_route_map_test.dart` / `route_map_test.dart`) - every
/// widget test pumping [ActivityDetailScreen] for a `recorded` activity
/// must override [mapTileProviderProvider] with something like this.
class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

Activity _buildActivity({
  required ActivitySource source,
  double distanceMeters = 5000,
}) {
  final now = DateTime.utc(2026);
  return Activity(
    id: EntityId.generate(),
    activityType: ActivityType.run,
    title: 'Morning Run',
    startedAt: now,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
    source: source,
    createdAt: now,
    updatedAt: now,
  );
}

/// A straight-line (fixed longitude), constant-speed track: every split
/// `computeSplits` produces from it has the exact same pace (see
/// `track_analysis_test.dart`'s `_buildTrack` doc for why a fixed-longitude
/// straight line makes distance an exact function of sample index) - this
/// is what lets the tests below assert on a single expected pace string
/// covering every split row, without duplicating `computeSplits`' own
/// logic to predict per-split values.
List<ActivitySample> _constantSpeedTrack(String activityId) {
  final base = DateTime.utc(2026, 1, 1, 8);
  return [
    for (var i = 0; i < 250; i++)
      ActivitySample(
        id: '$activityId-s$i',
        activityId: activityId,
        timestamp: base.add(Duration(seconds: i)),
        latitude: i * 0.0001,
        longitude: 0,
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

  testWidgets(
    'a recorded activity with samples shows a Splits section with '
    'correctly formatted metric paces',
    (tester) async {
      final repository = DriftActivityRepository(database);
      final activity = _buildActivity(source: ActivitySource.recorded);
      final samples = _constantSpeedTrack(activity.id);
      await repository.saveActivity(activity);
      await repository.insertSamples(samples);

      final expectedSplits = computeSplits(samples);
      expect(expectedSplits, isNotEmpty);
      final expectedPace = formatPace(
        expectedSplits.first.paceSecondsPerKm,
        UnitSystem.metric,
      );

      await tester.pumpWidget(wrap(activity.id));
      await tester.pumpAndSettle();

      expect(find.text('Splits'), findsOneWidget);
      // Every split has the same analytic pace (constant-speed track), so
      // the same formatted string should appear once per split row.
      expect(find.text(expectedPace), findsNWidgets(expectedSplits.length));
      expect(expectedPace, contains('/km'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'an imperial-profile user sees mile splits instead of kilometre splits',
    (tester) async {
      final repository = DriftActivityRepository(database);
      final profileRepository = DriftProfileRepository(database);
      final now = DateTime.utc(2026);
      await profileRepository.saveProfile(
        UserProfile(
          id: EntityId.generate(),
          displayName: 'Test User',
          unitSystem: UnitSystem.imperial,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final activity = _buildActivity(source: ActivitySource.recorded);
      final samples = _constantSpeedTrack(activity.id);
      await repository.saveActivity(activity);
      await repository.insertSamples(samples);

      final expectedSplits = computeSplits(samples, splitMeters: 1609.344);
      expect(expectedSplits, isNotEmpty);
      final expectedPace = formatPace(
        expectedSplits.first.paceSecondsPerKm,
        UnitSystem.imperial,
      );

      await tester.pumpWidget(wrap(activity.id));
      await tester.pumpAndSettle();

      expect(find.text('Splits'), findsOneWidget);
      expect(find.text(expectedPace), findsNWidgets(expectedSplits.length));
      expect(expectedPace, contains('/mi'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('a manually-logged activity shows no Splits section', (
    tester,
  ) async {
    final repository = DriftActivityRepository(database);
    final activity = _buildActivity(source: ActivitySource.manual);
    await repository.saveActivity(activity);

    await tester.pumpWidget(wrap(activity.id));
    await tester.pumpAndSettle();

    expect(find.text('Splits'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'a recorded activity with a track too short for any split shows no '
    'Splits section',
    (tester) async {
      final repository = DriftActivityRepository(database);
      final activity = _buildActivity(source: ActivitySource.recorded);
      await repository.saveActivity(activity);
      // Two points ~1m apart - far short of the 50m minimum for even a
      // trailing partial split.
      final base = DateTime.utc(2026, 1, 1, 8);
      await repository.insertSamples([
        ActivitySample(
          id: 'a',
          activityId: activity.id,
          timestamp: base,
          latitude: 51.5,
          longitude: -0.14,
        ),
        ActivitySample(
          id: 'b',
          activityId: activity.id,
          timestamp: base.add(const Duration(seconds: 1)),
          latitude: 51.50001,
          longitude: -0.14,
        ),
      ]);

      await tester.pumpWidget(wrap(activity.id));
      await tester.pumpAndSettle();

      expect(find.text('Splits'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  /// The highlight color `_SplitRow` applies to the fastest split's row
  /// (`colorScheme.primaryContainer`), read back off the outer `Container`
  /// directly inside the `Padding` keyed `split-$splitIndex` - the first
  /// `Container` found there is that row's own decoration box, not the
  /// nested one used for its pace bar.
  Color? highlightColorOf(WidgetTester tester, int splitIndex) {
    final container = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(ValueKey('split-$splitIndex')),
            matching: find.byType(Container),
          ),
        )
        .first;
    return (container.decoration as BoxDecoration?)?.color;
  }

  testWidgets(
    'a fast trailing partial split (a sprint finish) never steals the '
    'highlight from the fastest FULL split (F5)',
    (tester) async {
      final repository = DriftActivityRepository(database);
      final activity = _buildActivity(source: ActivitySource.recorded);

      final base = DateTime.utc(2026, 1, 1, 8);
      final samples = <ActivitySample>[];
      var time = base;
      var lat = 0.0;
      var index = 0;
      void addSteps(int count, double stepDegreesLat, Duration stepDuration) {
        for (var i = 0; i < count; i++) {
          index++;
          time = time.add(stepDuration);
          lat += stepDegreesLat;
          samples.add(
            ActivitySample(
              id: '${activity.id}-s$index',
              activityId: activity.id,
              timestamp: time,
              latitude: lat,
              longitude: 0,
            ),
          );
        }
      }

      samples.add(
        ActivitySample(
          id: '${activity.id}-s0',
          activityId: activity.id,
          timestamp: time,
          latitude: lat,
          longitude: 0,
        ),
      );
      // Split 1: slow (2s/step), a bit over 1000m.
      addSteps(90, 0.0001, const Duration(seconds: 2));
      // Split 2: faster (1s/step), a bit over another 1000m - the fastest
      // FULL split, and the only row that should ever be highlighted.
      addSteps(90, 0.0001, const Duration(seconds: 1));
      // Trailing partial: very fast (50ms/step) but short - must render,
      // must never be highlighted, however fast its pace looks.
      addSteps(20, 0.0001, const Duration(milliseconds: 50));

      await repository.saveActivity(activity);
      await repository.insertSamples(samples);

      final expectedSplits = computeSplits(samples);
      expect(
        expectedSplits.length,
        3,
        reason:
            'test fixture must produce exactly 2 full splits + 1 '
            'trailing partial',
      );
      expect(
        expectedSplits[2].paceSecondsPerKm,
        lessThan(expectedSplits[1].paceSecondsPerKm),
        reason:
            'the trailing partial must look faster than every full '
            'split for this test to be meaningful',
      );

      await tester.pumpWidget(wrap(activity.id));
      await tester.pumpAndSettle();

      expect(highlightColorOf(tester, 1), isNull);
      expect(highlightColorOf(tester, 2), isNotNull);
      expect(
        highlightColorOf(tester, 3),
        isNull,
        reason:
            'the fast trailing partial (split 3) must never be '
            'highlighted',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
