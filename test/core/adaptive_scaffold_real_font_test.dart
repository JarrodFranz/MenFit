import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/adaptive_scaffold.dart';

/// Does the five-destination bottom bar actually fit on a phone?
///
/// Ordinary widget tests cannot answer this. They run with
/// `--use-test-fonts`, whose glyphs are fixed-width boxes about one em
/// wide — "Nutrition" measures ~110px at 12sp there and still ~65px at 7sp,
/// so it "wraps" at every font size regardless of reality (see the central
/// `testing-pitfalls.md`). Every wrapping assertion under that font is
/// measuring Ahem, not the shipped UI.
///
/// This file loads the app's real bundled Inter and measures against it, so
/// the answer means something. Keep wrapping assertions in THIS file, and
/// nowhere else.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytes = await File('assets/fonts/Inter.ttf').readAsBytes();
    final loader = FontLoader(AppTheme.fontFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// The shipped destination list, kept in step with
  /// `app/router/routes.dart`'s `AppShellRouteData.destinations`.
  const destinations = [
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AdaptiveDestination(
      icon: Icons.directions_run_outlined,
      selectedIcon: Icons.directions_run,
      label: 'Activity',
    ),
    AdaptiveDestination(
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant,
      label: 'Nutrition',
    ),
    AdaptiveDestination(
      icon: Icons.spa_outlined,
      selectedIcon: Icons.spa,
      label: 'Wellbeing',
    ),
    AdaptiveDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppAdaptiveScaffold(
            navigationShell: navigationShell,
            destinations: destinations,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/a',
                  builder: (context, state) => const Text('Body'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: buildRouter(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectNoWrap(WidgetTester tester, String label) {
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    // Height with width unconstrained is by definition the one-line height.
    final oneLine = paragraph.getMinIntrinsicHeight(double.infinity);
    expect(
      paragraph.size.height,
      lessThanOrEqualTo(oneLine + 0.5),
      reason:
          '"$label" wraps at this width. Material\'s bottom-bar label has '
          'no ellipsis and no hyphenation, so a wrap breaks the word '
          'mid-way ("Wellb / eing"). Either the label shrink in '
          'AppAdaptiveScaffold needs to go further, or five tabs is one '
          'too many for this width and Settings should move to an app-bar '
          'action.',
    );
  }

  testWidgets('five labels fit on one line at 375dp (small phone)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));
    for (final destination in destinations) {
      expectNoWrap(tester, destination.label);
    }
  });

  testWidgets('five labels fit on one line at 320dp (smallest supported)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(320, 640));
    for (final destination in destinations) {
      expectNoWrap(tester, destination.label);
    }
  });

  testWidgets('five labels fit on one line at 412dp (large phone)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(412, 915));
    for (final destination in destinations) {
      expectNoWrap(tester, destination.label);
    }
  });
}
