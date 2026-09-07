import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/widgets/adaptive_scaffold.dart';

const List<AdaptiveDestination> _destinations = [
  AdaptiveDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'A',
  ),
  AdaptiveDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'B',
  ),
];

/// Six long single-word labels — the shape that wraps mid-word on a
/// phone-width [NavigationBar] (see `AppAdaptiveScaffold._compactLabelStyle`).
const List<AdaptiveDestination> _sixLongDestinations = [
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
    icon: Icons.favorite_outline,
    selectedIcon: Icons.favorite,
    label: 'Cycle',
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

GoRouter _buildTestRouter({
  List<AdaptiveDestination> destinations = _destinations,
}) {
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
                builder: (context, state) => const Text('Branch A'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (context, state) => const Text('Branch B'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'shows a NavigationBar and no NavigationRail at compact width',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: _buildTestRouter()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    },
  );

  // NOTE: these tests assert the label *style* the scaffold applies, not
  // whether text visually wraps. Widget tests run with `--use-test-fonts`,
  // whose glyphs are fixed-width boxes roughly one em wide - "Nutrition"
  // measures ~9x the font size there versus roughly half that in the real
  // proportional font. Any assertion about wrapping would therefore be
  // measuring Ahem, not the shipped UI. Wrapping is measured against the
  // real bundled Inter in `adaptive_scaffold_real_font_test.dart` instead.
  testWidgets('crowded bar shrinks the label style on a small phone', (
    tester,
  ) async {
    // 320dp is where six destinations genuinely stop fitting at full size -
    // see the real-font measurements in
    // `adaptive_scaffold_real_font_test.dart`. At 375dp they fit, and this
    // scaffold deliberately leaves the style alone there.
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: _buildTestRouter(destinations: _sixLongDestinations),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Wellbeing'),
      ),
    );
    // 320 / 6 = 53.3dp per cell, below the 62dp comfort threshold.
    expect(
      paragraph.text.style?.fontSize,
      lessThan(12),
      reason:
          'six destinations on a 320dp screen leave 53.3dp each - the '
          'default 12sp label needs to give ground',
    );
    expect(
      paragraph.text.style?.fontSize,
      greaterThanOrEqualTo(9),
      reason: 'never shrink past legibility - fewer tabs is the real fix',
    );
  });

  testWidgets('an uncrowded bar keeps the default label size', (tester) async {
    tester.view
      ..physicalSize = const Size(375, 812)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _buildTestRouter()),
    );
    await tester.pumpAndSettle();

    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('A')),
    );
    expect(
      paragraph.text.style?.fontSize,
      12,
      reason:
          'with room to spare the label style must be left alone - shrinking '
          'is a last resort for crowded bars, not the default',
    );
  });

  testWidgets(
    'shows a NavigationRail and no NavigationBar at expanded width',
    (tester) async {
      tester.view
        ..physicalSize = const Size(1400, 900)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: _buildTestRouter()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );
}
