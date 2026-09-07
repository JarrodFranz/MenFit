import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'SettingsScreen renders Nutrition & Foods section and '
    'My Foods Catalogue tile',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tileFinder = find.text('My Foods Catalogue');
      await tester.scrollUntilVisible(tileFinder, 300);

      expect(find.text('Nutrition & Foods'), findsOneWidget);
      expect(tileFinder, findsOneWidget);
      expect(
        find.text('View, edit, and manage custom and saved foods'),
        findsOneWidget,
      );
    },
  );
}
