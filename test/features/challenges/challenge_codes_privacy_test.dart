import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';

import 'challenge_fixtures.dart';

/// The privacy invariant of the whole feature, pinned.
///
/// A progress code carries a challenge id, a self-chosen name, one
/// percentage, a date and a random author tag. It must not be possible to
/// tell from a code whether its author had protected days — not from its
/// length, not from its shape, not from any field other than the
/// percentage that the pro-ration is *supposed* to move.
///
/// See the privacy invariant at the top of
/// `features/challenges/domain/challenge_codes.dart` for why this matters
/// more here than almost anywhere else in the app.
void main() {
  final blueprint = distanceBlueprint();
  final asOf = LocalDate(2026, 9, 18);

  // Identical training histories. The only difference between these two
  // participants is that one of them had a period.
  final activities = [
    for (var day = 1; day <= 18; day++)
      activityOn(LocalDate(2026, 9, day), distanceMeters: 3000),
  ];
  final protectedDays = daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9));

  final withoutProtection = computeSelfProgress(
    challenge: blueprint,
    activities: activities,
    protectedDays: const {},
  );
  final withProtection = computeSelfProgress(
    challenge: blueprint,
    activities: activities,
    protectedDays: protectedDays,
  );

  String codeFor(double percent, {String name = 'Alex'}) => encodeProgressCode(
    challengeId: blueprint.id,
    displayName: name,
    progressPercent: percent,
    asOf: asOf,
    authorTag: selfAuthorTag,
  );

  test('the fixture actually exercises the difference', () {
    expect(withProtection.protectedDaysInWindow, 5);
    expect(withoutProtection.protectedDaysInWindow, 0);
    expect(
      withProtection.adjustedTarget,
      lessThan(withoutProtection.adjustedTarget),
    );
    expect(
      withProtection.percent,
      greaterThan(withoutProtection.percent),
      reason: 'protection lowers the ask, so the same work reads as more',
    );
  });

  test('two codes are byte-identical in shape; only the percent differs', () {
    final plain = codeFor(withoutProtection.percent);
    final protectedCode = codeFor(withProtection.percent);

    expect(
      protectedCode.length,
      plain.length,
      reason:
          'a longer code for a participant with protected days would leak '
          'the fact of them before anything was even decoded',
    );

    final plainBytes = _payloadOf(plain);
    final protectedBytes = _payloadOf(protectedCode);

    expect(protectedBytes.length, plainBytes.length);

    // Byte-for-byte identical everywhere except the two percent bytes and
    // the two CRC bytes that necessarily follow from them. The four
    // author-tag bytes are inside this sweep on purpose: the tag is drawn
    // once per challenge and does not move when their protection does, so it
    // must be identical here or it would be a second channel.
    const percentOffset = 12;
    for (var i = 0; i < plainBytes.length; i++) {
      final isPercentByte = i == percentOffset || i == percentOffset + 1;
      final isCrcByte = i >= plainBytes.length - 2;
      if (isPercentByte || isCrcByte) continue;
      expect(
        protectedBytes[i],
        plainBytes[i],
        reason:
            'byte $i differs between a protected and an unprotected '
            'participant - only the percentage may',
      );
    }
  });

  test('the author tag is a function of nothing about their', () {
    // Stated as an equality rather than as prose: the tag the encoder
    // writes is exactly the tag it was handed. It is not derived from their
    // name, their percentage, their date or their protection, so there is
    // nothing in it to read.
    final tagged = <int>{
      for (final percent in [0.0, withProtection.percent, 212.4])
        for (final name in ['Alex', 'A much longer name here'])
          decodeProgressCode(codeFor(percent, name: name))
              .valueOrNull!
              .authorTag,
    };

    expect(
      tagged,
      {selfAuthorTag},
      reason:
          'the same tag came out of every combination of name, percentage '
          'and protection - it is the value handed in and nothing else',
    );
  });

  test('the decoded payloads agree on everything except the percentage', () {
    final plain = decodeProgressCode(
      codeFor(withoutProtection.percent),
    ).valueOrNull!;
    final protectedPayload = decodeProgressCode(
      codeFor(withProtection.percent),
    ).valueOrNull!;

    expect(protectedPayload.challengeId, plain.challengeId);
    expect(protectedPayload.displayName, plain.displayName);
    expect(protectedPayload.asOf, plain.asOf);
    expect(protectedPayload.authorTag, plain.authorTag);
    expect(protectedPayload.progressPercent, isNot(plain.progressPercent));
  });

  test('a code cannot be run backwards into distance, target or rest days', () {
    // Stated as an assertion about the payload type rather than as prose:
    // these five fields are the whole of what a buddy receives. If this
    // list ever needs updating, the invariant above needs re-arguing
    // first.
    final payload = decodeProgressCode(
      codeFor(withProtection.percent),
    ).valueOrNull!;

    expect(payload.challengeId, isA<String>());
    expect(payload.displayName, isA<String>());
    expect(payload.progressPercent, isA<double>());
    expect(payload.asOf, isA<LocalDate>());
    expect(payload.authorTag, isA<int>());
  });

  test('the payload length is a law of the name alone', () {
    // This replaces an older pair of assertions that looked for the digits
    // of their distance and their adjusted target inside the base64 body.
    // Those could not fail: base64url of 47 bytes essentially never
    // contains a given 5-digit run, so the test passed whatever the
    // encoder did. The length law can fail - it is exactly what a fifth
    // field, a variable-width percentage or a conditional byte would
    // break, and any of those is how raw work would get in.
    for (final name in ['A', 'Alex', 'Wwwwwwwwwwwwwwwwwwwwwwww']) {
      final expected = 21 + utf8.encode(name).length + 2;
      final lengths = <int>{
        for (final protection in [const <LocalDate>{}, protectedDays])
          for (final percent in [
            0.0,
            0.05,
            99.97,
            100.0,
            computeSelfProgress(
              challenge: blueprint,
              activities: activities,
              protectedDays: protection,
            ).percent,
            6553.5,
            double.nan,
          ])
            _payloadOf(codeFor(percent, name: name)).length,
      };

      expect(
        lengths,
        {expected},
        reason:
            'every percentage and every protection produced the same '
            '$expected-byte payload for a $name-length name',
      );
    }
  });

  test('the challenge code itself carries nothing personal either', () {
    // Both participants hold the same challenge code, so anything in it is
    // by definition shared, not personal. Pinned so a future field cannot
    // be added here as a shortcut: the payload is a fixed 14 bytes.
    final bytes = _payloadOf(encodeChallengeCode(blueprint));

    expect(bytes.length, 14, reason: '12 defining bytes plus a 2-byte CRC');
  });
}

List<int> _payloadOf(String code) {
  final body = code.substring(4);
  return base64Url.decode(body + '=' * ((4 - body.length % 4) % 4));
}
