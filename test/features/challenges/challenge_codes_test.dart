import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';

import 'challenge_fixtures.dart';

void main() {
  group('challenge codes', () {
    test('a distance challenge round-trips exactly', () {
      final blueprint = distanceBlueprint();

      final decoded = decodeChallengeCode(encodeChallengeCode(blueprint));

      expect(decoded, isA<CodeDecoded<ChallengeBlueprint>>());
      expect(decoded.valueOrNull, blueprint);
    });

    test('a session challenge round-trips exactly, any-type set included', () {
      final blueprint = sessionBlueprint(activityTypes: const {});

      final decoded = decodeChallengeCode(encodeChallengeCode(blueprint));

      expect(decoded.valueOrNull, blueprint);
      expect(
        decoded.valueOrNull!.activityTypes,
        isEmpty,
        reason: 'an empty type set is "anything counts", not a missing value',
      );
    });

    test('every activity type survives the mask, alone and together', () {
      for (final type in ActivityType.values) {
        final blueprint = sessionBlueprint(activityTypes: {type});
        expect(
          decodeChallengeCode(encodeChallengeCode(blueprint)).valueOrNull,
          blueprint,
          reason: '${type.name} did not survive the round trip',
        );
      }
      final all = sessionBlueprint(activityTypes: ActivityType.values.toSet());
      expect(decodeChallengeCode(encodeChallengeCode(all)).valueOrNull, all);
    });

    test('the id is a pure function of the defining parameters', () {
      final first = distanceBlueprint(salt: 42);
      final second = distanceBlueprint(salt: 42);

      expect(first.id, second.id);
      expect(encodeChallengeCode(first), encodeChallengeCode(second));
    });

    test('the salt is what separates two identical-looking challenges', () {
      expect(
        distanceBlueprint(salt: 1).id,
        isNot(distanceBlueprint(salt: 2).id),
      );
    });

    test('re-encoding a decoded challenge reproduces the same code', () {
      final code = encodeChallengeCode(distanceBlueprint());
      final decoded = decodeChallengeCode(code).valueOrNull!;

      expect(
        encodeChallengeCode(decoded),
        code,
        reason:
            're-sharing must be re-sharing, not a second challenge - the '
            'whole duplicate-join story rests on this',
      );
    });

    test('a progress code round-trips its five fields and no others', () {
      final blueprint = distanceBlueprint();

      final code = encodeProgressCode(
        challengeId: blueprint.id,
        displayName: 'Alex',
        progressPercent: 64.2,
        asOf: LocalDate(2026, 9, 18),
        authorTag: selfAuthorTag,
      );
      final payload = decodeProgressCode(code).valueOrNull!;

      expect(payload.challengeId, blueprint.id);
      expect(payload.displayName, 'Alex');
      expect(payload.progressPercent, closeTo(64.2, 0.05));
      expect(payload.asOf, LocalDate(2026, 9, 18));
    });

    test('a progress code carries the author tag that wrote it', () {
      final payload = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Alex',
          progressPercent: 50,
          asOf: LocalDate(2026, 9, 18),
          authorTag: 0xA9B8C7D6,
        ),
      ).valueOrNull!;

      expect(payload.authorTag, 0xA9B8C7D6);
    });

    test('an author tag with its top bit set survives the round trip', () {
      // Written and read with integer arithmetic rather than shifts: on
      // web `bytes[0] << 24` is a signed 32-bit operation and would read
      // this back as a negative number, so a device would fail to
      // recognise its own code (see `_u32` in challenge_codes.dart).
      for (final tag in [0, 1, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF]) {
        final payload = decodeProgressCode(
          encodeProgressCode(
            challengeId: distanceBlueprint().id,
            displayName: 'Alex',
            progressPercent: 50,
            asOf: LocalDate(2026, 9, 18),
            authorTag: tag,
          ),
        ).valueOrNull!;

        expect(payload.authorTag, tag, reason: 'tag $tag did not survive');
      }
    });

    test('a salt with its top bit set survives the round trip', () {
      final blueprint = distanceBlueprint(salt: 0xFFFFFFFF);

      expect(
        decodeChallengeCode(encodeChallengeCode(blueprint)).valueOrNull,
        blueprint,
      );
    });

    test('the percent is floored, so both devices see the same goal line', () {
      // 99.97% must not become 100.0 on the receiving device: their phone
      // would say they arrived while the phone that sent the code says they
      // have not, and there is no server to settle it.
      final justUnder = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Alex',
          progressPercent: 99.97,
          asOf: LocalDate(2026, 9, 18),
          authorTag: buddyAuthorTag,
        ),
      ).valueOrNull!;

      expect(justUnder.progressPercent, lessThan(100));
      expect(justUnder.progressPercent, 99.9);
      expect(
        ChallengeBuddySnapshot(
          displayName: 'Alex',
          progressPercent: justUnder.progressPercent,
          asOf: justUnder.asOf,
        ).reachedGoal,
        isFalse,
        reason: 'the sending device floors to 99% - the receiver must agree',
      );

      final exactly = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Alex',
          progressPercent: 100,
          asOf: LocalDate(2026, 9, 18),
          authorTag: buddyAuthorTag,
        ),
      ).valueOrNull!;

      expect(exactly.progressPercent, 100);
      expect(
        ChallengeBuddySnapshot(
          displayName: 'Alex',
          progressPercent: exactly.progressPercent,
          asOf: exactly.asOf,
        ).reachedGoal,
        isTrue,
        reason: 'arriving exactly on the line crosses it on both devices',
      );
    });

    test('a progress percent above 100 survives, uncapped', () {
      final payload = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Sam',
          progressPercent: 213.7,
          asOf: LocalDate(2026, 9, 18),
          authorTag: buddyAuthorTag,
        ),
      ).valueOrNull!;

      expect(payload.progressPercent, closeTo(213.7, 0.05));
    });

    test('a non-finite percent encodes as zero rather than corrupting', () {
      final payload = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Sam',
          progressPercent: double.nan,
          asOf: LocalDate(2026, 9, 18),
          authorTag: buddyAuthorTag,
        ),
      ).valueOrNull!;

      expect(payload.progressPercent, 0);
    });

    test('a name longer than the budget is truncated on a rune boundary', () {
      final payload = decodeProgressCode(
        encodeProgressCode(
          challengeId: distanceBlueprint().id,
          // 12 four-byte runes = 48 UTF-8 bytes, twice the budget.
          displayName: '🏃🏃🏃🏃🏃🏃🏃🏃🏃🏃🏃🏃',
          progressPercent: 10,
          asOf: LocalDate(2026, 9, 18),
          authorTag: buddyAuthorTag,
        ),
      ).valueOrNull!;

      expect(payload.displayName, '🏃🏃🏃🏃🏃🏃');
      expect(
        payload.displayName.runes.length,
        6,
        reason:
            'cutting mid-sequence would produce a name that fails to '
            'decode on the other device',
      );
    });
  });

  group('challenge code rejection', () {
    test('a tampered challenge code fails the checksum', () {
      final code = encodeChallengeCode(distanceBlueprint());

      // Flip one payload character. Without the CRC this would decode into
      // a different, entirely plausible challenge.
      final body = code.substring(4);
      final swapped = body[0] == 'A' ? 'B' : 'A';
      final tampered = 'FC1.$swapped${body.substring(1)}';

      expect(
        decodeChallengeCode(tampered),
        isA<CodeRejected<ChallengeBlueprint>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.checksumFailed,
        ),
      );
    });

    test('every single-character substitution is caught or rejected', () {
      final blueprint = distanceBlueprint();
      final code = encodeChallengeCode(blueprint);
      const alphabet =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

      for (var i = 4; i < code.length; i++) {
        for (final replacement in alphabet.split('')) {
          if (code[i] == replacement) continue;
          final mutated = code.replaceRange(i, i + 1, replacement);
          final decoded = decodeChallengeCode(mutated);
          expect(
            decoded.valueOrNull,
            anyOf(isNull, equals(blueprint)),
            reason:
                'a one-character typo must never decode into a *different* '
                'challenge (position $i -> $replacement)',
          );
        }
      }
    });

    test('a truncated code is malformed, not a half-decoded challenge', () {
      final code = encodeChallengeCode(distanceBlueprint());

      final decoded = decodeChallengeCode(code.substring(0, code.length - 4));

      expect(decoded, isA<CodeRejected<ChallengeBlueprint>>());
    });

    test('a future format version is a typed rejection, never a crash', () {
      final body = encodeChallengeCode(distanceBlueprint()).substring(4);

      for (final version in ['2', '7', '99']) {
        expect(
          decodeChallengeCode('FC$version.$body'),
          isA<CodeRejected<ChallengeBlueprint>>().having(
            (r) => r.reason,
            'reason',
            CodeRejection.unsupportedVersion,
          ),
          reason: 'v$version must read as "update the app", not as garbage',
        );
      }
    });

    test('a future version of a progress code is also typed, not a crash', () {
      final body = encodeProgressCode(
        challengeId: distanceBlueprint().id,
        displayName: 'Alex',
        progressPercent: 50,
        asOf: LocalDate(2026, 9, 18),
        authorTag: selfAuthorTag,
      ).substring(4);

      expect(
        decodeProgressCode('FP4.$body'),
        isA<CodeRejected<ProgressCodePayload>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.unsupportedVersion,
        ),
      );
    });

    test('the two code kinds refuse to be mistaken for each other', () {
      final challengeCode = encodeChallengeCode(distanceBlueprint());
      final progressCode = encodeProgressCode(
        challengeId: distanceBlueprint().id,
        displayName: 'Alex',
        progressPercent: 50,
        asOf: LocalDate(2026, 9, 18),
        authorTag: selfAuthorTag,
      );

      expect(
        decodeProgressCode(challengeCode),
        isA<CodeRejected<ProgressCodePayload>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.wrongCodeKind,
        ),
      );
      expect(
        decodeChallengeCode(progressCode),
        isA<CodeRejected<ChallengeBlueprint>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.wrongCodeKind,
        ),
      );
    });

    test('arbitrary text is malformed, in every shape a paste takes', () {
      for (final junk in [
        '',
        '   ',
        'hello',
        'FC1.',
        'FC1.!!!!',
        'FX1.AQABA',
        'FC.AQABA',
        'https://example.com/challenge/abc',
      ]) {
        final decoded = decodeChallengeCode(junk);
        expect(
          decoded,
          isA<CodeRejected<ChallengeBlueprint>>(),
          reason: 'input "$junk" produced a value',
        );
      }
    });

    test('surrounding whitespace from a paste is tolerated', () {
      final blueprint = distanceBlueprint();
      final code = encodeChallengeCode(blueprint);

      expect(decodeChallengeCode('  $code \n').valueOrNull, blueprint);
    });

    test('the prefix letter is case-insensitive, the payload is not', () {
      final blueprint = distanceBlueprint();
      final code = encodeChallengeCode(blueprint);

      expect(
        decodeChallengeCode('fc1.${code.substring(4)}').valueOrNull,
        blueprint,
      );
    });
  });

  group('challenge code length budget', () {
    // The whole design constraint: a code has to survive being typed into
    // a chat message. Anything approaching 120 characters starts wrapping
    // and inviting the truncation the CRC then has to catch.
    const budget = 120;

    test('a realistic challenge code is far inside the budget', () {
      final code = encodeChallengeCode(distanceBlueprint());

      expect(code.length, lessThan(budget));
      expect(code.length, 23, reason: 'format drift should be deliberate');
    });

    test('the longest possible progress code is still inside the budget', () {
      final code = encodeProgressCode(
        // The widest window, every activity type, the largest target.
        challengeId: sessionBlueprint(
          activityTypes: ActivityType.values.toSet(),
          targetUnits: 500,
          windowStart: LocalDate(2026, 7, 15),
          windowEnd: LocalDate(2026, 10, 14),
          salt: 0xFFFFFFFF,
        ).id,
        // 24 single-byte characters: the maximum a name may occupy.
        displayName: 'Wwwwwwwwwwwwwwwwwwwwwwww',
        progressPercent: 6553.5,
        asOf: LocalDate(2026, 10, 14),
        authorTag: 0xFFFFFFFF,
      );

      expect(code.length, lessThan(budget));
      expect(code.length, 67, reason: 'format drift should be deliberate');
    });
  });

  group('what the 12 defining bytes cannot hold, they refuse', () {
    // Every one of these used to be truncated by a bit mask, which is the
    // worst thing this format can do: two devices agree on an id while
    // disagreeing about what the challenge asks for, and nothing anywhere
    // notices. `challenge_validation.dart` keeps real input far inside
    // these bounds, so reaching one is a programming error and thrown as
    // one.
    ChallengeBlueprint build({
      int targetUnits = 1000,
      LocalDate? windowStart,
      LocalDate? windowEnd,
      int salt = 1,
    }) {
      return challengeBlueprintFrom(
        kind: ChallengeKind.totalDistance,
        activityTypes: const {ActivityType.run},
        targetUnits: targetUnits,
        windowStart: windowStart ?? septemberStart,
        windowEnd: windowEnd ?? septemberEnd,
        salt: salt,
      );
    }

    test('a target above 65,535 is refused, not wrapped', () {
      expect(build(targetUnits: 0xFFFF).targetUnits, 0xFFFF);
      expect(() => build(targetUnits: 0x10000), throwsArgumentError);
      expect(() => build(targetUnits: -1), throwsArgumentError);
    });

    test('a window longer than the length byte is refused', () {
      final start = LocalDate(2026, 1, 1);
      expect(
        build(
          windowStart: start,
          windowEnd: start.addDays(maxRepresentableWindowDays - 1),
        ).windowDays,
        maxRepresentableWindowDays,
      );
      expect(
        () => build(
          windowStart: start,
          windowEnd: start.addDays(maxRepresentableWindowDays),
        ),
        throwsArgumentError,
      );
    });

    test('a window that ends before it starts is refused', () {
      expect(
        () => build(
          windowStart: LocalDate(2026, 9, 10),
          windowEnd: LocalDate(2026, 9, 9),
        ),
        throwsArgumentError,
      );
    });

    test('a window start outside the epoch range is refused', () {
      expect(
        () => build(
          windowStart: LocalDate(2019, 12, 31),
          windowEnd: LocalDate(2020, 1, 5),
        ),
        throwsArgumentError,
        reason: 'before the epoch there is no day count to store',
      );
      expect(
        () => build(
          windowStart: maxRepresentableWindowStart.addDays(1),
          windowEnd: maxRepresentableWindowStart.addDays(2),
        ),
        throwsArgumentError,
      );
    });

    test('a salt outside 32 bits is refused', () {
      expect(build(salt: 0xFFFFFFFF).salt, 0xFFFFFFFF);
      expect(() => build(salt: 0x100000000), throwsArgumentError);
      expect(() => build(salt: -1), throwsArgumentError);
    });

    test('re-encoding an out-of-range blueprint is refused too', () {
      // `copyWith` is the other way to reach the encoder, and it must not
      // be a way around the guard.
      final overSized = distanceBlueprint().copyWith(targetUnits: 0x10000);

      expect(() => encodeChallengeCode(overSized), throwsArgumentError);
    });

    test('an author tag outside 32 bits is refused', () {
      expect(
        () => encodeProgressCode(
          challengeId: distanceBlueprint().id,
          displayName: 'Alex',
          progressPercent: 10,
          asOf: LocalDate(2026, 9, 18),
          authorTag: 0x100000000,
        ),
        throwsArgumentError,
      );
    });
  });

  group('forward compatibility', () {
    test('the activity-type bit order is frozen', () {
      // Reordering or inserting a type silently reinterprets every code
      // ever sent. Appending one is safe - and makes this test fail, which
      // is the point: the failure is the prompt to append to
      // `codeActivityTypes` too rather than to renumber it.
      expect(codeActivityTypes, ActivityType.values);
    });

    test('an unknown activity-type bit is rejected, never partly honoured', () {
      // Byte 1-2 is the type mask; bit 15 belongs to no type this build
      // knows. Hand-built rather than encoded, because the encoder cannot
      // produce one - which is exactly the future case being simulated.
      final code = _handBuiltChallengeCode([
        1, // distance
        0x80, 0x01, // mask: run (bit 0) + an unknown bit 15
        0x03, 0xE8, // target
        0x09, 0x83, // window start
        29, // length - 1
        0, 0, 0, 1, // salt
      ]);

      expect(
        decodeChallengeCode(code),
        isA<CodeRejected<ChallengeBlueprint>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.unsupportedContent,
        ),
        reason:
            'counting only the types we recognise would silently change '
            'what the challenge asks for',
      );
    });

    test('an unknown challenge kind is rejected the same way', () {
      final code = _handBuiltChallengeCode([
        9, // a kind added after this build shipped
        0x00, 0x01,
        0x03, 0xE8,
        0x09, 0x83,
        29,
        0, 0, 0, 1,
      ]);

      expect(
        decodeChallengeCode(code),
        isA<CodeRejected<ChallengeBlueprint>>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.unsupportedContent,
        ),
      );
    });
  });
}

/// Builds a challenge code around raw payload [bytes], CRC and all — the
/// only way to produce a code this build's encoder never would.
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
