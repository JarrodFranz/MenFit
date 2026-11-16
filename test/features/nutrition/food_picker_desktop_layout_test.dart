import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers;

/// The food picker at a **desktop browser window size**.
///
/// Every other test of this screen renders it at 500x1600 — a phone. The one
/// barcode path web and Windows have is an app-bar action, and an app bar is
/// exactly the kind of thing that can lay out differently once there is a
/// navigation rail beside it, so "the button exists" needs asserting at the
/// width people actually run the desktop build at.
void main() {
  late db.AppDatabase database;

  setUp(() => database = db.AppDatabase.forTesting(NativeDatabase.memory()));

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets('the barcode actions are present and tappable at 1595x624', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1595, 624)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

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

    await tester.tap(find.text('Nutrition').first);
    await tester.pumpAndSettle();
    final addFood = find.byKey(const Key('addFood-breakfast'));
    for (var i = 0; i < 10 && addFood.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(addFood);
    await tester.pumpAndSettle();
    await tester.tap(addFood);
    await tester.pumpAndSettle();

    expect(find.text('Add to breakfast'), findsOneWidget);

    // The only barcode path a browser has.
    final enterBarcode = find.byKey(const Key('enterBarcodeAction'));
    expect(enterBarcode, findsOneWidget, reason: 'manual entry is always on');

    // Present is not the same as reachable: an action pushed off the right
    // edge, or covered, still "exists" as far as a finder is concerned.
    final button = tester.getRect(enterBarcode);
    final screen = tester.getRect(find.byType(MaterialApp));
    expect(
      screen.contains(button.center),
      isTrue,
      reason: 'action centre $button must lie inside the window $screen',
    );
    expect(
      tester.widget<IconButton>(enterBarcode).onPressed,
      isNotNull,
      reason: 'not disabled while idle',
    );

    // And it does something: tapping opens the manual-entry dialog.
    await tester.tap(enterBarcode);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('barcodeEntryField')), findsOneWidget);

    await flushDriftTimers(tester);
  });
}
