import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';

import '../features/steps/fake_health_platform_adapter.dart';
import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';

/// Accessibility audit of the shell tabs plus Progress and Settings
/// (pushed from the Home gear since 2026-11-16).
///
/// **These tests report; they do not gate.** They fail only when a screen
/// cannot be rendered at all — layout findings are written to
/// `build/accessibility_audit/shell_tabs.md` and echoed to the test output
/// for triage. Turning individual findings into assertions is the right
/// move *after* they are fixed; asserting them now would just encode the
/// current bugs as expected behaviour.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_shell_tabs_audit_test.dart`
void main() {
  final report = A11yReport('shell_tabs');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  final screens = <A11yScreen>[
    A11yScreen(name: 'Home', location: (_) => '/home'),
    A11yScreen(name: 'Progress', location: (_) => '/home/progress'),
    A11yScreen(name: 'Train', location: (_) => '/activity'),
    A11yScreen(name: 'Nutrition', location: (_) => '/nutrition'),
    A11yScreen(
      name: 'Health',
      location: (_) => '/health',
      overrides: [
        healthPlatformAdapterProvider.overrideWithValue(
          FakeHealthPlatformAdapter(),
        ),
      ],
    ),
    A11yScreen(name: 'Recovery', location: (_) => '/recovery'),
    A11yScreen(name: 'Settings', location: (_) => '/home/settings'),
  ];

  for (final screen in screens) {
    for (final scenario in standardMatrix) {
      testWidgets('${screen.name} @ ${scenario.label}', (tester) async {
        await auditScreen(
          tester,
          report: report,
          screen: screen,
          scenario: scenario,
        );

        expect(
          report.findings.where(
            (f) =>
                f.screen == screen.name &&
                f.scenario == scenario.label &&
                f.issue == A11yIssue.renderFailure &&
                f.severity == A11ySeverity.critical,
          ),
          isEmpty,
          reason:
              '${screen.name} could not be rendered under '
              '${scenario.label}. A screen that throws is not a layout '
              'finding to triage later — it is broken now.',
        );
      });
    }
  }
}
