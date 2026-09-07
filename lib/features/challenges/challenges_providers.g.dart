// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenges_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persistence for challenges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.

@ProviderFor(challengeRepository)
final challengeRepositoryProvider = ChallengeRepositoryProvider._();

/// Persistence for challenges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.

final class ChallengeRepositoryProvider
    extends
        $FunctionalProvider<
          ChallengeRepository,
          ChallengeRepository,
          ChallengeRepository
        >
    with $Provider<ChallengeRepository> {
  /// Persistence for challenges, typed as the domain interface so nothing
  /// above `data/` knows Drift is behind it.
  ChallengeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChallengeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChallengeRepository create(Ref ref) {
    return challengeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeRepository>(value),
    );
  }
}

String _$challengeRepositoryHash() =>
    r'c88dc18d72e39f60eedd470a71e839703d1feaa6';

/// The calendar day everything below is evaluated against.
///
/// A provider rather than a `LocalDate.today()` call inside each consumer
/// so "today" is an explicit, overridable seam — a test that cannot pin
/// today cannot pin a window boundary. Same pattern as
/// `achievements_providers.dart#achievementsToday` and
/// `insights_providers.dart#insightsToday`.

@ProviderFor(challengesToday)
final challengesTodayProvider = ChallengesTodayProvider._();

/// The calendar day everything below is evaluated against.
///
/// A provider rather than a `LocalDate.today()` call inside each consumer
/// so "today" is an explicit, overridable seam — a test that cannot pin
/// today cannot pin a window boundary. Same pattern as
/// `achievements_providers.dart#achievementsToday` and
/// `insights_providers.dart#insightsToday`.

final class ChallengesTodayProvider
    extends $FunctionalProvider<LocalDate, LocalDate, LocalDate>
    with $Provider<LocalDate> {
  /// The calendar day everything below is evaluated against.
  ///
  /// A provider rather than a `LocalDate.today()` call inside each consumer
  /// so "today" is an explicit, overridable seam — a test that cannot pin
  /// today cannot pin a window boundary. Same pattern as
  /// `achievements_providers.dart#achievementsToday` and
  /// `insights_providers.dart#insightsToday`.
  ChallengesTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengesTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengesTodayHash();

  @$internal
  @override
  $ProviderElement<LocalDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalDate create(Ref ref) {
    return challengesToday(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDate>(value),
    );
  }
}

String _$challengesTodayHash() => r'79c841b18757b671413b8ffe8c3db8dc495dac35';

/// Every challenge on this device, newest window first.

@ProviderFor(challenges)
final challengesProvider = ChallengesProvider._();

/// Every challenge on this device, newest window first.

final class ChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Challenge>>,
          List<Challenge>,
          Stream<List<Challenge>>
        >
    with $FutureModifier<List<Challenge>>, $StreamProvider<List<Challenge>> {
  /// Every challenge on this device, newest window first.
  ChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengesHash();

  @$internal
  @override
  $StreamProviderElement<List<Challenge>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Challenge>> create(Ref ref) {
    return challenges(ref);
  }
}

String _$challengesHash() => r'3649cec69ecc06fc68c9111669baae06044b5e7f';

/// Challenges whose window has not closed yet (today inclusive).
///
/// Derived from the window against [challengesToday], never a stored
/// flag: a challenge does not change when it ends — the calendar moves.
///
/// Reads the repository stream directly rather than mapping
/// [challenges]: Riverpod 3 removed `StreamProvider.stream`, and a Drift
/// query stream is cheap enough that a second subscription over a handful
/// of rows is the simpler correct answer.

@ProviderFor(activeChallenges)
final activeChallengesProvider = ActiveChallengesProvider._();

/// Challenges whose window has not closed yet (today inclusive).
///
/// Derived from the window against [challengesToday], never a stored
/// flag: a challenge does not change when it ends — the calendar moves.
///
/// Reads the repository stream directly rather than mapping
/// [challenges]: Riverpod 3 removed `StreamProvider.stream`, and a Drift
/// query stream is cheap enough that a second subscription over a handful
/// of rows is the simpler correct answer.

final class ActiveChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Challenge>>,
          List<Challenge>,
          Stream<List<Challenge>>
        >
    with $FutureModifier<List<Challenge>>, $StreamProvider<List<Challenge>> {
  /// Challenges whose window has not closed yet (today inclusive).
  ///
  /// Derived from the window against [challengesToday], never a stored
  /// flag: a challenge does not change when it ends — the calendar moves.
  ///
  /// Reads the repository stream directly rather than mapping
  /// [challenges]: Riverpod 3 removed `StreamProvider.stream`, and a Drift
  /// query stream is cheap enough that a second subscription over a handful
  /// of rows is the simpler correct answer.
  ActiveChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChallengesHash();

  @$internal
  @override
  $StreamProviderElement<List<Challenge>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Challenge>> create(Ref ref) {
    return activeChallenges(ref);
  }
}

