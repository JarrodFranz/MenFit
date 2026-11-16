import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_screen.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

/// Writes a row straight into the table, bypassing the repository's write
/// path - the shape of a strength session imported from Health Connect
/// before the import-side distance filter existed.
Future<void> _insertLegacyRow(
  db.AppDatabase database, {
  required String id,
  required String type,
  required double distanceMeters,
  required DateTime startedAt,
  Duration movingTime = const Duration(minutes: 38, seconds: 42),
}) async {
  final millis = startedAt.millisecondsSinceEpoch;
  await database
      .into(database.activities)
      .insert(
        db.ActivitiesCompanion.insert(
          id: id,
          activityType: type,
          title: 'Garmin ${type == 'run' ? 'Run' : 'Strength'}',
          startedAt: millis,
          movingTimeMs: movingTime.inMilliseconds,
          elapsedTimeMs: movingTime.inMilliseconds,
          distanceMeters: distanceMeters,
          source: 'recorded',
          createdAt: millis,
          updatedAt: millis,
        ),
      );
}

Future<double> _storedDistance(db.AppDatabase database, String id) async {
  final row = await (database.select(
    database.activities,
  )..where((t) => t.id.equals(id))).getSingle();
  return row.distanceMeters;
}

void main() {
  late db.AppDatabase database;
  late DriftActivityRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftActivityRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('repository distance boundary', () {
    test('a stored strength distance reads back as zero; a run keeps its '
        'distance', () async {
      final start = DateTime.utc(2026, 10, 5, 7);
      await _insertLegacyRow(
        database,
        id: 'strength-1',
        type: 'strength',
        distanceMeters: 130,
        startedAt: start,
      );
      await _insertLegacyRow(
        database,
        id: 'run-1',
        type: 'run',
        distanceMeters: 5000,
        startedAt: start.add(const Duration(hours: 3)),
        movingTime: const Duration(minutes: 30),
      );

      final strength = await repository.getActivity('strength-1');
      final run = await repository.getActivity('run-1');

      expect(strength!.distanceMeters, 0);
      expect(strength.avgPaceSecondsPerKm, isNull);
      expect(run!.distanceMeters, 5000);
      expect(run.avgPaceSecondsPerKm, 360);
    });

    test('saving a non-distance activity stores no distance', () async {
      final now = DateTime.utc(2026, 10, 5, 7);
      await repository.saveActivity(
        Activity(
          id: 'yoga-1',
          activityType: ActivityType.yoga,
          title: 'Yoga',
          startedAt: now,
          movingTime: const Duration(minutes: 45),
          elapsedTime: const Duration(minutes: 45),
          distanceMeters: 420,
          source: ActivitySource.recorded,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await _storedDistance(database, 'yoga-1'), 0);
    });

    test('weekly distance totals exclude a legacy strength distance', () async {
      final today = LocalDate.fromDateTime(DateTime.now());
      final noon = DateTime(today.year, today.month, today.day, 12).toUtc();
      await _insertLegacyRow(
        database,
        id: 'strength-2',
        type: 'strength',
        distanceMeters: 130,
        startedAt: noon,
      );
      await _insertLegacyRow(
        database,
        id: 'run-2',
        type: 'run',
        distanceMeters: 5000,
        startedAt: noon.subtract(const Duration(hours: 1)),
        movingTime: const Duration(minutes: 30),
      );

      final summaries = computeWeeklySummaries(
        activities: await repository.getActivities(),
        today: today,
        weeks: 1,
      );

      expect(summaries.single.activityCount, 2);
      expect(summaries.single.distanceMeters, 5000);
    });
  });

  group('activity detail screen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    void useTallWindow(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Widget wrap(String activityId) {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
      'a strength session with a stored distance shows neither Distance nor '
      'Pace, and still shows moving time',
      (tester) async {
        useTallWindow(tester);
        await _insertLegacyRow(
          database,
          id: 'strength-3',
          type: 'strength',
          distanceMeters: 130,
          startedAt: DateTime.utc(2026, 10, 5, 7),
        );

        await tester.pumpWidget(wrap('strength-3'));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('Moving time')), findsOneWidget);
        expect(find.byKey(const ValueKey('Distance')), findsNothing);
        expect(find.byKey(const ValueKey('Pace')), findsNothing);
        expect(find.textContaining('0.13 km'), findsNothing);
        expect(find.textContaining('295:25'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('a run still shows Distance and Pace', (tester) async {
      useTallWindow(tester);
      await _insertLegacyRow(
        database,
        id: 'run-3',
        type: 'run',
        distanceMeters: 5000,
        startedAt: DateTime.utc(2026, 10, 5, 7),
        movingTime: const Duration(minutes: 30),
      );

      await tester.pumpWidget(wrap('run-3'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('Distance')), findsOneWidget);
      expect(find.byKey(const ValueKey('Pace')), findsOneWidget);
      expect(find.text('6:00 /km'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });
}
