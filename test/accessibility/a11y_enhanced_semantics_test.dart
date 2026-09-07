import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';

import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';
import 'harness/a11y_scenarios.dart';
import 'harness/a11y_seed.dart';

/// Proves the **Enhanced Semantics** preference does what its dartdoc and
/// its switch say: "detailed TalkBack / VoiceOver descriptions for charts
/// ... and calendar days".
///
/// This file gates, and it gates on the *whole path* — preference written
/// through the real `AccessibilityRepository`, read by the real controller,
/// carried through the real screens to the real widgets — because the bug
/// it exists to stop was never "the label is wrong", it was "nothing reads
/// the preference at all". A widget test that passes the flag in by hand
/// could not have caught that.
///
/// Both directions are asserted. A verbose description that cannot be
/// turned off is its own accessibility problem, so every "appears when on"
/// assertion is paired with "absent when off".
///
/// What each description *says* is pinned deterministically elsewhere, on
/// the widgets themselves and on the pure functions that build the
/// sentences — `test/features/cycle/cycle_day_semantics_test.dart`,
/// `test/features/cycle/cycle_calendar_semantics_test.dart`,
/// `test/features/progress/weekly_distance_semantics_test.dart` and
/// `test/features/weight/weight_trend_chart_semantics_test.dart`. This file
/// deliberately asserts only what those cannot: that the preference
/// reaches them at all.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_enhanced_semantics_test.dart`
void main() {
  final report = A11yReport('enhanced_semantics');

  setUpAll(loadRealAppFont);
  tearDownAll(report.write);

  /// Audits [screen] under both settings, asserting [pattern] is announced
  /// only under the second.
  void expectDescribedOnlyWhenOn({
    required String name,
    required String Function(SeededIds ids) location,
    required Pattern pattern,
    required String what,
    Future<void> Function(WidgetTester tester)? reveal,
  }) {
    for (final scenario in [enhancedSemanticsOff, enhancedSemanticsOn]) {
      final expectsDescription = scenario == enhancedSemanticsOn;
      testWidgets('$name $what @ ${scenario.label}', (tester) async {
        // Counted inside the pump and asserted after it: `auditScreen`
        // turns anything thrown in `afterNavigate` into a *finding*, which
        // is right for an audit and wrong for a gate — an `expect` in there
        // would be swallowed and the test would pass while reporting the
        // failure in a markdown table nobody is watching.
        var matches = -1;
        await auditScreen(
          tester,
          report: report,
          screen: A11yScreen(
            name: name,
            location: location,
            afterNavigate: (tester) async {
              if (reveal != null) {
                await reveal(tester);
                await tester.pumpAndSettle();
              }
              matches = tester
                  .widgetList(find.bySemanticsLabel(pattern))
                  .length;
            },
          ),
          scenario: scenario,
        );

        expect(matches, isNot(-1), reason: 'the screen never rendered');
        expect(
          matches > 0,
          expectsDescription,
          reason: expectsDescription
              ? '$what should describe itself in words when Enhanced '
                    'Semantics is on; found no node matching $pattern'
              : '$what must stay quiet when the preference is off — the '
                    'description is verbose by design',
        );
      });
    }
  }

  expectDescribedOnlyWhenOn(
    name: 'Progress',
    location: (_) => '/home/progress',
    pattern: RegExp('bars, one per week'),
    what: 'weekly distance chart',
    // The chart is only mounted for the Week period (see
    // `progress_activity_card.dart`), so the audit has to select it —
    // otherwise this passes vacuously in both directions.
    reveal: (tester) => tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<ProgressPeriod>),
        matching: find.text('Week'),
      ),
    ),
  );

  expectDescribedOnlyWhenOn(
    name: 'Weight',
    location: (_) => '/weight',
    pattern: RegExp('readings. from .* to '),
    what: 'weight trend chart',
  );

  expectDescribedOnlyWhenOn(
    name: 'Cycle',
    location: (_) => '/cycle',
    pattern: RegExp(r'Estimated \w+ phase'),
    what: 'calendar days',
  );
}
