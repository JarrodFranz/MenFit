import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/widgets/fitness_dashboard_cards.dart';

void main() {
  testWidgets(
    'renders At a Glance fitness cards with steps and weekly volume',
    (tester) async {
      final now = DateTime.now();
      final activities = [
        Activity(
          id: EntityId.generate(),
          activityType: ActivityType.run,
          title: 'Morning Run',
          startedAt: now.subtract(const Duration(days: 1)),
          movingTime: const Duration(minutes: 30),
          elapsedTime: const Duration(minutes: 30),
          distanceMeters: 5000,
          source: ActivitySource.manual,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: FitnessDashboardCards(
                  activities: activities,
                  unitSystem: UnitSystem.metric,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('At a Glance'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Active Energy'), findsOneWidget);
      expect(find.text('Weekly Volume'), findsOneWidget);
      expect(find.text('5.00 km'), findsOneWidget);
      expect(find.textContaining('1 workouts'), findsOneWidget);
    },
  );

  testWidgets(
    'displays active energy burned from a walk logged today',
    (tester) async {
      final now = DateTime.now();
      final todayWalk = [
        Activity(
          id: EntityId.generate(),
          activityType: ActivityType.walk,
          title: 'Afternoon Walk',
          startedAt: now,
          movingTime: const Duration(minutes: 20),
          elapsedTime: const Duration(minutes: 20),
          distanceMeters: 1200,
          source: ActivitySource.manual,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: FitnessDashboardCards(
                  activities: todayWalk,
                  unitSystem: UnitSystem.metric,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Energy'), findsOneWidget);
      // Net active calories for a 20 min walk is ~30-40 kcal
      expect(find.textContaining('kcal'), findsAtLeastNWidgets(1));
      expect(find.text("From today's workouts"), findsOneWidget);
    },
  );
}
