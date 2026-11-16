import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/keto/presentation/keto_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [400.0, 1280.0]) {
    testWidgets('Keto is a separate shell destination at $width', (
      tester,
    ) async {
      tester.view
        ..physicalSize = Size(width, 1000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      final navigation = width < 600
          ? find.byType(NavigationBar)
          : find.byType(NavigationRail);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Keto')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(KetoScreen), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      );
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/keto',
      );
      expect(find.text('Add reading'), findsOneWidget);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Recovery')),
      );
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/recovery',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
