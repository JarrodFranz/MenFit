// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persistence for earned badges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.

@ProviderFor(awardRepository)
final awardRepositoryProvider = AwardRepositoryProvider._();

/// Persistence for earned badges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.

final class AwardRepositoryProvider
    extends
        $FunctionalProvider<AwardRepository, AwardRepository, AwardRepository>
    with $Provider<AwardRepository> {
  /// Persistence for earned badges, typed as the domain interface so nothing
  /// above `data/` knows Drift is behind it.
  AwardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'awardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$awardRepositoryHash();

  @$internal
  @override
  $ProviderElement<AwardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AwardRepository create(Ref ref) {
    return awardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwardRepository>(value),
    );
  }
}

String _$awardRepositoryHash() => r'888a62a0154d0cd86a3aac2a800eece129138ac4';

/// Every award the user holds, newest first.

@ProviderFor(badgeAwards)
final badgeAwardsProvider = BadgeAwardsProvider._();

/// Every award the user holds, newest first.

final class BadgeAwardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BadgeAward>>,
          List<BadgeAward>,
          Stream<List<BadgeAward>>
        >
    with $FutureModifier<List<BadgeAward>>, $StreamProvider<List<BadgeAward>> {
  /// Every award the user holds, newest first.
  BadgeAwardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badgeAwardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badgeAwardsHash();

  @$internal
  @override
  $StreamProviderElement<List<BadgeAward>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BadgeAward>> create(Ref ref) {
    return badgeAwards(ref);
  }
}

String _$badgeAwardsHash() => r'bab1329facd2197b98d22f4e1be3e9a906d0e0d7';

/// The calendar day the evaluation is made against.
///
/// A provider rather than a `LocalDate.today()` call inside [badgeInputs]
/// so "today" is an explicit, overridable input — the engine below it is
/// deterministic, and a test that cannot pin today cannot pin a weekly
/// boundary, a season, or an early-morning hour. Same seam as
/// `features/insights/insights_providers.dart`'s `insightsToday`.

@ProviderFor(achievementsToday)
final achievementsTodayProvider = AchievementsTodayProvider._();

/// The calendar day the evaluation is made against.
///
/// A provider rather than a `LocalDate.today()` call inside [badgeInputs]
/// so "today" is an explicit, overridable input — the engine below it is
/// deterministic, and a test that cannot pin today cannot pin a weekly
/// boundary, a season, or an early-morning hour. Same seam as
/// `features/insights/insights_providers.dart`'s `insightsToday`.

final class AchievementsTodayProvider
    extends $FunctionalProvider<LocalDate, LocalDate, LocalDate>
    with $Provider<LocalDate> {
  /// The calendar day the evaluation is made against.
  ///
  /// A provider rather than a `LocalDate.today()` call inside [badgeInputs]
  /// so "today" is an explicit, overridable input — the engine below it is
  /// deterministic, and a test that cannot pin today cannot pin a weekly
  /// boundary, a season, or an early-morning hour. Same seam as
  /// `features/insights/insights_providers.dart`'s `insightsToday`.
  AchievementsTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementsTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementsTodayHash();

  @$internal
  @override
  $ProviderElement<LocalDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalDate create(Ref ref) {
    return achievementsToday(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDate>(value),
    );
  }
}

String _$achievementsTodayHash() => r'c2871aa243b5a8b532dc0e06825768973d4bf03d';

/// Everything the badge engine reads, pre-fetched from the owning
/// features' composition surfaces.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `insights_providers.dart#insightObservations` and
/// `recaps_providers.dart#recapForPeriod`: this walks the user's entire
/// history of activities, check-ins, water days and cycle records, and
/// re-running that on every unrelated log while the achievements screen
/// sits closed would be pure waste. It refreshes when invalidated, when
/// `today` rolls over, and when either of the two derived sources it
/// watches emits — which for a screen opened deliberately is soon enough.
///
/// Every read below is a genuine one-shot `get`, or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot: `Stream.first`
/// only completes once it has cancelled its subscription, and cancelling a
/// Drift query stream resolves through a root-zone future that escapes
/// `flutter_test`'s `FakeAsync`. See
/// `features/activity/domain/activity_repository.dart#getActivities`.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged or sent to analytics.

@ProviderFor(badgeInputs)
final badgeInputsProvider = BadgeInputsProvider._();

