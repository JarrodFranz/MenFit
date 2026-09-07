import 'dart:math';

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge_validation.dart';

/// Everything that turns a pasted string into stored state, and back.
///
/// The one piece of this feature that is neither pure domain nor
/// persistence: it validates, encodes, decodes and writes, with no rules
/// of its own — exactly the shape `architecture_overview.md` reserves the
/// `application/` layer for.
///
/// **Nothing here can widen what a progress code carries.** Exporting goes
/// through [progressCodeFor], which takes a percentage and hands it to
/// `challenge_codes.dart#encodeProgressCode`; neither function is given
/// the user's raw distance, their adjusted target, or their protected days.
/// See that library's privacy invariant.
class ChallengeCodeService {
  ChallengeCodeService(
    this._repository, {
    DateTime Function()? clock,
    int Function()? generateSalt,
    int Function()? generateAuthorTag,
  }) : _clock = clock ?? DateTime.now,
       _generateSalt = generateSalt ?? _random32,
       _generateAuthorTag = generateAuthorTag ?? _random32;

  final ChallengeRepository _repository;
  final DateTime Function() _clock;
  final int Function() _generateSalt;
  final int Function() _generateAuthorTag;

  static final Random _random = Random();

  /// A fresh 32-bit value, for a salt or an author tag.
  ///
  /// `Random` rather than `Random.secure` on purpose, for both uses. The
  /// salt exists so two challenges created with identical parameters on
  /// the same day are still two challenges, not to make a code
  /// unguessable: there is nothing behind a challenge code to guess your
  /// way into — no account, no data, no server. A code is a description of
  /// a shared goal, and the only thing knowing one lets you do is join it.
  /// The author tag is a tie-breaker between two devices in the same
  /// challenge, not a credential — forging one buys an attacker the
  /// ability to have a progress code they wrote *ignored*.
  static int _random32() => _random.nextInt(0x100000000);

  /// Creates a challenge, persists it, and returns it with the code to
  /// share.
  ///
  /// [targetUnits] is in the kind's own units — hundreds of metres for
  /// [ChallengeKind.totalDistance], sessions for
  /// [ChallengeKind.sessionCount] (see [ChallengeBlueprint.targetUnits]).
  Future<CreateChallengeResult> createChallenge({
    required ChallengeKind kind,
    required Set<ActivityType> activityTypes,
    required int targetUnits,
    required LocalDate windowStart,
    required LocalDate windowEnd,
    required String displayName,
    required LocalDate today,
  }) async {
    final validation = validateChallenge(
      kind: kind,
      targetUnits: targetUnits,
      windowStart: windowStart,
      windowEnd: windowEnd,
      displayName: displayName,
      today: today,
    );
    if (!validation.isValid) return ChallengeNotCreated(validation);

    final blueprint = challengeBlueprintFrom(
      kind: kind,
      activityTypes: activityTypes,
      targetUnits: targetUnits,
      windowStart: windowStart,
      windowEnd: windowEnd,
      salt: _generateSalt(),
    );
    final challenge = Challenge(
      blueprint: blueprint,
      selfDisplayName: displayName.trim(),
      origin: ChallengeOrigin.created,
      authorTag: _generateAuthorTag(),
      createdAt: _clock().toUtc(),
    );
    await _repository.saveChallenge(challenge);
    return ChallengeCreated(
      challenge: challenge,
      code: encodeChallengeCode(blueprint),
    );
  }

