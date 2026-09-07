/// Paste-able text codes — the entire transport for buddy challenges.
///
/// There is no backend (ADR 004), no QR generation, no deep links and no
/// account: two people exchange short strings through whatever messaging
/// app they already use, and each device reconstructs the shared state
/// from the string alone.
///
/// # THE PRIVACY INVARIANT
///
/// **A progress code carries exactly five things: the challenge id, a
/// self-chosen display name, one percentage, a date, and a random
/// per-challenge author tag.**
///
/// It does not carry — and no future version of this file may add without
/// re-arguing this paragraph — how far they ran, how many sessions they
/// logged, what their adjusted target was, how many of their days were
/// protected, or anything else derived from their cycle, their flares or their
/// recovery days. Their target is pro-rated privately on their own device
/// (`challenge_progress_engine.dart`); only the ratio crosses the gap.
///
/// The author tag is four bytes of noise drawn once per challenge, per
/// device, at the moment they create or join it — see
/// [ProgressCodePayload.authorTag]. It is a function of a random number
/// generator and nothing else: it is not derived from their name, their
/// device, their account (there is none), their body or their calendar, so it
/// says nothing about them that a coin-flip would not. Its whole job is to
/// let a device recognise its *own* code and refuse to import it, which is
/// what stops someone who pastes their own progress code back into their own
/// buddy box from silently overwriting their buddy's snapshot with their own
/// figure.
///
/// This is not a matter of taste. Cycle data is S3
/// (`knowledge/engineering/security_and_privacy.md`) and the person on the
/// other end of the code is by definition someone the user knows well
/// enough to train with — exactly the person best placed to notice that a
/// number moved. If a code carried both raw distance and percentage, the
/// adjusted target would be one division away, protected days one
/// subtraction after that, and a period would be inferable from a text
/// message. So the raw figure never leaves.
///
/// Enforced structurally, not by convention: [encodeProgressCode] takes a
/// percentage, a name, a date and an author tag. It has no parameter that
/// could hold anything else, and it is handed no object it could reach
/// into. `challenge_codes_privacy_test.dart` pins the byte-level
/// consequence — a participant with protected days and one without produce
/// codes of identical shape and length, differing only in the percentage.
///
/// # Format
///
/// ```text
/// FC1.<base64url>    a challenge code   (created once, shared once)
/// FP1.<base64url>    a progress code    (exported and pasted repeatedly)
/// ```
///
/// * `F` marks the family, `C`/`P` the code kind, the digits the **format
///   version**, `.` ends the prefix. A decoder that meets a version it
///   does not know says so ([CodeRejection.unsupportedVersion]) instead of
///   guessing, so a v2 format can circulate alongside v1 without either
///   side producing a garbage challenge.
/// * **`FP1` was amended before release, and stays `FP1`.** The progress
///   payload gained its four author-tag bytes after the format was first
///   written and before v1 ever shipped, so no code of the older shape has
///   ever existed outside this repository and there is nothing for a v2 to
///   be compatible with. The version digit buys forward compatibility for
///   codes that have circulated; spending it on a pre-release edit would
///   have taught the next reader that the digit tracks edits rather than
///   releases. **From the first shipped build, this rule inverts: any
///   change to either payload's field list is a new version number.**
/// * The body is a compact **binary** payload, base64url-encoded with
///   padding stripped. Binary rather than JSON because the whole budget is
///   about 120 characters — a friendly length for a chat message — and
///   JSON spends most of that on punctuation and field names. Every field
///   is fixed-width or length-prefixed, so there is no separator to
///   escape and no ambiguity to parse around.
/// * The last two bytes are a **CRC-16/CCITT** over everything before
///   them. A code that lost a character to a line wrap or gained one to an
///   autocorrect is rejected ([CodeRejection.checksumFailed]) rather than
///   decoded into a plausible-looking wrong challenge. CRC-16 is a typo
///   detector, not a signature: these codes are not secrets and nothing
///   here defends against a determined forger, which is the correct threat
///   model for a string two friends send each other on purpose.
///
/// Real examples — "100 km of running through September", and one
/// participant's progress in it (23 and 40 characters; the longest a
/// progress code can get, with a full 24-byte name, is 67):
///
/// ```text
/// FC1.AQABA-gJgx1b4wyKWKg
/// FP1.AQABA-gJgx1b4wyKAoIJlHo_kcQEQWxleCoB
/// ```
///
/// # Challenge payload (12 bytes + 2 CRC)
///
/// | offset | size | field |
/// |---|---|---|
/// | 0 | 1 | kind (1 = distance, 2 = sessions) |
/// | 1 | 2 | activity-type bitmask, BE ([codeActivityTypes] order) |
/// | 3 | 2 | target in the kind's units, BE |
/// | 5 | 2 | window start, days since [codeEpoch], BE |
/// | 7 | 1 | window length in days, minus one |
/// | 8 | 4 | salt, BE |
///
/// **The challenge id is the base64url of those 12 bytes.** Not a UUIDv7,
/// and that is the one deliberate departure from ADR 004's id convention
/// in this schema: both devices must arrive at the same id from the code
/// alone, and shipping a 16-byte UUID inside the code would spend 22
/// characters to say what the payload already says. Deriving the id from
/// the defining bytes also makes re-encoding stable for free — the same
/// challenge always produces the same code, so a user can re-share it
/// without creating a second challenge — and makes a duplicate join a
/// primary-key collision rather than something the app has to notice.
///
/// # Progress payload (21 bytes + name + 2 CRC)
///
/// | offset | size | field |
/// |---|---|---|
/// | 0 | 12 | the challenge's own 12 defining bytes |
/// | 12 | 2 | progress percent × 10, BE, **floored** |
/// | 14 | 2 | as-of day, days since [codeEpoch], BE |
/// | 16 | 4 | author tag, BE |
/// | 20 | 1 | display-name length in UTF-8 bytes |
/// | 21 | n | display name, UTF-8 |
///
/// The percentage is fixed-width whatever its value, and so is the author
/// tag, so a code's length depends only on the length of the name its
/// owner chose — see the privacy invariant above.
///
/// The percentage is **floored** to the tenth below rather than rounded,
/// because every display of it floors too
/// (`presentation/challenges_copy.dart#formatPercent`). Rounding here
/// would let 99.97% cross the goal line on the receiving device while
/// reading as 99% on the device that sent it, and "they say they finished,
/// my phone says they did not" is the one disagreement a feature with no
/// server to arbitrate cannot afford.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';

