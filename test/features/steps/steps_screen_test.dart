import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_screen.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_bar_chart.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_daily_list.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_message_panel.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_period_header.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

import 'steps_test_fakes.dart';

void main() {
  final today = LocalDate.today();

  Future<FakeStepsSync> pumpScreen(
    WidgetTester tester, {
    required FakeStepsRepository repository,
    StepsAvailability availability = StepsAvailability.available,
    FakeHealthSync? healthSync,
    bool permissionPending = false,
    bool settle = true,
  }) async {
    final sync = FakeStepsSync();
    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: repository,
          sync: sync,
          availability: availability,
          healthSync: healthSync,
          permissionPending: permissionPending,
        ),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const StepsScreen(),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // A never-completing permission future leaves a spinner on screen
      // forever, so `pumpAndSettle` would time out rather than settle.
      await tester.pump();
      await tester.pump();
    }
    return sync;
  }

  group('availability states', () {
    testWidgets('unsupported platform explains itself and offers no action', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
        availability: StepsAvailability.unsupportedPlatform,
      );

      expect(find.byKey(const Key('stepsUnsupportedPanel')), findsOneWidget);
      expect(find.text(stepsUnsupportedTitle), findsOneWidget);
      // No button: there is nothing tapping one could achieve here, and
      // offering one would imply otherwise.
      expect(find.byKey(const Key('stepsMessagePanelAction')), findsNothing);
      // Nothing was ever synced, so there is no history to show under it.
      expect(find.text(stepsUnsupportedBody), findsOneWidget);
      expect(find.byType(StepsBarChart), findsNothing);
      expect(find.byType(StepsPeriodHeader), findsNothing);
    });

    testWidgets('unsupported platform still shows history a phone synced', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository([stepsRow(today, 8000)]),
        availability: StepsAvailability.unsupportedPlatform,
      );

      // The panel stays, as a header - this device genuinely cannot read
      // new counts...
      expect(find.byKey(const Key('stepsUnsupportedPanel')), findsOneWidget);
      // ...but the days already in the database are real and are drawn.
      expect(find.byType(StepsPeriodHeader), findsOneWidget);
      expect(find.byType(StepsBarChart), findsOneWidget);
      expect(find.byType(StepsDailyList), findsOneWidget);
      // And the copy no longer claims there is nothing to read.
      expect(find.text(stepsUnsupportedBodyWithHistory), findsOneWidget);
      expect(find.text(stepsUnsupportedBody), findsNothing);
    });

    testWidgets('the history copy follows the range on screen', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository([stepsRow(today, 8000)]),
        availability: StepsAvailability.unsupportedPlatform,
      );
      expect(find.text(stepsUnsupportedBodyWithHistory), findsOneWidget);

      // Step back to a window with nothing in it. The header and chart stay
      // mounted (otherwise there would be no way back), but "the history
      // below was synced on your phone" would now point at an empty chart.
      await tester.tap(find.byKey(const Key('stepsPreviousPeriod')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(StepsPeriodHeader), findsOneWidget);
      expect(find.text(stepsUnsupportedBody), findsOneWidget);
      expect(find.text(stepsUnsupportedBodyWithHistory), findsNothing);
    });

    testWidgets('sync off points at the Settings switch', (tester) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
        availability: StepsAvailability.syncOff,
      );

      expect(find.byKey(const Key('stepsSyncOffPanel')), findsOneWidget);
      expect(find.text(stepsSyncOffTitle), findsOneWidget);
      expect(find.text(stepsSyncOffAction), findsOneWidget);
      expect(find.text(stepsSyncOffBody), findsOneWidget);
      expect(find.byType(StepsBarChart), findsNothing);
    });

    testWidgets('sync off still shows what was synced before it went off', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository([stepsRow(today, 8000)]),
        availability: StepsAvailability.syncOff,
      );

      expect(find.byKey(const Key('stepsSyncOffPanel')), findsOneWidget);
      expect(find.byType(StepsBarChart), findsOneWidget);
      expect(find.text(stepsSyncOffBodyWithHistory), findsOneWidget);
      expect(find.text(stepsSyncOffBody), findsNothing);
    });

    testWidgets('permission needed asks, then re-syncs once granted', (
      tester,
    ) async {
      final healthSync = FakeHealthSync();
      final sync = await pumpScreen(
        tester,
        // Seeded on purpose: the point of the assertion below is that rows
        // in the database are still not drawn under a permission prompt.
        repository: FakeStepsRepository([stepsRow(today, 8000)]),
        availability: StepsAvailability.permissionNeeded,
        healthSync: healthSync,
      );

      expect(find.byKey(const Key('stepsPermissionPanel')), findsOneWidget);
      expect(find.text(stepsPermissionAction), findsOneWidget);
      // Panel-only by choice, even with rows in the database - see
      // `_StepsBody`'s dartdoc: a chart under a question reads as its
      // answer.
      expect(find.byType(StepsBarChart), findsNothing);

      await tester.tap(find.byKey(const Key('stepsMessagePanelAction')));
      await tester.pumpAndSettle();

      expect(healthSync.requestCount, 1);
      expect(
        sync.recentCalls.where((call) => call.force),
        hasLength(1),
        reason: 'a granted permission must be followed by a forced re-sync',
      );
    });

    testWidgets('a refused permission says so instead of re-asking silently', (
      tester,
    ) async {
      final healthSync = FakeHealthSync(grant: false);
      await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
        availability: StepsAvailability.permissionNeeded,
        healthSync: healthSync,
      );

      await tester.tap(find.byKey(const Key('stepsMessagePanelAction')));
      await tester.pumpAndSettle();

      expect(find.text(stepsPermissionRefusedBody), findsOneWidget);
    });

    testWidgets('available shows the chart, summary and list', (tester) async {
      await pumpScreen(
        tester,
        repository: FakeStepsRepository([stepsRow(today, 8000)]),
      );

      expect(find.byType(StepsMessagePanel), findsNothing);
      expect(find.byType(StepsBarChart), findsOneWidget);
      expect(find.byType(StepsDailyList), findsOneWidget);
      expect(find.text(stepsTotalLabel), findsOneWidget);
      expect(find.text(stepsAverageLabel), findsOneWidget);
      expect(find.text(stepsAtTargetLabel), findsOneWidget);
    });
  });

  testWidgets('syncs on open', (tester) async {
    final sync = await pumpScreen(tester, repository: FakeStepsRepository());

    expect(sync.recentCalls, hasLength(1));
    expect(sync.recentCalls.single.force, isFalse);
  });

  testWidgets('the refresh action forces a sync', (tester) async {
    final sync = await pumpScreen(
      tester,
      repository: FakeStepsRepository([stepsRow(today, 8000)]),
    );

    await tester.tap(find.byKey(const Key('stepsRefreshAction')));
    await tester.pumpAndSettle();

    expect(sync.recentCalls.last.force, isTrue);
  });

  testWidgets('the average is captioned with the days it was taken over', (
    tester,
  ) async {
    // One recorded day inside the current week, whichever weekday today is.
    await pumpScreen(
      tester,
      repository: FakeStepsRepository([stepsRow(today, 8000)]),
    );

    expect(find.text('8,000'), findsWidgets);
    expect(find.text(stepsDaysWithDataCaption(1)), findsNWidgets(2));
  });

  testWidgets('switching Week to Month changes the range that is asked for', (
    tester,
  ) async {
    final repository = FakeStepsRepository([stepsRow(today, 8000)]);
    await pumpScreen(tester, repository: repository);

    final weekRange = ProgressPeriod.week.rangeFor(today);
    expect(repository.watchedRanges.last.start, weekRange.start);
    expect(repository.watchedRanges.last.end, weekRange.end);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    // Clears the 300 ms range-settle timer this tap scheduled.
    await tester.pump(const Duration(milliseconds: 400));

    final monthRange = ProgressPeriod.month.rangeFor(today);
    expect(repository.watchedRanges.last.start, monthRange.start);
    expect(repository.watchedRanges.last.end, monthRange.end);
  });

  testWidgets('stepping back a period asks for the earlier range', (
    tester,
  ) async {
    final repository = FakeStepsRepository();
    final sync = await pumpScreen(tester, repository: repository);

    await tester.tap(find.byKey(const Key('stepsPreviousPeriod')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));

    final previous = ProgressPeriod.week.rangeFor(
      ProgressPeriod.week.previous(today),
    );
    expect(repository.watchedRanges.last.start, previous.start);
    // The window it just navigated to is also fetched from the platform -
    // `syncRecent` only covers the recent window, so an older month would
    // otherwise show gaps that are an artefact of the sync window.
    expect(sync.rangeCalls, isNotEmpty);
    expect(sync.rangeCalls.last.start, previous.start);
  });

  testWidgets('forward is disabled in the current period', (tester) async {
    await pumpScreen(tester, repository: FakeStepsRepository());

    final next = tester.widget<IconButton>(
      find.byKey(const Key('stepsNextPeriod')),
    );
    expect(next.onPressed, isNull);
  });

  testWidgets('shows a checking state instead of flashing the prompt, then '
      'gives up rather than spinning forever', (tester) async {
    // `stepsAvailability` is synchronous and reads `permissionNeeded` while
    // the platform is still answering, so without this branch a permitted
    // device shows a permission prompt for a frame or two on every open.
    await pumpScreen(
      tester,
      repository: FakeStepsRepository(),
      availability: StepsAvailability.permissionNeeded,
      permissionPending: true,
      settle: false,
    );

    expect(find.byKey(const Key('stepsCheckingPanel')), findsOneWidget);
    expect(find.text(stepsCheckingMessage), findsOneWidget);
    expect(find.byType(StepsMessagePanel), findsNothing);
    expect(find.byKey(const Key('stepsPermissionPanel')), findsNothing);

    // The platform never answers. After the timeout the screen stops
    // spinning and offers the button, saying why it is offering it.
    await tester.pump(const Duration(seconds: 9));
    await tester.pump();

    expect(find.byKey(const Key('stepsCheckingPanel')), findsNothing);
    expect(find.byKey(const Key('stepsPermissionPanel')), findsOneWidget);
    expect(find.text(stepsStillCheckingNote), findsOneWidget);
  });

  group('range fetching', () {
    testWidgets('three quick period steps fetch only the settled window', (
      tester,
    ) async {
      // The notifier drops a `syncRange` that arrives while another is in
      // flight, so firing one per tap lost the 2nd and 3rd and left an
      // older month rendering "30 days have no recorded step count" - a
      // false statement produced entirely by scheduling.
      final sync = await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('stepsPreviousPeriod')));
        await tester.pump();
      }
      expect(
        sync.rangeCalls,
        isEmpty,
        reason: 'nothing is fetched while the anchor is still moving',
      );

      await tester.pump(const Duration(milliseconds: 400));

      var anchor = today;
      for (var i = 0; i < 3; i++) {
        anchor = ProgressPeriod.week.previous(anchor);
      }
      final settled = ProgressPeriod.week.rangeFor(anchor);
      expect(sync.rangeCalls, hasLength(1));
      expect(sync.rangeCalls.single.start, settled.start);
      expect(sync.rangeCalls.single.end, settled.end);
    });

    testWidgets('a window requested mid-sync is re-issued once it finishes', (
      tester,
    ) async {
      final sync = await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
      );

      // A sync is already running (the open-the-screen `syncRecent`, say).
      sync.beginSync();
      await tester.pump();

      await tester.tap(find.byKey(const Key('stepsPreviousPeriod')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        sync.rangeCalls,
        isEmpty,
        reason: 'the notifier would have dropped this one',
      );

      sync.endSync();
      await tester.pump();

      final previous = ProgressPeriod.week.rangeFor(
        ProgressPeriod.week.previous(today),
      );
      expect(sync.rangeCalls, hasLength(1));
      expect(sync.rangeCalls.single.start, previous.start);
    });
  });

  // Regression guard in the shape of `trackers_test.dart`'s swim group:
  // test fonts are fixed-width and wider than Inter, so a pass here is a
  // pass on device.
  for (final (label, size, scale) in [
    ('320dp phone at 100%', const Size(320, 640), 1.0),
    ('320dp phone at 150%', const Size(320, 640), 1.5),
  ]) {
    testWidgets('does not overflow on a $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await pumpScreen(
        tester,
        repository: FakeStepsRepository([
          stepsRow(today, 8000),
          stepsRow(today.addDays(-1), 3200),
        ]),
      );

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: exception is FlutterError
            ? exception.diagnostics.map((d) => d.toStringDeep()).join()
            : '$exception',
      );
    });

    testWidgets('the sync-off panel does not overflow on a $label', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await pumpScreen(
        tester,
        repository: FakeStepsRepository(),
        availability: StepsAvailability.syncOff,
      );

      expect(tester.takeException(), isNull);
    });
  }
}
