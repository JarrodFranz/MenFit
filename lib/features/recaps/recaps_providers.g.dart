// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recaps_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `recaps` feature (ADR 007).
///
/// The only legal way for another feature (`home`'s trigger widget,
/// `progress`'s recap history section) to reach this feature's logic and
/// storage — other features may import this file, never `data/` or
/// `presentation/` directly.

@ProviderFor(recapMarkerStore)
final recapMarkerStoreProvider = RecapMarkerStoreProvider._();

/// Composition surface for the `recaps` feature (ADR 007).
///
/// The only legal way for another feature (`home`'s trigger widget,
/// `progress`'s recap history section) to reach this feature's logic and
/// storage — other features may import this file, never `data/` or
/// `presentation/` directly.

final class RecapMarkerStoreProvider
    extends
        $FunctionalProvider<
          RecapMarkerStore,
          RecapMarkerStore,
          RecapMarkerStore
        >
    with $Provider<RecapMarkerStore> {
  /// Composition surface for the `recaps` feature (ADR 007).
  ///
  /// The only legal way for another feature (`home`'s trigger widget,
  /// `progress`'s recap history section) to reach this feature's logic and
  /// storage — other features may import this file, never `data/` or
  /// `presentation/` directly.
  RecapMarkerStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recapMarkerStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recapMarkerStoreHash();

  @$internal
  @override
  $ProviderElement<RecapMarkerStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecapMarkerStore create(Ref ref) {
    return recapMarkerStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecapMarkerStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecapMarkerStore>(value),
    );
  }
}

String _$recapMarkerStoreHash() => r'ea071a1bf8a12c89b4f5e835a292510f9b4c1d5a';

/// Preference controller for whether automatic cycle and monthly recap stories
/// are presented on startup / cycle end. Defaults to true.

@ProviderFor(ShowAutomaticRecapsController)
final showAutomaticRecapsControllerProvider =
    ShowAutomaticRecapsControllerProvider._();

