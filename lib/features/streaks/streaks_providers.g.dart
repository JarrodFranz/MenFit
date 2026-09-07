// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streaks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits [LocalDate.today]'s value immediately on listen, then again at
/// every local-midnight rollover for as long as something keeps listening
/// — the S2 fix for staleness across a session left open overnight (see
/// [streakResult]'s dartdoc for how it's consumed).
///
/// `@riverpod` (autoDispose, the default — not `keepAlive`): this
/// provider's only job is feeding [streakResult], which is itself
/// autoDispose, so its lifecycle should match rather than outlive it. The
/// scheduled [Timer] is cancelled from *two* places for belt-and-braces
/// safety - the stream's own `onCancel` (fires once the last listener
/// cancels) and `ref.onDispose` (fires on provider disposal) - covering
/// both a bare `Stream.listen` consumer and a Riverpod-mediated one.
/// `Timer.cancel()` is synchronous (unlike a Drift stream subscription's
/// `cancel()` future - see `flutter development knowledge/
/// testing-pitfalls.md`'s "awaited subscription cancel wedges teardown"
/// entry), so there's no fire-and-forget hazard here: by the time
/// `ref.onDispose` returns, no pending `Timer` survives - exactly what a
/// widget test's end-of-test teardown needs to avoid a false "Timer is
/// still pending" failure.

@ProviderFor(localDay)
final localDayProvider = LocalDayProvider._();

/// Emits [LocalDate.today]'s value immediately on listen, then again at
/// every local-midnight rollover for as long as something keeps listening
/// — the S2 fix for staleness across a session left open overnight (see
/// [streakResult]'s dartdoc for how it's consumed).
///
/// `@riverpod` (autoDispose, the default — not `keepAlive`): this
/// provider's only job is feeding [streakResult], which is itself
/// autoDispose, so its lifecycle should match rather than outlive it. The
/// scheduled [Timer] is cancelled from *two* places for belt-and-braces
/// safety - the stream's own `onCancel` (fires once the last listener
/// cancels) and `ref.onDispose` (fires on provider disposal) - covering
/// both a bare `Stream.listen` consumer and a Riverpod-mediated one.
/// `Timer.cancel()` is synchronous (unlike a Drift stream subscription's
/// `cancel()` future - see `flutter development knowledge/
/// testing-pitfalls.md`'s "awaited subscription cancel wedges teardown"
/// entry), so there's no fire-and-forget hazard here: by the time
/// `ref.onDispose` returns, no pending `Timer` survives - exactly what a
/// widget test's end-of-test teardown needs to avoid a false "Timer is
/// still pending" failure.

final class LocalDayProvider
    extends
        $FunctionalProvider<AsyncValue<LocalDate>, LocalDate, Stream<LocalDate>>
    with $FutureModifier<LocalDate>, $StreamProvider<LocalDate> {
  /// Emits [LocalDate.today]'s value immediately on listen, then again at
  /// every local-midnight rollover for as long as something keeps listening
  /// — the S2 fix for staleness across a session left open overnight (see
  /// [streakResult]'s dartdoc for how it's consumed).
  ///
  /// `@riverpod` (autoDispose, the default — not `keepAlive`): this
  /// provider's only job is feeding [streakResult], which is itself
  /// autoDispose, so its lifecycle should match rather than outlive it. The
  /// scheduled [Timer] is cancelled from *two* places for belt-and-braces
  /// safety - the stream's own `onCancel` (fires once the last listener
  /// cancels) and `ref.onDispose` (fires on provider disposal) - covering
  /// both a bare `Stream.listen` consumer and a Riverpod-mediated one.
  /// `Timer.cancel()` is synchronous (unlike a Drift stream subscription's
  /// `cancel()` future - see `flutter development knowledge/
  /// testing-pitfalls.md`'s "awaited subscription cancel wedges teardown"
  /// entry), so there's no fire-and-forget hazard here: by the time
  /// `ref.onDispose` returns, no pending `Timer` survives - exactly what a
  /// widget test's end-of-test teardown needs to avoid a false "Timer is
  /// still pending" failure.
  LocalDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDayHash();

  @$internal
  @override
  $StreamProviderElement<LocalDate> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LocalDate> create(Ref ref) {
    return localDay(ref);
  }
}