/// The day counts in both payloads are measured from here. Chosen well
/// before the app existed and never moved: a change would silently
/// reinterpret every code in circulation.
final LocalDate codeEpoch = LocalDate(2020, 1, 1);

/// The bit order of the activity-type mask. **Frozen forever.**
///
/// A shipped code's mask means these types in this order. Appending a new
/// type at the end is safe (old decoders reject the unknown bit — see
/// [CodeRejection.unsupportedContent]); inserting or reordering one
/// silently reinterprets every code ever sent. `challenge_codes_test.dart`
/// pins this list so adding an [ActivityType] fails loudly here rather
/// than quietly on someone's phone.
const List<ActivityType> codeActivityTypes = [
  ActivityType.run,
  ActivityType.walk,
  ActivityType.hike,
  ActivityType.ride,
  ActivityType.strength,
  ActivityType.yoga,
  ActivityType.hiit,
  ActivityType.pilates,
  ActivityType.swim,
  ActivityType.other,
];

/// The format version this build writes. Decoding anything else is a
/// typed rejection, never a guess.
const int challengeCodeVersion = 1;

/// The greatest number of UTF-8 bytes a display name may occupy in a
/// progress code. Wide enough for a real name or a nickname, narrow
/// enough to keep the code inside the length budget — and narrow enough
/// that a name is a name rather than somewhere to paste a paragraph.
const int maxDisplayNameBytes = 24;

