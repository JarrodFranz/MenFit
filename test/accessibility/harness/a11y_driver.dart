import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'a11y_checks.dart';
import 'a11y_findings.dart';
import 'a11y_scenarios.dart';
import 'a11y_seed.dart';

/// Loads the app's real bundled Inter so measurements mean something.
///
/// Widget tests otherwise render with the test font, whose glyphs are
/// fixed-width boxes — every label "wraps", every card "overflows", and
/// none of it corresponds to the shipped UI. The same reasoning (and the
/// same loader) as `test/core/adaptive_scaffold_real_font_test.dart`;
/// without this call the entire audit is measuring Ahem.
Future<void> loadRealAppFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await File('assets/fonts/Inter.ttf').readAsBytes();
  final loader = FontLoader(AppTheme.fontFamily)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

/// A screen the audit visits, addressed the way the app addresses it.
class A11yScreen {
  const A11yScreen({
    required this.name,
    required this.location,
    this.onboardingComplete = true,
    this.overrides = const [],
    this.afterNavigate,
  });

  final String name;

  /// The go_router location, built from the ids the seed produced.
  final String Function(SeededIds ids) location;

  final bool onboardingComplete;

  final List<Override> overrides;

  /// Optional extra interaction once the screen is up (open a sheet, a
  /// tab, a dialog) before the checks run.
  final Future<void> Function(WidgetTester tester)? afterNavigate;
}

/// Pumps [screen] under [scenario] through the **real** application path —
/// real `App`, real `GoRouter`, real theme, real
/// `AccessibilityRepository` reading real `SharedPreferences` keys — then
/// runs every check and files the findings in [report].
///
/// Preferences are written through [AccessibilityRepository] rather than
/// injected into a provider so the audit exercises persistence, the
/// controller and `App.builder`'s `MediaQuery` override exactly as a user
/// toggling the settings screen would.
Future<void> auditScreen(
  WidgetTester tester, {
  required A11yReport report,
  required A11yScreen screen,
  required A11yScenario scenario,
}) async {
  final cell = scenario.label;
  report.recordCell(screen.name, cell);

  tester.view
    ..physicalSize = scenario.surface
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scenario.osTextScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({
    'onboarding_complete': screen.onboardingComplete,
  });
  final prefs = await SharedPreferences.getInstance();
  await AccessibilityRepository(prefs).setPreferences(scenario.prefs);

  final database = db.AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);
  final ids = await seedRealisticData(database, prefs);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(database),
      ...screen.overrides,
    ],
  );

  final captured = <FlutterErrorDetails>[];
  final previousOnError = FlutterError.onError;
  FlutterError.onError = captured.add;

  final semantics = tester.ensureSemantics();

  try {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await _settle(tester);

    final target = screen.location(ids);
    if (container.read(routerProvider).state.uri.toString() != target) {
      container.read(routerProvider).go(target);
      await _settle(tester);
    }

    final afterNavigate = screen.afterNavigate;
    if (afterNavigate != null) {
      await afterNavigate(tester);
      await _settle(tester);
    }

    // Reaching the wrong location silently would make every "no findings"
    // result meaningless, so it is itself a finding.
    final landed = container.read(routerProvider).state.uri.toString();
    if (!landed.startsWith(target.split('?').first)) {
      report.add(
        A11yFinding(
          screen: screen.name,
          scenario: cell,
          issue: A11yIssue.renderFailure,
          severity: A11ySeverity.medium,
          detail: 'navigation redirected: asked for $target, landed on $landed',
        ),
      );
    }

    report
      ..addAll(
        overflowFindings(
          screen: screen.name,
          scenario: cell,
          errors: captured,
        ),
      )
      ..addAll(
        tapTargetFindings(
          screen: screen.name,
          scenario: cell,
          tester: tester,
        ),
      )
      ..addAll(
        truncationFindings(
          screen: screen.name,
          scenario: cell,
          tester: tester,
        ),
      )
      ..addAll(
        occlusionFindings(
          screen: screen.name,
          scenario: cell,
          tester: tester,
        ),
      );
  } on Object catch (error, stackTrace) {
    report.add(
      A11yFinding(
        screen: screen.name,
        scenario: cell,
        issue: A11yIssue.renderFailure,
        severity: A11ySeverity.critical,
        detail: 'harness threw: ${error.toString().split('\n').first}',
        source: const LineSplitter()
            .convert(stackTrace.toString())
            .where((line) => line.contains('package:menfit_app/'))
            .take(3)
            .map((line) => line.trim())
            .join(' / '),
      ),
    );
  } finally {
    FlutterError.onError = previousOnError;
    semantics.dispose();
  }

  // Drift-stream-backed providers and `localDay`'s midnight `Timer` were
  // subscribed during this pump. Both must be torn down **inside** the test
  // body: `TestWidgetsFlutterBinding` checks its "no pending timers"
  // invariant the moment the body returns, before any `addTearDown`
  // callback runs, so disposing the container in a teardown is too late by
  // construction (same reasoning as
  // `test/features/weight/weight_test_vocabulary.dart#flushDriftTimers`).
  await tester.pumpWidget(const SizedBox.shrink());
  container.dispose();
  await tester.pump(const Duration(milliseconds: 1));
}

/// Settles without letting a permanently-running animation fail the audit:
/// a pulsing "recording" indicator is a design choice, not a reason to
/// stop measuring the screen it sits on.
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 32));
  } on Object {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 32));
    }
  }
}
