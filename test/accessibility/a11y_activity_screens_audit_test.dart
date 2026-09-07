import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';

/// Accessibility audit of everything under `/activity`: the nine exercise
/// hubs, manual entry, activity detail and edit, saved routes, route
/// suggestion, and the four live trackers.
///
/// Reports; does not gate — see `a11y_shell_tabs_audit_test.dart`.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_activity_screens_audit_test.dart`
void main() {
  final report = A11yReport('activity_screens');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  final hubs = [
    for (final type in ActivityType.values)
      if (type != ActivityType.other)
        A11yScreen(
          name: 'Hub ${type.label}',
          location: (_) => '/activity/hub/${type.toStorage()}',
        ),
  ];

  final detailScreens = <A11yScreen>[
    A11yScreen(name: 'Manual entry', location: (_) => '/activity/log'),
    A11yScreen(
      name: 'Activity detail',
      location: (ids) => '/activity/${ids.activityId}',
    ),
    A11yScreen(
      name: 'Activity edit',
      location: (ids) => '/activity/${ids.activityId}/edit',
    ),
    A11yScreen(name: 'Saved routes', location: (_) => '/activity/routes'),
    A11yScreen(
      name: 'Route detail',
      location: (ids) => '/activity/routes/${ids.routeId}',
    ),
    A11yScreen(
      name: 'Route suggest',
      location: (_) => '/activity/routes/suggest',
    ),
  ];

  final trackers = <A11yScreen>[
    A11yScreen(
      name: 'Strength tracker',
      location: (_) => '/activity/track/strength',
    ),
    A11yScreen(name: 'HIIT tracker', location: (_) => '/activity/track/hiit'),
    A11yScreen(
      name: 'Mindful tracker',
      location: (_) => '/activity/track/mindful',
    ),
    A11yScreen(name: 'Swim tracker', location: (_) => '/activity/track/swim'),
    A11yScreen(name: 'GPS record', location: (_) => '/activity/record'),
  ];

  void auditAll(List<A11yScreen> screens, List<A11yScenario> matrix) {
    for (final screen in screens) {
      for (final scenario in matrix) {
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

  // Nine hubs share one layout, so a full sweep of each would measure the
  // same widgets nine times. The short matrix brackets them; the detail
  // screens, which are all different, get the full one.
  auditAll(hubs, shortMatrix);
  auditAll(detailScreens, standardMatrix);
  auditAll(trackers, shortMatrix);
}
