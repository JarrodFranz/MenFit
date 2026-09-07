import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_screen.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'award_detector_test.dart' show FakeAwardRepository;

/// The real `/achievements` route (generated from [AchievementsRouteData])
/// plus a stand-in for the Progress screen it is pushed from, so the route
/// can be exercised without dragging the six-branch shell and its
/// database-backed screens into the test.
GoRouter _buildRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      $achievementsRouteData,
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('home stub')),
        routes: [
          GoRoute(
            path: 'progress',
            builder: (context, state) =>
                const Scaffold(body: Text('progress stub')),
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('/achievements resolves to the trophy case', (tester) async {
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          awardRepositoryProvider.overrideWithValue(FakeAwardRepository()),
          badgeProgressProvider.overrideWith(
            (ref) async => const <BadgeProgress>[],
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _buildRouter(initialLocation: '/achievements'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AchievementsScreen), findsOneWidget);
    expect(find.text(achievementsScreenTitle), findsOneWidget);

    await flushDriftTimers(tester);
  });

  test('the route is root-level, so it is reachable as a deep link', () {
    // The location the Progress card pushes is the same string a cold deep
    // link arrives on - if this ever became a shell-nested path it would
    // silently stop matching (and, per the dartdoc on the route, would
    // reintroduce the root-navigator GlobalKey crash).
    expect(const AchievementsRouteData().location, '/achievements');
  });
}
