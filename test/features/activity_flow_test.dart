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
import 'package:shared_preferences/shared_preferences.dart';

/// This flow exercises the manual-entry path specifically, so recording is
/// reported as unavailable regardless of the test-harness's default
/// platform (`flutter_test` defaults `defaultTargetPlatform` to
/// `TargetPlatform.android`, which would otherwise make
/// `ActivityScreen` show "Record" instead of "Log activity" - see
/// `presentation/recording/record_flow_test.dart` for the Record path).
class _NotCapableLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities => const LocationCapabilities(
    canRecordActivities: false,
    reason: 'Recording works on your phone.',
  );

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      throw UnimplementedError();

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      throw UnimplementedError();

  @override
  Stream<LocationFix> fixes() => throw UnimplementedError();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'empty state -> log an activity -> list shows it with correct stats -> '
    'open detail -> delete -> empty state again',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 1400)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
            locationAdapterProvider.overrideWithValue(
              _NotCapableLocationAdapter(),
            ),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to the Activity tab.
      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Activity')),
      );
      await tester.pumpAndSettle();

      // Empty state.
      expect(
        find.textContaining('No activities yet'),
        findsOneWidget,
      );
      expect(find.text('Log activity'), findsOneWidget);
      // Logging is reached from the fixed button under the Exercise Hubs
      // row; nothing floats over the dashboard cards.
      expect(find.byType(FloatingActionButton), findsNothing);

      // Log activity.
      await tester.tap(find.text('Log activity'));
      await tester.pumpAndSettle();

      expect(find.text('Log activity'), findsOneWidget); // app bar title

      // Duration: 0h 30m 0s.
      final durationFields = find.byType(TextField).evaluate().toList();
      expect(
        durationFields.length,
        greaterThanOrEqualTo(6),
        reason: 'expected h/m/s + distance + title + notes fields',
      );
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '0'); // hours
      await tester.enterText(textFields.at(1), '30'); // minutes
      await tester.enterText(textFields.at(2), '0'); // seconds
      await tester.enterText(textFields.at(3), '5.0'); // distance (km)
      await tester.enterText(textFields.at(4), 'Test Run'); // title
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Back on the list, showing the new entry with correctly formatted
      // stats: 5km in 30:00 -> 6:00/km pace.
      expect(find.text('Test Run'), findsOneWidget);
      expect(
        find.textContaining('5.00 km · 30:00 · 6:00 /km'),
        findsOneWidget,
      );
      // Still no FAB once the list has entries: the floating Record button
      // was removed when Record moved under the Exercise Hubs row.
      expect(find.byType(FloatingActionButton), findsNothing);

      // Open the detail screen.
      await tester.drag(find.byType(ListView).first, const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Run'));
      await tester.pumpAndSettle();

      expect(find.text('Test Run'), findsOneWidget);
      expect(find.textContaining('5.00 km'), findsOneWidget);
      expect(find.textContaining('6:00 /km'), findsOneWidget);

      // Delete it.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete this activity?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Back to the empty state.
      expect(find.textContaining('No activities yet'), findsOneWidget);
      expect(find.text('Test Run'), findsNothing);

      // Drift's query-stream cleanup schedules a zero-duration `Timer` when
      // an autoDispose stream provider (activityListControllerProvider,
      // activityUnitSystemProvider, ...) loses its last listener - normal
      // in-app behaviour, but this test drives several such
      // subscribe/navigate-away/dispose cycles, and flutter_test's own
      // teardown unmounts the widget tree (disposing whatever's still
      // watching at that point) *after* the test body returns, with no
      // further `pump()` of ours left to flush the timer(s) that creates.
      // Left unflushed, flutter_test's end-of-test invariant check fails
      // with "A Timer is still pending" even though nothing is actually
      // wrong. Forcing disposal under a pump *we* control, then pumping
      // once more, flushes them before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