/// Why a pasted code could not be used. Every failure mode is one of
/// these — nothing here throws, and nothing returns a half-decoded value.
enum CodeRejection {
  /// Not a code at all: wrong prefix, unparseable base64, or too short to
  /// hold the fields the format requires.
  malformed,

  /// A code from a format version this build does not know. Distinct from
  /// [malformed] on purpose: the honest message is "update the app", not
  /// "your friend sent you nonsense".
  unsupportedVersion,

  /// A valid code of the other kind — a challenge code pasted into the
  /// progress box, or the reverse. Worth its own value because it is the
  /// single likeliest user mistake in this feature.
  wrongCodeKind,

  /// The checksum did not match: the code was corrupted in transit or in
  /// the paste. Rejecting is the whole point — a one-character change to
  /// the payload would otherwise land on a different, entirely plausible
  /// challenge.
  checksumFailed,

  /// Structurally sound, but it names something this build cannot
  /// represent — an activity type or challenge kind added after it
  /// shipped. Same honest answer as [unsupportedVersion]: update, don't
  /// guess.
  unsupportedContent,
}

/// The outcome of decoding a code: a value or a typed rejection, never an
/// exception. Same convention as `streaks/domain/recovery_validation.dart`
/// — an expected outcome is a sealed return value
/// (`knowledge/engineering/error_handling.md`).
sealed class CodeDecode<T> {
  const CodeDecode();

  /// The decoded value, or null when this is a rejection.
  T? get valueOrNull => switch (this) {
    CodeDecoded<T>(:final value) => value,
    CodeRejected<T>() => null,
  };
}

/// A code that decoded cleanly.
final class CodeDecoded<T> extends CodeDecode<T> {
  const CodeDecoded(this.value);

  final T value;
}

/// A code that could not be used, and why.
final class CodeRejected<T> extends CodeDecode<T> {
  const CodeRejected(this.reason);

  final CodeRejection reason;
}

/// What a progress code says: a challenge id, a name, a percentage, a date
/// and the author tag of the device that wrote it. The complete contents —
/// see the privacy invariant on this library.
class ProgressCodePayload {
  const ProgressCodePayload({
    required this.challengeId,
    required this.displayName,
    required this.progressPercent,
    required this.asOf,
    required this.authorTag,
  });

  final String challengeId;
  final String displayName;
  final double progressPercent;
  final LocalDate asOf;

  /// The 32-bit tag of the device that exported this code, drawn at random
  /// when that device created or joined the challenge.
  ///
  /// Compared against the importing device's own tag and used for exactly
  /// one decision: a code whose tag is ours is our own code coming back,
  /// and importing it would overwrite the buddy's snapshot with our own
  /// figure (`application/challenge_code_service.dart#importProgressCode`).
  /// It is random noise and identifies no person — see the privacy
  /// invariant on this library.
  final int authorTag;
}

/// Builds a [ChallengeBlueprint] with the deterministic id its own fields
/// imply. **The only correct way to make one** — constructing a blueprint
/// by hand with an invented id produces something whose code decodes to a
/// different challenge on the other device.
///
/// Throws [ArgumentError] for a challenge the 12-byte payload cannot hold
/// exactly: a target above [maxRepresentableTargetUnits], a window longer
/// than [maxRepresentableWindowDays] or ending before it starts, a window
/// start outside [codeEpoch]`..`[codeEpoch]`+65535 days`, or a salt outside
/// 32 bits. Every one of those used to be silently truncated by the
/// bit-masking below, and a truncated field is the worst failure this
/// format has: two devices would agree on an id while disagreeing about
/// what the challenge asks for, and neither would have anything to notice.
/// `domain/challenge_validation.dart` keeps user input far inside these
/// bounds, so reaching one of them means a caller built a blueprint by
/// hand — a programming error, and thrown as one.
ChallengeBlueprint challengeBlueprintFrom({
  required ChallengeKind kind,
  required Set<ActivityType> activityTypes,
  required int targetUnits,
  required LocalDate windowStart,
  required LocalDate windowEnd,
  required int salt,
}) {
  final bytes = _challengeBytes(
    kind: kind,
    activityTypes: activityTypes,
    targetUnits: targetUnits,
    windowStart: windowStart,
    windowEnd: windowEnd,
    salt: salt,
  );
  return ChallengeBlueprint(
    id: _base64(bytes),
    kind: kind,
    activityTypes: activityTypes,
    targetUnits: targetUnits,
    windowStart: windowStart,
    windowEnd: windowEnd,
    salt: salt,
  );
}

