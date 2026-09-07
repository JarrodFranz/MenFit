// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The calendar day every weight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside each provider
/// below, so "today" is an explicit, overridable input — same seam and
/// same reasoning as `features/insights/insights_providers.dart`'s
/// `insightsToday`.

@ProviderFor(weightToday)
final weightTodayProvider = WeightTodayProvider._();

/// The calendar day every weight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside each provider
/// below, so "today" is an explicit, overridable input — same seam and
/// same reasoning as `features/insights/insights_providers.dart`'s
/// `insightsToday`.

final class WeightTodayProvider
    extends $FunctionalProvider<LocalDate, LocalDate, LocalDate>
    with $Provider<LocalDate> {
  /// The calendar day every weight window ends on.
  ///
  /// A provider rather than a `LocalDate.today()` call inside each provider
  /// below, so "today" is an explicit, overridable input — same seam and
  /// same reasoning as `features/insights/insights_providers.dart`'s
  /// `insightsToday`.
  WeightTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightTodayHash();

  @$internal
  @override
  $ProviderElement<LocalDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalDate create(Ref ref) {
    return weightToday(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDate>(value),
    );
  }
}

String _$weightTodayHash() => r'57b05205f847b71dc1bd6091b03b32fe4e663438';

/// Every reading inside [range], oldest first (the repository's ordering,
/// unchanged — see `domain/weight_repository.dart`).
///
/// The history list reverses this for display; the chart and the trend
/// engine both want it as it comes.

@ProviderFor(weightLogsInRange)
final weightLogsInRangeProvider = WeightLogsInRangeFamily._();

/// Every reading inside [range], oldest first (the repository's ordering,
/// unchanged — see `domain/weight_repository.dart`).
///
/// The history list reverses this for display; the chart and the trend
/// engine both want it as it comes.

