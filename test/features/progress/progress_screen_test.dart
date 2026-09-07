import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_activity_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_nutrition_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_wellbeing_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/weekly_distance_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

Activity _activity({
  required String id,
  required DateTime startedAt,
  required String title,
  double distanceMeters = 5000,
  Duration movingTime = const Duration(minutes: 30),
  double? elevationGainMeters,
}) {
  return Activity(
    id: id,
    activityType: ActivityType.run,
    title: title,
    startedAt: startedAt,
    movingTime: movingTime,
    elapsedTime: movingTime,
    distanceMeters: distanceMeters,
    elevationGainMeters: elevationGainMeters,
    source: ActivitySource.manual,
    createdAt: startedAt,
    updatedAt: startedAt,
  );
}

/// UTC instant for local noon on [day] - converting *from* local time (not
/// hardcoding a UTC instant) keeps the intended local calendar day correct
/// regardless of the host machine's timezone.
DateTime _localNoonUtc(LocalDate day) {
  return DateTime(day.year, day.month, day.day, 12).toUtc();
}

/// Pumps the full [App] against an in-memory database seeded via
/// [seed] (called with a ready [DriftActivityRepository]), then navigates
/// from the home dashboard to the Progress screen.
Future<void> _pumpProgressScreen(
  WidgetTester tester, {
  Future<void> Function(DriftActivityRepository repository)? seed,
  UnitSystem unitSystem = UnitSystem.metric,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_complete': true});
  final prefs = await SharedPreferences.getInstance();
  final database = db.AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);

  if (unitSystem == UnitSystem.imperial) {
    final now = DateTime.utc(2026);
    await DriftProfileRepository(database).saveProfile(
      UserProfile(
        id: EntityId.generate(),
        displayName: 'Test User',
        unitSystem: UnitSystem.imperial,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  if (seed != null) {
    await seed(DriftActivityRepository(database));
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();

  // The Home redesign replaced the old "Explore & Track" grid's Progress
  // tile with the "This week" progress-summary card (ProgressSummaryCard);
  // its title text is unique on Home, so it doubles as the tap target. It
  // can sit below the fold on the default test surface - scroll it into
  // view before tapping.
  await tester.ensureVisible(find.text('This week'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('This week'));
  await tester.pumpAndSettle();
}

/// See `flutter_patterns.md`'s "Any widget test that pumps the full `App()`"
/// entry: the streak chain (and now this feature's own Drift-backed
/// providers) subscribe to Drift streams on every app boot, so every
/// full-app test must end by forcing disposal under a pump it controls,
/// then flushing once more, or flutter_test's own teardown can fail with a
/// false "Timer is still pending".
Future<void> _flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('progress screen displays Day/Week/Month selector and cards', (
    tester,
  ) async {
    final thisWeekMonday = mondayOf(LocalDate.today());

    await _pumpProgressScreen(
      tester,
      seed: (repository) async {
        await repository.saveActivity(
          _activity(
            id: 'this-week-a',
            title: 'Morning run',
            startedAt: _localNoonUtc(thisWeekMonday),
          ),
        );
        await repository.saveActivity(
          _activity(
            id: 'this-week-b',
            title: 'Evening run',
            startedAt: _localNoonUtc(thisWeekMonday),
            distanceMeters: 2000,
            movingTime: const Duration(minutes: 10),
          ),
        );
      },
    );

    // Period selector segments are rendered
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);

    // Top period range header (defaults to Week: 'This Week')
    expect(find.text('This Week'), findsOneWidget);

    // Nutrition card rendered
    expect(find.byType(ProgressNutritionCard), findsOneWidget);

    // Activity card shows total 7.0 km and 40m
    expect(find.byType(ProgressActivityCard), findsOneWidget);
    expect(find.text('7.0 km'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('progress-stat-workouts')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    ); // 2 workouts

    // Wellbeing card rendered
    expect(find.byType(ProgressWellbeingCard), findsOneWidget);

    // Switch to Day mode
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    // Switch to Month mode
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.text('This Month'), findsOneWidget);

    await _flushDriftTimers(tester);
  });

  testWidgets(
    'the weekly distance chart renders with a summarising semantics label',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final thisWeekMonday = mondayOf(LocalDate.today());

      await _pumpProgressScreen(
        tester,
        seed: (repository) => repository.saveActivity(
          _activity(
            id: 'this-week',
            title: 'A run',
            startedAt: _localNoonUtc(thisWeekMonday),
            distanceMeters: 7000,
          ),
        ),
      );

      await tester.ensureVisible(find.byType(WeeklyDistanceChart));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp(r'Weekly distance chart.*7\.0 kilometres'),
        ),
        findsOneWidget,
      );

      semanticsHandle.dispose();
      await _flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a personal-record row shows formatted values and navigates to the '
    "record-holding activity's detail screen on tap",
    (tester) async {
      final recordWeek = mondayOf(LocalDate.today()).addDays(-21);

      await _pumpProgressScreen(
        tester,
        seed: (repository) => repository.saveActivity(
          _activity(
            id: 'longest',
            title: 'Longest Run',
            startedAt: _localNoonUtc(recordWeek),
            distanceMeters: 20000,
          ),
        ),
      );

      // Scroll to personal records
      await tester.ensureVisible(find.text('Personal records'));
      await tester.pumpAndSettle();

      expect(find.text('Longest activity'), findsOneWidget);
      expect(find.text('20.00 km'), findsOneWidget);
      expect(find.textContaining('Longest Run'), findsOneWidget);

      await tester.tap(find.text('Longest activity'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      await _flushDriftTimers(tester);
    },
  );

  testWidgets(
    'an imperial-profile user sees mile-formatted stats and chart title',
    (tester) async {
      final thisWeekMonday = mondayOf(LocalDate.today());

      await _pumpProgressScreen(
        tester,
        unitSystem: UnitSystem.imperial,
        seed: (repository) => repository.saveActivity(
          _activity(
            id: 'this-week',
            title: 'A run',
            startedAt: _localNoonUtc(thisWeekMonday),
            distanceMeters: 8000,
          ),
        ),
      );

      expect(find.text('5.0 mi'), findsOneWidget);
      expect(find.text('Weekly distance (mi)'), findsOneWidget);

      await _flushDriftTimers(tester);
    },
  );
}
