import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_detail_screen.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_screen.dart';
import 'package:menfit_app/features/challenges/presentation/create_challenge_screen.dart';
import 'package:menfit_app/features/challenges/presentation/join_challenge_screen.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'fake_challenge_repository.dart';

/// The real `/challenges` subtree (generated from [ChallengesRouteData])
/// plus a stand-in for the Progress screen it is pushed from, so the
/// routes can be exercised without dragging the six-branch shell and its
/// database-backed screens into the test.
GoRouter _buildRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      $challengesRouteData,
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
  late FakeChallengeRepository repository;

  setUp(() {
    repository = FakeChallengeRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpAt(WidgetTester tester, String location) async {
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(LocalDate(2026, 9, 20)),
          selfProgressProvider.overrideWith((ref, id) => null),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _buildRouter(initialLocation: location),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('/challenges resolves to the challenge list', (tester) async {
    await pumpAt(tester, '/challenges');

    expect(tester.takeException(), isNull);
    expect(find.byType(ChallengesScreen), findsOneWidget);
    expect(find.text(challengesScreenTitle), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('/challenges/create resolves to the create flow', (tester) async {
    await pumpAt(tester, '/challenges/create');

    expect(tester.takeException(), isNull);
    expect(find.byType(CreateChallengeScreen), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('/challenges/join resolves to the join flow', (tester) async {
    await pumpAt(tester, '/challenges/join');

    expect(tester.takeException(), isNull);
    expect(find.byType(JoinChallengeScreen), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('a challenge id in the path resolves to the detail screen', (
    tester,
  ) async {
    final challenge = challengeFrom(distanceBlueprint());
    repository.seed([challenge]);

    await pumpAt(tester, ChallengeDetailRouteData(challenge.id).location);

    expect(tester.takeException(), isNull);
    expect(find.byType(ChallengeDetailScreen), findsOneWidget);
    expect(find.text('100 km'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  test('the routes are root-level, so they are reachable as deep links', () {
    // The location the Progress card pushes is the same string a cold
    // deep link arrives on - if this ever became a shell-nested path it
    // would silently stop matching (and, per the dartdoc on the route,
    // would reintroduce the root-navigator GlobalKey crash).
    expect(const ChallengesRouteData().location, '/challenges');
    expect(const CreateChallengeRouteData().location, '/challenges/create');
    expect(const JoinChallengeRouteData().location, '/challenges/join');
  });

  test('the literal sub-routes are matched before the id parameter', () {
    // `:challengeId` would happily bind the literal `create`/`join`
    // segments; go_router matches in declaration order, so the literals
    // must stay above it in `routes.dart`.
    final router = _buildRouter(initialLocation: '/challenges');
    final challengesRoute = router.configuration.routes
        .whereType<GoRoute>()
        .firstWhere((route) => route.path == '/challenges');
    expect(
      challengesRoute.routes.whereType<GoRoute>().map((r) => r.path).toList(),
      ['create', 'join', ':challengeId'],
    );
  });

  test('a detail location carries the id through verbatim', () {
    // Challenge ids are base64url of the defining bytes - URL-safe by
    // construction, so nothing in a path needs escaping.
    final id = distanceBlueprint().id;
    expect(ChallengeDetailRouteData(id).location, '/challenges/$id');
  });
}
