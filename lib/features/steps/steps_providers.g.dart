// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persistence for the daily step history, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.

@ProviderFor(stepsRepository)
final stepsRepositoryProvider = StepsRepositoryProvider._();

/// Persistence for the daily step history, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.

final class StepsRepositoryProvider
    extends
        $FunctionalProvider<StepsRepository, StepsRepository, StepsRepository>
    with $Provider<StepsRepository> {
  /// Persistence for the daily step history, typed as the domain interface so
  /// nothing above `data/` knows Drift is behind it.
  StepsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StepsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StepsRepository create(Ref ref) {
    return stepsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StepsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StepsRepository>(value),
    );
  }
}

String _$stepsRepositoryHash() => r'8e2d53a2122ffc43d5a9a7a2507ab8803ee3afbc';

/// Every stored step total in `[start, end]` — inclusive both ends, oldest
/// first, only days that have a row — re-emitted on every change.

@ProviderFor(dailyStepsRange)
final dailyStepsRangeProvider = DailyStepsRangeFamily._();

/// Every stored step total in `[start, end]` — inclusive both ends, oldest
/// first, only days that have a row — re-emitted on every change.

final class DailyStepsRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailySteps>>,
          List<DailySteps>,
          Stream<List<DailySteps>>
        >
    with $FutureModifier<List<DailySteps>>, $StreamProvider<List<DailySteps>> {
  /// Every stored step total in `[start, end]` — inclusive both ends, oldest
  /// first, only days that have a row — re-emitted on every change.
  DailyStepsRangeProvider._({
    required DailyStepsRangeFamily super.from,
    required (LocalDate, LocalDate) super.argument,
  }) : super(
         retry: null,
         name: r'dailyStepsRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyStepsRangeHash();

  @override
  String toString() {
    return r'dailyStepsRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailySteps>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailySteps>> create(Ref ref) {
    final argument = this.argument as (LocalDate, LocalDate);
    return dailyStepsRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyStepsRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyStepsRangeHash() => r'ab24a9cf7696100b958041d2d339f8745591b43e';

/// Every stored step total in `[start, end]` — inclusive both ends, oldest
/// first, only days that have a row — re-emitted on every change.

final class DailyStepsRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<DailySteps>>,
          (LocalDate, LocalDate)
        > {
  DailyStepsRangeFamily._()
    : super(
        retry: null,
        name: r'dailyStepsRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every stored step total in `[start, end]` — inclusive both ends, oldest
  /// first, only days that have a row — re-emitted on every change.

  DailyStepsRangeProvider call(LocalDate start, LocalDate end) =>
      DailyStepsRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'dailyStepsRangeProvider';
}

/// The daily step target the UI draws its ring and progress against.
///
/// A provider rather than a bare constant so the eventual per-user target
/// (stored alongside the other goals) is a change in one place. Today it
/// always answers [defaultDailyStepTarget]; see that constant for why the
/// number is a display default and not health advice.

@ProviderFor(stepsTarget)
final stepsTargetProvider = StepsTargetProvider._();

/// The daily step target the UI draws its ring and progress against.
///
/// A provider rather than a bare constant so the eventual per-user target
/// (stored alongside the other goals) is a change in one place. Today it
/// always answers [defaultDailyStepTarget]; see that constant for why the
/// number is a display default and not health advice.

final class StepsTargetProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The daily step target the UI draws its ring and progress against.
  ///
  /// A provider rather than a bare constant so the eventual per-user target
  /// (stored alongside the other goals) is a change in one place. Today it
  /// always answers [defaultDailyStepTarget]; see that constant for why the
  /// number is a display default and not health advice.
  StepsTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsTargetHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return stepsTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$stepsTargetHash() => r'51c944fb92165845772290e5c120982ce51f5e65';

/// Whether the health platform has granted this app read access to steps.
///
/// Its own provider, rather than an `await` inside [stepsAvailability],
/// because this is the only asynchronous part of that question and keeping
/// it separate lets availability stay a plain synchronous value the UI can
/// switch on. A throwing `hasPermissions()` answers `false`: if the app
/// cannot establish that it has been granted access to her health data, it
/// must not behave as though it has.

@ProviderFor(stepsPermission)
final stepsPermissionProvider = StepsPermissionProvider._();

/// Whether the health platform has granted this app read access to steps.
///
/// Its own provider, rather than an `await` inside [stepsAvailability],
/// because this is the only asynchronous part of that question and keeping
/// it separate lets availability stay a plain synchronous value the UI can
/// switch on. A throwing `hasPermissions()` answers `false`: if the app
/// cannot establish that it has been granted access to her health data, it
/// must not behave as though it has.

final class StepsPermissionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the health platform has granted this app read access to steps.
  ///
  /// Its own provider, rather than an `await` inside [stepsAvailability],
  /// because this is the only asynchronous part of that question and keeping
  /// it separate lets availability stay a plain synchronous value the UI can
  /// switch on. A throwing `hasPermissions()` answers `false`: if the app
  /// cannot establish that it has been granted access to her health data, it
  /// must not behave as though it has.
  StepsPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsPermissionHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return stepsPermission(ref);
  }
}

String _$stepsPermissionHash() => r'2650a77129913682502c3e7f7eaefb13dcb3d7e7';

/// Whether steps can be synced on this device right now, and if not, why —
/// the four cases the UI shows different, honest empty states for.
///
/// The two cheap questions are asked first and **short-circuit** the third,
/// so on web and Windows — and whenever the user's sync toggle is off —
/// [stepsPermission] is never even subscribed to and nothing touches the
/// health platform.
///
/// While [stepsPermission] is still resolving this reads
/// [StepsAvailability.permissionNeeded], and settles to
/// [StepsAvailability.available] when the platform answers. That direction
/// is deliberate: a moment of "we need permission" that resolves itself is
/// harmless, whereas defaulting to "available" would have the UI ask for
/// step data the app may have no right to.

@ProviderFor(stepsAvailability)
final stepsAvailabilityProvider = StepsAvailabilityProvider._();

/// Whether steps can be synced on this device right now, and if not, why —
/// the four cases the UI shows different, honest empty states for.
///
/// The two cheap questions are asked first and **short-circuit** the third,
/// so on web and Windows — and whenever the user's sync toggle is off —
/// [stepsPermission] is never even subscribed to and nothing touches the
/// health platform.
///
/// While [stepsPermission] is still resolving this reads
/// [StepsAvailability.permissionNeeded], and settles to
/// [StepsAvailability.available] when the platform answers. That direction
/// is deliberate: a moment of "we need permission" that resolves itself is
/// harmless, whereas defaulting to "available" would have the UI ask for
/// step data the app may have no right to.

final class StepsAvailabilityProvider
    extends
        $FunctionalProvider<
          StepsAvailability,
          StepsAvailability,
          StepsAvailability
        >
    with $Provider<StepsAvailability> {
  /// Whether steps can be synced on this device right now, and if not, why —
  /// the four cases the UI shows different, honest empty states for.
  ///
  /// The two cheap questions are asked first and **short-circuit** the third,
  /// so on web and Windows — and whenever the user's sync toggle is off —
  /// [stepsPermission] is never even subscribed to and nothing touches the
  /// health platform.
  ///
  /// While [stepsPermission] is still resolving this reads
  /// [StepsAvailability.permissionNeeded], and settles to
  /// [StepsAvailability.available] when the platform answers. That direction
  /// is deliberate: a moment of "we need permission" that resolves itself is
  /// harmless, whereas defaulting to "available" would have the UI ask for
  /// step data the app may have no right to.
  StepsAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsAvailabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsAvailabilityHash();

  @$internal
  @override
  $ProviderElement<StepsAvailability> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StepsAvailability create(Ref ref) {
    return stepsAvailability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StepsAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StepsAvailability>(value),
    );
  }
}

String _$stepsAvailabilityHash() => r'acdd451e99a52e47eb9fd582dfeb1e15b757b6e2';

/// Reads step totals from the platform health source and stores them.
///
/// `keepAlive` because [StepsSyncState.lastSyncedAt] is what the throttle in
/// [StepsSync.syncRecent] measures against — an autoDispose notifier would
/// forget it every time the steps screen popped, and the throttle would stop
/// existing.
///
/// S2 (`knowledge/engineering/security_and_privacy.md`: health-platform
/// data). Three rules hold throughout:
///
/// * **Nothing is read unless she asked for it.** Every entry point returns
///   without touching the adapter while the fitness-device sync toggle is
///   off, which is her explicit per-source permission for this app.
/// * **No step value is ever logged**, and no platform exception is either —
///   a health platform's error text can carry the values themselves.
/// * **Outcomes are honest.** A missing permission is reported as
///   [StepsSyncOutcome.noPermission], never as a failure; an absent platform
///   as [StepsSyncOutcome.unsupported]; and [StepsSyncOutcome.synced] is
///   only ever claimed for a window that was actually read.

@ProviderFor(StepsSync)
final stepsSyncProvider = StepsSyncProvider._();

/// Reads step totals from the platform health source and stores them.
///
/// `keepAlive` because [StepsSyncState.lastSyncedAt] is what the throttle in
/// [StepsSync.syncRecent] measures against — an autoDispose notifier would
/// forget it every time the steps screen popped, and the throttle would stop
/// existing.
///
/// S2 (`knowledge/engineering/security_and_privacy.md`: health-platform
/// data). Three rules hold throughout:
///
/// * **Nothing is read unless she asked for it.** Every entry point returns
///   without touching the adapter while the fitness-device sync toggle is
///   off, which is her explicit per-source permission for this app.
/// * **No step value is ever logged**, and no platform exception is either —
///   a health platform's error text can carry the values themselves.
/// * **Outcomes are honest.** A missing permission is reported as
///   [StepsSyncOutcome.noPermission], never as a failure; an absent platform
///   as [StepsSyncOutcome.unsupported]; and [StepsSyncOutcome.synced] is
///   only ever claimed for a window that was actually read.
final class StepsSyncProvider
    extends $NotifierProvider<StepsSync, StepsSyncState> {
  /// Reads step totals from the platform health source and stores them.
  ///
  /// `keepAlive` because [StepsSyncState.lastSyncedAt] is what the throttle in
  /// [StepsSync.syncRecent] measures against — an autoDispose notifier would
  /// forget it every time the steps screen popped, and the throttle would stop
  /// existing.
  ///
  /// S2 (`knowledge/engineering/security_and_privacy.md`: health-platform
  /// data). Three rules hold throughout:
  ///
  /// * **Nothing is read unless she asked for it.** Every entry point returns
  ///   without touching the adapter while the fitness-device sync toggle is
  ///   off, which is her explicit per-source permission for this app.
  /// * **No step value is ever logged**, and no platform exception is either —
  ///   a health platform's error text can carry the values themselves.
  /// * **Outcomes are honest.** A missing permission is reported as
  ///   [StepsSyncOutcome.noPermission], never as a failure; an absent platform
  ///   as [StepsSyncOutcome.unsupported]; and [StepsSyncOutcome.synced] is
  ///   only ever claimed for a window that was actually read.
  StepsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsSyncHash();

  @$internal
  @override
  StepsSync create() => StepsSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StepsSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StepsSyncState>(value),
    );
  }
}

String _$stepsSyncHash() => r'ead4f92ddb2766b528ed91553f74474d778afb66';

/// Reads step totals from the platform health source and stores them.
///
/// `keepAlive` because [StepsSyncState.lastSyncedAt] is what the throttle in
/// [StepsSync.syncRecent] measures against — an autoDispose notifier would
/// forget it every time the steps screen popped, and the throttle would stop
/// existing.
///
/// S2 (`knowledge/engineering/security_and_privacy.md`: health-platform
/// data). Three rules hold throughout:
///
/// * **Nothing is read unless she asked for it.** Every entry point returns
///   without touching the adapter while the fitness-device sync toggle is
///   off, which is her explicit per-source permission for this app.
/// * **No step value is ever logged**, and no platform exception is either —
///   a health platform's error text can carry the values themselves.
/// * **Outcomes are honest.** A missing permission is reported as
///   [StepsSyncOutcome.noPermission], never as a failure; an absent platform
///   as [StepsSyncOutcome.unsupported]; and [StepsSyncOutcome.synced] is
///   only ever claimed for a window that was actually read.

abstract class _$StepsSync extends $Notifier<StepsSyncState> {
  StepsSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StepsSyncState, StepsSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StepsSyncState, StepsSyncState>,
              StepsSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
