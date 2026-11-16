import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_screen.dart';
import 'package:menfit_app/features/activity/presentation/widgets/fitness_dashboard_cards.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_placeholders_card.dart';
import 'package:menfit_app/features/steps/presentation/steps_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'steps_test_fakes.dart';

class _FakeLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

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

/// The real `/steps` route (generated from [StepsRouteData]) plus a stand-in
/// for whichever screen is pushing it, so each entry point can be exercised
/// without dragging the six-branch shell into the test.
GoRouter _buildRouter({
  required String initialLocation,
  required WidgetBuilder homeBuilder,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      $stepsRouteData,
      GoRoute(path: '/home', builder: (context, state) => homeBuilder(context)),
      GoRoute(
        path: '/home/settings',
        builder: (context, state) =>
            const Scaffold(body: Text('settings stub')),
      ),
    ],
  );
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  test('the route is root-level, so it is reachable as a deep link', () {
    // The location every entry point pushes is the same string a cold deep
    // link arrives on - if this became a shell-nested path it would silently
    // stop matching, and (per the route's dartdoc) would reintroduce the
    // root-navigator GlobalKey crash for a screen pushed from three
    // different branches.
    expect(const StepsRouteData().location, '/steps');
  });

  testWidgets('/steps resolves to the steps screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: FakeStepsRepository(),
          sync: FakeStepsSync(),
          healthSync: FakeHealthSync(),
        ),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _buildRouter(
            initialLocation: '/steps',
            homeBuilder: (context) => const Scaffold(body: Text('home stub')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(StepsScreen), findsOneWidget);
  });

  testWidgets('the home "At a Glance" steps ring opens /steps', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: FakeStepsRepository(),
          sync: FakeStepsSync(),
          healthSync: FakeHealthSync(),
        ),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _buildRouter(
            initialLocation: '/home',
            homeBuilder: (context) => const Scaffold(
              body: SingleChildScrollView(
                child: FitnessDashboardCards(
                  activities: [],
                  unitSystem: UnitSystem.metric,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FitnessDashboardCards), findsOneWidget);
    await tester.tap(find.text('Steps'));
    await tester.pumpAndSettle();

    expect(find.byType(StepsScreen), findsOneWidget);
  });

  testWidgets('the Progress "Daily Steps" card opens /steps', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: FakeStepsRepository(),
          sync: FakeStepsSync(),
          healthSync: FakeHealthSync(),
        ),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _buildRouter(
            initialLocation: '/home',
            homeBuilder: (context) =>
                const Scaffold(body: ProgressFutureIntegrationCards()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily Steps'));
    await tester.pumpAndSettle();

    expect(find.byType(StepsScreen), findsOneWidget);
  });

  group('walking hub', () {
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

    testWidgets('offers a Daily steps action that opens /steps', (
      tester,
    ) async {
      addTearDown(() => flushDriftTimers(tester));
      tester.view
        ..physicalSize = const Size(400, 1400)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
            locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
            ...stepsOverrides(
              repository: FakeStepsRepository(),
              sync: FakeStepsSync(),
              healthSync: FakeHealthSync(),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: _buildRouter(
              initialLocation: '/home',
              homeBuilder: (context) =>
                  const ExerciseHubScreen(type: ActivityType.walk),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('walkingHubDailyStepsButton'));
      await tester.scrollUntilVisible(
        button,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(StepsScreen), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('the running hub does not offer it', (tester) async {
      addTearDown(() => flushDriftTimers(tester));
      tester.view
        ..physicalSize = const Size(400, 1400)
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
            home: const ExerciseHubScreen(type: ActivityType.run),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('walkingHubDailyStepsButton')),
        findsNothing,
      );

      await flushDriftTimers(tester);
    });
  });
}
