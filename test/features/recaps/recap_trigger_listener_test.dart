import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/presentation/recap_trigger_controller.dart';
import 'package:menfit_app/features/recaps/recaps_widgets.dart';

CycleRecap _recap(RecapPeriod period) =>
    CycleRecap(period: period, sessionCount: 9, consistencyRatio: 9 / 31);

/// A cycle-end recap and a month recap — the exact pair
/// `RecapTriggerEvaluator` can surface back to back, since marking the
/// cycle-end shown lets the runner-up month become due immediately.
final CycleRecap _recapA = _recap(RecapPeriod.forMonth(LocalDate(2026, 7, 1)));
final CycleRecap _recapB = _recap(RecapPeriod.forMonth(LocalDate(2026, 6, 1)));

/// Stands in for the real controller so the test drives the exact
/// sequence: a due recap, then a *different* due recap after `markShown`.
///
/// Subclasses the real notifier rather than faking the repositories under
/// it — the behaviour under test is entirely
/// `RecapTriggerListener._handled`, and reproducing the real controller's
/// cycle-record → evaluator → builder chain would test everything except
/// that.
class _FakeRecapTriggerController extends RecapTriggerController {
  int markShownCalls = 0;

  @override
  Future<CycleRecap?> build() async => null;

  /// Test-only: surfaces [recap] as the currently due one.
  void emit(CycleRecap? recap) => state = AsyncData(recap);

  /// The real implementation writes a marker and calls `invalidateSelf`;
  /// the fake only records the call, so the test decides what surfaces
  /// next rather than the marker store.
  @override
  Future<void> markShown() async => markShownCalls++;
}

/// Counts every route push, so "pushed exactly once" is asserted against
/// navigation itself rather than against whatever the story screen
/// happens to render.
class _PushCountingObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

/// A two-route stand-in for the app's router: Home mounts the listener,
/// and `/recap` records which recap it was handed. The real
/// `RecapStoryRouteData` resolves to this same `/recap` location, so the
/// listener's real push path is exercised without dragging the whole
/// six-branch shell (and its database-backed screens) into the test.
GoRouter _buildRouter({
  required NavigatorObserver observer,
  required List<String> builtWith,
}) {
  return GoRouter(
    initialLocation: '/home',
    observers: [observer],
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: RecapTriggerListener()),
      ),
      GoRoute(
        path: '/recap',
        builder: (context, state) {
          builtWith.add((state.extra! as CycleRecap).period.label);
          return const Scaffold(body: Text('recap story'));
        },
      ),
    ],
  );
}

void main() {
  testWidgets('presents exactly one recap per mount, even when a second '
      'becomes due', (tester) async {
    final observer = _PushCountingObserver();
    final builtWith = <String>[];
    final fake = _FakeRecapTriggerController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [recapTriggerControllerProvider.overrideWith(() => fake)],
        child: MaterialApp.router(
          routerConfig: _buildRouter(
            observer: observer,
            builtWith: builtWith,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Home itself is a push; everything below is measured against it.
    final baseline = observer.pushes;
    expect(builtWith, isEmpty);

    fake.emit(_recapA);
    await tester.pumpAndSettle();

    expect(observer.pushes - baseline, 1);
    expect(builtWith, [_recapA.period.label]);
    expect(fake.markShownCalls, 1);

    // A second recap becoming due must not stack a story on top of the
    // one still open: the runner-up waits for the next Home mount.
    fake.emit(_recapB);
    await tester.pumpAndSettle();

    expect(observer.pushes - baseline, 1);
    expect(builtWith, [_recapA.period.label]);
    expect(fake.markShownCalls, 1);
  });

  testWidgets('pushes nothing while no recap is due', (tester) async {
    final observer = _PushCountingObserver();
    final builtWith = <String>[];
    final fake = _FakeRecapTriggerController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [recapTriggerControllerProvider.overrideWith(() => fake)],
        child: MaterialApp.router(
          routerConfig: _buildRouter(
            observer: observer,
            builtWith: builtWith,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final baseline = observer.pushes;
    fake.emit(null);
    await tester.pumpAndSettle();

    expect(observer.pushes - baseline, 0);
    expect(builtWith, isEmpty);
    expect(fake.markShownCalls, 0);
  });
}
