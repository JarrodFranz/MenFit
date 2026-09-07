import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/hub/hub_activity_card.dart';

void main() {
  group('EmptyHubActivitiesCard', () {
    Widget buildSubject(ActivityType type) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: EmptyHubActivitiesCard(type: type),
        ),
      );
    }

    testWidgets('renders swim icon and label for swim hub', (tester) async {
      await tester.pumpWidget(buildSubject(ActivityType.swim));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pool_outlined), findsOneWidget);
      expect(find.text('No Swim activities logged yet.'), findsOneWidget);
    });

    testWidgets('renders run icon and label for run hub', (tester) async {
      await tester.pumpWidget(buildSubject(ActivityType.run));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_run_outlined), findsOneWidget);
      expect(find.text('No Run activities logged yet.'), findsOneWidget);
    });

    testWidgets('renders yoga icon and label for yoga hub', (tester) async {
      await tester.pumpWidget(buildSubject(ActivityType.yoga));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.self_improvement_outlined), findsOneWidget);
      expect(find.text('No Yoga activities logged yet.'), findsOneWidget);
    });
  });
}
