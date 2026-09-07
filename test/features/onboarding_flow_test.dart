import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'onboarding shows first when incomplete; finishing it creates a '
    'profile, persists the flag, and lands on home',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      // setMockInitialValues must be called exactly once per test - a
      // second call silently resets the in-memory backing store.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
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

      // Onboarding shows, not the home screen.
      expect(find.text('Welcome to FemFit'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);

      // Step 1 (welcome) -> step 2 (about you).
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('About you'), findsOneWidget);

      // An empty display name is rejected with a field error, not an
      // exception, and the step doesn't advance.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your name to continue.'), findsOneWidget);
      expect(find.text('About you'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Jordan');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3 (optional "Tell us a little more") - skippable via a
      // dedicated Skip affordance, distinct from Continue.
      expect(find.text('Tell us a little more'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Step 4 (privacy).
      expect(find.text('Your privacy'), findsOneWidget);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Lands on home (the redirect fires now that onboarding is complete).
      expect(find.textContaining('Welcome back'), findsOneWidget);
      expect(find.text('Welcome to FemFit'), findsNothing);

      // The profile row exists, with the entered name, and no goal since
      // the optional step was skipped.
      final rows = await database.select(database.userProfiles).get();
      expect(rows, hasLength(1));
      expect(rows.single.displayName, 'Jordan');
      expect(rows.single.fitnessGoal, isNull);
      expect(rows.single.runningExperience, isNull);

      // The onboarding-complete flag is persisted.
      expect(prefs.getBool('onboarding_complete'), isTrue);

      // Flush Drift's stream-cleanup timers under a pump we control before
      // the framework's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'choosing a goal and running experience on the optional step persists '
    'them onto the created profile',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
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

      await tester.tap(find.text('Continue')); // welcome -> about you
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.tap(find.text('Continue')); // about you -> more about you
      await tester.pumpAndSettle();

      expect(find.text('Tell us a little more'), findsOneWidget);
      await tester.tap(find.text('Run further'));
      await tester.tap(find.text('Regular'));
      await tester.tap(find.text('Continue')); // -> privacy
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Welcome back'), findsOneWidget);

      final rows = await database.select(database.userProfiles).get();
      expect(rows, hasLength(1));
      expect(rows.single.fitnessGoal, 'runFurther');
      expect(rows.single.runningExperience, 'regular');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'system back navigates backward within onboarding steps',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
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

      expect(find.text('Welcome to FemFit'), findsOneWidget);

      // Advance to step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('About you'), findsOneWidget);

      // Simulate Android system back button
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should return to step 1
      expect(find.text('Welcome to FemFit'), findsOneWidget);
    },
  );
}