String _$localDayHash() => r'68cb1bb1d64475a9e89d8626522154f6ae9b0ed5';

/// Composition surface for the `streaks` feature (ADR 007).
///
/// The streak *result* is still **derived, never stored**
/// (`data_architecture.md`'s "Derived vs stored" section) —
/// [streakResultProvider] remains a pure recompute with no cache table.
/// S1-2 gives the feature its first genuine `data/` layer
/// ([recoveryRepositoryProvider]) for a different thing: the user's own
/// explicit "I marked this day as recovery" record (see
/// `core/db/tables/recovery_days.dart`'s dartdoc for why that's not a
/// contradiction).

@ProviderFor(recoveryRepository)
final recoveryRepositoryProvider = RecoveryRepositoryProvider._();

/// Composition surface for the `streaks` feature (ADR 007).
///
/// The streak *result* is still **derived, never stored**
/// (`data_architecture.md`'s "Derived vs stored" section) —
/// [streakResultProvider] remains a pure recompute with no cache table.
/// S1-2 gives the feature its first genuine `data/` layer
/// ([recoveryRepositoryProvider]) for a different thing: the user's own
/// explicit "I marked this day as recovery" record (see
/// `core/db/tables/recovery_days.dart`'s dartdoc for why that's not a
/// contradiction).

final class RecoveryRepositoryProvider
    extends
        $FunctionalProvider<
          RecoveryRepository,
          RecoveryRepository,
          RecoveryRepository
        >
    with $Provider<RecoveryRepository> {
  /// Composition surface for the `streaks` feature (ADR 007).
  ///
  /// The streak *result* is still **derived, never stored**
  /// (`data_architecture.md`'s "Derived vs stored" section) —
  /// [streakResultProvider] remains a pure recompute with no cache table.
  /// S1-2 gives the feature its first genuine `data/` layer
  /// ([recoveryRepositoryProvider]) for a different thing: the user's own
  /// explicit "I marked this day as recovery" record (see
  /// `core/db/tables/recovery_days.dart`'s dartdoc for why that's not a
  /// contradiction).
  RecoveryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoveryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecoveryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecoveryRepository create(Ref ref) {
    return recoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecoveryRepository>(value),
    );
  }
}

String _$recoveryRepositoryHash() =>
    r'704a596743699b903dc8d399b3171f8fa54bee8b';

/// Recomputes a [StreakResult] on every change to activities, recovery
/// days, protecting flare days (F1: unwindowed — see
/// `WellbeingRepository.watchProtectingFlareDays`'s dartdoc), cycle
/// records, the streak-pausing preference, or the local calendar day
/// rolling over. Watches `activity`'s, `cycle`'s, and `wellbeing`'s
/// composition surfaces (never their `data/` — ADR 007) plus this
/// feature's own [recoveryRepositoryProvider].
///
/// S2 (fixed): a review previously found this dartdoc's old claim -
/// "a recompute that happens to straddle local midnight still evaluates
/// against the correct today" - didn't actually hold for a session left
/// open with nothing else changing overnight: [LocalDate.today] being read
/// fresh *inside the combiner* only helps if the combiner runs again, and
/// with no source-stream change there was nothing to trigger that. The
/// actual fix is watching [localDayProvider] below: it ticks over exactly
/// at local midnight (see its dartdoc), and `ref.watch` on a provider whose
/// value changes rebuilds this whole provider function - which
/// resubscribes every source stream from scratch. That's a deliberately
/// simpler fix than threading a sixth stream through the combinator: these
/// repository streams are cheap to resubscribe (a Drift `.watch()` just
/// re-runs its query; the prefs stream re-seeds its current value), and it
/// happens at most once a day. [LocalDate.today] is still also read fresh
/// inside the combiner on every recompute, as a second, cheap layer of
/// defence.

@ProviderFor(streakResult)
final streakResultProvider = StreakResultProvider._();