  /// Joins the challenge a pasted [code] describes.
  ///
  /// Pasting a code for a challenge already held is **not an error**: it
  /// returns [ChallengeAlreadyJoined] carrying the row as it stands, with
  /// their existing display name and their buddy's last snapshot untouched.
  /// The alternative — overwriting — would let a re-shared code silently
  /// wipe progress they had already imported.
  ///
  /// The window is re-validated on this side. A code that arrives long
  /// after its window has passed, or that names a window this build
  /// considers absurd, is rejected here rather than stored as a challenge
  /// nobody can act on.
  Future<JoinChallengeResult> joinFromCode(
    String code, {
    required String displayName,
    required LocalDate today,
  }) async {
    final decoded = decodeChallengeCode(code);
    if (decoded case CodeRejected(:final reason)) {
      return ChallengeCodeUnusable(reason);
    }
    final blueprint = (decoded as CodeDecoded<ChallengeBlueprint>).value;

    final validation = validateChallenge(
      kind: blueprint.kind,
      targetUnits: blueprint.targetUnits,
      windowStart: blueprint.windowStart,
      windowEnd: blueprint.windowEnd,
      displayName: displayName,
      today: today,
    );
    if (!validation.isValid) return ChallengeJoinRejected(validation);

    final existing = await _repository.getChallenge(blueprint.id);
    if (existing != null) return ChallengeAlreadyJoined(existing);

    final challenge = Challenge(
      blueprint: blueprint,
      selfDisplayName: displayName.trim(),
      origin: ChallengeOrigin.joined,
      authorTag: _generateAuthorTag(),
      createdAt: _clock().toUtc(),
    );
    await _repository.saveChallenge(challenge);
    return ChallengeJoined(challenge);
  }

  /// The progress code to hand to the buddy.
  ///
  /// [progressPercent] comes from
  /// `domain/challenge_progress_engine.dart`'s
  /// `ChallengeSelfProgress.percent` and is the **only** thing about their
  /// standing that crosses the gap — see this class's doc and the privacy
  /// invariant on `domain/challenge_codes.dart`.
  String progressCodeFor(
    Challenge challenge, {
    required double progressPercent,
    required LocalDate asOf,
  }) {
    return encodeProgressCode(
      challengeId: challenge.id,
      displayName: challenge.selfDisplayName,
      progressPercent: progressPercent,
      asOf: asOf,
      authorTag: challenge.authorTag,
    );
  }

  /// Applies a pasted progress code to the challenge it names.
  ///
  /// **Their own code coming back is not an import.** Every progress code
  /// carries the author tag of the device that wrote it
  /// (`domain/challenge_codes.dart`), and a code whose tag matches this
  /// challenge's own is one this device exported — pasted back by mistake,
  /// or quoted back in the chat thread the two of them are using. Writing
  /// it would replace the buddy's snapshot with the user's own percentage
  /// under the buddy's name, which is worse than useless: it is a wrong
  /// number about someone else that looks exactly like a right one. It is
  /// reported as [BuddyProgressIsYourOwn] instead.
  ///
  /// **A stale code can never regress the snapshot.** Codes travel through
  /// chat threads, so one exported on Monday can perfectly well be pasted
  /// on Friday, after Wednesday's has already landed. A snapshot strictly
  /// older than the stored one is reported as [BuddyProgressNotNewer]
  /// rather than written — the buddy's progress would otherwise appear to
  /// fall, which is both wrong and, in a feature built to avoid making
  /// anyone feel behind, exactly the wrong kind of wrong.
  ///
  /// **A code for the same day is applied, unless it says the same thing.**
  /// Two codes exported on one day are an ordinary event — they train
  /// twice, or fixes a name — and the later paste is the one the user
  /// chose to paste, so it wins. Only a code that would change nothing is
  /// reported as [BuddyProgressNotNewer], which is what keeps re-pasting
  /// the identical string idempotent.
  Future<ImportProgressResult> importProgressCode(String code) async {
    final decoded = decodeProgressCode(code);
    if (decoded case CodeRejected(:final reason)) {
      return BuddyProgressUnusable(reason);
    }
    final payload = (decoded as CodeDecoded<ProgressCodePayload>).value;

    final challenge = await _repository.getChallenge(payload.challengeId);
    if (challenge == null) return const BuddyProgressUnknownChallenge();

    if (payload.authorTag == challenge.authorTag) {
      return BuddyProgressIsYourOwn(challenge);
    }

    final existing = challenge.buddy;
    if (existing != null && _changesNothing(existing, payload)) {
      return BuddyProgressNotNewer(challenge);
    }
    if (existing != null && payload.asOf.isBefore(existing.asOf)) {
      return BuddyProgressNotNewer(challenge);
    }

    final updated = challenge.copyWith(
      buddy: ChallengeBuddySnapshot(
        displayName: payload.displayName,
        progressPercent: payload.progressPercent,
        asOf: payload.asOf,
      ),
    );
    await _repository.saveChallenge(updated);
    return BuddyProgressImported(updated);
  }

