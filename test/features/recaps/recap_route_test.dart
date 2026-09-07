import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/app/router/routes.dart';

/// The real `/recap` route (generated from `RecapStoryRouteData`) plus a
/// stand-in for the Progress screen it redirects to, so the redirect can
/// be exercised without dragging the six-branch shell and its
/// database-backed screens into the test.
GoRouter _buildRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      $recapStoryRouteData,
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
  testWidgets('/recap without a recap redirects to Progress instead of '
      'throwing', (tester) async {
    // A web reload or a deep link arrives with `state.extra == null`:
    // go_router's `extra` is an in-memory object and never survives
    // either. The generated factory used to cast it to a non-nullable
    // `MonthRecap` and throw during route build.
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _buildRouter(initialLocation: '/recap')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('progress stub'), findsOneWidget);
  });

  testWidgets('an unrelated location is untouched by the recap redirect', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _buildRouter(initialLocation: '/home')),
    );
    await tester.pumpAndSettle();

    expect(find.text('home stub'), findsOneWidget);
  });
}
