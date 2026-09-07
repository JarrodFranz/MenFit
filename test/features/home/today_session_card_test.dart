import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_session_card.dart';

/// The dashboard's strength-first card: MenFit opens on what to lift today,
/// not on what was run yesterday. The card is the only place on Home that
/// reads the active training cycle, so both of its states are pinned here.
void main() {
  Widget host(List<Override> overrides) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: TodaySessionCard()),
    ),
  );

  testWidgets(
    'shows a start-a-routine prompt when no strength cycle is active',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        host([
          activeStrengthCycleProvider.overrideWith((ref) => Stream.value(null)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's session"), findsOneWidget);
      expect(find.text('Start a routine'), findsOneWidget);
    },
  );

  testWidgets('names the active cycle and offers to start the next day', (
    tester,
  ) async {
    final cycle = StrengthCycle.create(
      name: 'Upper / Lower Split',
      isActive: true,
      routines: [
        StrengthDayRoutine.create(
          name: 'Upper A',
          exercises: const [StrengthExerciseTemplate(name: 'Bench Press')],
        ),
        StrengthDayRoutine.create(
          name: 'Lower A',
          exercises: const [StrengthExerciseTemplate(name: 'Back Squat')],
        ),
      ],
    );

    await tester.pumpWidget(
      host([
        activeStrengthCycleProvider.overrideWith((ref) => Stream.value(cycle)),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('Upper / Lower Split'), findsOneWidget);
    // The day counter comes from the cycle's own `currentDayIndex` /
    // `routines`, the same pair the Strength Hub counts with - the domain
    // has no notion of weeks.
    expect(find.text('Day 1 of 2'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('a failing cycle stream still offers Start a routine', (
    tester,
  ) async {
    // The card used to render `SizedBox.shrink()` on error, leaving a
    // titled card over blank space - a dead end the user can neither act on
    // nor diagnose. A repository failure now degrades to the no-cycle
    // state, which is the one useful thing to offer either way.
    await tester.pumpWidget(
      host([
        activeStrengthCycleProvider.overrideWith(
          (ref) => Stream<StrengthCycle?>.error(
            StateError('routine repository unavailable'),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('No routine running'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start a routine'), findsOne);
  });
}
