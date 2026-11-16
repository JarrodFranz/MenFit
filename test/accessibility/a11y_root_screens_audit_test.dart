import 'package:flutter_test/flutter_test.dart';

import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';

/// Accessibility audit of the root-level screens and the settings/nutrition
/// sub-screens: weight, achievements, the challenge flow, onboarding,
/// profile, the accessibility settings screen itself, and the food-logging
/// flow.
///
/// Reports; does not gate — see `a11y_shell_tabs_audit_test.dart`.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_root_screens_audit_test.dart`
void main() {
  final report = A11yReport('root_screens');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  final screens = <A11yScreen>[
    A11yScreen(name: 'Weight', location: (_) => '/weight'),
    A11yScreen(name: 'Achievements', location: (_) => '/achievements'),
    A11yScreen(name: 'Challenges', location: (_) => '/challenges'),
    A11yScreen(
      name: 'Challenge create',
      location: (_) => '/challenges/create',
    ),
    A11yScreen(name: 'Challenge join', location: (_) => '/challenges/join'),
    A11yScreen(
      name: 'Challenge detail',
      location: (ids) => '/challenges/${ids.challengeId}',
    ),
    A11yScreen(name: 'Profile', location: (_) => '/home/settings/profile'),
    A11yScreen(
      name: 'Accessibility settings',
      location: (_) => '/home/settings/accessibility',
    ),
    A11yScreen(name: 'Nutrition goals', location: (_) => '/nutrition/goals'),
    A11yScreen(name: 'Food picker', location: (_) => '/nutrition/add'),
    A11yScreen(name: 'Food form', location: (_) => '/nutrition/add/food'),
    // Onboarding is the one screen a user sees *before* they can reach the
    // accessibility settings, so it has to survive whatever their OS is
    // already asking for. `onboardingComplete: false` is what makes the
    // router's redirect leave the harness there.
    A11yScreen(
      name: 'Onboarding',
      location: (_) => '/onboarding',
      onboardingComplete: false,
    ),
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
      });
    }
  }
}