/// Recomputes a [StreakResult] on every change to activities, recovery
/// days, protecting flare days (F1: unwindowed — see
/// `WellbeingRepository.watchProtectingFlareDays`'s dartdoc), cycle
/// records, the streak-pausing preference, or the local calendar day
/// rolling over. Watches `activity`'s, `cycle`'s, and `wellbeing`'s
/// composition surfaces (never their `data/` — ADR 007) plus this
/// feature's own [recoveryRepositoryProvider].
///
/// S2 (fixed): a review previously found this dartdoc's old claim -
/// "a recompute that happens to straddle local midnight still evaluates
/// against the correct today" - didn't actually hold for a session left
/// open with nothing else changing overnight: [LocalDate.today] being read
/// fresh *inside the combiner* only helps if the combiner runs again, and
/// with no source-stream change there was nothing to trigger that. The
/// actual fix is watching [localDayProvider] below: it ticks over exactly
/// at local midnight (see its dartdoc), and `ref.watch` on a provider whose
/// value changes rebuilds this whole provider function - which
/// resubscribes every source stream from scratch. That's a deliberately
/// simpler fix than threading a sixth stream through the combinator: these
/// repository streams are cheap to resubscribe (a Drift `.watch()` just
/// re-runs its query; the prefs stream re-seeds its current value), and it
/// happens at most once a day. [LocalDate.today] is still also read fresh
/// inside the combiner on every recompute, as a second, cheap layer of
/// defence.

final class StreakResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakResult>,
          StreakResult,
          Stream<StreakResult>
        >
    with $FutureModifier<StreakResult>, $StreamProvider<StreakResult> {
  /// Recomputes a [StreakResult] on every change to activities, recovery
  /// days, protecting flare days (F1: unwindowed — see
  /// `WellbeingRepository.watchProtectingFlareDays`'s dartdoc), cycle
  /// records, the streak-pausing preference, or the local calendar day
  /// rolling over. Watches `activity`'s, `cycle`'s, and `wellbeing`'s
  /// composition surfaces (never their `data/` — ADR 007) plus this
  /// feature's own [recoveryRepositoryProvider].
  ///
  /// S2 (fixed): a review previously found this dartdoc's old claim -
  /// "a recompute that happens to straddle local midnight still evaluates
  /// against the correct today" - didn't actually hold for a session left
  /// open with nothing else changing overnight: [LocalDate.today] being read
  /// fresh *inside the combiner* only helps if the combiner runs again, and
  /// with no source-stream change there was nothing to trigger that. The
  /// actual fix is watching [localDayProvider] below: it ticks over exactly
  /// at local midnight (see its dartdoc), and `ref.watch` on a provider whose
  /// value changes rebuilds this whole provider function - which
  /// resubscribes every source stream from scratch. That's a deliberately
  /// simpler fix than threading a sixth stream through the combinator: these
  /// repository streams are cheap to resubscribe (a Drift `.watch()` just
  /// re-runs its query; the prefs stream re-seeds its current value), and it
  /// happens at most once a day. [LocalDate.today] is still also read fresh
  /// inside the combiner on every recompute, as a second, cheap layer of
  /// defence.
  StreakResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakResultHash();

  @$internal
  @override
  $StreamProviderElement<StreakResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreakResult> create(Ref ref) {
    return streakResult(ref);
  }
}

String _$streakResultHash() => r'fa4f6006be5648ad0e420da75f772f3cb5cd7c4c';

/// Watches every logged recovery day as full records (day + note),
/// unwindowed — a thin pass-through onto
/// [RecoveryRepository.watchRecoveryDayEntries] (see its own dartdoc for
/// why it's unwindowed). Consumed directly by [todayProtectionSourcesProvider]
/// below, and by the wellbeing history screen, which filters the result to
/// its own 30-day window client-side rather than needing a second,
/// windowed repository query for what stays a small dataset in practice.

@ProviderFor(recoveryDayEntries)
final recoveryDayEntriesProvider = RecoveryDayEntriesProvider._();