/// The shareable code for [blueprint]. Stable: the same blueprint always
/// produces the same string, so re-sharing is re-sharing rather than a
/// second challenge.
String encodeChallengeCode(ChallengeBlueprint blueprint) {
  final bytes = _challengeBytes(
    kind: blueprint.kind,
    activityTypes: blueprint.activityTypes,
    targetUnits: blueprint.targetUnits,
    windowStart: blueprint.windowStart,
    windowEnd: blueprint.windowEnd,
    salt: blueprint.salt,
  );
  return '${_prefix(_CodeKind.challenge)}${_base64(_withCrc(bytes))}';
}

/// Decodes a challenge code into the blueprint both devices share.
CodeDecode<ChallengeBlueprint> decodeChallengeCode(String code) {
  final body = _readBody(code, _CodeKind.challenge);
  switch (body) {
    case CodeRejected(:final reason):
      return CodeRejected(reason);
    case CodeDecoded(:final value):
      if (value.length != _challengeBytesLength) {
        return const CodeRejected(CodeRejection.malformed);
      }
      return _readChallengeBytes(value);
  }
}

/// Builds a progress code.
///
/// **Read the privacy invariant at the top of this library before
/// changing this signature.** The parameter list is the enforcement: there
/// is nowhere here to put a distance, a target, or a protected-day count,
/// and callers hand over a number rather than a
/// `ChallengeSelfProgress` so there is nothing to reach
/// into either.
///
/// [progressPercent] is stored to one decimal place, **floored** (see the
/// library's payload table for why never rounded), and saturates at
/// 6553.5% — a bound nobody will meet, present only so the field is
/// fixed-width. A non-finite value reads as 0 rather than corrupting the
/// payload.
///
/// [authorTag] is this device's tag for this challenge (`Challenge
/// .authorTag`), so the buddy's device can tell the code apart from its
/// own. Throws [ArgumentError] if it does not fit in 32 bits.
String encodeProgressCode({
  required String challengeId,
  required String displayName,
  required double progressPercent,
  required LocalDate asOf,
  required int authorTag,
}) {
  final idBytes = _decodeBase64(challengeId);
  if (idBytes == null || idBytes.length != _challengeBytesLength) {
    throw ArgumentError.value(
      // S1: the id is not sensitive, but it is long and pointless in a
      // message - name the argument, not the value.
      'challengeId',
      'challengeId',
      'not a challenge id produced by challengeBlueprintFrom',
    );
  }
  _requireU32(authorTag, 'authorTag');
  final nameBytes = _clampedNameBytes(displayName);

  final tenths = progressPercent.isFinite
      ? _clampInt((progressPercent * 10).floor(), 0xFFFF)
      : 0;

  final builder = BytesBuilder()
    ..add(idBytes)
    ..add(_u16(tenths))
    ..add(_u16(_epochDays(asOf)))
    ..add(_u32(authorTag))
    ..addByte(nameBytes.length)
    ..add(nameBytes);

  return '${_prefix(_CodeKind.progress)}'
      '${_base64(_withCrc(builder.toBytes()))}';
}

