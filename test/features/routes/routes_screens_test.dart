import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/presentation/route_detail_screen.dart';
import 'package:menfit_app/features/routes/presentation/routes_screen.dart';

import 'route_suggest_screen_test.dart'
    show FakeLocationAdapter, FakeTileProvider;

void main() {
  late db.AppDatabase database;
  late DriftRouteRepository repository;

  final tokens = AppTheme.light().extension<AppTokens>()!;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftRouteRepository(database);
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<void> saveRoute({double? ascentMeters = 42}) {
    final now = DateTime.utc(2026, 8, 27, 8);
    return repository.saveRoute(
      SavedRoute(
        id: 'route-1',
        name: 'River loop',
        activityType: ActivityType.run,
        distanceMeters: 5100,
        points: const [
          GeoPoint(latitude: 51.5074, longitude: -0.1278),
          GeoPoint(latitude: 51.51, longitude: -0.12),
          GeoPoint(latitude: 51.5074, longitude: -0.1278),
        ],
        source: RouteSource.suggested,
        estimatedDuration: const Duration(minutes: 31),
        ascentMeters: ascentMeters,
        descentMeters: 39,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Widget buildScreen(
    Widget screen, {
    UnitSystem unitSystem = UnitSystem.metric,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
        locationAdapterProvider.overrideWithValue(FakeLocationAdapter()),
        activityUnitSystemProvider.overrideWith(
          (ref) => Stream.value(unitSystem),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: screen),
    );
  }

  void useWindow(WidgetTester tester, Size size) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
  }

  /// Both screens watch a Drift stream; tearing the tree down schedules a
  /// stream-close timer that the test binding otherwise flags as pending
  /// (same helper, same reason, as `routes_flow_test.dart`).
  Future<void> flushDriftTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  group('content width on wide windows (review finding 10)', () {
    testWidgets('the saved-routes list is capped, not full-bleed', (
      tester,
    ) async {
      useWindow(tester, const Size(1400, 1000));
      await saveRoute();
      await tester.pumpWidget(buildScreen(const RoutesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('River loop'), findsOneWidget);
      expect(
        tester.getSize(find.byType(ListView)).width,
        tokens.contentMaxWidth,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('route detail is capped, not full-bleed', (tester) async {
      useWindow(tester, const Size(1400, 1000));
      await saveRoute();
      await tester.pumpWidget(
        buildScreen(const RouteDetailScreen(routeId: 'route-1')),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(ListView)).width,
        tokens.contentMaxWidth,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('a narrow window still fills the width', (tester) async {
      useWindow(tester, const Size(400, 900));
      await saveRoute();
      await tester.pumpWidget(buildScreen(const RoutesScreen()));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(ListView)).width, 400);

      await flushDriftTimers(tester);
    });
  });

  testWidgets('imperial: route detail shows ascent in feet', (tester) async {
    useWindow(tester, const Size(500, 1000));
    await saveRoute();
    await tester.pumpWidget(
      buildScreen(
        const RouteDetailScreen(routeId: 'route-1'),
        unitSystem: UnitSystem.imperial,
      ),
    );
    await tester.pumpAndSettle();

    // 42 m of climb is 138 ft.
    expect(find.text('138 ft'), findsOneWidget);
    expect(find.text('42 m'), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('metric: route detail still shows ascent in metres', (
    tester,
  ) async {
    useWindow(tester, const Size(500, 1000));
    await saveRoute();
    await tester.pumpWidget(
      buildScreen(const RouteDetailScreen(routeId: 'route-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('42 m'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'renaming to a blank name is not offered: the confirm action is '
    'disabled rather than silently doing nothing',
    (tester) async {
      useWindow(tester, const Size(500, 1000));
      await saveRoute();
      await tester.pumpWidget(
        buildScreen(const RouteDetailScreen(routeId: 'route-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Rename'));
      await tester.pumpAndSettle();

      FilledButton confirmButton() => tester.widget<FilledButton>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Save'),
        ),
      );
      expect(confirmButton().onPressed, isNotNull);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '   ',
      );
      await tester.pump();

      expect(
        confirmButton().onPressed,
        isNull,
        reason: 'a whitespace-only name is not a name',
      );

      // Typing something real re-enables it, and the rename lands.
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Hill loop',
      );
      await tester.pump();
      expect(confirmButton().onPressed, isNotNull);

      await flushDriftTimers(tester);
    },
  );
}
