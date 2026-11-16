import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/health/presentation/watch_vitals_card.dart';
import 'package:menfit_app/features/health/presentation/watch_vitals_controller.dart';

import '../../steps/fake_health_platform_adapter.dart';

void main() {
  final readAt = DateTime.utc(2026, 11, 16, 9);
  DateTime ago(Duration d) => readAt.subtract(d);

  final fullSnapshot = HealthVitalsSnapshot(
    readAt: readAt,
    latestHeartRateBpm: 72,
    latestHeartRateAt: ago(const Duration(minutes: 5)),
    restingHeartRateBpm: 58,
    restingHeartRateAt: ago(const Duration(hours: 7)),
    bloodOxygenPercent: 97,
    bloodOxygenAt: ago(const Duration(hours: 2)),
    sleep: SleepSummary(
      start: ago(const Duration(hours: 9)),
      end: ago(const Duration(hours: 1)),
      asleep: const Duration(hours: 7, minutes: 30),
      deep: const Duration(hours: 1, minutes: 30),
      light: const Duration(hours: 2),
      rem: const Duration(hours: 4),
      awake: const Duration(minutes: 30),
    ),
    hrvMs: 45,
    hrvKind: HrvKind.rmssd,
    hrvAt: ago(const Duration(hours: 30)),
    respiratoryRate: 14.5,
    respiratoryRateAt: ago(const Duration(hours: 3)),
    source: 'Health Connect',
  );

  Future<void> pump(WidgetTester tester, FakeHealthPlatformAdapter fake) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [healthPlatformAdapterProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WatchVitalsCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('unsupported platform: explanation only, no buttons', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final fake = FakeHealthPlatformAdapter()..vitalsToReturn = fullSnapshot;
    await pump(tester, fake);

    expect(find.text(WatchVitalsCard.unsupportedText), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(fake.vitalsReadCallCount, 0);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Health Connect not installed is unsupported', (tester) async {
    final fake = FakeHealthPlatformAdapter(supported: false);
    await pump(tester, fake);

    expect(find.text(WatchVitalsCard.unsupportedText), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('Android without grant: connect requests vitals, then reads', (
    tester,
  ) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsPermissionGranted = false
      ..vitalsAfterRequest = fullSnapshot;
    await pump(tester, fake);

    expect(find.text(WatchVitalsCard.permissionText), findsOneWidget);
    expect(fake.vitalsReadCallCount, 0);

    await tester.tap(find.text('Connect watch data'));
    await tester.pumpAndSettle();

    expect(fake.requestVitalsCallCount, 1);
    expect(fake.requestPermissionsCallCount, 0);
    expect(find.text('72 bpm · as of 5 min ago'), findsOneWidget);
  });

  testWidgets('iOS unknown grant + empty read prompts once, then empty', (
    tester,
  ) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsPermissionGranted = null
      ..vitalsToReturn = HealthVitalsSnapshot(readAt: readAt);
    await pump(tester, fake);

    expect(fake.vitalsReadCallCount, 1);
    expect(find.text('Connect watch data'), findsOneWidget);

    await tester.tap(find.text('Connect watch data'));
    await tester.pumpAndSettle();

    expect(fake.requestVitalsCallCount, 1);
    expect(find.text(WatchVitalsCard.emptyText), findsOneWidget);
    expect(find.text('Connect watch data'), findsNothing);
  });

  testWidgets('iOS unknown grant with data shows the data', (tester) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsPermissionGranted = null
      ..vitalsToReturn = fullSnapshot;
    await pump(tester, fake);

    expect(find.text('Connect watch data'), findsNothing);
    expect(find.text('Heart rate'), findsOneWidget);
  });

  testWidgets('loading shows a progress indicator', (tester) async {
    final gate = Completer<void>();
    final fake = FakeHealthPlatformAdapter()
      ..vitalsGate = gate
      ..vitalsToReturn = fullSnapshot;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [healthPlatformAdapterProvider.overrideWithValue(fake)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: WatchVitalsCard()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('granted but nothing recent shows the empty state', (
    tester,
  ) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsToReturn = HealthVitalsSnapshot(readAt: readAt);
    await pump(tester, fake);

    expect(find.text(WatchVitalsCard.emptyText), findsOneWidget);
    expect(find.text('Connect watch data'), findsNothing);
    expect(find.text(WatchVitalsCard.caption), findsOneWidget);
  });

  testWidgets('data: one row per metric with unit and as-of time', (
    tester,
  ) async {
    final fake = FakeHealthPlatformAdapter()..vitalsToReturn = fullSnapshot;
    await pump(tester, fake);

    expect(find.text('72 bpm · as of 5 min ago'), findsOneWidget);
    expect(find.text('58 bpm · as of 7 h ago'), findsOneWidget);
    expect(find.text('97 % · as of 2 h ago'), findsOneWidget);
    expect(find.text('7 h 30 min · as of 1 h ago'), findsOneWidget);
    expect(
      find.text('Deep 1 h 30 min · Light 2 h · REM 4 h · Awake 30 min'),
      findsOneWidget,
    );
    expect(find.text('Heart-rate variability (RMSSD)'), findsOneWidget);
    expect(find.text('45 ms · as of 1 day ago'), findsOneWidget);
    expect(find.text('14.5 breaths/min · as of 3 h ago'), findsOneWidget);
    expect(find.text(WatchVitalsCard.caption), findsOneWidget);
    expect(
      find.bySemanticsLabel('Heart rate, 72 bpm, as of 5 min ago'),
      findsOneWidget,
    );
  });

  testWidgets('missing metrics get no row; sleep without stages', (
    tester,
  ) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsToReturn = HealthVitalsSnapshot(
        readAt: readAt,
        hrvMs: 40,
        hrvKind: HrvKind.sdnn,
        hrvAt: readAt,
        sleep: SleepSummary(
          start: ago(const Duration(hours: 8)),
          end: ago(const Duration(hours: 1)),
          asleep: const Duration(hours: 7),
        ),
      );
    await pump(tester, fake);

    expect(find.text('Heart-rate variability (SDNN)'), findsOneWidget);
    expect(find.text('7 h · as of 1 h ago'), findsOneWidget);
    expect(find.textContaining('Deep'), findsNothing);
    expect(find.text('Heart rate'), findsNothing);
    expect(find.text('Blood oxygen'), findsNothing);
  });

  testWidgets('refresh reads the platform again', (tester) async {
    final fake = FakeHealthPlatformAdapter()
      ..vitalsToReturn = HealthVitalsSnapshot(readAt: readAt);
    await pump(tester, fake);
    expect(find.text(WatchVitalsCard.emptyText), findsOneWidget);

    fake.vitalsToReturn = fullSnapshot;
    await tester.tap(find.byTooltip('Refresh watch data'));
    await tester.pumpAndSettle();

    expect(fake.vitalsReadCallCount, 2);
    expect(find.text('Heart rate'), findsOneWidget);
  });

  testWidgets('compact width lays out without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = FakeHealthPlatformAdapter()..vitalsToReturn = fullSnapshot;
    await pump(tester, fake);

    expect(tester.takeException(), isNull);
    expect(find.text('Sleep'), findsOneWidget);
  });

  group('labels', () {
    test('asOfLabel is relative to the read time', () {
      expect(asOfLabel(readAt, readAt), 'as of just now');
      expect(
        asOfLabel(ago(const Duration(minutes: 59)), readAt),
        'as of 59 min ago',
      );
      expect(
        asOfLabel(ago(const Duration(hours: 49)), readAt),
        'as of 2 days ago',
      );
    });

    test('formatSleepDuration', () {
      expect(formatSleepDuration(const Duration(minutes: 45)), '45 min');
      expect(formatSleepDuration(const Duration(hours: 8)), '8 h');
    });
  });
}
