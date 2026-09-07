import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'cycle tab -> start period -> status updates -> calendar renders -> '
    'info modal opens -> end period -> history records range',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;

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

      // Navigate to the Cycle tab.
      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Cycle')),
      );
      await tester.pumpAndSettle();

      // Verify top bar actions & initial state
      expect(find.text('Cycle'), findsWidgets);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.text('Start Period'), findsOneWidget);
      expect(find.text('Add Past Period'), findsOneWidget);
      expect(find.text('Logged period'), findsOneWidget); // Calendar legend
      expect(
        find.byKey(const Key('cycleConfidenceBadge')),
        findsOneWidget,
      );
      expect(find.text('Getting started'), findsOneWidget);

      // Test Info Modal
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text('About Cycle Tracking & Predictions'), findsOneWidget);
      expect(find.text('How Predictions Work'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Medical & Contraception Disclaimer'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Medical & Contraception Disclaimer'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Got it'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Start a period
      await tester.tap(find.text('Start Period'));
      await tester.pumpAndSettle();

      expect(find.text('Log your period'), findsOneWidget);
      final logDialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(of: logDialog, matching: find.text('Log period')),
      );
      await tester.pumpAndSettle();

      // Status card now shows Period Day 1, and End Period button is active
      expect(find.textContaining('Period · Day 1'), findsOneWidget);
      expect(find.text('End Period'), findsOneWidget);

      // End the period
      await tester.tap(find.text('End Period'));
      await tester.pumpAndSettle();

      expect(find.text('End your period'), findsOneWidget);
      final endDialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(of: endDialog, matching: find.text('End period')),
      );
      await tester.pumpAndSettle();

      // Back to tracking overview and history
      expect(find.text('Start Period'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('History'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('History'), findsOneWidget);
      expect(find.textContaining('1 day'), findsOneWidget);

      final rows = await database.select(database.cycleRecords).get();
      expect(rows, hasLength(1));
      expect(rows.single.periodEndDay, isNotNull);

      // Clean teardown flush
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'cycle options menu opens and renders all actions without overflow '
    'on narrow viewport',
    (tester) async {
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;

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

      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Cycle')),
      );
      await tester.pumpAndSettle();

      // Open cycle options menu
      final menuButton = find.byTooltip('Cycle Options');
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // All menu items should be rendered
      expect(
        find.text('Sync from Health Connect / Apple Health'),
        findsOneWidget,
      );
      expect(find.text('Import from CSV or JSON'), findsOneWidget);
      expect(find.text('Export Your Data'), findsOneWidget);
      expect(find.text('Settings and FAQs'), findsOneWidget);

      // Dismiss menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Clean teardown flush
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
