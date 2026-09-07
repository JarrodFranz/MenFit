// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `progress` feature (ADR 007).
///
/// A derived feature with no `data/` layer at all (same shape as
/// `features/streaks/`) - this provider *is* the entire feature surface. It
/// watches `activity`'s composition surface for the activity list (never its
/// `data/` - ADR 007) and recomputes [WeeklySummary]s on every change.
///
/// Also watches `streaks`' `localDayProvider` (legal: another feature's
/// composition surface, never its data/presentation) purely as a
/// local-midnight-rollover trigger - the same "watch for dependency only,
/// re-read `LocalDate.today()` fresh inside" pattern as
/// `streaks_providers.dart#streakResult` (see that provider's dartdoc for
/// why watching the emitted value alone wouldn't be enough: without this,
/// a session left open overnight with no new activity would keep showing
/// yesterday's "this week" until something else happened to change).

@ProviderFor(weeklySummaries)
final weeklySummariesProvider = WeeklySummariesProvider._();

/// Composition surface for the `progress` feature (ADR 007).
///
/// A derived feature with no `data/` layer at all (same shape as
/// `features/streaks/`) - this provider *is* the entire feature surface. It
/// watches `activity`'s composition surface for the activity list (never its
/// `data/` - ADR 007) and recomputes [WeeklySummary]s on every change.
///
/// Also watches `streaks`' `localDayProvider` (legal: another feature's
/// composition surface, never its data/presentation) purely as a
/// local-midnight-rollover trigger - the same "watch for dependency only,
/// re-read `LocalDate.today()` fresh inside" pattern as
/// `streaks_providers.dart#streakResult` (see that provider's dartdoc for
/// why watching the emitted value alone wouldn't be enough: without this,
/// a session left open overnight with no new activity would keep showing
/// yesterday's "this week" until something else happened to change).

final class WeeklySummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeeklySummary>>,
          List<WeeklySummary>,
          Stream<List<WeeklySummary>>
        >
    with
        $FutureModifier<List<WeeklySummary>>,
        $StreamProvider<List<WeeklySummary>> {
  /// Composition surface for the `progress` feature (ADR 007).
  ///
  /// A derived feature with no `data/` layer at all (same shape as
  /// `features/streaks/`) - this provider *is* the entire feature surface. It
  /// watches `activity`'s composition surface for the activity list (never its
  /// `data/` - ADR 007) and recomputes [WeeklySummary]s on every change.
  ///
  /// Also watches `streaks`' `localDayProvider` (legal: another feature's
  /// composition surface, never its data/presentation) purely as a
  /// local-midnight-rollover trigger - the same "watch for dependency only,
  /// re-read `LocalDate.today()` fresh inside" pattern as
  /// `streaks_providers.dart#streakResult` (see that provider's dartdoc for
  /// why watching the emitted value alone wouldn't be enough: without this,
  /// a session left open overnight with no new activity would keep showing
  /// yesterday's "this week" until something else happened to change).
  WeeklySummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklySummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklySummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<WeeklySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WeeklySummary>> create(Ref ref) {
    return weeklySummaries(ref);
  }
}

String _$weeklySummariesHash() => r'6f2a222949ab0686d2c7be166d24c8ac6dbe6ce7';

/// All activities stream for multi-domain progress overview aggregations.

@ProviderFor(progressActivities)
final progressActivitiesProvider = ProgressActivitiesProvider._();

/// All activities stream for multi-domain progress overview aggregations.

final class ProgressActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Activity>>,
          List<Activity>,
          Stream<List<Activity>>
        >
    with $FutureModifier<List<Activity>>, $StreamProvider<List<Activity>> {
  /// All activities stream for multi-domain progress overview aggregations.
  ProgressActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressActivitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressActivitiesHash();

  @$internal
  @override
  $StreamProviderElement<List<Activity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Activity>> create(Ref ref) {
    return progressActivities(ref);
  }
}

String _$progressActivitiesHash() =>
    r'd089ddf67ca94188ecf12d5ffa67f64f59b8a996';

/// Recent check-ins for the progress overview.

@ProviderFor(progressRecentCheckins)
final progressRecentCheckinsProvider = ProgressRecentCheckinsFamily._();

/// Recent check-ins for the progress overview.

final class ProgressRecentCheckinsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyCheckin>>,
          List<DailyCheckin>,
          Stream<List<DailyCheckin>>
        >
    with
        $FutureModifier<List<DailyCheckin>>,
        $StreamProvider<List<DailyCheckin>> {
  /// Recent check-ins for the progress overview.
  ProgressRecentCheckinsProvider._({
    required ProgressRecentCheckinsFamily super.from,
    required ({int days, LocalDate today}) super.argument,
  }) : super(
         retry: null,
         name: r'progressRecentCheckinsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$progressRecentCheckinsHash();

  @override
  String toString() {
    return r'progressRecentCheckinsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyCheckin>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyCheckin>> create(Ref ref) {
    final argument = this.argument as ({int days, LocalDate today});
    return progressRecentCheckins(
      ref,
      days: argument.days,
      today: argument.today,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressRecentCheckinsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$progressRecentCheckinsHash() =>
    r'bcc7d68a5834a4c80861a585d80ae9c64df365ab';

/// Recent check-ins for the progress overview.

final class ProgressRecentCheckinsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<DailyCheckin>>,
          ({int days, LocalDate today})
        > {
  ProgressRecentCheckinsFamily._()
    : super(
        retry: null,
        name: r'progressRecentCheckinsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recent check-ins for the progress overview.

  ProgressRecentCheckinsProvider call({
    required int days,
    required LocalDate today,
  }) => ProgressRecentCheckinsProvider._(
    argument: (days: days, today: today),
    from: this,
  );

  @override
  String toString() => r'progressRecentCheckinsProvider';
}

/// Recent flares for the progress overview.

@ProviderFor(progressRecentFlares)
final progressRecentFlaresProvider = ProgressRecentFlaresFamily._();

/// Recent flares for the progress overview.

final class ProgressRecentFlaresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlareEvent>>,
          List<FlareEvent>,
          Stream<List<FlareEvent>>
        >
    with $FutureModifier<List<FlareEvent>>, $StreamProvider<List<FlareEvent>> {
  /// Recent flares for the progress overview.
  ProgressRecentFlaresProvider._({
    required ProgressRecentFlaresFamily super.from,
    required ({int days, LocalDate today}) super.argument,
  }) : super(
         retry: null,
         name: r'progressRecentFlaresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$progressRecentFlaresHash();

  @override
  String toString() {
    return r'progressRecentFlaresProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<FlareEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FlareEvent>> create(Ref ref) {
    final argument = this.argument as ({int days, LocalDate today});
    return progressRecentFlares(
      ref,
      days: argument.days,
      today: argument.today,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressRecentFlaresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$progressRecentFlaresHash() =>
    r'cb98f00df0a988690bb86949aa77ce7313cc807e';

/// Recent flares for the progress overview.

final class ProgressRecentFlaresFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<FlareEvent>>,
          ({int days, LocalDate today})
        > {
  ProgressRecentFlaresFamily._()
    : super(
        retry: null,
        name: r'progressRecentFlaresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recent flares for the progress overview.

  ProgressRecentFlaresProvider call({
    required int days,
    required LocalDate today,
  }) => ProgressRecentFlaresProvider._(
    argument: (days: days, today: today),
    from: this,
  );

  @override
  String toString() => r'progressRecentFlaresProvider';
}
