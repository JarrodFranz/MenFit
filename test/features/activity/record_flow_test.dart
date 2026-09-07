import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [TileProvider] that never touches the network - see
/// `route_map_test.dart` for the fuller explanation. Any flow that lands on
/// the detail screen for a `recorded` activity renders a real [RouteMap]
/// (wave C3), so every such test MUST override [mapTileProviderProvider].
class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

/// Minimal always-granted fake: this file only needs a controllable fix
/// stream and a fixed [capabilities] answer, unlike
/// `recording_controller_test.dart`'s fake which also scripts permission
/// denial paths.
class _FakeLocationAdapter implements LocationAdapter {
  _FakeLocationAdapter({
    this.capabilities = const LocationCapabilities(canRecordActivities: true),
  });

  @override
  final LocationCapabilities capabilities;

  final _fixController = StreamController<LocationFix>.broadcast();

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => _fixController.stream;

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();

  void emit(LocationFix fix) => _fixController.add(fix);

  Future<void> close() => _fixController.close();
}

/// Controllable clock override for [recordingClockProvider] - lets this
/// file's forgotten-end test jump the session's/ticker's notion of "now"
/// forward by minutes without a real 10-minute wait. See
/// `recording_controller_test.dart`'s identical fake for the full
/// rationale.
class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