/// Decodes a progress code.
CodeDecode<ProgressCodePayload> decodeProgressCode(String code) {
  final body = _readBody(code, _CodeKind.progress);
  if (body case CodeRejected(:final reason)) return CodeRejected(reason);
  final bytes = (body as CodeDecoded<Uint8List>).value;

  if (bytes.length < _progressHeaderLength) {
    return const CodeRejected(CodeRejection.malformed);
  }
  final nameLength = bytes[_progressHeaderLength - 1];
  if (bytes.length != _progressHeaderLength + nameLength ||
      nameLength > maxDisplayNameBytes) {
    return const CodeRejected(CodeRejection.malformed);
  }

  final idBytes = Uint8List.sublistView(bytes, 0, _challengeBytesLength);
  // The id half of a progress code is the challenge's own defining bytes,
  // so it must decode as a challenge would - a code naming a kind or an
  // activity type this build does not know is unusable even though its
  // percentage would parse.
  final blueprint = _readChallengeBytes(idBytes);
  if (blueprint is CodeRejected<ChallengeBlueprint>) {
    return CodeRejected(blueprint.reason);
  }

  final String displayName;
  try {
    displayName = utf8.decode(
      Uint8List.sublistView(bytes, _progressHeaderLength),
    );
  } on FormatException {
    // A truncated multi-byte sequence: the length prefix survived but the
    // name did not. Malformed, not a checksum failure - the CRC already
    // passed, so this is a badly built code rather than a corrupted one.
    return const CodeRejected(CodeRejection.malformed);
  }

  return CodeDecoded(
    ProgressCodePayload(
      challengeId: _base64(idBytes),
      displayName: displayName,
      progressPercent: _readU16(bytes, _challengeBytesLength) / 10,
      asOf: codeEpoch.addDays(_readU16(bytes, _challengeBytesLength + 2)),
      authorTag: _readU32(bytes, _challengeBytesLength + 4),
    ),
  );
}

/// UTF-8 bytes of [name], truncated on a character boundary so the result
/// never exceeds [maxDisplayNameBytes].
///
/// Truncation is by whole runes rather than by bytes: cutting mid-sequence
/// would produce a name that fails to decode on the other device, which is
/// a far worse outcome than a shortened one.
Uint8List _clampedNameBytes(String name) {
  final trimmed = name.trim();
  var bytes = utf8.encode(trimmed);
  if (bytes.length <= maxDisplayNameBytes) return Uint8List.fromList(bytes);

  final runes = trimmed.runes.toList();
  var end = runes.length;
  while (end > 0) {
    end--;
    bytes = utf8.encode(String.fromCharCodes(runes.take(end)));
    if (bytes.length <= maxDisplayNameBytes) break;
  }
  return Uint8List.fromList(bytes);
}

enum _CodeKind {
  challenge('C'),
  progress('P');

  const _CodeKind(this.letter);

  final String letter;
}

const int _challengeBytesLength = 12;

/// Id bytes + percent + as-of + author tag + the name-length byte.
const int _progressHeaderLength = _challengeBytesLength + 9;

const int _crcLength = 2;

/// The largest target a challenge payload's 2-byte field can hold.
const int maxRepresentableTargetUnits = 0xFFFF;

/// The longest window a challenge payload can describe, both endpoints
/// included: the length byte holds `windowDays - 1`.
const int maxRepresentableWindowDays = 256;

/// The last day a window may start on: the start is stored as an unsigned
/// 16-bit day count from [codeEpoch].
final LocalDate maxRepresentableWindowStart = codeEpoch.addDays(0xFFFF);

String _prefix(_CodeKind kind) => 'F${kind.letter}$challengeCodeVersion.';

/// Case-insensitive on the prefix only — a code retyped in lower case
/// should still work, while the base64url body stays case-sensitive
/// because its alphabet is (the CRC catches a case-mangled body).
final RegExp _prefixPattern = RegExp(
  r'^F([A-Za-z])(\d{1,3})\.(.*)$',
  caseSensitive: false,
);

