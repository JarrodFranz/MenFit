import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';
import 'package:menfit_app/features/insights/insights_providers.dart';
import 'package:menfit_app/features/insights/insights_widgets.dart';

PersonalInsight _insight({
  InsightKind kind = InsightKind.proteinTargetNextDayOutput,
  InsightMetric metric = InsightMetric.strengthTonnageKg,
  int pairedObservations = 24,
}) {
  return PersonalInsight(
    kind: kind,
    metric: metric,
    higherGroup: InsightGroup.proteinTargetMet,
    lowerGroup: InsightGroup.proteinTargetNotMet,
    higherTypicalValue: 2280,
    lowerTypicalValue: 2000,
    higherGroupCount: 13,
    lowerGroupCount: 11,
    relativeDifference: 0.14,
    effectSize: 0.41,
    pairedObservations: pairedObservations,
    confidence: InsightConfidence.emerging,
    rangeStart: LocalDate(2026, 4, 2),
    rangeEnd: LocalDate(2026, 6, 28),
  );
}

Widget _app(List<PersonalInsight> insights, {int? maxInsights}) {
  return ProviderScope(
    overrides: [
      personalInsightsProvider.overrideWith((ref) async => insights),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Column(
          children: [
            const Text('above'),
            if (maxInsights == null)
              const InsightDiscoverySection()
            else
              InsightDiscoverySection(maxInsights: maxInsights),
            const Text('below'),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders nothing at all when there is no insight', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();

    expect(find.text('What your data shows'), findsNothing);
    expect(
      find.textContaining('logged days'),
      findsNothing,
      reason: 'no card, and no "keep logging to unlock this" nag either',
    );

    // Zero height: the empty state must not even leave its own spacing
    // behind between the widgets around it.
    final above = tester.getBottomLeft(find.text('above'));
    final below = tester.getTopLeft(find.text('below'));
    expect(above.dy, below.dy);
  });

  testWidgets('renders nothing while the insights are still loading', (
    tester,
  ) async {
    final pending = Completer<List<PersonalInsight>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          personalInsightsProvider.overrideWith((ref) => pending.future),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: InsightDiscoverySection()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('What your data shows'), findsNothing);

    // Let the pending future settle so the test doesn't leave a dangling
    // completer behind it.
    pending.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('a populated card shows the sentence including its n', (
    tester,
  ) async {
    await tester.pumpWidget(_app([_insight()]));
    await tester.pumpAndSettle();

    expect(find.text('What your data shows'), findsOneWidget);
    expect(
      find.textContaining('Across 24 logged days'),
      findsOneWidget,
      reason: 'the sample size always travels with the claim',
    );
    expect(find.textContaining('14% higher'), findsOneWidget);
    expect(find.textContaining('Emerging pattern'), findsOneWidget);
    expect(
      find.textContaining('not medical advice'),
      findsOneWidget,
      reason: 'health-adjacent findings can surface here (mens_health.md)',
    );
  });

  testWidgets('maxInsights narrows what is shown, e.g. Home showing one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app([
        _insight(),
        _insight(
          kind: InsightKind.sleepScoreSameDayOutput,
          metric: InsightMetric.runDistanceMeters,
          pairedObservations: 18,
        ),
      ], maxInsights: 1),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Across 24 logged days'), findsOneWidget);
    expect(find.textContaining('Across 18 logged days'), findsNothing);
  });
}
