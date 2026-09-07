import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    "log a flare via the sheet's flare button -> appears on wellbeing "
    'history; category left unset stays null; delete removes it',
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

      // Open the check-in sheet, then log a flare from inside it.
      await tester.tap(find.text('Check in'));
      await tester.pumpAndSettle();

      final logFlareButton = find.text('Log a flare-up');
      await tester.ensureVisible(logFlareButton);
      await tester.tap(logFlareButton);
      await tester.pumpAndSettle();

      expect(find.byType(FlareDialog), findsOneWidget);

      // The dialog's content can be taller than the viewport - scroll each
      // field into view within its `SingleChildScrollView` before tapping.
      Future<void> tapInDialog(String text) async {
        final finder = find.descendant(
          of: find.byType(FlareDialog),
          matching: find.text(text),
        );
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump();
      }

      // Severity.
      await tapInDialog('Moderate');

      // A symptom.
      await tapInDialog('Bloating');

      // Impact.
      await tapInDialog('Reduced my training');

      // Category is deliberately left unset ("Prefer not to say").
      await tapInDialog('Log flare-up');
      await tester.pumpAndSettle();

      // The flare dialog closed; the check-in sheet (still empty - never
      // saved) is still open behind it. Close it too.
      expect(find.byType(FlareDialog), findsNothing);
      expect(find.byType(CheckinSheet), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(CheckinSheet),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CheckinSheet), findsNothing);

      // A fully-empty check-in is a no-op - only the flare was persisted.
      expect(await database.select(database.dailyCheckins).get(), isEmpty);

      final flareRows = await database.select(database.flareEvents).get();
      expect(flareRows, hasLength(1));
      expect(flareRows.single.severity, 'moderate');
      expect(flareRows.single.impact, 'reducedTraining');
      expect(flareRows.single.symptoms, 'bloating');
      expect(
        flareRows.single.category,
        isNull,
        reason: 'category was left unset - never required',
      );

      // The home card shows a flare chip today.
      expect(find.text('Flare-up logged'), findsOneWidget);

      // It appears on the wellbeing history screen.
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.byType(WellbeingScreen), findsOneWidget);
      // Scoped to the history CARD. The tab now also carries a calendar
      // whose legend names the same glyph vocabulary the cards use, so a
      // bare `textContaining('Flare-up')` matches the legend item as well
      // and no longer says which one this test means.
      final flareCardTitle = find.descendant(
        of: find.byType(FlareTile),
        matching: find.textContaining('Flare-up'),
      );
      expect(flareCardTitle, findsOneWidget);
      expect(find.textContaining('Moderate'), findsOneWidget);
      expect(find.textContaining('Reduced my training'), findsOneWidget);

      // Tap through to edit/delete it.
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(flareCardTitle);
      await tester.pumpAndSettle();

      expect(find.byType(FlareDialog), findsOneWidget);
      await tapInDialog('Delete');
      await tester.pumpAndSettle();

      expect(find.text('Delete this flare-up?'), findsOneWidget);
      // Both the confirm dialog and the flare dialog behind it are
      // `AlertDialog`s at this point - scope to the confirm dialog
      // specifically by its title (testing-pitfalls.md: an unscoped
      // `find.text('Delete')` here would match both dialogs' buttons).
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(AlertDialog, 'Delete this flare-up?'),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlareDialog), findsNothing);
      expect(await database.select(database.flareEvents).get(), isEmpty);
      expect(
        find.text(
          'Nothing logged yet. Check-ins are optional — they help the '
          'app adapt to you.',
        ),
        findsOneWidget,
      );

      // Flush Drift's stream-cleanup timers under a pump we control before
      // flutter_test's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