final class WeightLogsInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeightLog>>,
          List<WeightLog>,
          Stream<List<WeightLog>>
        >
    with $FutureModifier<List<WeightLog>>, $StreamProvider<List<WeightLog>> {
  /// Every reading inside [range], oldest first (the repository's ordering,
  /// unchanged — see `domain/weight_repository.dart`).
  ///
  /// The history list reverses this for display; the chart and the trend
  /// engine both want it as it comes.
  WeightLogsInRangeProvider._({
    required WeightLogsInRangeFamily super.from,
    required WeightRange super.argument,
  }) : super(
         retry: null,
         name: r'weightLogsInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weightLogsInRangeHash();

  @override
  String toString() {
    return r'weightLogsInRangeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WeightLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WeightLog>> create(Ref ref) {
    final argument = this.argument as WeightRange;
    return weightLogsInRange(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightLogsInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weightLogsInRangeHash() => r'f752b4763968ad69488a51fc1ebbbfeb968f3d2f';

/// Every reading inside [range], oldest first (the repository's ordering,
/// unchanged — see `domain/weight_repository.dart`).
///
/// The history list reverses this for display; the chart and the trend
/// engine both want it as it comes.

final class WeightLogsInRangeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<WeightLog>>, WeightRange> {
  WeightLogsInRangeFamily._()
    : super(
        retry: null,
        name: r'weightLogsInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every reading inside [range], oldest first (the repository's ordering,
  /// unchanged — see `domain/weight_repository.dart`).
  ///
  /// The history list reverses this for display; the chart and the trend
  /// engine both want it as it comes.

  WeightLogsInRangeProvider call(WeightRange range) =>
      WeightLogsInRangeProvider._(argument: range, from: this);

  @override
  String toString() => r'weightLogsInRangeProvider';
}

/// The smoothed series for [range].
///
/// Derived from [weightLogsInRange] rather than opening a second query
/// stream over the same window, so the list and the chart on one screen
/// share a single subscription.

@ProviderFor(weightTrend)
final weightTrendProvider = WeightTrendFamily._();

/// The smoothed series for [range].
///
/// Derived from [weightLogsInRange] rather than opening a second query
/// stream over the same window, so the list and the chart on one screen
/// share a single subscription.

final class WeightTrendProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeightTrendSeries>,
          WeightTrendSeries,
          FutureOr<WeightTrendSeries>
        >
    with
        $FutureModifier<WeightTrendSeries>,
        $FutureProvider<WeightTrendSeries> {
  /// The smoothed series for [range].
  ///
  /// Derived from [weightLogsInRange] rather than opening a second query
  /// stream over the same window, so the list and the chart on one screen
  /// share a single subscription.
  WeightTrendProvider._({
    required WeightTrendFamily super.from,
    required WeightRange super.argument,
  }) : super(
         retry: null,
         name: r'weightTrendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weightTrendHash();

  @override
  String toString() {
    return r'weightTrendProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WeightTrendSeries> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeightTrendSeries> create(Ref ref) {
    final argument = this.argument as WeightRange;
    return weightTrend(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightTrendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weightTrendHash() => r'789d857a4d073c85d0b27164b732c9d9fc121107';

/// The smoothed series for [range].
///
/// Derived from [weightLogsInRange] rather than opening a second query
/// stream over the same window, so the list and the chart on one screen
/// share a single subscription.

final class WeightTrendFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WeightTrendSeries>, WeightRange> {
  WeightTrendFamily._()
    : super(
        retry: null,
        name: r'weightTrendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The smoothed series for [range].
  ///
  /// Derived from [weightLogsInRange] rather than opening a second query
  /// stream over the same window, so the list and the chart on one screen
  /// share a single subscription.

  WeightTrendProvider call(WeightRange range) =>
      WeightTrendProvider._(argument: range, from: this);

  @override
  String toString() => r'weightTrendProvider';
}

/// The single most recent reading, whenever it was — independent of the
/// selected range, since the header's "latest reading" should not vanish
/// because the user narrowed the chart to the last month.

@ProviderFor(latestWeightLog)
final latestWeightLogProvider = LatestWeightLogProvider._();

/// The single most recent reading, whenever it was — independent of the
/// selected range, since the header's "latest reading" should not vanish
/// because the user narrowed the chart to the last month.

final class LatestWeightLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeightLog?>,
          WeightLog?,
          Stream<WeightLog?>
        >
    with $FutureModifier<WeightLog?>, $StreamProvider<WeightLog?> {
  /// The single most recent reading, whenever it was — independent of the
  /// selected range, since the header's "latest reading" should not vanish
  /// because the user narrowed the chart to the last month.
  LatestWeightLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestWeightLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestWeightLogHash();

  @$internal
  @override
  $StreamProviderElement<WeightLog?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<WeightLog?> create(Ref ref) {
    return latestWeightLog(ref);
  }
}

String _$latestWeightLogHash() => r'5e3693a4e5791e4808f8e771b37f65bd670f7284';

/// Whether the user has logged any period at all.
///
/// Gates the cycle overlay: the chart offers it, and defaults it on, only
/// for a user who tracks her cycle. Cycle tracking is opt-in and every
/// consumer degrades to silence without it
/// (`knowledge/domain/womens_health.md` rule 4) — here that means no
/// toggle, no band, and no copy mentioning phases.

@ProviderFor(weightHasCycleContext)
final weightHasCycleContextProvider = WeightHasCycleContextProvider._();

/// Whether the user has logged any period at all.
///
/// Gates the cycle overlay: the chart offers it, and defaults it on, only
/// for a user who tracks her cycle. Cycle tracking is opt-in and every
/// consumer degrades to silence without it
/// (`knowledge/domain/womens_health.md` rule 4) — here that means no
/// toggle, no band, and no copy mentioning phases.

final class WeightHasCycleContextProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the user has logged any period at all.
  ///
  /// Gates the cycle overlay: the chart offers it, and defaults it on, only
  /// for a user who tracks her cycle. Cycle tracking is opt-in and every
  /// consumer degrades to silence without it
  /// (`knowledge/domain/womens_health.md` rule 4) — here that means no
  /// toggle, no band, and no copy mentioning phases.
  WeightHasCycleContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightHasCycleContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightHasCycleContextHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return weightHasCycleContext(ref);
  }
}

String _$weightHasCycleContextHash() =>
    r'd5ca8202932627f9fe88b7c90bfdecfe24f500a5';

/// Per-day cycle phase for `[start, end]`, for the chart's background
/// bands.
///
/// **[start] and [end] are the first and last plotted points**, not the
/// selected range's calendar bounds. `WeightTrendChart` only draws
/// annotations between those two days, so phasing anything outside them
/// produces phases no band is ever painted from — and worse, made the
/// panel's legend and cycle explainer appear for a window whose visible
/// chart carries no band at all (the map was non-empty, the bands were
/// not). Bounding the window at the plotted span makes "the map has a
/// banded phase in it" and "the chart drew a band" the same statement.
///
/// Days whose phase is [CyclePhase.none] are **left out of the map**
/// rather than stored: `none` is the engine's "no phase is known for this
/// day", and an absent key is how every consumer in this codebase spells
/// unknown — storing it would make untracked days look like a tracked
/// group. Same skip as `features/insights/insights_providers.dart` and
/// `features/recaps/recaps_providers.dart`.
///
/// Returns an empty map when nothing is logged. S3 data
/// (`knowledge/engineering/security_and_privacy.md`): this map is derived
/// in memory for one chart and is never logged, persisted, or attached to
/// a weight row.

@ProviderFor(weightCyclePhases)
final weightCyclePhasesProvider = WeightCyclePhasesFamily._();

/// Per-day cycle phase for `[start, end]`, for the chart's background
/// bands.
///
/// **[start] and [end] are the first and last plotted points**, not the
/// selected range's calendar bounds. `WeightTrendChart` only draws
/// annotations between those two days, so phasing anything outside them
/// produces phases no band is ever painted from — and worse, made the
/// panel's legend and cycle explainer appear for a window whose visible
/// chart carries no band at all (the map was non-empty, the bands were
/// not). Bounding the window at the plotted span makes "the map has a
/// banded phase in it" and "the chart drew a band" the same statement.
///
/// Days whose phase is [CyclePhase.none] are **left out of the map**
/// rather than stored: `none` is the engine's "no phase is known for this
/// day", and an absent key is how every consumer in this codebase spells
/// unknown — storing it would make untracked days look like a tracked
/// group. Same skip as `features/insights/insights_providers.dart` and
/// `features/recaps/recaps_providers.dart`.
///
/// Returns an empty map when nothing is logged. S3 data
/// (`knowledge/engineering/security_and_privacy.md`): this map is derived
/// in memory for one chart and is never logged, persisted, or attached to
/// a weight row.

final class WeightCyclePhasesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<LocalDate, CyclePhase>>,
          Map<LocalDate, CyclePhase>,
          FutureOr<Map<LocalDate, CyclePhase>>
        >
    with
        $FutureModifier<Map<LocalDate, CyclePhase>>,
        $FutureProvider<Map<LocalDate, CyclePhase>> {
  /// Per-day cycle phase for `[start, end]`, for the chart's background
  /// bands.
  ///
  /// **[start] and [end] are the first and last plotted points**, not the
  /// selected range's calendar bounds. `WeightTrendChart` only draws
  /// annotations between those two days, so phasing anything outside them
  /// produces phases no band is ever painted from — and worse, made the
  /// panel's legend and cycle explainer appear for a window whose visible
  /// chart carries no band at all (the map was non-empty, the bands were
  /// not). Bounding the window at the plotted span makes "the map has a
  /// banded phase in it" and "the chart drew a band" the same statement.
  ///
  /// Days whose phase is [CyclePhase.none] are **left out of the map**
  /// rather than stored: `none` is the engine's "no phase is known for this
  /// day", and an absent key is how every consumer in this codebase spells
  /// unknown — storing it would make untracked days look like a tracked
  /// group. Same skip as `features/insights/insights_providers.dart` and
  /// `features/recaps/recaps_providers.dart`.
  ///
  /// Returns an empty map when nothing is logged. S3 data
  /// (`knowledge/engineering/security_and_privacy.md`): this map is derived
  /// in memory for one chart and is never logged, persisted, or attached to
  /// a weight row.
  WeightCyclePhasesProvider._({
    required WeightCyclePhasesFamily super.from,
    required ({LocalDate start, LocalDate end}) super.argument,
  }) : super(
         retry: null,
         name: r'weightCyclePhasesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weightCyclePhasesHash();

  @override
  String toString() {
    return r'weightCyclePhasesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<LocalDate, CyclePhase>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<LocalDate, CyclePhase>> create(Ref ref) {
    final argument = this.argument as ({LocalDate start, LocalDate end});
    return weightCyclePhases(ref, start: argument.start, end: argument.end);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightCyclePhasesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weightCyclePhasesHash() => r'af257673ca8efcc8156ad1a120927b91405fdc37';

/// Per-day cycle phase for `[start, end]`, for the chart's background
/// bands.
///
/// **[start] and [end] are the first and last plotted points**, not the
/// selected range's calendar bounds. `WeightTrendChart` only draws
/// annotations between those two days, so phasing anything outside them
/// produces phases no band is ever painted from — and worse, made the
/// panel's legend and cycle explainer appear for a window whose visible
/// chart carries no band at all (the map was non-empty, the bands were
/// not). Bounding the window at the plotted span makes "the map has a
/// banded phase in it" and "the chart drew a band" the same statement.
///
/// Days whose phase is [CyclePhase.none] are **left out of the map**
/// rather than stored: `none` is the engine's "no phase is known for this
/// day", and an absent key is how every consumer in this codebase spells
/// unknown — storing it would make untracked days look like a tracked
/// group. Same skip as `features/insights/insights_providers.dart` and
/// `features/recaps/recaps_providers.dart`.
///
/// Returns an empty map when nothing is logged. S3 data
/// (`knowledge/engineering/security_and_privacy.md`): this map is derived
/// in memory for one chart and is never logged, persisted, or attached to
/// a weight row.

final class WeightCyclePhasesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<LocalDate, CyclePhase>>,
          ({LocalDate start, LocalDate end})
        > {
  WeightCyclePhasesFamily._()
    : super(
        retry: null,
        name: r'weightCyclePhasesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-day cycle phase for `[start, end]`, for the chart's background
  /// bands.
  ///
  /// **[start] and [end] are the first and last plotted points**, not the
  /// selected range's calendar bounds. `WeightTrendChart` only draws
  /// annotations between those two days, so phasing anything outside them
  /// produces phases no band is ever painted from — and worse, made the
  /// panel's legend and cycle explainer appear for a window whose visible
  /// chart carries no band at all (the map was non-empty, the bands were
  /// not). Bounding the window at the plotted span makes "the map has a
  /// banded phase in it" and "the chart drew a band" the same statement.
  ///
  /// Days whose phase is [CyclePhase.none] are **left out of the map**
  /// rather than stored: `none` is the engine's "no phase is known for this
  /// day", and an absent key is how every consumer in this codebase spells
  /// unknown — storing it would make untracked days look like a tracked
  /// group. Same skip as `features/insights/insights_providers.dart` and
  /// `features/recaps/recaps_providers.dart`.
  ///
  /// Returns an empty map when nothing is logged. S3 data
  /// (`knowledge/engineering/security_and_privacy.md`): this map is derived
  /// in memory for one chart and is never logged, persisted, or attached to
  /// a weight row.

  WeightCyclePhasesProvider call({
    required LocalDate start,
    required LocalDate end,
  }) => WeightCyclePhasesProvider._(
    argument: (start: start, end: end),
    from: this,
  );

  @override
  String toString() => r'weightCyclePhasesProvider';
}
