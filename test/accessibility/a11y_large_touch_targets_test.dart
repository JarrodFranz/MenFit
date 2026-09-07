import 'package:flutter_test/flutter_test.dart';

import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';

/// Proves the **Large Touch Targets** preference does what its switch says:
/// "Enforces a minimum 48x48 dp bounding area for interactive buttons and
/// chips."
///
/// Unlike the rest of `test/accessibility/`, this file **gates**. The other
/// audit files report findings for triage because they measure the app as
/// it is; this one measures a promise the settings screen makes to a user
/// with a motor impairment, and a promise that is only sometimes true is
/// not a promise. Every enabled interactive widget on these screens must
/// measure >= 48dp on both axes with the preference on.
///
/// Scope note — the reference surface is 411dp wide (Pixel 6 Pro, the
/// device the audit reproduced on). The wellbeing calendar's 7-column month
/// grid cannot reach 48dp *wide* cells below ~400dp of screen width; that
/// is arithmetic, not a fixable layout (see `core/widgets/month_calendar.dart`).
/// Narrow-width behaviour is asserted separately and honestly below.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_large_touch_targets_test.dart`
void main() {
  final report = A11yReport('large_touch_targets');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  final screens = <A11yScreen>[
    A11yScreen(name: 'Home', location: (_) => '/home'),
    A11yScreen(name: 'Progress', location: (_) => '/home/progress'),
    A11yScreen(name: 'Train', location: (_) => '/activity'),
    A11yScreen(name: 'Nutrition', location: (_) => '/nutrition'),
    A11yScreen(name: 'Recovery', location: (_) => '/recovery'),
    A11yScreen(name: 'Settings', location: (_) => '/settings'),
    A11yScreen(
      name: 'Accessibility settings',
      location: (_) => '/settings/accessibility',
    ),
    A11yScreen(
      name: 'Strength tracker',
      location: (_) => '/activity/track/strength',
    ),
    A11yScreen(name: 'HIIT tracker', location: (_) => '/activity/track/hiit'),
  ];

  for (final screen in screens) {
    // The baseline cell is recorded, not asserted: it is what makes the
    // "with the setting on" result meaningful rather than a tautology.
    testWidgets('${screen.name} baseline (setting off)', (tester) async {
      await auditScreen(
        tester,
        report: report,
        screen: screen,
        scenario: touchTargetsOff,
      );
    });

    testWidgets('${screen.name} @ ${touchTargetsOn.label}', (tester) async {
      await auditScreen(
        tester,
        report: report,
        screen: screen,
        scenario: touchTargetsOn,
      );

      final violations = report.findings.where(
        (f) =>
            f.screen == screen.name &&
            f.scenario == touchTargetsOn.label &&
            f.issue == A11yIssue.tapTarget,
      );
      final summary = violations
          .map((f) => '${f.detail} (${f.measurement})')
          .join('; ');
      expect(
        violations,
        isEmpty,
        reason:
            'Large Touch Targets is on, so every interactive widget on '
            '${screen.name} must be at least 48x48dp. Still under: $summary',
      );
    });
  }
}