/// Watches every logged recovery day as full records (day + note),
/// unwindowed — a thin pass-through onto
/// [RecoveryRepository.watchRecoveryDayEntries] (see its own dartdoc for
/// why it's unwindowed). Consumed directly by [todayProtectionSourcesProvider]
/// below, and by the wellbeing history screen, which filters the result to
/// its own 30-day window client-side rather than needing a second,
/// windowed repository query for what stays a small dataset in practice.

final class RecoveryDayEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecoveryDayEntry>>,
          List<RecoveryDayEntry>,
          Stream<List<RecoveryDayEntry>>
        >
    with
        $FutureModifier<List<RecoveryDayEntry>>,
        $StreamProvider<List<RecoveryDayEntry>> {
  /// Watches every logged recovery day as full records (day + note),
  /// unwindowed — a thin pass-through onto
  /// [RecoveryRepository.watchRecoveryDayEntries] (see its own dartdoc for
  /// why it's unwindowed). Consumed directly by [todayProtectionSourcesProvider]
  /// below, and by the wellbeing history screen, which filters the result to
  /// its own 30-day window client-side rather than needing a second,
  /// windowed repository query for what stays a small dataset in practice.
  RecoveryDayEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoveryDayEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recoveryDayEntriesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecoveryDayEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecoveryDayEntry>> create(Ref ref) {
    return recoveryDayEntries(ref);
  }
}

String _$recoveryDayEntriesHash() =>
    r'0af12ed0f374c5b3c7d4d7a8644c4a93bf491d2c';

/// Every day the streak engine treats as protected recovery, as of today —
/// `domain/streak_assembly.dart`'s [assembleProtectedDays] over the same
/// three sources [streakResult] folds into its own `protectedDays`.
///
/// Exposed on the composition surface (ADR 007) because "was this day
/// protected" is a question other features legitimately have to ask:
/// `achievements` needs it so a period week cannot void a week of its
/// cycle-aware consistency ladder
/// (`features/achievements/domain/weekly_walking_rule.dart`). Handing over
/// the answer rather than the sources is the point — a second feature
/// re-deriving "protected" from recovery days, flares and the pausing
/// toggle would be a second definition, and the two would eventually
/// disagree.
///
/// Same midnight-rollover handling as [streakResult]: a dependency-only
/// watch on [localDayProvider] forces a full resubscribe at local midnight,
/// and [LocalDate.today] is read fresh inside the combiner regardless.

@ProviderFor(protectedDays)
final protectedDaysProvider = ProtectedDaysProvider._();

/// Every day the streak engine treats as protected recovery, as of today —
/// `domain/streak_assembly.dart`'s [assembleProtectedDays] over the same
/// three sources [streakResult] folds into its own `protectedDays`.
///
/// Exposed on the composition surface (ADR 007) because "was this day
/// protected" is a question other features legitimately have to ask:
/// `achievements` needs it so a period week cannot void a week of its
/// cycle-aware consistency ladder
/// (`features/achievements/domain/weekly_walking_rule.dart`). Handing over
/// the answer rather than the sources is the point — a second feature
/// re-deriving "protected" from recovery days, flares and the pausing
/// toggle would be a second definition, and the two would eventually
/// disagree.
///
/// Same midnight-rollover handling as [streakResult]: a dependency-only
/// watch on [localDayProvider] forces a full resubscribe at local midnight,
/// and [LocalDate.today] is read fresh inside the combiner regardless.

