import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/settings/presentation/settings_screen.dart';
import 'package:menfit_app/features/settings/presentation/widgets/garmin_connect_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'SettingsScreen shows Garmin Connect tile and opens instructions sheet',
    (
      tester,
    ) async {
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

      expect(find.text('Garmin Connect'), findsOneWidget);
      await tester.tap(find.text('Garmin Connect'));
      await tester.pumpAndSettle();

      expect(find.byType(GarminConnectSheet), findsOneWidget);
      expect(find.text('Garmin Connect Sync'), findsOneWidget);
      expect(find.text('Open the Garmin Connect app'), findsOneWidget);

      await tester.ensureVisible(find.text('Got it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(GarminConnectSheet), findsNothing);
    },
  );
}
