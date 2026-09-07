import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/adaptive_scaffold.dart';

import 'harness/a11y_checks.dart';
import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';

/// The five-tab bottom bar, at the widths and text scales it actually
/// breaks at.
///
/// 98 of the audit's distinct mid-word wraps traced to this one widget:
/// Material's `NavigationBar` label has neither ellipsis nor hyphenation,
/// so once a cell is too narrow "Wellbeing" is drawn as "Wellb / eing".
/// Shrinking the font bought room at 100% and ran out the moment a user
/// raised their text size, because the user's scale multiplies whatever
/// base size the shrink picked.
///
/// The rule these tests pin down is: keep the labels while they
/// **measurably** fit, and fall back to icons — never to a broken word —
/// when they do not. Everything here runs against the real bundled Inter
/// ([loadRealAppFont]); under the default test font every label "wraps" at
/// every size and none of these numbers would mean anything.
void main() {
  setUpAll(loadRealAppFont);

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// The shipped destination list, kept in step with
  /// `app/router/routes.dart`'s `AppShellRouteData.destinations`.
  const destinations = [
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AdaptiveDestination(
      icon: Icons.directions_run_outlined,
      selectedIcon: Icons.directions_run,
      label: 'Activity',
    ),
    AdaptiveDestination(
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant,
      label: 'Nutrition',
    ),
    AdaptiveDestination(
      icon: Icons.spa_outlined,
      selectedIcon: Icons.spa,
      label: 'Wellbeing',
    ),
    AdaptiveDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppAdaptiveScaffold(
            navigationShell: navigationShell,
            destinations: destinations,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/a',
                  builder: (context, state) =>
                      const Center(child: Text('Body')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Pumps the shell at [width] logical pixels with the app's text-scale
  /// preference resolved to [textScale] — the same thing `App.builder`
  /// hands the tree once the user picks a preset.
  Future<void> pumpShell(
    WidgetTester tester, {
    required double width,
    required double textScale,
  }) async {
    tester.view
      ..physicalSize = Size(width, 780)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: buildRouter(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  NavigationDestinationLabelBehavior? labelBehavior(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior;

  /// The harness's own mid-word-wrap check, run over the pumped shell.
  ///
  /// Asserting through the audit's check rather than by eye is the point:
  /// this is the same code that produced the 98 findings, so a green result
  /// here is the same evidence in reverse.
  List<A11yFinding> wrapFindings(WidgetTester tester, String scenario) {
    return truncationFindings(
      screen: 'AppAdaptiveScaffold',
      scenario: scenario,
      tester: tester,
    ).where((f) => f.issue == A11yIssue.midWordWrap).toList();
  }

  void expectAllNamesAnnounced(WidgetTester tester) {
    for (final destination in destinations) {
      expect(
        find.bySemanticsLabel(RegExp(destination.label)),
        findsWidgets,
        reason:
            '"${destination.label}" is not in the semantics tree. Hiding a '
            'label visually must never remove it from what a screen reader '
            'announces.',
      );
    }
  }

  testWidgets('411dp at 100%: labels are shown and none of them wraps', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpShell(tester, width: 411, textScale: 1);

    expect(
      labelBehavior(tester),
      NavigationDestinationLabelBehavior.alwaysShow,
      reason:
          'Five labels fit comfortably on a reference phone at the default '
          'text size. Hiding them here would be a regression, not a fix.',
    );
    for (final destination in destinations) {
      expect(find.text(destination.label), findsOneWidget);
    }
    expect(wrapFindings(tester, '411dp/100%'), isEmpty);
    expectAllNamesAnnounced(tester);
    semantics.dispose();
  });

  testWidgets('360dp at 130%: labels hide, and nothing wraps mid-word', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpShell(tester, width: 360, textScale: 1.3);

    expect(
      labelBehavior(tester),
      NavigationDestinationLabelBehavior.alwaysHide,
      reason:
          '360dp / 72dp per cell is the measured first failure point for '
          "MenFit's five destinations: at 130% \"Nutrition\" no longer fits "
          'a cell, and Material would break it mid-word rather than '
          'ellipsise it. (FemFit measured 68dp per cell across six '
          'destinations; five destinations give each cell more room, so '
          'the boundary sits at a narrower shell width than before.)',
    );
    expect(
      wrapFindings(tester, '360dp/130%'),
      isEmpty,
      reason:
          'The whole point of the icon-only fallback is that no word is '
          'broken. A finding here means the fallback did not engage, or did '
          'not help.',
    );
    expectAllNamesAnnounced(tester);
    semantics.dispose();
  });

  testWidgets('320dp at 150%: labels hide, and nothing wraps mid-word', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpShell(tester, width: 320, textScale: 1.5);

    expect(
      labelBehavior(tester),
      NavigationDestinationLabelBehavior.alwaysHide,
    );
    expect(wrapFindings(tester, '320dp/150%'), isEmpty);
    expectAllNamesAnnounced(tester);
    semantics.dispose();
  });

  testWidgets('every destination carries a tooltip naming it', (tester) async {
    // With labels hidden this is the only way a sighted user who does not
    // recognise an icon can recover its name.
    await pumpShell(tester, width: 320, textScale: 1.5);

    final tooltips = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((destination) => destination.tooltip)
        .toList();
    expect(
      tooltips,
      destinations.map((destination) => destination.label).toList(),
    );
  });
}