String _$activeChallengesHash() => r'2777b19819ee4644f8315b616d24d082fc3e2ffc';

/// Challenges whose window has closed. Kept, not deleted — a finished
/// challenge is something they did, and the celebration card lives here.

@ProviderFor(archivedChallenges)
final archivedChallengesProvider = ArchivedChallengesProvider._();

/// Challenges whose window has closed. Kept, not deleted — a finished
/// challenge is something they did, and the celebration card lives here.

final class ArchivedChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Challenge>>,
          List<Challenge>,
          Stream<List<Challenge>>
        >
    with $FutureModifier<List<Challenge>>, $StreamProvider<List<Challenge>> {
  /// Challenges whose window has closed. Kept, not deleted — a finished
  /// challenge is something they did, and the celebration card lives here.
  ArchivedChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedChallengesHash();

  @$internal
  @override
  $StreamProviderElement<List<Challenge>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Challenge>> create(Ref ref) {
    return archivedChallenges(ref);
  }
}

String _$archivedChallengesHash() =>
    r'cf7bd49da3524bf146adba9657e766f6a2337630';

/// Where the user stands in one challenge, recomputed from their own logs.
///
/// Null when there is no such challenge (it was deleted while a screen
/// held its id).
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `achievements_providers.dart#badgeInputs`: it walks the activity log,
/// and re-running that on every unrelated write while nothing is looking
/// would be waste. It refreshes when invalidated, when `today` rolls over,
/// and whenever protection changes.
///
/// Every read is a genuine one-shot `get` or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot, which
/// deadlocks widget tests (see
/// `features/activity/domain/activity_repository.dart#getActivities`).
///
/// **Protection comes from `streaks`' single decision source**
/// (`streaks_providers.dart#protectedDays` over
/// `assembleProtectedDays`), never a re-derivation — a second definition
/// of "protected" would eventually disagree with the first, and the day it
/// did, a period would start raising the ask.
///
/// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
/// in this provider or below it is logged, and the adjusted target it
/// returns is never persisted or encoded — see
/// `domain/challenge_codes.dart`'s privacy invariant.

@ProviderFor(selfProgress)
final selfProgressProvider = SelfProgressFamily._();

/// Where the user stands in one challenge, recomputed from their own logs.
///
/// Null when there is no such challenge (it was deleted while a screen
/// held its id).
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `achievements_providers.dart#badgeInputs`: it walks the activity log,
/// and re-running that on every unrelated write while nothing is looking
/// would be waste. It refreshes when invalidated, when `today` rolls over,
/// and whenever protection changes.
///
/// Every read is a genuine one-shot `get` or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot, which
/// deadlocks widget tests (see
/// `features/activity/domain/activity_repository.dart#getActivities`).
///
/// **Protection comes from `streaks`' single decision source**
/// (`streaks_providers.dart#protectedDays` over
/// `assembleProtectedDays`), never a re-derivation — a second definition
/// of "protected" would eventually disagree with the first, and the day it
/// did, a period would start raising the ask.
///
/// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
/// in this provider or below it is logged, and the adjusted target it
/// returns is never persisted or encoded — see
/// `domain/challenge_codes.dart`'s privacy invariant.