/// Pumps in small, bounded, non-zero-duration steps until [finder] matches
/// something (or [maxIterations] is exhausted), instead of `pumpAndSettle`.
///
/// `pumpAndSettle` is unsafe on this screen: `RecordingController` keeps a
/// real 1-second `Timer.periodic` ticker alive for the whole recording
/// (deliberately - see `record_screen.dart`'s class doc), and in this test
/// environment `pumpAndSettle` reliably timed out (confirmed by repeated
/// runs, not resource contention) whenever any such ticker was still
/// alive, rather than converging once it was cancelled the way its
/// documentation implies. Callers that trigger real async work (e.g. Drift
/// writes - see the `finish()` flow below) should let that resolve via
/// `tester.runAsync` *before* calling this, since pumped fake time alone
/// was confirmed not to drive it to completion (CL-10,
/// `testing-pitfalls.md`) - by the time this helper runs, it only needs to
/// wait out widget rebuilds/route transitions, so its default budget is
/// deliberately modest.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxIterations = 100,
  Duration step = const Duration(milliseconds: 20),
}) async {
  for (var i = 0; i < maxIterations; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required _FakeLocationAdapter locationAdapter,
    required db.AppDatabase database,
    List<Override> extraOverrides = const [],
  }) async {
    tester.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          locationAdapterProvider.overrideWithValue(locationAdapter),
          mapTileProviderProvider.overrideWithValue(_FakeTileProvider()),
          // The workout celebration mounts `PostWorkoutBadgeStrip`, whose
          // detector otherwise walks the WHOLE badge input chain against
          // real Drift - unwindowed activity/check-in/water/cycle reads
          // plus a per-activity GPS-sample rescan for personal records,
          // over four live streams - from inside this file's fake-async
          // zone, and is then torn down mid-flight. Nothing here is about
          // badges, so the chain is cut at its root: an empty progress
          // list hits the strip's own early return, and persistence is
          // never opened at all (`post_workout_badge_strip.dart`).
          badgeProgressProvider.overrideWith((ref) async => const []),
          ...extraOverrides,
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    await tester.tap(
      find.descendant(of: navigationBar, matching: find.text('Activity')),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Activity screen shows Record when capable',
    (tester) async {
      final locationAdapter = _FakeLocationAdapter();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(locationAdapter.close);

      await pumpApp(
        tester,
        locationAdapter: locationAdapter,
        database: database,
      );

      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Log Previous'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'Activity screen hides Record and shows a capability hint when not capable',
    (tester) async {
      final locationAdapter = _FakeLocationAdapter(
        capabilities: const LocationCapabilities(
          canRecordActivities: false,
          reason: 'Recording works on your phone.',
        ),
      );
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(locationAdapter.close);

      await pumpApp(
        tester,
        locationAdapter: locationAdapter,
        database: database,
      );

      expect(find.text('Record'), findsNothing);
      expect(find.text('Log activity'), findsOneWidget);
      expect(find.text('Recording works on your phone.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'record flow: start -> live stats update -> finish -> detail screen '
    'shows the saved recorded activity',
    (tester) async {
      final locationAdapter = _FakeLocationAdapter();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(locationAdapter.close);

      await pumpApp(
        tester,
        locationAdapter: locationAdapter,
        database: database,
      );

      await tester.tap(find.text('Record'));
      await tester.pumpAndSettle();

      // Pre-start view: explainer + Start recording.
      expect(
        find.textContaining("We'll use your location"),
        findsOneWidget,
      );
      await tester.tap(find.text('Start recording'));
      // The recording controller starts a real 1s Timer.periodic ticker
      // once recording begins, so `pumpAndSettle` (which waits for no
      // pending timers) must not be used again until `finish()`/`discard()`
      // cancels it - plain `pump()` calls flush the permission-check
      // microtasks without waiting on that ticker.
      await tester.pump();
      await tester.pump();

      final baseTime = DateTime.utc(2026);
      locationAdapter.emit(
        LocationFix(
          timestamp: baseTime,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 2,
        ),
      );
      await tester.pump();

      // ~11m north, 2s later - well under the run implausible-jump ceiling.
      locationAdapter.emit(
        LocationFix(
          timestamp: baseTime.add(const Duration(seconds: 2)),
          latitude: 0.0001,
          longitude: 0,
          speedMetersPerSecond: 2,
        ),
      );
      await tester.pump();

      // Live stats visible: distance no longer at the zeroed placeholder.
      expect(find.textContaining('0.01 km'), findsOneWidget);

      await tester.tap(find.text('Finish'));
      await tester.pump();
      expect(find.text('Finish recording?'), findsOneWidget);
      // Two "Finish" widgets now: the underlying screen's button and the
      // AlertDialog's action button. `.last` is NOT a reliable way to pick
      // the dialog's one - the dialog sits under a (by default)
      // barrier-dismissible modal barrier, and if the underlying screen's
      // button happens to be the one `.last` resolves to, tapping its
      // on-screen position hits that barrier instead (dismissing the
      // dialog with a `null` result, silently skipping `confirmFinish`'s
      // `if (confirmed == true)` branch - confirmed by a diagnostic run
      // that showed the recording screen, not the detail screen,
      // immediately after this tap). Scope the finder to the dialog
      // itself instead.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Finish'),
        ),
      );
      await tester.pump();
      // `controller.finish()`'s async chain includes real Drift writes
      // (`NativeDatabase.memory()`) that do not resolve purely via pumped
      // fake time in this environment (confirmed by direct diagnostics:
      // state stayed on `RecordingLifecycle.saving` even after several
      // seconds of pumped fake time) - central `testing-pitfalls.md`'s
      // CL-10: real I/O never completes in the widget-test fake-async
      // zone. `runAsync` steps outside that zone so the real Timers/IO the
      // Drift stack depends on can actually fire.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      // Wait for celebration dialog or transition
      for (var i = 0; i < 100; i++) {
        if (find.text('View Workout Details').evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 500));
          await tester.tap(
            find.text('View Workout Details'),
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 300));
          break;
        }
        await tester.pump(const Duration(milliseconds: 20));
      }

      for (var i = 0; i < 100; i++) {
        final onDetailScreen = find.byType(FlutterMap).evaluate().isNotEmpty;
        final stillOnRecordScreen = find.text('Discard').evaluate().isNotEmpty;
        if (onDetailScreen && !stillOnRecordScreen) break;
        await tester.pump(const Duration(milliseconds: 20));
      }

      // Landed on the detail screen for the newly recorded activity, with
      // its route map rendering the two recorded GPS samples.
      expect(find.textContaining('Run'), findsWidgets);
      expect(find.textContaining('0.01 km'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      final polylineLayer = tester.widget<PolylineLayer>(
        find.byType(PolylineLayer),
      );
      expect(polylineLayer.polylines.single.points, hasLength(2));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'forgotten-end: banner appears once auto-paused for 10 minutes; its '
    'Finish action saves straight away (no extra dialog) and navigates to '
    'the detail screen',
    (tester) async {
      final locationAdapter = _FakeLocationAdapter();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(locationAdapter.close);
      final fakeClock = _FakeClock(DateTime.utc(2026));

      await pumpApp(
        tester,
        locationAdapter: locationAdapter,
        database: database,
        extraOverrides: [
          recordingClockProvider.overrideWithValue(fakeClock.call),
        ],
      );

      await tester.tap(find.text('Record'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start recording'));
      // Same rationale as the flow test above: a real 1s ticker is now
      // alive, so plain `pump()` only (no `pumpAndSettle`) until finish().
      await tester.pump();
      await tester.pump();

      // Drive the session into an auto-paused episode via a sustained
      // low-speed streak. Every fix sits at the same lat/lon (0,0) so none
      // is ever rejected as an implausible jump - only the fake clock and
      // fix timestamps need to move together.
      locationAdapter.emit(
        LocationFix(
          timestamp: fakeClock.now,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 2,
        ),
      );
      await tester.pump();

      fakeClock.now = fakeClock.now.add(const Duration(seconds: 1));
      final boundary = fakeClock.now;
      locationAdapter.emit(
        LocationFix(
          timestamp: boundary,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0.2,
        ),
      );
      await tester.pump();

      fakeClock.now = fakeClock.now.add(const Duration(seconds: 6));
      locationAdapter.emit(
        LocationFix(
          timestamp: fakeClock.now,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0.2,
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('Auto-paused'),
        findsOneWidget,
        reason: 'sanity check: the sustained low-speed streak auto-paused',
      );
      expect(find.textContaining("Looks like you've stopped"), findsNothing);

      // Jump the fake clock forward 10 minutes. The controller's 1s
      // `Timer.periodic` ticker is real, but `flutter_test`'s pumped-time
      // zone fires it as the pumped duration is advanced (see
      // `pumpUntilFound`'s doc on this file's ticker/pumpAndSettle
      // interaction) - a single 1s pump is enough to trigger one
      // re-evaluation against the jumped fake clock, no real wait needed.
      fakeClock.now = boundary.add(const Duration(minutes: 10));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(
        find.textContaining("Looks like you've stopped"),
        findsOneWidget,
      );
      expect(find.text("I'm still going"), findsOneWidget);

      // Tap the banner's own "Finish" - scoped to the banner's container
      // (not the primary Finish button lower on screen, which shares the
      // same label) via its sibling "I'm still going" text.
      final bannerContainer = find
          .ancestor(
            of: find.text("I'm still going"),
            matching: find.byType(Container),
          )
          .first;
      await tester.tap(
        find.descendant(of: bannerContainer, matching: find.text('Finish')),
      );
      await tester.pump();

      // The banner's Finish calls RecordingController.finish() directly -
      // no "Finish recording?" confirmation dialog in between.
      expect(find.text('Finish recording?'), findsNothing);

      // Same CL-10 rationale as the flow test above: flush the real Drift
      // writes outside the fake-async zone before waiting on the route
      // transition.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      for (var i = 0; i < 100; i++) {
        final onDetailScreen = find.byType(FlutterMap).evaluate().isNotEmpty;
        final stillOnRecordScreen = find.text('Discard').evaluate().isNotEmpty;
        if (onDetailScreen && !stillOnRecordScreen) break;
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.textContaining('Run'), findsWidgets);
      expect(find.byType(FlutterMap), findsOneWidget);

      // The persisted activity's elapsedTime was trimmed back to the
      // auto-pause boundary, not the finish() call 10 minutes later -
      // asserted directly against the row rather than a formatted label,
      // since duration formatting isn't this test's concern.
      final row = await database.select(database.activities).getSingle();
      expect(
        row.elapsedTimeMs,
        boundary.difference(DateTime.utc(2026)).inMilliseconds,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
