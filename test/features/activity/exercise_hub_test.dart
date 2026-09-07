import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_screen.dart';
import 'package:menfit_app/features/activity/presentation/hub/screen_awake_section.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities => const LocationCapabilities(
    canRecordActivities: true,
  );

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  group('Exercise Hub & Adaptive Manual Entry', () {
    late db.AppDatabase database;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      prefs = await SharedPreferences.getInstance();
      database = db.AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    Widget createTestApp({Widget? home}) {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
        ],
        child: home != null
            ? MaterialApp(theme: AppTheme.light(), home: home)
            : const App(),
      );
    }

    testWidgets(
      'ExerciseHubScreen renders Strength Hub with custom cycle banner',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 800)
          ..devicePixelRatio = 1;

        // Seed a strength activity
        final now = DateTime.now().toUtc();
        final act = Activity(
          id: EntityId.generate(),
          activityType: ActivityType.strength,
          title: 'Strength Session',
          startedAt: now.subtract(const Duration(hours: 2)),
          movingTime: const Duration(minutes: 45),
          elapsedTime: const Duration(minutes: 45),
          distanceMeters: 0,
          source: ActivitySource.manual,
          workoutDetails: const StrengthWorkoutDetails(
            exercises: [
              StrengthExercise(
                name: 'Barbell Squat',
                sets: [
                  StrengthSet(setNumber: 1, reps: 8, weightKg: 60),
                  StrengthSet(setNumber: 2, reps: 8, weightKg: 60),
                  StrengthSet(setNumber: 3, reps: 8, weightKg: 60),
                ],
              ),
            ],
          ),
          createdAt: now,
          updatedAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
          ],
        );
        addTearDown(container.dispose);
        await container.read(activityRepositoryProvider).saveActivity(act);

        await tester.pumpWidget(
          createTestApp(
            home: const ExerciseHubScreen(type: ActivityType.strength),
          ),
        );
        await tester.pumpAndSettle();

        // Check header and overview
        expect(find.text('Strength Hub'), findsOneWidget);
        expect(find.text('Strength Overview'), findsOneWidget);
        expect(find.text('Total Volume'), findsOneWidget);
        expect(find.text('Sets Logged'), findsOneWidget);

        // Check custom cycle banner
        expect(find.text('No Active Training Cycle'), findsOneWidget);
        expect(find.text('Pick Cycle'), findsOneWidget);
        expect(find.text('Saved Routines'), findsOneWidget);
        expect(find.text('Training Cycles'), findsOneWidget);

        // Check recent activity item. The hub body is a lazy ListView and
        // the per-hub "Keep screen awake" card (2026-09-04) pushed the
        // recent list below the 600dp test fold, where it is not built.
        await tester.scrollUntilVisible(
          find.text('Strength Session'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Strength Session'), findsOneWidget);
        expect(find.text('Volume: 1.4 t'), findsOneWidget);
        expect(find.textContaining('1 exercises • 3 sets'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('ExerciseHubScreen renders HIIT Hub with interval presets', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 1200)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        createTestApp(
          home: const ExerciseHubScreen(type: ActivityType.hiit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HIIT Hub'), findsOneWidget);
      expect(find.text('HIIT Overview'), findsOneWidget);
      expect(find.text('Interval Presets'), findsOneWidget);
      expect(find.text('Tabata (20s/10s × 8)'), findsOneWidget);
      expect(find.text('Power 40/20 × 6'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('ExerciseHubScreen renders Swim Hub with pool presets', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 1200)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        createTestApp(
          home: const ExerciseHubScreen(type: ActivityType.swim),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Swim Hub'), findsOneWidget);
      expect(find.text('Swim Overview'), findsOneWidget);
      expect(find.text('Pool Presets'), findsOneWidget);
      expect(find.text('25m Short Course'), findsOneWidget);
      expect(find.text('50m Olympic Pool'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'HIIT Hub interval preset opens config dialog without starting',
      (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(400, 1200)
          ..devicePixelRatio = 1;

        await tester.pumpWidget(
          createTestApp(
            home: const ExerciseHubScreen(type: ActivityType.hiit),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Tabata preset
        await tester.tap(find.text('Tabata (20s/10s × 8)'));
        await tester.pumpAndSettle();

        // Dialog opens allowing review/customization
        expect(find.text('Tabata Protocol'), findsOneWidget);
        expect(find.text('Work Interval'), findsOneWidget);
        expect(find.text('Rest Interval'), findsOneWidget);
        expect(find.text('Total Rounds'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);
        expect(find.text('Start Workout'), findsOneWidget);

        // Close without starting
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.text('Tabata Protocol'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('Swim Hub pool preset opens config dialog without starting', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 1200)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        createTestApp(
          home: const ExerciseHubScreen(type: ActivityType.swim),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 25m Short Course preset
      await tester.tap(find.text('25m Short Course'));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('25m Pool Preset'), findsOneWidget);
      expect(
        find.text('Choose your lane pool length for lap tracking:'),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Start Swim'), findsOneWidget);

      // Close without starting
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('25m Pool Preset'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'ExerciseHubScreen renders Other Hub with generic overview and '
      'Log Activity button',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 1200)
          ..devicePixelRatio = 1;

        final now = DateTime.now().toUtc();
        final act = Activity(
          id: EntityId.generate(),
          activityType: ActivityType.other,
          title: 'Kayaking Session',
          startedAt: now.subtract(const Duration(hours: 1)),
          movingTime: const Duration(minutes: 50),
          elapsedTime: const Duration(minutes: 50),
          distanceMeters: 0,
          source: ActivitySource.manual,
          createdAt: now,
          updatedAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
          ],
        );
        addTearDown(container.dispose);
        await container.read(activityRepositoryProvider).saveActivity(act);

        await tester.pumpWidget(
          createTestApp(
            home: const ExerciseHubScreen(type: ActivityType.other),
          ),
        );
        await tester.pumpAndSettle();

        // Check header and overview
        expect(find.text('Other Hub'), findsOneWidget);
        expect(find.text('Other Overview'), findsOneWidget);
        expect(find.text('Total Time'), findsOneWidget);
        expect(find.text('Activities'), findsOneWidget);

        // Does NOT fall through to mindful or GPS branches
        expect(find.text('Mindful Time'), findsNothing);
        expect(find.text('Most practised style'), findsNothing);
        expect(find.text('Record GPS'), findsNothing);

        // Action button is full-width Log Activity
        expect(find.text('Log Activity'), findsOneWidget);

        // Recent activity item visible
        expect(find.text('Kayaking Session'), findsOneWidget);
        expect(find.text('50 min'), findsWidgets);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets(
      'ManualEntryScreen adapts fields for Strength and saves structured data',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 1400)
          ..devicePixelRatio = 1;

        await tester.pumpWidget(
          createTestApp(
            home: const ManualEntryScreen(initialType: ActivityType.strength),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Strength specific sections are shown, distance is hidden
        expect(find.text('Exercises & Sets'), findsOneWidget);
        expect(find.text('Add Exercise'), findsOneWidget);
        expect(find.text('Distance'), findsNothing);

        // Add an exercise
        await tester.tap(find.text('Add Exercise'));
        await tester.pumpAndSettle();

        expect(find.text('Squat'), findsOneWidget);
        // Tap chip 'Squat'
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('Set 1:'), findsOneWidget);

        // Enter duration
        await tester.enterText(find.byType(TextField).at(1), '45');
        await tester.pumpAndSettle();

        // Save
        await tester.ensureVisible(find.text('Save'));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify activity is saved in repository
        final rows = await (database.select(
          database.activities,
        )..where((t) => t.deletedAt.isNull())).get();
        expect(rows.length, 1);
        expect(rows.first.activityType, 'strength');
        final details =
            WorkoutDetails.fromStorage(rows.first.metadataJson)!
                as StrengthWorkoutDetails;
        expect(details.exercises.first.name, 'Squat');

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('ManualEntryScreen edits existing Swim activity', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 1400)
        ..devicePixelRatio = 1;

      final now = DateTime.now().toUtc();
      final swimAct = Activity(
        id: EntityId.generate(),
        activityType: ActivityType.swim,
        title: 'Morning Laps',
        startedAt: now.subtract(const Duration(hours: 1)),
        movingTime: const Duration(minutes: 30),
        elapsedTime: const Duration(minutes: 30),
        distanceMeters: 1000,
        source: ActivitySource.manual,
        workoutDetails: const SwimWorkoutDetails(
          poolLengthMeters: 50,
          laps: 20,
        ),
        createdAt: now,
        updatedAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activityRepositoryProvider).saveActivity(swimAct);

      await tester.pumpWidget(
        createTestApp(
          home: ManualEntryScreen(editActivityId: swimAct.id),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Check fields are populated
      expect(find.text('Edit activity'), findsOneWidget);
      expect(find.text('Pool Setup & Laps'), findsOneWidget);
      expect(find.text('Freestyle'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'Yoga style chip opens a dialog titled with the style itself '
      '(ADR 014 §5: the chip label IS the payload)',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 1200)
          ..devicePixelRatio = 1;

        await tester.pumpWidget(
          createTestApp(
            home: const ExerciseHubScreen(type: ActivityType.yoga),
          ),
        );
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('mindfulStyleChip_Restorative')),
          200,
        );
        await tester.tap(
          find.byKey(const ValueKey('mindfulStyleChip_Restorative')),
        );
        await tester.pumpAndSettle();

        // Title, and the chip label it came from, are the same string.
        expect(find.text('Restorative'), findsWidgets);
        expect(
          find.text('Slow holds and long breaths, with props for support.'),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });

  group('Keep screen awake', () {
    late db.AppDatabase database;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      prefs = await SharedPreferences.getInstance();
      database = db.AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    Finder switchTile() =>
        find.widgetWithText(SwitchListTile, 'Keep screen awake');

    bool switchValue(WidgetTester tester) =>
        tester.widget<SwitchListTile>(switchTile()).value;

    Future<void> pumpHub(WidgetTester tester, ActivityType type) async {
      tester.view
        ..physicalSize = const Size(400, 1600)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
            locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: ExerciseHubScreen(type: type),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// The section on its own, so a layout assertion is about this card and
    /// not about whatever else the hub happens to be showing.
    Future<void> pumpSection(
      WidgetTester tester, {
      ActivityType type = ActivityType.run,
      Size surface = const Size(400, 900),
      TextScaler textScaler = TextScaler.noScaling,
    }) async {
      tester.view
        ..physicalSize = surface
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ScreenAwakeSection(type: type),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the Run hub offers it, on by default', (tester) async {
      await pumpHub(tester, ActivityType.run);

      expect(switchTile(), findsOneWidget);
      expect(find.text('While a Run workout is running'), findsOneWidget);
      expect(switchValue(tester), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('the Yoga hub says it covers sequences too', (tester) async {
      await pumpHub(tester, ActivityType.yoga);

      expect(switchTile(), findsOneWidget);
      expect(
        find.text('While a Yoga session or sequence is running'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('turning it off persists, and only for that type', (
      tester,
    ) async {
      await pumpHub(tester, ActivityType.run);

      await tester.tap(switchTile());
      await tester.pumpAndSettle();

      expect(switchValue(tester), isFalse);
      expect(prefs.getBool('screen_awake_run'), isFalse);
      // Nothing was written for any other hub.
      expect(prefs.getBool('screen_awake_yoga'), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('a stored choice is what the hub shows', (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'screen_awake_swim': false,
      });
      prefs = await SharedPreferences.getInstance();

      await pumpHub(tester, ActivityType.swim);

      expect(switchValue(tester), isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('lays out at 320dp with 150% text', (tester) async {
      await pumpSection(
        tester,
        surface: const Size(320, 900),
        textScaler: const TextScaler.linear(1.5),
      );

      expect(tester.takeException(), isNull);
      expect(switchTile(), findsOneWidget);
    });
  });
}
