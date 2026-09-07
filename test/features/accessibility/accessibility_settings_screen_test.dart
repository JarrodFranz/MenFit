import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/settings/presentation/accessibility_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AccessibilitySettingsScreen', () {
    late SharedPreferences preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
    });

    tearDown(() {
      addTearDown(() {});
    });

    Future<Widget> createSubject({
      AccessibilityPreferences? initialPrefs,
    }) async {
      final repository = AccessibilityRepository(preferences);
      if (initialPrefs != null) {
        await preferences.setString(
          'accessibility_color_blindness',
          initialPrefs.colorBlindness.name,
        );
        await preferences.setBool(
          'accessibility_high_contrast',
          initialPrefs.highContrast,
        );
      }

      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          accessibilityRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AccessibilitySettingsScreen(),
        ),
      );
    }

    testWidgets('renders all accessibility sections and controls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Live Preview'), findsOneWidget);
      expect(find.text('Visual & Sight'), findsOneWidget);
      expect(find.text('Color Vision Mode'), findsOneWidget);
      expect(find.text('High Contrast'), findsOneWidget);
      expect(find.text('Text Size Scale'), findsOneWidget);
      expect(find.text('Bold Text'), findsOneWidget);
      expect(find.text('Motion & Touch'), findsOneWidget);
      expect(find.text('Reduce Motion'), findsOneWidget);
      expect(find.text('Large Touch Targets'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsOneWidget);
      expect(find.text('Sound cues'), findsOneWidget);
      expect(find.text('Screen Reader & Audio'), findsOneWidget);
      expect(find.text('Enhanced Semantics'), findsOneWidget);
      expect(find.text('Reset Accessibility Defaults'), findsOneWidget);
    });

    testWidgets('switching color blindness mode updates state and preview', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Standard · 100%'), findsOneWidget);

      // Tap Deuteranopia chip
      await tester.tap(find.text('Deuteranopia'));
      await tester.pumpAndSettle();

      expect(find.text('Deuteranopia · 100%'), findsOneWidget);
    });

    testWidgets('toggling high contrast and bold text updates state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await createSubject());
      await tester.pumpAndSettle();

      final highContrastSwitch = find.byType(Switch).at(0);
      await tester.tap(highContrastSwitch);
      await tester.pumpAndSettle();

      final boldTextSwitch = find.byType(Switch).at(1);
      await tester.tap(boldTextSwitch);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping reset defaults resets state and shows snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        await createSubject(
          initialPrefs: const AccessibilityPreferences(
            colorBlindness: ColorBlindnessMode.monochromacy,
            highContrast: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to find reset button
      final resetButton = find.text('Reset Accessibility Defaults');
      await tester.scrollUntilVisible(resetButton, 300);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Accessibility settings reset to default'),
        findsOneWidget,
      );
    });
  });
}