final class ProtectedDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<LocalDate>>,
          Set<LocalDate>,
          Stream<Set<LocalDate>>
        >
    with $FutureModifier<Set<LocalDate>>, $StreamProvider<Set<LocalDate>> {
  /// Every day the streak engine treats as protected recovery, as of today —
  /// `domain/streak_assembly.dart`'s [assembleProtectedDays] over the same
  /// three sources [streakResult] folds into its own `protectedDays`.
  ///
  /// Exposed on the composition surface (ADR 007) because "was this day
  /// protected" is a question other features legitimately have to ask:
  /// `achievements` needs it so a period week cannot void a week of its
  /// cycle-aware consistency ladder
  /// (`features/achievements/domain/weekly_walking_rule.dart`). Handing over
  /// the answer rather than the sources is the point — a second feature
  /// re-deriving "protected" from recovery days, flares and the pausing
  /// toggle would be a second definition, and the two would eventually
  /// disagree.
  ///
  /// Same midnight-rollover handling as [streakResult]: a dependency-only
  /// watch on [localDayProvider] forces a full resubscribe at local midnight,
  /// and [LocalDate.today] is read fresh inside the combiner regardless.
  ProtectedDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'protectedDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$protectedDaysHash();

  @$internal
  @override
  $StreamProviderElement<Set<LocalDate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<LocalDate>> create(Ref ref) {
    return protectedDays(ref);
  }
}

String _$protectedDaysHash() => r'7bfb7fdbc1855fd1f5af3cfd887a8988bda41788';

/// The per-source breakdown of what's protecting *today* specifically —
/// `domain/today_protection_sources.dart`'s [TodayProtectionSources],
/// assembled by [assembleTodayProtectionSources] from the same raw
/// per-source data [streakResultProvider] above draws its `protectedDays`
/// union from, just resolved per-source instead of unioned. Powers the
/// streak card's "Today" management sheet
/// (`features/home/presentation/widgets/today_sheet.dart`) — the engine
/// itself stays untouched; this is a second, independent derived view over
/// the same sources.
///
/// Same midnight-rollover handling as [streakResultProvider]: a
/// dependency-only watch on [localDayProvider] forces a full resubscribe of
/// the underlying streams at local midnight, and [LocalDate.today] is read
/// fresh inside the combiner on every recompute regardless.

@ProviderFor(todayProtectionSources)
final todayProtectionSourcesProvider = TodayProtectionSourcesProvider._();

/// The per-source breakdown of what's protecting *today* specifically —
/// `domain/today_protection_sources.dart`'s [TodayProtectionSources],
/// assembled by [assembleTodayProtectionSources] from the same raw
/// per-source data [streakResultProvider] above draws its `protectedDays`
/// union from, just resolved per-source instead of unioned. Powers the
/// streak card's "Today" management sheet
/// (`features/home/presentation/widgets/today_sheet.dart`) — the engine
/// itself stays untouched; this is a second, independent derived view over
/// the same sources.
///
/// Same midnight-rollover handling as [streakResultProvider]: a
/// dependency-only watch on [localDayProvider] forces a full resubscribe of
/// the underlying streams at local midnight, and [LocalDate.today] is read
/// fresh inside the combiner on every recompute regardless.

final class TodayProtectionSourcesProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayProtectionSources>,
          TodayProtectionSources,
          Stream<TodayProtectionSources>
        >
    with
        $FutureModifier<TodayProtectionSources>,
        $StreamProvider<TodayProtectionSources> {
  /// The per-source breakdown of what's protecting *today* specifically —
  /// `domain/today_protection_sources.dart`'s [TodayProtectionSources],
  /// assembled by [assembleTodayProtectionSources] from the same raw
  /// per-source data [streakResultProvider] above draws its `protectedDays`
  /// union from, just resolved per-source instead of unioned. Powers the
  /// streak card's "Today" management sheet
  /// (`features/home/presentation/widgets/today_sheet.dart`) — the engine
  /// itself stays untouched; this is a second, independent derived view over
  /// the same sources.
  ///
  /// Same midnight-rollover handling as [streakResultProvider]: a
  /// dependency-only watch on [localDayProvider] forces a full resubscribe of
  /// the underlying streams at local midnight, and [LocalDate.today] is read
  /// fresh inside the combiner on every recompute regardless.
  TodayProtectionSourcesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProtectionSourcesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayProtectionSourcesHash();

  @$internal
  @override
  $StreamProviderElement<TodayProtectionSources> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TodayProtectionSources> create(Ref ref) {
    return todayProtectionSources(ref);
  }
}

String _$todayProtectionSourcesHash() =>
    r'f7ea07fc233d7ed050cf1d1127bc370c9f9f1fa5';