/// Everything the badge engine reads, pre-fetched from the owning
/// features' composition surfaces.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `insights_providers.dart#insightObservations` and
/// `recaps_providers.dart#recapForPeriod`: this walks the user's entire
/// history of activities, check-ins, water days and cycle records, and
/// re-running that on every unrelated log while the achievements screen
/// sits closed would be pure waste. It refreshes when invalidated, when
/// `today` rolls over, and when either of the two derived sources it
/// watches emits — which for a screen opened deliberately is soon enough.
///
/// Every read below is a genuine one-shot `get`, or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot: `Stream.first`
/// only completes once it has cancelled its subscription, and cancelling a
/// Drift query stream resolves through a root-zone future that escapes
/// `flutter_test`'s `FakeAsync`. See
/// `features/activity/domain/activity_repository.dart#getActivities`.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged or sent to analytics.

final class BadgeInputsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BadgeInputs>,
          BadgeInputs,
          FutureOr<BadgeInputs>
        >
    with $FutureModifier<BadgeInputs>, $FutureProvider<BadgeInputs> {
  /// Everything the badge engine reads, pre-fetched from the owning
  /// features' composition surfaces.
  ///
  /// One-shot (`Future`, not `Stream`) for the same reason as
  /// `insights_providers.dart#insightObservations` and
  /// `recaps_providers.dart#recapForPeriod`: this walks the user's entire
  /// history of activities, check-ins, water days and cycle records, and
  /// re-running that on every unrelated log while the achievements screen
  /// sits closed would be pure waste. It refreshes when invalidated, when
  /// `today` rolls over, and when either of the two derived sources it
  /// watches emits — which for a screen opened deliberately is soon enough.
  ///
  /// Every read below is a genuine one-shot `get`, or a `.future` on another
  /// feature's provider — never a `watchXxx().first` snapshot: `Stream.first`
  /// only completes once it has cancelled its subscription, and cancelling a
  /// Drift query stream resolves through a root-zone future that escapes
  /// `flutter_test`'s `FakeAsync`. See
  /// `features/activity/domain/activity_repository.dart#getActivities`.
  ///
  /// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
  /// nothing in this provider or below it is logged or sent to analytics.
  BadgeInputsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badgeInputsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badgeInputsHash();

  @$internal
  @override
  $FutureProviderElement<BadgeInputs> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BadgeInputs> create(Ref ref) {
    return badgeInputs(ref);
  }
}

String _$badgeInputsHash() => r'b161df4bbac7eacd00c074bbd24f40e48786b115';

/// Where the user stands on every badge in the catalogue, in catalogue
/// order — the trophy case's whole data source.

@ProviderFor(badgeProgress)
final badgeProgressProvider = BadgeProgressProvider._();

/// Where the user stands on every badge in the catalogue, in catalogue
/// order — the trophy case's whole data source.

final class BadgeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BadgeProgress>>,
          List<BadgeProgress>,
          FutureOr<List<BadgeProgress>>
        >
    with
        $FutureModifier<List<BadgeProgress>>,
        $FutureProvider<List<BadgeProgress>> {
  /// Where the user stands on every badge in the catalogue, in catalogue
  /// order — the trophy case's whole data source.
  BadgeProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badgeProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badgeProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<BadgeProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BadgeProgress>> create(Ref ref) {
    return badgeProgress(ref);
  }
}

String _$badgeProgressHash() => r'b237948ed548ad7ebe30b50844d206eec8c0b8ff';

/// Records newly-crossed awards and reports them back for celebration.
///
/// See [AwardDetector] for where it is meant to be called from. No trigger
/// is wired from here — reaching into another feature's flow belongs to the
/// presentation half of this task.

@ProviderFor(awardDetector)
final awardDetectorProvider = AwardDetectorProvider._();

/// Records newly-crossed awards and reports them back for celebration.
///
/// See [AwardDetector] for where it is meant to be called from. No trigger
/// is wired from here — reaching into another feature's flow belongs to the
/// presentation half of this task.

final class AwardDetectorProvider
    extends $FunctionalProvider<AwardDetector, AwardDetector, AwardDetector>
    with $Provider<AwardDetector> {
  /// Records newly-crossed awards and reports them back for celebration.
  ///
  /// See [AwardDetector] for where it is meant to be called from. No trigger
  /// is wired from here — reaching into another feature's flow belongs to the
  /// presentation half of this task.
  AwardDetectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'awardDetectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$awardDetectorHash();

  @$internal
  @override
  $ProviderElement<AwardDetector> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AwardDetector create(Ref ref) {
    return awardDetector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwardDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwardDetector>(value),
    );
  }
}

String _$awardDetectorHash() => r'4243bbeb5c7e583f95615c33bfb7ea2213033a0f';