/// Strips and validates the prefix, base64-decodes the body, and checks
/// the CRC — the shared front half of both decoders.
CodeDecode<Uint8List> _readBody(String code, _CodeKind expected) {
  final match = _prefixPattern.firstMatch(code.trim());
  if (match == null) return const CodeRejected(CodeRejection.malformed);

  final kind = switch (match.group(1)!.toUpperCase()) {
    'C' => _CodeKind.challenge,
    'P' => _CodeKind.progress,
    _ => null,
  };
  if (kind == null) return const CodeRejected(CodeRejection.malformed);

  // Version is checked before kind: a v2 code of the *other* kind is
  // still, first and foremost, a version this build cannot read.
  final version = int.tryParse(match.group(2)!);
  if (version != challengeCodeVersion) {
    return const CodeRejected(CodeRejection.unsupportedVersion);
  }
  if (kind != expected) return const CodeRejected(CodeRejection.wrongCodeKind);

  final raw = _decodeBase64(match.group(3)!);
  if (raw == null || raw.length <= _crcLength) {
    return const CodeRejected(CodeRejection.malformed);
  }

  final payload = Uint8List.sublistView(raw, 0, raw.length - _crcLength);
  final expectedCrc = (raw[raw.length - 2] << 8) | raw[raw.length - 1];
  if (_crc16(payload) != expectedCrc) {
    return const CodeRejected(CodeRejection.checksumFailed);
  }
  return CodeDecoded(payload);
}

CodeDecode<ChallengeBlueprint> _readChallengeBytes(Uint8List bytes) {
  final kind = switch (bytes[0]) {
    1 => ChallengeKind.totalDistance,
    2 => ChallengeKind.sessionCount,
    _ => null,
  };
  if (kind == null) return const CodeRejected(CodeRejection.unsupportedContent);

  final mask = _readU16(bytes, 1);
  final knownMask = (1 << codeActivityTypes.length) - 1;
  if (mask & ~knownMask != 0) {
    // A bit for an activity type added after this build shipped. Counting
    // the types we do recognise would silently change what the challenge
    // asks for, so this is a rejection rather than a best effort.
    return const CodeRejected(CodeRejection.unsupportedContent);
  }
  final types = <ActivityType>{
    for (var bit = 0; bit < codeActivityTypes.length; bit++)
      if (mask & (1 << bit) != 0) codeActivityTypes[bit],
  };

  return CodeDecoded(
    ChallengeBlueprint(
      id: _base64(bytes),
      kind: kind,
      activityTypes: types,
      targetUnits: _readU16(bytes, 3),
      windowStart: codeEpoch.addDays(_readU16(bytes, 5)),
      windowEnd: codeEpoch.addDays(_readU16(bytes, 5) + bytes[7]),
      salt: _readU32(bytes, 8),
    ),
  );
}

Uint8List _challengeBytes({
  required ChallengeKind kind,
  required Set<ActivityType> activityTypes,
  required int targetUnits,
  required LocalDate windowStart,
  required LocalDate windowEnd,
  required int salt,
}) {
  // Checked here rather than only in `challengeBlueprintFrom` so a
  // blueprint built by `copyWith` cannot reach the bit-masking below
  // either: silent truncation is what makes two devices agree on an id
  // while disagreeing about the challenge (see that function's doc).
  if (targetUnits < 0 || targetUnits > maxRepresentableTargetUnits) {
    throw ArgumentError.value(
      targetUnits,
      'targetUnits',
      'must be 0..$maxRepresentableTargetUnits to fit a challenge code',
    );
  }
  final lengthDays = windowStart.difference(windowEnd);
  if (lengthDays < 0 || lengthDays >= maxRepresentableWindowDays) {
    throw ArgumentError.value(
      lengthDays + 1,
      'windowEnd',
      'a window must be 1..$maxRepresentableWindowDays days to fit a '
          'challenge code',
    );
  }
  final startDays = codeEpoch.difference(windowStart);
  if (startDays < 0 || startDays > 0xFFFF) {
    throw ArgumentError.value(
      windowStart.toIso(),
      'windowStart',
      'must fall between ${codeEpoch.toIso()} and '
          '${maxRepresentableWindowStart.toIso()} to fit a challenge code',
    );
  }
  _requireU32(salt, 'salt');

  var mask = 0;
  for (var bit = 0; bit < codeActivityTypes.length; bit++) {
    if (activityTypes.contains(codeActivityTypes[bit])) mask |= 1 << bit;
  }

  return Uint8List.fromList([
    switch (kind) {
      ChallengeKind.totalDistance => 1,
      ChallengeKind.sessionCount => 2,
    },
    ..._u16(mask),
    ..._u16(targetUnits),
    ..._u16(startDays),
    lengthDays,
    ..._u32(salt),
  ]);
}

