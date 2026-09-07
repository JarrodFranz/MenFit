import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/steps/steps_widgets.dart';

import 'steps_test_fakes.dart';

/// Regression guard for the hard-coded "Last 7d" row this strip replaced
/// (`fitness_dashboard_cards.dart`, before 2026-09-03): indices 0-3 always
/// rendered a tick and 4-5 always rendered grey, on every install, whatever
/// the user had walked. Every assertion here is about the markers coming
/// from data — a strip that ticks a day with no row fails.
void main() {
  final today = LocalDate.today();

  Future<void> pumpStrip(
    WidgetTester tester, {
    required FakeStepsRepository repository,
    int? todaySteps,
    int target = 7500,
    double? width,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    final strip = StepsWeekStrip(todaySteps: todaySteps);
    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: repository,
          sync: FakeStepsSync(),
          target: target,
        ),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: textScaler),
            child: Scaffold(
              body: width == null
                  ? strip
                  : Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(width: width, child: strip),
                    ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'seven markers fit the Steps glance card at 320dp and 150% text',
    (
      tester,
    ) async {
      // The glance card gives the strip ~108dp on a 320dp phone; before the
      // markers were given equal flexible slots their natural widths summed
      // to 108.5dp at 150% text (caught by the Activity 320dp layout guard).
      final repository = FakeStepsRepository([stepsRow(today, 10000)]);

      await pumpStrip(
        tester,
        repository: repository,
        width: 108,
        textScaler: const TextScaler.linear(1.5),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(6));
    },
  );

  testWidgets('ticks only days at or above target, and never a missing day', (
    tester,
  ) async {
    final repository = FakeStepsRepository([
      stepsRow(today.addDays(-6), 9000), // at/above target -> filled tick
      stepsRow(today.addDays(-5), 1000), // below target    -> filled dot
      // days -4 .. -1 have no row at all -> hollow ring
    ]);

    await pumpStrip(tester, repository: repository, todaySteps: 500);

    // -6 met the target; nothing else did.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    // -5 and today are recorded but below.
    expect(find.byIcon(Icons.circle), findsNWidgets(2));
    // -4, -3, -2, -1 were never synced.
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(4));
  });

  testWidgets('a day with no row is a hollow marker labelled "no data"', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FakeStepsRepository([stepsRow(today, 10000)]);

    await pumpStrip(tester, repository: repository);

    expect(find.bySemanticsLabel(RegExp('no data')), findsNWidgets(6));
    expect(find.bySemanticsLabel(RegExp('target reached')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('today takes the live count when it is the larger reading', (
    tester,
  ) async {
    // The stored row is this morning's reading of a day still accruing;
    // the live snapshot has since cleared the target.
    final repository = FakeStepsRepository([stepsRow(today, 200)]);

    await pumpStrip(tester, repository: repository, todaySteps: 9000);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsNothing);
  });

  testWidgets('a live count LOWER than the stored row keeps the stored row', (
    tester,
  ) async {
    // A day's count only accrues, so a smaller live reading is not a
    // correction - it is a failure. `health_providers.dart` falls back to
    // an empty snapshot when the platform returns null or throws, and the
    // dashboard passes `snapshot?.steps`, so a transient failure at 18:00
    // arrives here as a live `0`. Overwriting on it turned a target-met day
    // into a below-target dot on the home card while `/steps` still showed
    // 9,300 for the same date.
    final repository = FakeStepsRepository([stepsRow(today, 9300)]);

    await pumpStrip(tester, repository: repository, todaySteps: 0);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsNothing);
  });

  testWidgets('a live zero with no stored row is still "no data"', (
    tester,
  ) async {
    // Nothing has been synced for today, so the zero is the fabricated one
    // and there is no measurement to report. A filled "below target" dot
    // here would be a claim; a hollow ring is the absence of one.
    await pumpStrip(
      tester,
      repository: FakeStepsRepository(),
      todaySteps: 0,
    );

    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(7));
    expect(find.byIcon(Icons.circle), findsNothing);
  });

  testWidgets('a still-loading day gets its own glyph, not a "no data" ring', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await pumpStrip(tester, repository: FakeStepsRepository.pendingReads());

    // A dash, not a fainter ring: two rings differing only in opacity is
    // not a distinction anyone can see at 12dp.
    expect(find.byIcon(Icons.remove), findsNWidgets(7));
    expect(find.byIcon(Icons.circle_outlined), findsNothing);
    expect(find.bySemanticsLabel(RegExp('loading')), findsNWidgets(7));
    expect(find.bySemanticsLabel(RegExp('no data')), findsNothing);
    semantics.dispose();
  });

  testWidgets('exactly the target counts as reached', (tester) async {
    final repository = FakeStepsRepository([stepsRow(today.addDays(-1), 7500)]);

    await pumpStrip(tester, repository: repository);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('renders one marker per day of the last week', (tester) async {
    await pumpStrip(tester, repository: FakeStepsRepository());

    expect(find.byType(Icon), findsNWidgets(7));
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(7));
  });
}