final class SelfProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChallengeSelfProgress?>,
          ChallengeSelfProgress?,
          FutureOr<ChallengeSelfProgress?>
        >
    with
        $FutureModifier<ChallengeSelfProgress?>,
        $FutureProvider<ChallengeSelfProgress?> {
  /// Where the user stands in one challenge, recomputed from their own logs.
  ///
  /// Null when there is no such challenge (it was deleted while a screen
  /// held its id).
  ///
  /// One-shot (`Future`, not `Stream`) for the same reason as
  /// `achievements_providers.dart#badgeInputs`: it walks the activity log,
  /// and re-running that on every unrelated write while nothing is looking
  /// would be waste. It refreshes when invalidated, when `today` rolls over,
  /// and whenever protection changes.
  ///
  /// Every read is a genuine one-shot `get` or a `.future` on another
  /// feature's provider — never a `watchXxx().first` snapshot, which
  /// deadlocks widget tests (see
  /// `features/activity/domain/activity_repository.dart#getActivities`).
  ///
  /// **Protection comes from `streaks`' single decision source**
  /// (`streaks_providers.dart#protectedDays` over
  /// `assembleProtectedDays`), never a re-derivation — a second definition
  /// of "protected" would eventually disagree with the first, and the day it
  /// did, a period would start raising the ask.
  ///
  /// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
  /// in this provider or below it is logged, and the adjusted target it
  /// returns is never persisted or encoded — see
  /// `domain/challenge_codes.dart`'s privacy invariant.
  SelfProgressProvider._({
    required SelfProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selfProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selfProgressHash();

  @override
  String toString() {
    return r'selfProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChallengeSelfProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChallengeSelfProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return selfProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelfProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selfProgressHash() => r'b6ca6ce404a1cac9eea99d42b5324e3a214a9909';

/// Where the user stands in one challenge, recomputed from their own logs.
///
/// Null when there is no such challenge (it was deleted while a screen
/// held its id).
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `achievements_providers.dart#badgeInputs`: it walks the activity log,
/// and re-running that on every unrelated write while nothing is looking
/// would be waste. It refreshes when invalidated, when `today` rolls over,
/// and whenever protection changes.
///
/// Every read is a genuine one-shot `get` or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot, which
/// deadlocks widget tests (see
/// `features/activity/domain/activity_repository.dart#getActivities`).
///
/// **Protection comes from `streaks`' single decision source**
/// (`streaks_providers.dart#protectedDays` over
/// `assembleProtectedDays`), never a re-derivation — a second definition
/// of "protected" would eventually disagree with the first, and the day it
/// did, a period would start raising the ask.
///
/// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
/// in this provider or below it is logged, and the adjusted target it
/// returns is never persisted or encoded — see
/// `domain/challenge_codes.dart`'s privacy invariant.

final class SelfProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChallengeSelfProgress?>, String> {
  SelfProgressFamily._()
    : super(
        retry: null,
        name: r'selfProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Where the user stands in one challenge, recomputed from their own logs.
  ///
  /// Null when there is no such challenge (it was deleted while a screen
  /// held its id).
  ///
  /// One-shot (`Future`, not `Stream`) for the same reason as
  /// `achievements_providers.dart#badgeInputs`: it walks the activity log,
  /// and re-running that on every unrelated write while nothing is looking
  /// would be waste. It refreshes when invalidated, when `today` rolls over,
  /// and whenever protection changes.
  ///
  /// Every read is a genuine one-shot `get` or a `.future` on another
  /// feature's provider — never a `watchXxx().first` snapshot, which
  /// deadlocks widget tests (see
  /// `features/activity/domain/activity_repository.dart#getActivities`).
  ///
  /// **Protection comes from `streaks`' single decision source**
  /// (`streaks_providers.dart#protectedDays` over
  /// `assembleProtectedDays`), never a re-derivation — a second definition
  /// of "protected" would eventually disagree with the first, and the day it
  /// did, a period would start raising the ask.
  ///
  /// S3 data flows through here (`protectedDays` is cycle-derived). Nothing
  /// in this provider or below it is logged, and the adjusted target it
  /// returns is never persisted or encoded — see
  /// `domain/challenge_codes.dart`'s privacy invariant.

  SelfProgressProvider call(String challengeId) =>
      SelfProgressProvider._(argument: challengeId, from: this);

  @override
  String toString() => r'selfProgressProvider';
}

/// Creates, joins, exports and imports codes. Stateless apart from its
/// repository, so `keepAlive` costs nothing and saves rebuilding it on
/// every paste.

@ProviderFor(challengeCodeService)
final challengeCodeServiceProvider = ChallengeCodeServiceProvider._();

/// Creates, joins, exports and imports codes. Stateless apart from its
/// repository, so `keepAlive` costs nothing and saves rebuilding it on
/// every paste.

final class ChallengeCodeServiceProvider
    extends
        $FunctionalProvider<
          ChallengeCodeService,
          ChallengeCodeService,
          ChallengeCodeService
        >
    with $Provider<ChallengeCodeService> {
  /// Creates, joins, exports and imports codes. Stateless apart from its
  /// repository, so `keepAlive` costs nothing and saves rebuilding it on
  /// every paste.
  ChallengeCodeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeCodeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeCodeServiceHash();

  @$internal
  @override
  $ProviderElement<ChallengeCodeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChallengeCodeService create(Ref ref) {
    return challengeCodeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeCodeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeCodeService>(value),
    );
  }
}

String _$challengeCodeServiceHash() =>
    r'316b3bddde3f3ba8ea8d4fb0bc85d30b5668607c';