  /// Whether [payload] would write exactly what is already stored.
  ///
  /// The percentage is quantised to a tenth by the wire format, so two
  /// codes saying the same thing decode to the same `double` exactly —
  /// this is an equality between two values that came off the same
  /// two bytes, not a comparison of two computed figures.
  bool _changesNothing(
    ChallengeBuddySnapshot existing,
    ProgressCodePayload payload,
  ) {
    return existing.asOf == payload.asOf &&
        existing.progressPercent == payload.progressPercent &&
        existing.displayName == payload.displayName;
  }
}

/// Outcome of [ChallengeCodeService.createChallenge].
sealed class CreateChallengeResult {
  const CreateChallengeResult();
}

final class ChallengeCreated extends CreateChallengeResult {
  const ChallengeCreated({required this.challenge, required this.code});

  final Challenge challenge;

  /// The string to share. Stable — re-encoding the same challenge later
  /// produces this same code.
  final String code;
}

final class ChallengeNotCreated extends CreateChallengeResult {
  const ChallengeNotCreated(this.validation);

  final ChallengeValidation validation;
}

/// Outcome of [ChallengeCodeService.joinFromCode].
sealed class JoinChallengeResult {
  const JoinChallengeResult();
}

final class ChallengeJoined extends JoinChallengeResult {
  const ChallengeJoined(this.challenge);

  final Challenge challenge;
}

/// The code was fine and names a challenge already held — a normal
/// outcome, not a failure.
final class ChallengeAlreadyJoined extends JoinChallengeResult {
  const ChallengeAlreadyJoined(this.challenge);

  final Challenge challenge;
}

final class ChallengeCodeUnusable extends JoinChallengeResult {
  const ChallengeCodeUnusable(this.reason);

  final CodeRejection reason;
}

/// The code decoded, but what it describes (or the name they picked) did
/// not pass validation on this side.
final class ChallengeJoinRejected extends JoinChallengeResult {
  const ChallengeJoinRejected(this.validation);

  final ChallengeValidation validation;
}

/// Outcome of [ChallengeCodeService.importProgressCode].
sealed class ImportProgressResult {
  const ImportProgressResult();
}

final class BuddyProgressImported extends ImportProgressResult {
  const BuddyProgressImported(this.challenge);

  final Challenge challenge;
}

/// The code was valid but says nothing new — either older than what is
/// stored, or identical to it — so nothing changed.
final class BuddyProgressNotNewer extends ImportProgressResult {
  const BuddyProgressNotNewer(this.challenge);

  final Challenge challenge;
}

/// The code was one this device exported for this challenge, pasted back
/// into its own buddy box. Nothing was written.
final class BuddyProgressIsYourOwn extends ImportProgressResult {
  const BuddyProgressIsYourOwn(this.challenge);

  final Challenge challenge;
}

/// A valid progress code for a challenge this device does not hold —
/// typically the buddy's code arriving before the challenge code was
/// joined.
final class BuddyProgressUnknownChallenge extends ImportProgressResult {
  const BuddyProgressUnknownChallenge();
}

final class BuddyProgressUnusable extends ImportProgressResult {
  const BuddyProgressUnusable(this.reason);

  final CodeRejection reason;
}
