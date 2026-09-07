import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/create_challenge_screen.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenges_test_vocabulary.dart';
import 'fake_challenge_repository.dart';

final LocalDate _today = LocalDate(2026, 9, 1);

void main() {
  late FakeChallengeRepository repository;

  setUp(() {
    repository = FakeChallengeRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Records whatever the screen writes to the clipboard — the same stub,
  /// and the same reason, as `workout_share_dialog_test.dart`.
  String? Function() interceptClipboard(WidgetTester tester) {
    String? captured;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          captured =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return () => captured;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(_today),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const CreateChallengeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byKey(const Key('challengeCreateSubmitButton'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('validation surfacing', () {
    testWidgets('reports every field at once, not one at a time', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      // Nothing typed: no target and no name. Both messages must be on
      // screen together - `validateChallenge` reports all three fields in
      // one pass and the form is not allowed to hoard two of them.
      await submit(tester);

      expect(
        find.text('Pick a distance between 1 km and 1,000 km.'),
        findsOneWidget,
      );
      expect(
        find.text('Pick a name to show your buddy — anything you like.'),
        findsOneWidget,
      );
      expect(await repository.getChallenges(), isEmpty);

      await flushDriftTimers(tester);
    });

    testWidgets('reports the session bound when the kind is sessions', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.tap(find.text(kindSessionsLabel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '900',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      expect(
        find.text('Pick a number of sessions between 1 and 500.'),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('clears the messages once the challenge is created', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await submit(tester);
      expect(
        find.text('Pick a name to show your buddy — anything you like.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      expect(
        find.text('Pick a name to show your buddy — anything you like.'),
        findsNothing,
      );
      expect(find.text(challengeCreatedTitle), findsOneWidget);

      await flushDriftTimers(tester);
    });
  });

  group('the kilometre conversion', () {
    testWidgets('stores a whole-kilometre distance as hundreds of metres', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      expect(stored.blueprint.kind, ChallengeKind.totalDistance);
      expect(stored.blueprint.targetUnits, 1000);
      // The unit the progress engine works in is metres, and 100 km is
      // 100,000 of them - the conversion that would silently put two
      // people in different challenges if it drifted.
      expect(stored.blueprint.target, 100000);

      await flushDriftTimers(tester);
    });

    testWidgets('keeps a tenth of a kilometre', (tester) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '42.2',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      expect(stored.blueprint.targetUnits, 422);
      expect(stored.blueprint.target, 42200);

      await flushDriftTimers(tester);
    });

    testWidgets('a session target is a plain count', (tester) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.tap(find.text(kindSessionsLabel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '12',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      expect(stored.blueprint.kind, ChallengeKind.sessionCount);
      expect(stored.blueprint.targetUnits, 12);
      expect(stored.blueprint.target, 12);

      await flushDriftTimers(tester);
    });
  });

  group('the created code', () {
    testWidgets('is shown selectably, copyable, and with what it contains', (
      tester,
    ) async {
      useTallWindow(tester);
      final copied = interceptClipboard(tester);
      await pumpScreen(tester);

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      final expectedCode = encodeChallengeCode(stored.blueprint);

      // Selectable, so it can be read out or half-dragged into a message,
      // not only copied wholesale.
      final code = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(code.data, expectedCode);
      expect(find.text(challengeCodePrivacyNote), findsOneWidget);

      await tester.tap(find.byKey(const Key('challengeCodeCopyButton')));
      await tester.pumpAndSettle();

      expect(copied(), expectedCode);
      expect(find.text(codeCopiedMessage), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('an empty activity picker means every type counts', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      expect(stored.blueprint.activityTypes, isEmpty);
      expect(stored.blueprint.countsType(ActivityType.swim), isTrue);

      await flushDriftTimers(tester);
    });

    testWidgets('a picked activity type narrows what counts', (tester) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('challengeActivityChip_run')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);

      final stored = (await repository.getChallenges()).single;
      expect(stored.blueprint.activityTypes, {ActivityType.run});
      expect(stored.blueprint.countsType(ActivityType.swim), isFalse);

      await flushDriftTimers(tester);
    });
  });

  group('the forbidden-vocabulary sweep', () {
    void expectClean(WidgetTester tester, {required String where}) {
      final rendered = [
        for (final widget in tester.widgetList<Text>(find.byType(Text)))
          if (widget.data != null) ('a Text widget', widget.data!),
        // The code body itself is skipped: base64url of a binary payload
        // is not copy, and a random 58-character string contains a
        // three-letter entry from the list about once in a few hundred
        // codes (see `challengeCodeTextKey`). Every label around it -
        // including the privacy note under it - is still swept.
        for (final widget in tester.widgetList<SelectableText>(
          find.byType(SelectableText),
        ))
          if (widget.key != challengeCodeTextKey && widget.data != null)
            ('a SelectableText', widget.data!),
        for (final widget in tester.widgetList<Tooltip>(find.byType(Tooltip)))
          if (widget.message != null) ('a Tooltip', widget.message!),
        for (final widget in tester.widgetList<Semantics>(
          find.byType(Semantics),
        )) ...[
          if (widget.properties.label case final label?)
            ('a semantics label', label),
          // Swept as well as the label: a `semanticsValue` is read aloud
          // like any other string, and the two are set in different places.
          if (widget.properties.value case final value?)
            ('a semantics value', value),
        ],
      ];
      expect(rendered, isNotEmpty, reason: 'nothing was swept in $where');
      for (final (source, text) in rendered) {
        expectNoForbiddenChallengeVocabulary(text, source: '$source in $where');
      }
    }

    testWidgets('across the form, its errors and the created code', (
      tester,
    ) async {
      useTallWindow(tester);
      await pumpScreen(tester);

      expectClean(tester, where: 'the create form');

      await submit(tester);
      expectClean(tester, where: 'the create form with every error showing');

      await tester.enterText(
        find.byKey(const Key('challengeTargetField')),
        '100',
      );
      await tester.enterText(
        find.byKey(const Key('challengeNameField')),
        'Alex',
      );
      await submit(tester);
      expectClean(tester, where: 'the created-code screen');

      await flushDriftTimers(tester);
    });
  });
}
