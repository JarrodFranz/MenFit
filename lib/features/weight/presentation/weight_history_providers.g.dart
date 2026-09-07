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
