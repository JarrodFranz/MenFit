// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The calendar day the insight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside
/// [insightObservations] so "today" is an explicit, overridable input: the
/// engine below it is deterministic, and a test that cannot pin the last
/// day of the window cannot pin the window at all. Same seam as
/// `features/streaks/streaks_providers.dart`'s `localDay`, without the
/// midnight timer — a 90-day window whose end rolls over a few hours late
/// changes nothing a user would notice.

@ProviderFor(insightsToday)
final insightsTodayProvider = InsightsTodayProvider._();

/// The calendar day the insight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside
/// [insightObservations] so "today" is an explicit, overridable input: the
/// engine below it is deterministic, and a test that cannot pin the last
/// day of the window cannot pin the window at all. Same seam as
/// `features/streaks/streaks_providers.dart`'s `localDay`, without the
/// midnight timer — a 90-day window whose end rolls over a few hours late
/// changes nothing a user would notice.

final class InsightsTodayProvider
    extends $FunctionalProvider<LocalDate, LocalDate, LocalDate>
    with $Provider<LocalDate> {
  /// The calendar day the insight window ends on.
  ///
  /// A provider rather than a `LocalDate.today()` call inside
  /// [insightObservations] so "today" is an explicit, overridable input: the
  /// engine below it is deterministic, and a test that cannot pin the last
  /// day of the window cannot pin the window at all. Same seam as
  /// `features/streaks/streaks_providers.dart`'s `localDay`, without the
  /// midnight timer — a 90-day window whose end rolls over a few hours late
  /// changes nothing a user would notice.
  InsightsTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsTodayHash();

  @$internal
  @override
  $ProviderElement<LocalDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalDate create(Ref ref) {
    return insightsToday(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDate>(value),
    );
  }
}

String _$insightsTodayHash() => r'775020278e68d0dbe50dc00375fc4be5eea28fae';

/// The last [insightWindowDays] days of the user's own logs, reduced to the
/// engine's [DailyObservation] input.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `features/recaps/recaps_providers.dart#recapForPeriod`: this walks 90
/// days of activities, diary entries, water totals, check-ins and cycle
/// records, and re-running that aggregation on every unrelated log while
/// Home sits offstage would be pure waste. It refreshes when it is
/// invalidated or its repositories change, which for a discovery surface is
/// soon enough.
///
/// Every source is read through the owning feature's composition surface
/// (ADR 007), never a `data/` import.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged, and nothing reaches
/// analytics.

@ProviderFor(insightObservations)
final insightObservationsProvider = InsightObservationsProvider._();

/// The last [insightWindowDays] days of the user's own logs, reduced to the
/// engine's [DailyObservation] input.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `features/recaps/recaps_providers.dart#recapForPeriod`: this walks 90
/// days of activities, diary entries, water totals, check-ins and cycle
/// records, and re-running that aggregation on every unrelated log while
/// Home sits offstage would be pure waste. It refreshes when it is
/// invalidated or its repositories change, which for a discovery surface is
/// soon enough.
///
/// Every source is read through the owning feature's composition surface
/// (ADR 007), never a `data/` import.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged, and nothing reaches
/// analytics.

final class InsightObservationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyObservation>>,
          List<DailyObservation>,
          FutureOr<List<DailyObservation>>
        >
    with
        $FutureModifier<List<DailyObservation>>,
        $FutureProvider<List<DailyObservation>> {
  /// The last [insightWindowDays] days of the user's own logs, reduced to the
  /// engine's [DailyObservation] input.
  ///
  /// One-shot (`Future`, not `Stream`) for the same reason as
  /// `features/recaps/recaps_providers.dart#recapForPeriod`: this walks 90
  /// days of activities, diary entries, water totals, check-ins and cycle
  /// records, and re-running that aggregation on every unrelated log while
  /// Home sits offstage would be pure waste. It refreshes when it is
  /// invalidated or its repositories change, which for a discovery surface is
  /// soon enough.
  ///
  /// Every source is read through the owning feature's composition surface
  /// (ADR 007), never a `data/` import.
  ///
  /// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
  /// nothing in this provider or below it is logged, and nothing reaches
  /// analytics.
  InsightObservationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightObservationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightObservationsHash();

  @$internal
  @override
  $FutureProviderElement<List<DailyObservation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyObservation>> create(Ref ref) {
    return insightObservations(ref);
  }
}

String _$insightObservationsHash() =>
    r'7f6e094f8331ec98f3a26eaffaa9de1a2cf54682';

/// Every pattern in the user's own data that clears
/// `InsightThresholds`, strongest first, capped by the engine at
/// `InsightThresholds.maxSimultaneousInsights`.
///
/// An empty list is the normal state for most users most of the time, and
/// the UI renders exactly nothing for it — see
/// `presentation/widgets/insight_discovery_section.dart`.

@ProviderFor(personalInsights)
final personalInsightsProvider = PersonalInsightsProvider._();

/// Every pattern in the user's own data that clears
/// `InsightThresholds`, strongest first, capped by the engine at
/// `InsightThresholds.maxSimultaneousInsights`.
///
/// An empty list is the normal state for most users most of the time, and
/// the UI renders exactly nothing for it — see
/// `presentation/widgets/insight_discovery_section.dart`.

final class PersonalInsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonalInsight>>,
          List<PersonalInsight>,
          FutureOr<List<PersonalInsight>>
        >
    with
        $FutureModifier<List<PersonalInsight>>,
        $FutureProvider<List<PersonalInsight>> {
  /// Every pattern in the user's own data that clears
  /// `InsightThresholds`, strongest first, capped by the engine at
  /// `InsightThresholds.maxSimultaneousInsights`.
  ///
  /// An empty list is the normal state for most users most of the time, and
  /// the UI renders exactly nothing for it — see
  /// `presentation/widgets/insight_discovery_section.dart`.
  PersonalInsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalInsightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalInsightsHash();

  @$internal
  @override
  $FutureProviderElement<List<PersonalInsight>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalInsight>> create(Ref ref) {
    return personalInsights(ref);
  }
}

String _$personalInsightsHash() => r'659cf255a1870e900a1c4b53e52445b657cca58f';
