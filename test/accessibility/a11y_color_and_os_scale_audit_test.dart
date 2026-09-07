import 'package:flutter_test/flutter_test.dart';

import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';

/// Two smaller sweeps that the main matrix deliberately leaves out.
///
/// * **Colour-blindness modes** on the colour-carrying screens. These modes
///   swap `AppTokens` palettes and the achievement tier ramp; they change no
///   metrics, so they are audited here rather than multiplied through the
///   layout matrix.
/// * **OS text scale underneath the app's own preset.** `app.dart` resolves
///   the two into a single `TextScaler`, and that resolution is the one
///   place an accessibility control can make text *smaller* than the system
///   asked for — worth exercising explicitly.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_color_and_os_scale_audit_test.dart`
void main() {
  final report = A11yReport('color_and_os_scale');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  final colourHeavy = <A11yScreen>[
    A11yScreen(name: 'Achievements', location: (_) => '/achievements'),
    A11yScreen(name: 'Cycle', location: (_) => '/cycle'),
    A11yScreen(name: 'Progress', location: (_) => '/home/progress'),
    A11yScreen(name: 'Wellbeing', location: (_) => '/wellbeing'),
    A11yScreen(name: 'Nutrition', location: (_) => '/nutrition'),
  ];

  for (final screen in colourHeavy) {
    for (final scenario in colorBlindnessScenarios) {
      testWidgets('${screen.name} @ ${scenario.label}', (tester) async {
        await auditScreen(
          tester,
          report: report,
          screen: screen,
          scenario: scenario,
        );
      });
    }
  }

  final osScaleScreens = <A11yScreen>[
    A11yScreen(name: 'Home', location: (_) => '/home'),
    A11yScreen(name: 'Activity', location: (_) => '/activity'),
    A11yScreen(name: 'Nutrition', location: (_) => '/nutrition'),
    A11yScreen(name: 'Settings', location: (_) => '/settings'),
  ];

  for (final screen in osScaleScreens) {
    for (final scenario in osScaleMatrix) {
      testWidgets('${screen.name} @ ${scenario.label}', (tester) async {
        await auditScreen(
          tester,
          report: report,
          screen: screen,
          scenario: scenario,
        );
      });
    }
  }
}
