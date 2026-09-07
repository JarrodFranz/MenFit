import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_view_providers.g.dart';

/// One challenge, watched by id — what the detail screen is looking at.
///
/// Presentation-layer rather than part of the feature's composition
/// surface (`challenges_providers.dart`) for the same reason as
/// `features/weight/presentation/weight_history_providers.dart`: no other
/// feature has any business asking for one challenge by id, and ADR 007's
/// surface is for what crosses feature boundaries, not for everything
/// this feature happens to need.
///
/// Emits `null` when the row is gone — a challenge deleted while a screen
/// held its id — so the detail screen can say so rather than throw.
@riverpod
Stream<Challenge?> challengeDetail(Ref ref, String challengeId) {
  return ref.watch(challengeRepositoryProvider).watchChallenge(challengeId);
}

/// Assembles the [ChallengePair] the cards and the detail screen render.
///
/// A plain function rather than a provider: the list screen already holds
/// every [Challenge] from `activeChallengesProvider`, and re-watching each
/// one by id would open a second query stream per card to learn what the
/// first stream already said.
///
/// Returns `null` while [progress] is still loading — a card with a bar at
/// zero would be a claim, and "not known yet" is not zero.
ChallengePair? challengePairOf(
  Challenge challenge,
  ChallengeSelfProgress? progress,
) {
  if (progress == null) return null;
  final buddy = challenge.buddy;
  return ChallengePair(
    challenge: challenge,
    self: SelfParticipant(
      displayName: challenge.selfDisplayName,
      progress: progress,
    ),
    buddy: buddy == null ? null : BuddyParticipant(buddy),
  );
}
