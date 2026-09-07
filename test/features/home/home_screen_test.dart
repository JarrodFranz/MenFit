import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/home/presentation/home_screen.dart';
import 'package:menfit_app/features/home/presentation/widgets/macros_today_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/progress_summary_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/recent_achievement_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_overview_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_session_card.dart';
import 'package:menfit_app/features/home/presentation/widgets/water_quick_add_card.dart';
import 'package:menfit_app/features/steps/steps_widgets.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;

const _unstartedStreak = StreakResult(
  currentStreak: 0,
  longestStreak: 0,
  todayStatus: DayStatus.unscheduled,
  todaySatisfied: false,
);

void main() {
  /// Pumps the dashboard on its own (no router), over an in-memory
  /// database so every Drift-backed card on it resolves to a real, empty
  /// day rather than to whatever is on the machine running the test.
  ///
  /// **Every caller must end its test body with
  /// `await flushDriftTimers(tester);`** — see the note on
  /// [flushDriftTimers]'s use below. It cannot be done for them here.
  Future<void> pumpDashboard(
    WidgetTester tester, {
    StreakResult streak = _unstartedStreak,
    Size surface = const Size(420, 1600),
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    tester.view
      ..physicalSize = surface
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    // Deliberately NOT `addTearDown(() => flushDriftTimers(tester))`: a
    // tear-down runs *after* the binding's "a Timer is still pending"
    // invariant check, so flushing there is always too late. The flush has
    // to be the last statement of the test body itself.

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          streakResultProvider.overrideWith((ref) => Stream.value(streak)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            // copyWith, not a bare MediaQueryData: replacing the whole
            // thing would zero the view size and every layout with it.
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: const HomeScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps the real `App` — router included — so a card's `onTap` has
  /// somewhere to navigate to. Same override shape as
  /// `test/features/activity_flow_test.dart`.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(420, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the redesigned dashboard', () {
    testWidgets("shows today's session card above today's six cards", (
      tester,
    ) async {
      await pumpDashboard(tester);

      // Strength-first: the session card is the first card on the page,
      // above the two-column grid.
      expect(find.byType(TodaySessionCard), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(TodaySessionCard)).dy,
        lessThan(tester.getTopLeft(find.byType(MacrosTodayCard)).dy),
      );

      expect(find.byType(StepsRingCard), findsOneWidget);
      expect(find.byType(WaterQuickAddCard), findsOneWidget);
      expect(find.byType(MacrosTodayCard), findsOneWidget);
      expect(find.byType(ProgressSummaryCard), findsOneWidget);
      expect(find.byType(RecentAchievementCard), findsOneWidget);
      expect(find.byType(TodayOverviewCard), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets(
      'no longer carries the quick launchers or the Explore & Track grid',
      (tester) async {
        await pumpDashboard(tester);

        // The two quick launchers.
        expect(find.text('Strength Tracker'), findsNothing);
        expect(find.text('Record GPS Run'), findsNothing);

        // The grid and its three tiles. `find.text` is an exact match, so
        // 'Nutrition' does not match the 'Nutrition today' card title -
        // which is the point: the tile is gone, the card is not.
        expect(find.text('Explore & Track'), findsNothing);
        expect(find.byType(GridView), findsNothing);
        expect(find.text('Nutrition'), findsNothing);
        expect(find.text('Cycle'), findsNothing);
        expect(find.text('Progress'), findsNothing);

        await flushDriftTimers(tester);
      },
    );

    testWidgets('keeps the streak banner and its protected state', (
      tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.text('Log an activity to start your streak'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('shows the normal streak card', (tester) async {
      await pumpDashboard(
        tester,
        streak: const StreakResult(
          currentStreak: 4,
          longestStreak: 9,
          todayStatus: DayStatus.unscheduled,
          todaySatisfied: false,
        ),
      );

      expect(find.text('4-day streak'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('shows the protected streak card', (tester) async {
      await pumpDashboard(
        tester,
        streak: const StreakResult(
          currentStreak: 6,
          longestStreak: 6,
          todayStatus: DayStatus.protectedRecovery,
          todaySatisfied: false,
        ),
      );

      expect(
        find.text('Recovery day — your 6-day streak is safe'),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('names no cycle phase', (tester) async {
      // The recovery banner is deliberately reason-silent (S1-2 ruling in
      // `streak_card.dart`), and the redesign must not have smuggled a
      // phase word onto the dashboard through the new "Today" card.
      await pumpDashboard(
        tester,
        streak: const StreakResult(
          currentStreak: 3,
          longestStreak: 3,
          todayStatus: DayStatus.protectedRecovery,
          todaySatisfied: false,
        ),
      );

      for (final phaseWord in [
        'Menstrual',
        'Follicular',
        'Ovulatory',
        'Luteal',
        'Period',
      ]) {
        expect(
          find.textContaining(phaseWord, findRichText: true),
          findsNothing,
          reason: '"$phaseWord" must not appear on the home dashboard',
        );
      }

      await flushDriftTimers(tester);
    });

    testWidgets('survives 320dp at 150% text without overflowing', (
      tester,
    ) async {
      await pumpDashboard(
        tester,
        surface: const Size(320, 2400),
        textScaler: const TextScaler.linear(1.5),
      );

      expect(tester.takeException(), isNull);

      await flushDriftTimers(tester);
    });

    testWidgets('lays the cards out in two columns at expanded width', (
      tester,
    ) async {
      await pumpDashboard(tester, surface: const Size(1000, 1600));

      // Cards alternate between the two columns in order, so the first
      // (Macros) and the second (Water) sit side by side rather than
      // stacked.
      final macros = tester.getTopLeft(find.byType(MacrosTodayCard));
      final water = tester.getTopLeft(find.byType(WaterQuickAddCard));

      expect(water.dx, greaterThan(macros.dx));
      expect((water.dy - macros.dy).abs(), lessThan(1));

      await flushDriftTimers(tester);
    });

    testWidgets('stacks the cards in one column on a phone', (tester) async {
      await pumpDashboard(tester, surface: const Size(400, 2400));

      final macros = tester.getTopLeft(find.byType(MacrosTodayCard));
      final water = tester.getTopLeft(find.byType(WaterQuickAddCard));

      expect(water.dx, macros.dx);
      expect(water.dy, greaterThan(macros.dy));

      await flushDriftTimers(tester);
    });
  });

  group('dashboard navigation', () {
    testWidgets('tapping the steps card opens the daily steps history', (
      tester,
    ) async {
      await pumpApp(tester);

      final card = find.byType(StepsRingCard);
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Steps'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('tapping the week card opens Progress', (tester) async {
      await pumpApp(tester);

      final card = find.byType(ProgressSummaryCard);
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Checked via the AppBar title plus a section heading unique to that
      // screen - the nav bar carries a 'Progress' label of its own.
      expect(find.widgetWithText(AppBar, 'Progress'), findsOneWidget);
      expect(find.text('Personal records'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('tapping the nutrition card opens the food diary tab', (
      tester,
    ) async {
      await pumpApp(tester);

      final card = find.byType(MacrosTodayCard);
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Nutrition'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets(
      "the session card's empty state opens the Strength hub",
      (tester) async {
        // The real (empty) database means no cycle is active, which is the
        // state that offers 'Start a routine'.
        await pumpApp(tester);

        final button = find.text('Start a routine');
        expect(button, findsOneWidget);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.text('Strength Hub'), findsOneWidget);

        await flushDriftTimers(tester);
      },
    );
  });
}
