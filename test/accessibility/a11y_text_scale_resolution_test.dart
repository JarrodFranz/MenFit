import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How `App.builder` resolves the OS font scale against the in-app text
/// preset.
///
/// The rule under test: **the app never renders text smaller than the
/// system asked for.** Before this file existed, `app.dart` used the in-app
/// preset whenever it was above 1.0, so a user running Android at 130% who
/// then chose "Large (115%)" in the app got *smaller* text than before they
/// touched the setting — an accessibility control that reduced
/// accessibility, and exactly the kind of defect no screenshot review
/// catches because both states look plausible on their own.
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.clearTextScaleFactorTestValue();
  });

  Future<double> effectiveScale(
    WidgetTester tester, {
    required double osScale,
    required TextScalePreset preset,
  }) async {
    tester.platformDispatcher.textScaleFactorTestValue = osScale;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    await AccessibilityRepository(
      prefs,
    ).setPreferences(AccessibilityPreferences(textScale: preset));

    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    // Read the scaler the app installed, from inside the routed subtree.
    final context = tester.element(find.byType(Scaffold).first);
    final scale = MediaQuery.of(context).textScaler.scale(1);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
    return scale;
  }

  testWidgets('the OS scale is honoured when the app preset is Normal', (
    tester,
  ) async {
    expect(
      await effectiveScale(
        tester,
        osScale: 1.3,
        preset: TextScalePreset.system,
      ),
      closeTo(1.3, 0.001),
    );
  });

  testWidgets('a smaller in-app preset never shrinks text below the OS', (
    tester,
  ) async {
    expect(
      await effectiveScale(
        tester,
        osScale: 1.3,
        preset: TextScalePreset.large,
      ),
      closeTo(1.3, 0.001),
      reason:
          'OS 130% + app "Large (115%)" must stay at 130%. Resolving to '
          '1.15 would make choosing a larger in-app size shrink the text.',
    );
  });

  testWidgets('a larger in-app preset raises the OS scale', (tester) async {
    expect(
      await effectiveScale(
        tester,
        osScale: 1,
        preset: TextScalePreset.huge,
      ),
      closeTo(1.5, 0.001),
    );
  });

  testWidgets('the two scales are not multiplied together', (tester) async {
    // 2.0 x 1.5 = 3.0 would be unreadable and is not what either the OS or
    // the preset asked for; the stronger of the two requests is 2.0.
    expect(
      await effectiveScale(
        tester,
        osScale: 2,
        preset: TextScalePreset.huge,
      ),
      closeTo(2, 0.001),
    );
  });
}
