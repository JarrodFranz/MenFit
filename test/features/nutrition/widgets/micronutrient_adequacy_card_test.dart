import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/micronutrient_adequacy.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/micronutrient_adequacy_card.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/micronutrient_info_sheet.dart';

void main() {
  testWidgets('renders micronutrient card and primary nutrients', (
    tester,
  ) async {
    const totals = NutritionTotals(
      entryCount: 2,
      facts: NutritionFacts(
        ironMg: 4,
        calciumMg: 800,
        vitaminDMcg: 10,
        fiberGrams: 18,
        vitaminCMg: 60,
      ),
      ironIsPartial: true,
    );

    final items = evaluateMicronutrientAdequacy(totals: totals);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: MicronutrientAdequacyCard(items: items),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('micronutrientAdequacyCard')), findsOneWidget);
    expect(find.text('Micronutrient Adequacy'), findsOneWidget);

    // Primary nutrients
    expect(find.text('Iron'), findsOneWidget);
    expect(find.text('Calcium'), findsOneWidget);
    expect(find.text('Vitamin D'), findsOneWidget);
    expect(find.text('Partial floor'), findsOneWidget); // Iron is partial

    // Secondary items hidden initially
    expect(find.text('Fiber'), findsNothing);
    expect(find.text('Vitamin C'), findsNothing);

    // Tap to expand
    await tester.tap(find.byKey(const Key('toggleMoreNutrientsButton')));
    await tester.pumpAndSettle();

    expect(find.text('Fiber'), findsOneWidget);
    expect(find.text('Vitamin C'), findsOneWidget);
    expect(find.text('Show fewer nutrients'), findsOneWidget);

    // Open info sheet
    await tester.tap(find.byKey(const Key('micronutrientInfoButton')));
    await tester.pumpAndSettle();

    expect(find.byType(MicronutrientInfoSheet), findsOneWidget);
    expect(find.text('Micronutrients & Recovery'), findsOneWidget);
    expect(find.textContaining('Not medical advice'), findsOneWidget);

    // Close info sheet
    await tester.tap(find.byKey(const Key('micronutrientInfoCloseButton')));
    await tester.pumpAndSettle();

    expect(find.byType(MicronutrientInfoSheet), findsNothing);
  });
}
