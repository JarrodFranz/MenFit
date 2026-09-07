import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/data/drift_strength_routine_repository.dart';
import 'package:menfit_app/features/activity/presentation/activity_screen.dart';
import 'package:menfit_app/features/activity/presentation/strength/strength_routine_editor_sheet.dart';
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

  group('Strength Editors & ActivityScreen Exercise Hubs tiles', () {
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

    testWidgets('ActivityScreen renders the Exercise Hubs type tiles', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 1000)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        createTestApp(
          home: const Scaffold(body: ActivityScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exercise Hubs'), findsOneWidget);
      // The separate "Focused Tools" card strip is gone - the type tiles
      // are the only hub entry point on this screen now.
      expect(find.text('Focused Tools'), findsNothing);
      expect(find.byTooltip('Open Strength hub'), findsOneWidget);
      expect(find.byTooltip('Open Run hub'), findsOneWidget);
      expect(find.byTooltip('Open Walk hub'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'StrengthRoutineEditorSheet allows editing and saving without starting',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 1000)
          ..devicePixelRatio = 1;

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: StrengthRoutineEditorSheet()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('New Day Routine'), findsOneWidget);
        expect(find.text('Exercises (3)'), findsOneWidget);
        expect(find.text('Barbell Squat'), findsOneWidget);
        expect(find.text('Save Routine'), findsOneWidget);
        expect(find.text('Start Workout Now'), findsOneWidget);

        // Edit routine name
        await tester.enterText(
          find.byType(TextField).first,
          'Leg Day Hypertrophy',
        );
        await tester.pumpAndSettle();

        // Tap Save Routine
        await tester.tap(find.text('Save Routine'));
        await tester.pumpAndSettle();

        // Verify routine saved in database
        final repo = DriftStrengthRoutineRepository(database);
        final routines = await repo.getRoutines();
        expect(routines.length, 1);
        expect(routines.first.name, 'Leg Day Hypertrophy');
        expect(routines.first.exercises.length, 3);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets(
      'StrengthCycleEditorSheet allows configuring cycle without starting',
      (tester) async {
        tester.view
          ..physicalSize = const Size(400, 1000)
          ..devicePixelRatio = 1;

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: StrengthCycleEditorSheet()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('New Training Cycle'), findsOneWidget);
        expect(find.text('Cycle Name'), findsOneWidget);
        expect(find.text('Set as Active Cycle'), findsOneWidget);
        expect(find.text('Save Cycle'), findsOneWidget);

        // Fill in cycle details
        await tester.enterText(
          find.byType(TextField).first,
          '4-Week Glute & Core',
        );
        await tester.pumpAndSettle();

        // Save cycle
        await tester.tap(find.text('Save Cycle'));
        await tester.pumpAndSettle();

        final repo = DriftStrengthRoutineRepository(database);
        final cycles = await repo.getCycles();
        expect(cycles.length, 1);
        expect(cycles.first.name, '4-Week Glute & Core');

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });
}
