import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/home/domain/home_today_overview.dart';
import 'package:menfit_app/features/home/presentation/home_overview_controller.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_overview_card.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required HomeTodayOverview overview,
  }) async {
    tester.view
      ..physicalSize = const Size(420, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTodayOverviewProvider.overrideWith(
            (ref) => Stream.value(overview),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: TodayOverviewCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('states an untouched day plainly', (tester) async {
    await pumpCard(
      tester,
      overview: const HomeTodayOverview(
        checkinLogged: false,
        isRecoveryDay: false,
        workoutsToday: 0,
      ),
    );

    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Not yet'), findsOneWidget);
    expect(find.text('Recovery'), findsOneWidget);
    expect(find.text('Not marked'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('states a busy day', (tester) async {
    await pumpCard(
      tester,
      overview: const HomeTodayOverview(
        checkinLogged: true,
        isRecoveryDay: true,
        workoutsToday: 2,
      ),
    );

    expect(find.text('Logged'), findsOneWidget);
    expect(find.text('Marked'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('says it is still checking rather than reporting zeros', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTodayOverviewProvider.overrideWith(
            (ref) => const Stream<HomeTodayOverview>.empty(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TodayOverviewCard()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Checking today'), findsOneWidget);
    expect(find.text('Not yet'), findsNothing);
  });
}