/// Preference controller for whether automatic cycle and monthly recap stories
/// are presented on startup / cycle end. Defaults to true.
final class ShowAutomaticRecapsControllerProvider
    extends $NotifierProvider<ShowAutomaticRecapsController, bool> {
  /// Preference controller for whether automatic cycle and monthly recap stories
  /// are presented on startup / cycle end. Defaults to true.
  ShowAutomaticRecapsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showAutomaticRecapsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showAutomaticRecapsControllerHash();

  @$internal
  @override
  ShowAutomaticRecapsController create() => ShowAutomaticRecapsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showAutomaticRecapsControllerHash() =>
    r'ccc9dd59503e837456ccbdb558e9fadab282b7ed';

/// Preference controller for whether automatic cycle and monthly recap stories
/// are presented on startup / cycle end. Defaults to true.

abstract class _$ShowAutomaticRecapsController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Builds the [CycleRecap] for an arbitrary [period], gathering every
/// source through the owning feature's composition surface (ADR 007) —
/// never a `data/` import. Returns `null` when [RecapBuilder]'s
/// sparse-data guard applies.
///
/// One-shot (`Future`, not `Stream`): a recap describes a period that has
/// already finished, so nothing about it changes once its inputs have been
/// read - unlike the rest of this codebase's mostly-live providers, a
/// live-updating recap would only mean pointlessly re-running this fairly
/// expensive aggregation on every unrelated activity/water/nutrition log
/// while the story screen is open.
///
/// ## Cost, and why it is safe on the launch path
///
/// This runs from Home's `RecapTriggerListener` whenever a recap is due,
/// so its cost lands on an app launch. It is honestly not cheap: the
/// prior-records fold walks *every activity ever logged* before the
/// period, scanning each recorded activity's GPS track five times (once
/// per `standardEffortDistances` target) inside
/// `foldActivityIntoRecords`. A year of runs is on the order of a million
/// sample comparisons.
///
/// What makes that acceptable rather than a freeze:
/// - **Nothing forces it before first paint.** Every consumer is async and
///   renders a non-blocking placeholder first —
///   `recapTriggerControllerProvider` `await`s this and its listener acts
///   only on a later `AsyncData`, and the history section renders from
///   `AsyncValue.when`. Home paints while this is still pending.
/// - **The queries are off the UI isolate.** Drift on native runs its
///   executor in a background isolate (`core/db/app_database.dart`), and
///   the sample reads are now batched
///   (`ActivityRepository.getSamplesForActivities`) rather than one
///   awaited round trip per historical activity, which is what used to
///   dominate the wall clock here.
/// - **Peak memory stays bounded.** The prior fold is walked in chunks of
///   [_priorFoldChunkSize] activities, so a whole history's tracks are
///   never all resident at once.
///
/// The *arithmetic* still runs on the UI isolate and is the remaining
/// cost. It is deliberately not pushed through `compute()`: the payload
/// would be the sample lists themselves, and copying hundreds of
/// thousands of `ActivitySample`s across an isolate boundary plausibly
/// costs more than the scan it would offload. The cheaper win, if this
/// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
/// same cleaned/cumulative-distance track once per target distance, so a
/// multi-target variant in `activity/domain/track_analysis.dart` would cut
/// the geometry work ~5x with no isolate involved. Tracked in
/// `knowledge/product/deferred.md`.
///
/// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.

@ProviderFor(recapForPeriod)
final recapForPeriodProvider = RecapForPeriodFamily._();

/// Builds the [CycleRecap] for an arbitrary [period], gathering every
/// source through the owning feature's composition surface (ADR 007) —
/// never a `data/` import. Returns `null` when [RecapBuilder]'s
/// sparse-data guard applies.
///
/// One-shot (`Future`, not `Stream`): a recap describes a period that has
/// already finished, so nothing about it changes once its inputs have been
/// read - unlike the rest of this codebase's mostly-live providers, a
/// live-updating recap would only mean pointlessly re-running this fairly
/// expensive aggregation on every unrelated activity/water/nutrition log
/// while the story screen is open.
///
/// ## Cost, and why it is safe on the launch path
///
/// This runs from Home's `RecapTriggerListener` whenever a recap is due,
/// so its cost lands on an app launch. It is honestly not cheap: the
/// prior-records fold walks *every activity ever logged* before the
/// period, scanning each recorded activity's GPS track five times (once
/// per `standardEffortDistances` target) inside
/// `foldActivityIntoRecords`. A year of runs is on the order of a million
/// sample comparisons.
///
/// What makes that acceptable rather than a freeze:
/// - **Nothing forces it before first paint.** Every consumer is async and
///   renders a non-blocking placeholder first —
///   `recapTriggerControllerProvider` `await`s this and its listener acts
///   only on a later `AsyncData`, and the history section renders from
///   `AsyncValue.when`. Home paints while this is still pending.
/// - **The queries are off the UI isolate.** Drift on native runs its
///   executor in a background isolate (`core/db/app_database.dart`), and
///   the sample reads are now batched
///   (`ActivityRepository.getSamplesForActivities`) rather than one
///   awaited round trip per historical activity, which is what used to
///   dominate the wall clock here.
/// - **Peak memory stays bounded.** The prior fold is walked in chunks of
///   [_priorFoldChunkSize] activities, so a whole history's tracks are
///   never all resident at once.
///
/// The *arithmetic* still runs on the UI isolate and is the remaining
/// cost. It is deliberately not pushed through `compute()`: the payload
/// would be the sample lists themselves, and copying hundreds of
/// thousands of `ActivitySample`s across an isolate boundary plausibly
/// costs more than the scan it would offload. The cheaper win, if this
/// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
/// same cleaned/cumulative-distance track once per target distance, so a
/// multi-target variant in `activity/domain/track_analysis.dart` would cut
/// the geometry work ~5x with no isolate involved. Tracked in
/// `knowledge/product/deferred.md`.
///
/// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.

final class RecapForPeriodProvider
    extends
        $FunctionalProvider<
          AsyncValue<CycleRecap?>,
          CycleRecap?,
          FutureOr<CycleRecap?>
        >
    with $FutureModifier<CycleRecap?>, $FutureProvider<CycleRecap?> {
  /// Builds the [CycleRecap] for an arbitrary [period], gathering every
  /// source through the owning feature's composition surface (ADR 007) —
  /// never a `data/` import. Returns `null` when [RecapBuilder]'s
  /// sparse-data guard applies.
  ///
  /// One-shot (`Future`, not `Stream`): a recap describes a period that has
  /// already finished, so nothing about it changes once its inputs have been
  /// read - unlike the rest of this codebase's mostly-live providers, a
  /// live-updating recap would only mean pointlessly re-running this fairly
  /// expensive aggregation on every unrelated activity/water/nutrition log
  /// while the story screen is open.
  ///
  /// ## Cost, and why it is safe on the launch path
  ///
  /// This runs from Home's `RecapTriggerListener` whenever a recap is due,
  /// so its cost lands on an app launch. It is honestly not cheap: the
  /// prior-records fold walks *every activity ever logged* before the
  /// period, scanning each recorded activity's GPS track five times (once
  /// per `standardEffortDistances` target) inside
  /// `foldActivityIntoRecords`. A year of runs is on the order of a million
  /// sample comparisons.
  ///
  /// What makes that acceptable rather than a freeze:
  /// - **Nothing forces it before first paint.** Every consumer is async and
  ///   renders a non-blocking placeholder first —
  ///   `recapTriggerControllerProvider` `await`s this and its listener acts
  ///   only on a later `AsyncData`, and the history section renders from
  ///   `AsyncValue.when`. Home paints while this is still pending.
  /// - **The queries are off the UI isolate.** Drift on native runs its
  ///   executor in a background isolate (`core/db/app_database.dart`), and
  ///   the sample reads are now batched
  ///   (`ActivityRepository.getSamplesForActivities`) rather than one
  ///   awaited round trip per historical activity, which is what used to
  ///   dominate the wall clock here.
  /// - **Peak memory stays bounded.** The prior fold is walked in chunks of
  ///   [_priorFoldChunkSize] activities, so a whole history's tracks are
  ///   never all resident at once.
  ///
  /// The *arithmetic* still runs on the UI isolate and is the remaining
  /// cost. It is deliberately not pushed through `compute()`: the payload
  /// would be the sample lists themselves, and copying hundreds of
  /// thousands of `ActivitySample`s across an isolate boundary plausibly
  /// costs more than the scan it would offload. The cheaper win, if this
  /// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
  /// same cleaned/cumulative-distance track once per target distance, so a
  /// multi-target variant in `activity/domain/track_analysis.dart` would cut
  /// the geometry work ~5x with no isolate involved. Tracked in
  /// `knowledge/product/deferred.md`.
  ///
  /// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.
  RecapForPeriodProvider._({
    required RecapForPeriodFamily super.from,
    required RecapPeriod super.argument,
  }) : super(
         retry: _noRetry,
         name: r'recapForPeriodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recapForPeriodHash();

  @override
  String toString() {
    return r'recapForPeriodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CycleRecap?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CycleRecap?> create(Ref ref) {
    final argument = this.argument as RecapPeriod;
    return recapForPeriod(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecapForPeriodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recapForPeriodHash() => r'8a4d57031448415799da78bb778aeb3bfc45d45c';

/// Builds the [CycleRecap] for an arbitrary [period], gathering every
/// source through the owning feature's composition surface (ADR 007) —
/// never a `data/` import. Returns `null` when [RecapBuilder]'s
/// sparse-data guard applies.
///
/// One-shot (`Future`, not `Stream`): a recap describes a period that has
/// already finished, so nothing about it changes once its inputs have been
/// read - unlike the rest of this codebase's mostly-live providers, a
/// live-updating recap would only mean pointlessly re-running this fairly
/// expensive aggregation on every unrelated activity/water/nutrition log
/// while the story screen is open.
///
/// ## Cost, and why it is safe on the launch path
///
/// This runs from Home's `RecapTriggerListener` whenever a recap is due,
/// so its cost lands on an app launch. It is honestly not cheap: the
/// prior-records fold walks *every activity ever logged* before the
/// period, scanning each recorded activity's GPS track five times (once
/// per `standardEffortDistances` target) inside
/// `foldActivityIntoRecords`. A year of runs is on the order of a million
/// sample comparisons.
///
/// What makes that acceptable rather than a freeze:
/// - **Nothing forces it before first paint.** Every consumer is async and
///   renders a non-blocking placeholder first —
///   `recapTriggerControllerProvider` `await`s this and its listener acts
///   only on a later `AsyncData`, and the history section renders from
///   `AsyncValue.when`. Home paints while this is still pending.
/// - **The queries are off the UI isolate.** Drift on native runs its
///   executor in a background isolate (`core/db/app_database.dart`), and
///   the sample reads are now batched
///   (`ActivityRepository.getSamplesForActivities`) rather than one
///   awaited round trip per historical activity, which is what used to
///   dominate the wall clock here.
/// - **Peak memory stays bounded.** The prior fold is walked in chunks of
///   [_priorFoldChunkSize] activities, so a whole history's tracks are
///   never all resident at once.
///
/// The *arithmetic* still runs on the UI isolate and is the remaining
/// cost. It is deliberately not pushed through `compute()`: the payload
/// would be the sample lists themselves, and copying hundreds of
/// thousands of `ActivitySample`s across an isolate boundary plausibly
/// costs more than the scan it would offload. The cheaper win, if this
/// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
/// same cleaned/cumulative-distance track once per target distance, so a
/// multi-target variant in `activity/domain/track_analysis.dart` would cut
/// the geometry work ~5x with no isolate involved. Tracked in
/// `knowledge/product/deferred.md`.
///
/// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.

final class RecapForPeriodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CycleRecap?>, RecapPeriod> {
  RecapForPeriodFamily._()
    : super(
        retry: _noRetry,
        name: r'recapForPeriodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Builds the [CycleRecap] for an arbitrary [period], gathering every
  /// source through the owning feature's composition surface (ADR 007) —
  /// never a `data/` import. Returns `null` when [RecapBuilder]'s
  /// sparse-data guard applies.
  ///
  /// One-shot (`Future`, not `Stream`): a recap describes a period that has
  /// already finished, so nothing about it changes once its inputs have been
  /// read - unlike the rest of this codebase's mostly-live providers, a
  /// live-updating recap would only mean pointlessly re-running this fairly
  /// expensive aggregation on every unrelated activity/water/nutrition log
  /// while the story screen is open.
  ///
  /// ## Cost, and why it is safe on the launch path
  ///
  /// This runs from Home's `RecapTriggerListener` whenever a recap is due,
  /// so its cost lands on an app launch. It is honestly not cheap: the
  /// prior-records fold walks *every activity ever logged* before the
  /// period, scanning each recorded activity's GPS track five times (once
  /// per `standardEffortDistances` target) inside
  /// `foldActivityIntoRecords`. A year of runs is on the order of a million
  /// sample comparisons.
  ///
  /// What makes that acceptable rather than a freeze:
  /// - **Nothing forces it before first paint.** Every consumer is async and
  ///   renders a non-blocking placeholder first —
  ///   `recapTriggerControllerProvider` `await`s this and its listener acts
  ///   only on a later `AsyncData`, and the history section renders from
  ///   `AsyncValue.when`. Home paints while this is still pending.
  /// - **The queries are off the UI isolate.** Drift on native runs its
  ///   executor in a background isolate (`core/db/app_database.dart`), and
  ///   the sample reads are now batched
  ///   (`ActivityRepository.getSamplesForActivities`) rather than one
  ///   awaited round trip per historical activity, which is what used to
  ///   dominate the wall clock here.
  /// - **Peak memory stays bounded.** The prior fold is walked in chunks of
  ///   [_priorFoldChunkSize] activities, so a whole history's tracks are
  ///   never all resident at once.
  ///
  /// The *arithmetic* still runs on the UI isolate and is the remaining
  /// cost. It is deliberately not pushed through `compute()`: the payload
  /// would be the sample lists themselves, and copying hundreds of
  /// thousands of `ActivitySample`s across an isolate boundary plausibly
  /// costs more than the scan it would offload. The cheaper win, if this
  /// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
  /// same cleaned/cumulative-distance track once per target distance, so a
  /// multi-target variant in `activity/domain/track_analysis.dart` would cut
  /// the geometry work ~5x with no isolate involved. Tracked in
  /// `knowledge/product/deferred.md`.
  ///
  /// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.

  RecapForPeriodProvider call(RecapPeriod period) =>
      RecapForPeriodProvider._(argument: period, from: this);

  @override
  String toString() => r'recapForPeriodProvider';
}

/// Every completed cycle and completed calendar month recap period
/// available to revisit, newest-ending-first, capped at
/// [recapHistoryLimit] — powers the Progress screen's re-viewable recap
/// history (`TASKS_TO_DO.md` Task 1.3's second entry point).
///
/// A candidate month is only offered once it clears the same bar
/// [RecapBuilder.minSessionsForMonthRecap] applies when actually building
/// one. Without that, a brand-new account's Progress screen showed six
/// months whose only possible answer was "there's not quite enough logged
/// for this period to recap yet" — a list of six dead ends is worse than
/// no list. Completed *cycles* are not filtered: a cycle appears here only
/// because she logged the period that closed it, which is a stronger
/// reality test than a session count, and `RecapBuilder`'s cycle-end guard
/// accepts water or food or a check-in as content.

@ProviderFor(recentRecapPeriods)
final recentRecapPeriodsProvider = RecentRecapPeriodsProvider._();

/// Every completed cycle and completed calendar month recap period
/// available to revisit, newest-ending-first, capped at
/// [recapHistoryLimit] — powers the Progress screen's re-viewable recap
/// history (`TASKS_TO_DO.md` Task 1.3's second entry point).
///
/// A candidate month is only offered once it clears the same bar
/// [RecapBuilder.minSessionsForMonthRecap] applies when actually building
/// one. Without that, a brand-new account's Progress screen showed six
/// months whose only possible answer was "there's not quite enough logged
/// for this period to recap yet" — a list of six dead ends is worse than
/// no list. Completed *cycles* are not filtered: a cycle appears here only
/// because she logged the period that closed it, which is a stronger
/// reality test than a session count, and `RecapBuilder`'s cycle-end guard
/// accepts water or food or a check-in as content.

final class RecentRecapPeriodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecapPeriod>>,
          List<RecapPeriod>,
          FutureOr<List<RecapPeriod>>
        >
    with
        $FutureModifier<List<RecapPeriod>>,
        $FutureProvider<List<RecapPeriod>> {
  /// Every completed cycle and completed calendar month recap period
  /// available to revisit, newest-ending-first, capped at
  /// [recapHistoryLimit] — powers the Progress screen's re-viewable recap
  /// history (`TASKS_TO_DO.md` Task 1.3's second entry point).
  ///
  /// A candidate month is only offered once it clears the same bar
  /// [RecapBuilder.minSessionsForMonthRecap] applies when actually building
  /// one. Without that, a brand-new account's Progress screen showed six
  /// months whose only possible answer was "there's not quite enough logged
  /// for this period to recap yet" — a list of six dead ends is worse than
  /// no list. Completed *cycles* are not filtered: a cycle appears here only
  /// because she logged the period that closed it, which is a stronger
  /// reality test than a session count, and `RecapBuilder`'s cycle-end guard
  /// accepts water or food or a check-in as content.
  RecentRecapPeriodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentRecapPeriodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentRecapPeriodsHash();

  @$internal
  @override
  $FutureProviderElement<List<RecapPeriod>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecapPeriod>> create(Ref ref) {
    return recentRecapPeriods(ref);
  }
}

String _$recentRecapPeriodsHash() =>
    r'462c6564fba428cbacc4f823719467cf5152e888';
