import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/presentation/widgets/fitness_dashboard_cards.dart';

import 'steps_test_fakes.dart';

/// The home "At a Glance" steps ring, which is the surface most users see
/// most often — and, before this, the one that could disagree with `/steps`
/// about the same day.
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<FakeStepsSync> pumpDashboard(
    WidgetTester tester, {
    FakeStepsRepository? repository,
  }) async {
    tester.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;

    final sync = FakeStepsSync();
    await tester.pumpWidget(
      ProviderScope(
        overrides: stepsOverrides(
          repository: repository ?? FakeStepsRepository(),
          sync: sync,
          healthSync: FakeHealthSync(),
        ),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: FitnessDashboardCards(
                activities: [],
                unitSystem: UnitSystem.metric,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return sync;
  }

  testWidgets('mounting the dashboard syncs recent steps', (tester) async {
    // Before this the only caller of `syncRecent` was the steps screen, so
    // a fresh, permitted install showed seven hollow "no data" rings on the
    // most-viewed card until the user happened to open `/steps`. The call
    // is toggle-gated and hour-throttled inside the notifier, so mounting
    // this repeatedly costs nothing.
    final sync = await pumpDashboard(tester);

    expect(sync.recentCalls, hasLength(1));
    expect(sync.recentCalls.single.force, isFalse);
  });

  testWidgets('renders "--" rather than 0 when no snapshot has been read', (
    tester,
  ) async {
    // `FakeHealthSync` reports no snapshot, so there is no count. A literal
    // `0` would contradict the strip underneath it, which correctly says
    // "no data" for the same day.
    await pumpDashboard(tester);

    expect(find.text('--'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
