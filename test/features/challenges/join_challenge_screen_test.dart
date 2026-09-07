import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/join_challenge_screen.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';
import 'fake_challenge_repository.dart';

/// Inside the September fixtures' window, so a code for one is joinable.
final LocalDate _today = LocalDate(2026, 9, 10);

void main() {
  late FakeChallengeRepository repository;

  setUp(() {
    repository = FakeChallengeRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  /// Pushed onto a stub route rather than mounted as `home`, so the
  /// screen's own `Navigator.pop` after a successful join has somewhere
  /// to pop back to.
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const JoinChallengeScreen(),
                    ),
                  ),
                  child: const Text('open join'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open join'));
    await tester.pumpAndSettle();
  }

  Future<void> paste(WidgetTester tester, String code) async {
    await tester.enterText(find.byKey(const Key('joinCodeField')), code);
    await tester.pumpAndSettle();
  }

  bool joinEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(const Key('joinSubmitButton')))
          .onPressed !=
      null;

  group('live decode feedback', () {
    testWidgets('shows what a good code describes, and enables joining', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(joinEnabled(tester), isFalse);

      await paste(tester, encodeChallengeCode(distanceBlueprint()));

      expect(find.byKey(const Key('joinCodePreview')), findsOneWidget);
      expect(
        find.text('100 km · Run · 1 Sep – 30 Sep 2026'),
        findsOneWidget,
      );
      expect(joinEnabled(tester), isTrue);

      await flushDriftTimers(tester);
    });

    testWidgets('says nothing at all about an empty field', (tester) async {
      await pumpScreen(tester);

      await paste(tester, encodeChallengeCode(distanceBlueprint()));
      expect(find.byKey(const Key('joinCodePreview')), findsOneWidget);

      await paste(tester, '');
      expect(find.byKey(const Key('joinCodePreview')), findsNothing);
      for (final rejection in CodeRejection.values) {
        expect(find.text(joinCodeRejectionMessage(rejection)), findsNothing);
      }

      await flushDriftTimers(tester);
    });

    testWidgets('gives each rejection its own human message', (tester) async {
      final good = encodeChallengeCode(distanceBlueprint());
      final body = good.substring(4);
      final swappedFirst = body[0] == 'A' ? 'B' : 'A';

      final cases = <CodeRejection, String>{
        CodeRejection.malformed: 'have you seen my keys',
        CodeRejection.unsupportedVersion: 'FC7.$body',
        CodeRejection.wrongCodeKind: buddyProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Sam',
          progressPercent: 40,
          asOf: _today,
        ),
        CodeRejection.checksumFailed: 'FC1.$swappedFirst${body.substring(1)}',
        // Bit 15 of the activity mask belongs to no type this build knows.
        // Hand-built because the encoder cannot produce one, which is
        // precisely the future case being simulated.
        CodeRejection.unsupportedContent: _handBuiltChallengeCode([
          1,
          0x80,
          0x01,
          0x03,
          0xE8,
          0x09,
          0x83,
          29,
          0,
          0,
          0,
          1,
        ]),
      };

      await pumpScreen(tester);

      for (final entry in cases.entries) {
        await paste(tester, entry.value);

        expect(
          find.text(joinCodeRejectionMessage(entry.key)),
          findsOneWidget,
          reason: '${entry.key.name} should have its own message',
        );
        expect(find.byKey(const Key('joinCodePreview')), findsNothing);
        expect(
          joinEnabled(tester),
          isFalse,
          reason: 'a code that cannot be read cannot be joined',
        );
      }

      // Every message is distinct: five outcomes with one shared "that
      // did not work" would tell her nothing about what to do next.
      final messages = {
        for (final rejection in CodeRejection.values)
          joinCodeRejectionMessage(rejection),
      };
      expect(messages, hasLength(CodeRejection.values.length));

      await flushDriftTimers(tester);
    });

    testWidgets('the progress box reverses only the wrong-kind message', (
      tester,
    ) async {
      // The likeliest mistake is direction-dependent, and the copy has to
      // follow it: in the join box a progress code is the wrong one; in
      // the buddy box the challenge code is.
      expect(
        progressCodeRejectionMessage(CodeRejection.wrongCodeKind),
        isNot(joinCodeRejectionMessage(CodeRejection.wrongCodeKind)),
      );
      for (final rejection in CodeRejection.values) {
        if (rejection == CodeRejection.wrongCodeKind) continue;
        expect(
          progressCodeRejectionMessage(rejection),
          joinCodeRejectionMessage(rejection),
        );
      }
    });
  });

  group('joining', () {
    testWidgets('stores the challenge under the name she chose', (
      tester,
    ) async {
      await pumpScreen(tester);
      await paste(tester, encodeChallengeCode(distanceBlueprint()));
      await tester.enterText(find.byKey(const Key('joinNameField')), 'Alex');
      await tester.tap(find.byKey(const Key('joinSubmitButton')));
      await tester.pumpAndSettle();

      final stored = (await repository.getChallenges()).single;
      expect(stored.id, distanceBlueprint().id);
      expect(stored.selfDisplayName, 'Alex');
      expect(stored.origin, ChallengeOrigin.joined);
      expect(find.text(joinedMessage), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('says so gently when she already has it, and changes '
        'nothing', (tester) async {
      // The fixture's own display name, which the re-paste must not
      // overwrite.
      final existing = challengeFrom(distanceBlueprint());
      repository.seed([existing]);

      await pumpScreen(tester);
      await paste(tester, encodeChallengeCode(distanceBlueprint()));
      await tester.enterText(find.byKey(const Key('joinNameField')), 'Someone');
      await tester.tap(find.byKey(const Key('joinSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text(alreadyJoinedMessage), findsOneWidget);
      final stored = (await repository.getChallenges()).single;
      expect(
        stored.selfDisplayName,
        'Alex',
        reason: 'a re-pasted code must not overwrite what she already has',
      );

      await flushDriftTimers(tester);
    });

    testWidgets('surfaces a validation problem on the field it belongs to', (
      tester,
    ) async {
      await pumpScreen(tester);
      await paste(tester, encodeChallengeCode(distanceBlueprint()));
      await tester.tap(find.byKey(const Key('joinSubmitButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Pick a name to show your buddy — anything you like.'),
        findsOneWidget,
      );
      expect(await repository.getChallenges(), isEmpty);

      await flushDriftTimers(tester);
    });
  });

  testWidgets('the forbidden-vocabulary sweep, including every rejection', (
    tester,
  ) async {
    await pumpScreen(tester);

    final codes = <String>[
      '',
      'have you seen my keys',
      encodeChallengeCode(distanceBlueprint()),
      buddyProgressCode(
        challengeId: distanceBlueprint().id,
        displayName: 'Sam',
        progressPercent: 40,
        asOf: _today,
      ),
    ];

    for (final code in codes) {
      await paste(tester, code);
      for (final widget in tester.widgetList<Text>(find.byType(Text))) {
        if (widget.data case final text?) {
          expectNoForbiddenChallengeVocabulary(
            text,
            source: 'the join screen',
          );
        }
      }
    }

    await flushDriftTimers(tester);
  });
}

/// A challenge code built byte by byte with a correct CRC — the same
/// helper, and the same reason, as `challenge_codes_test.dart`'s: the
/// encoder deliberately cannot produce the future-format payloads these
/// rejections exist for.
String _handBuiltChallengeCode(List<int> bytes) {
  var crc = 0xFFFF;
  for (final byte in bytes) {
    crc = (crc ^ ((byte & 0xFF) << 8)) & 0xFFFF;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0
          ? ((crc << 1) ^ 0x1021) & 0xFFFF
          : (crc << 1) & 0xFFFF;
    }
  }
  final withCrc = [...bytes, (crc >> 8) & 0xFF, crc & 0xFF];
  return 'FC1.${base64UrlNoPadding(withCrc)}';
}