int _epochDays(LocalDate day) => _clampInt(codeEpoch.difference(day), 0xFFFF);

/// `num.clamp` returns a `num`, which is a nuisance at every call site
/// that needs an `int` for bit work. Written out rather than cast.
int _clampInt(int value, int max) {
  if (value < 0) return 0;
  return value > max ? max : value;
}

void _requireU32(int value, String name) {
  if (value < 0 || value > 0xFFFFFFFF) {
    throw ArgumentError.value(value, name, 'must be an unsigned 32-bit value');
  }
}

List<int> _u16(int value) => [(value >> 8) & 0xFF, value & 0xFF];

int _readU16(Uint8List bytes, int offset) =>
    (bytes[offset] << 8) | bytes[offset + 1];

/// The two 32-bit fields (salt, author tag) are written and read with
/// multiplication rather than shifts.
///
/// Same reason the CRC below is written in 16-bit steps: on web an `int`
/// is a JavaScript double and `<<`/`>>` go through 32-bit **signed**
/// operations, so `bytes[0] << 24` reads back as a negative number for any
/// value with its top bit set. That would leave a salt — and therefore a
/// decoded blueprint — unequal to the one that was encoded on web only,
/// and would make a device fail to recognise its own author tag. Exact
/// integer arithmetic has neither problem on either platform.
List<int> _u32(int value) => [
  (value ~/ 0x1000000) & 0xFF,
  (value ~/ 0x10000) & 0xFF,
  (value ~/ 0x100) & 0xFF,
  value & 0xFF,
];

int _readU32(Uint8List bytes, int offset) =>
    bytes[offset] * 0x1000000 +
    bytes[offset + 1] * 0x10000 +
    bytes[offset + 2] * 0x100 +
    bytes[offset + 3];

Uint8List _withCrc(Uint8List payload) {
  final crc = _crc16(payload);
  return Uint8List.fromList([...payload, ..._u16(crc)]);
}

/// CRC-16/CCITT-FALSE (poly `0x1021`, init `0xFFFF`).
///
/// Written with 16-bit masked shifts and XORs only, deliberately: this app
/// ships to web, where Dart integers are JavaScript doubles and anything
/// above 2^53 silently loses precision. A 32- or 64-bit hash would have to
/// be written half-word at a time to be correct in a browser; a 16-bit CRC
/// simply cannot overflow. Two bytes is also the right size for the job —
/// this catches typos and truncation, and claims nothing more.
int _crc16(List<int> bytes) {
  var crc = 0xFFFF;
  for (final byte in bytes) {
    crc ^= (byte & 0xFF) << 8;
    crc &= 0xFFFF;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
      crc &= 0xFFFF;
    }
  }
  return crc;
}

String _base64(Uint8List bytes) => base64Url.encode(bytes).replaceAll('=', '');

/// Base64url-decodes [value], restoring the stripped padding. Returns null
/// for anything that is not valid base64url.
Uint8List? _decodeBase64(String value) {
  final padding = (4 - value.length % 4) % 4;
  if (padding == 3) return null;
  try {
    return base64Url.decode(value + '=' * padding);
  } on FormatException {
    return null;
  }
}
