import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/presentation/widgets/exercise_quick_logger.dart';

void main() {
  testWidgets('renders all exercise types and action buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ExerciseQuickLogger(
                capabilities: LocationCapabilities(
                  canRecordActivities: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise Hubs'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Log Previous'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Hike'), findsOneWidget);
    expect(find.text('Ride'), findsOneWidget);
  });

  testWidgets('every type tile is a button announcing the hub it opens', (
    tester,
  ) async {
    // `find.bySemanticsLabel` needs the semantics tree actually built -
    // disposed explicitly at the end, not via addTearDown (flutter_test's
    // own "no SemanticsHandle left open" check runs first).
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ExerciseQuickLogger(
                capabilities: LocationCapabilities(
                  canRecordActivities: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Off-screen tiles are not built by the horizontal list, so this checks
    // the leading ones rather than all ten.
    final runTile = find.bySemanticsLabel('Open Run hub');
    expect(runTile, findsOneWidget);
    expect(find.bySemanticsLabel('Open Walk hub'), findsOneWidget);
    expect(
      tester.getSemantics(runTile),
      isSemantics(isButton: true, hasTapAction: true),
    );
    expect(find.byTooltip('Open Run hub'), findsOneWidget);

    // 48dp in both axes at the default text scale (the tile is 72x92).
    final tile = tester.getSize(
      find.ancestor(
        of: find.text('Run'),
        matching: find.byType(InkWell),
      ),
    );
    expect(tile.width, greaterThanOrEqualTo(48));
    expect(tile.height, greaterThanOrEqualTo(48));

    handle.dispose();
  });

  testWidgets('renders Log activity and Routes when not capable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ExerciseQuickLogger(
                capabilities: LocationCapabilities(
                  canRecordActivities: false,
                  reason: 'Recording works on your phone.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise Hubs'), findsOneWidget);
    expect(find.text('Record'), findsNothing);
    expect(find.text('Log activity'), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Recording works on your phone.'), findsOneWidget);
  });
}
