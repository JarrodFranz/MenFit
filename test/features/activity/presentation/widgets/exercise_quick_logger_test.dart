import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/widgets/exercise_quick_logger.dart';

/// The Train tab's top section. MenFit is strength-first, so two things are
/// pinned here beyond "it renders": Strength is the *first* hub tile, and
/// the tab's only filled button is the lift — never GPS recording, which is
/// what the forked-from app led with.
void main() {
  final cycle = StrengthCycle.create(
    name: 'Upper / Lower Split',
    isActive: true,
    routines: [
      StrengthDayRoutine.create(
        name: 'Upper A',
        exercises: const [StrengthExerciseTemplate(name: 'Bench Press')],
      ),
    ],
  );

  Widget host({
    required LocationCapabilities capabilities,
    StrengthCycle? activeCycle,
  }) {
    final overrides = <Override>[
      activeStrengthCycleProvider.overrideWith(
        (ref) => Stream.value(activeCycle),
      ),
    ];
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseQuickLogger(capabilities: capabilities),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the exercise hubs and the action block', (tester) async {
    await tester.pumpWidget(
      host(
        capabilities: const LocationCapabilities(canRecordActivities: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise Hubs'), findsOneWidget);
    expect(find.text('Record GPS activity'), findsOneWidget);
    expect(find.text('Log Previous'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
  });

  testWidgets('Strength is the first hub tile, ahead of Run', (tester) async {
    await tester.pumpWidget(
      host(
        capabilities: const LocationCapabilities(canRecordActivities: true),
      ),
    );
    await tester.pumpAndSettle();

    // Horizontal list: leftmost tile is the first one.
    final strengthX = tester.getTopLeft(find.text('Strength')).dx;
    for (final later in const ['Run', 'Walk', 'Hike', 'Ride']) {
      expect(
        strengthX,
        lessThan(tester.getTopLeft(find.text(later)).dx),
        reason: '$later must sit to the right of Strength',
      );
    }
  });

  testWidgets('with no active cycle the primary action is Start a routine', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        capabilities: const LocationCapabilities(canRecordActivities: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Start a routine'), findsOne);
    expect(find.text('Start workout'), findsNothing);
    // GPS recording is demoted, not removed.
    expect(
      find.widgetWithText(OutlinedButton, 'Record GPS activity'),
      findsOne,
    );
    expect(find.byType(FilledButton), findsOne);
  });

  testWidgets('with an active cycle the primary action is Start workout', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        capabilities: const LocationCapabilities(canRecordActivities: true),
        activeCycle: cycle,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Start workout'), findsOne);
    expect(find.text('Start a routine'), findsNothing);
    expect(
      find.widgetWithText(OutlinedButton, 'Record GPS activity'),
      findsOne,
    );
  });

  testWidgets('every type tile is a button announcing the hub it opens', (
    tester,
  ) async {
    // `find.bySemanticsLabel` needs the semantics tree actually built -
    // disposed explicitly at the end, not via addTearDown (flutter_test's
    // own "no SemanticsHandle left open" check runs first).
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        capabilities: const LocationCapabilities(canRecordActivities: true),
      ),
    );
    await tester.pumpAndSettle();

    // Off-screen tiles are not built by the horizontal list, so this checks
    // the leading ones rather than all ten.
    final strengthTile = find.bySemanticsLabel('Open Strength hub');
    expect(strengthTile, findsOneWidget);
    expect(find.bySemanticsLabel('Open Run hub'), findsOneWidget);
    expect(
      tester.getSemantics(strengthTile),
      isSemantics(isButton: true, hasTapAction: true),
    );
    expect(find.byTooltip('Open Strength hub'), findsOneWidget);

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
      host(
        capabilities: const LocationCapabilities(
          canRecordActivities: false,
          reason: 'Recording works on your phone.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise Hubs'), findsOneWidget);
    expect(find.text('Record GPS activity'), findsNothing);
    expect(find.text('Log activity'), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Recording works on your phone.'), findsOneWidget);
    // The strength primary action survives losing GPS.
    expect(find.widgetWithText(FilledButton, 'Start a routine'), findsOne);
  });
}
