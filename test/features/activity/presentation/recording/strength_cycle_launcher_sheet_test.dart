import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_cycle_launcher_sheet.dart';

import '../../../weight/weight_test_vocabulary.dart' show flushDriftTimers;

/// Regression guard for the 2026-09-02 on-device finding: a training-cycle
/// tile's trailing `Row` (edit icon button + Start/Set Active) ate so much
/// width at 411dp that the cycle's title and subtitle wrapped. The edit
/// button was removed (the tile already opens the editor on tap) and the
/// title now caps at one line with ellipsis rather than wrapping.
void main() {
  late AppDatabase db;

  // Ordinary widget tests render with --use-test-fonts, whose glyphs are
  // fixed-width and far wider than Inter - "Upper / Lower Split" measures
  // roughly 2x its real width there, so a `didExceedMaxLines` check would
  // report a false wrap regardless of the actual layout fix (see the
  // central `testing-pitfalls.md` and the same loader in
  // `test/core/adaptive_scaffold_real_font_test.dart`). Loading the real
  // bundled Inter once here makes the measurement below mean something.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytes = await File('assets/fonts/Inter.ttf').readAsBytes();
    final loader = FontLoader(AppTheme.fontFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: StrengthCycleLauncherSheet()),
      ),
    );
  }

  Future<void> seedCycle({required bool isActive}) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final repo = container.read(strengthRoutineRepositoryProvider);
    final cycle = StrengthCycle.create(
      name: 'Upper / Lower Split',
      routines: [
        StrengthDayRoutine.create(
          name: 'Upper A',
          exercises: const [StrengthExerciseTemplate(name: 'Bench Press')],
        ),
      ],
    );
    await repo.saveCycle(cycle);
    if (isActive) {
      await repo.setActiveCycle(cycle.id);
    }
  }

  RenderParagraph titleParagraph(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text));
  }

  /// The `ListTile` for the cycle named [text] — scoped so the hero
  /// "active cycle" card's own (untouched) edit button doesn't get
  /// mistaken for the one removed from this tile.
  Finder cycleListTile(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(ListTile),
    );
  }

  testWidgets(
    'inactive cycle tile keeps its title on one line at 411dp/100% '
    '(no edit icon button squeezing it)',
    (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Containment only - see the explicit flush at the end of this body,
      // which is what actually satisfies flutter_test's pending-timer
      // invariant (addTearDown runs too late for that: the sheet watches
      // Drift streams via `strengthCyclesProvider` and friends, and an
      // un-flushed cleanup timer wedges `db.close()` in tearDown on the
      // same opening lock - see the central testing-pitfalls.md "Drift +
      // widget-test trap" entries).
      addTearDown(() => flushDriftTimers(tester));

      await seedCycle(isActive: false);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Upper / Lower Split'), findsOneWidget);
      expect(find.text('Set Active'), findsOneWidget);
      // The edit icon button is gone; the tile itself is still the way in.
      expect(
        find.descendant(
          of: cycleListTile('Upper / Lower Split'),
          matching: find.byIcon(Icons.edit_outlined),
        ),
        findsNothing,
      );

      final paragraph = titleParagraph(tester, 'Upper / Lower Split');
      expect(
        paragraph.didExceedMaxLines,
        isFalse,
        reason:
            'the full cycle name must fit on its single line without '
            'truncating - if this is true the trailing action(s) are '
            'crowding the title again',
      );

      // Must be the LAST statement: unmounts the tree so the sheet's Drift
      // stream subscriptions are cancelled and their cleanup timers fire
      // before the body returns (flutter_test checks for pending timers
      // the instant it does, before tearDown runs).
      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'active cycle tile (Start button) also keeps its title on one line',
    (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // See the first test in this file for why this is needed.
      addTearDown(() => flushDriftTimers(tester));

      await seedCycle(isActive: true);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Upper / Lower Split'), findsOneWidget);
      // Both the hero "active cycle" card's Start button and this tile's
      // could read "Start"; the hero card's is a distinct string ("Start
      // Day 1: ...").
      expect(find.text('Start'), findsOneWidget);
      expect(
        find.descendant(
          of: cycleListTile('Upper / Lower Split'),
          matching: find.byIcon(Icons.edit_outlined),
        ),
        findsNothing,
      );

      final paragraph = titleParagraph(tester, 'Upper / Lower Split');
      expect(paragraph.didExceedMaxLines, isFalse);

      // Must be the LAST statement - see the first test in this file.
      await flushDriftTimers(tester);
    },
  );
}
