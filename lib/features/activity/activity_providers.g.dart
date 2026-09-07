// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `activity` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.

@ProviderFor(activityRepository)
final activityRepositoryProvider = ActivityRepositoryProvider._();

/// Composition surface for the `activity` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.

final class ActivityRepositoryProvider
    extends
        $FunctionalProvider<
          ActivityRepository,
          ActivityRepository,
          ActivityRepository
        >
    with $Provider<ActivityRepository> {
  /// Composition surface for the `activity` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root) to
  /// reach this feature's persistence: other features may import this file,
  /// never `data/` or `presentation/` directly.
  ActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActivityRepository create(Ref ref) {
    return activityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityRepository>(value),
    );
  }
}

String _$activityRepositoryHash() =>
    r'e95ee7228a115e21e79187c0e51b83693c837288';

/// Watches every non-deleted activity, newest first.

@ProviderFor(activities)
final activitiesProvider = ActivitiesProvider._();

/// Watches every non-deleted activity, newest first.

final class ActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Activity>>,
          List<Activity>,
          Stream<List<Activity>>
        >
    with $FutureModifier<List<Activity>>, $StreamProvider<List<Activity>> {
  /// Watches every non-deleted activity, newest first.
  ActivitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activitiesHash();

  @$internal
  @override
  $StreamProviderElement<List<Activity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Activity>> create(Ref ref) {
    return activities(ref);
  }
}

String _$activitiesHash() => r'baf367124ee05b189e56c05d114ddae3f88ab490';

@ProviderFor(strengthRoutineRepository)
final strengthRoutineRepositoryProvider = StrengthRoutineRepositoryProvider._();

final class StrengthRoutineRepositoryProvider
    extends
        $FunctionalProvider<
          StrengthRoutineRepository,
          StrengthRoutineRepository,
          StrengthRoutineRepository
        >
    with $Provider<StrengthRoutineRepository> {
  StrengthRoutineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strengthRoutineRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strengthRoutineRepositoryHash();

  @$internal
  @override
  $ProviderElement<StrengthRoutineRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StrengthRoutineRepository create(Ref ref) {
    return strengthRoutineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StrengthRoutineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StrengthRoutineRepository>(value),
    );
  }
}

String _$strengthRoutineRepositoryHash() =>
    r'69d07a4e7b95a324ec32e0ab1eab8103c8c2614f';

@ProviderFor(strengthCycles)
final strengthCyclesProvider = StrengthCyclesProvider._();

final class StrengthCyclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StrengthCycle>>,
          List<StrengthCycle>,
          Stream<List<StrengthCycle>>
        >
    with
        $FutureModifier<List<StrengthCycle>>,
        $StreamProvider<List<StrengthCycle>> {
  StrengthCyclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strengthCyclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strengthCyclesHash();

  @$internal
  @override
  $StreamProviderElement<List<StrengthCycle>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StrengthCycle>> create(Ref ref) {
    return strengthCycles(ref);
  }
}

String _$strengthCyclesHash() => r'a6d912989451a8037113c694b94008626fe7b641';

@ProviderFor(strengthRoutines)
final strengthRoutinesProvider = StrengthRoutinesProvider._();

final class StrengthRoutinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StrengthDayRoutine>>,
          List<StrengthDayRoutine>,
          Stream<List<StrengthDayRoutine>>
        >
    with
        $FutureModifier<List<StrengthDayRoutine>>,
        $StreamProvider<List<StrengthDayRoutine>> {
  StrengthRoutinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strengthRoutinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strengthRoutinesHash();

  @$internal
  @override
  $StreamProviderElement<List<StrengthDayRoutine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StrengthDayRoutine>> create(Ref ref) {
    return strengthRoutines(ref);
  }
}

String _$strengthRoutinesHash() => r'4b7503c66eb3a79af35d6cf891368658b22c2154';

/// The active training cycle, live.
///
/// A stream over [StrengthRoutineRepository.watchCycles] rather than a
/// one-shot `getActiveCycle()`: as a Future this provider was never
/// invalidated after `setActiveCycle`, so "Set Active" wrote to the database
/// and neither the launcher sheet nor the Strength Hub ever showed it
/// (found on device 2026-09-02).

@ProviderFor(activeStrengthCycle)
final activeStrengthCycleProvider = ActiveStrengthCycleProvider._();

/// The active training cycle, live.
///
/// A stream over [StrengthRoutineRepository.watchCycles] rather than a
/// one-shot `getActiveCycle()`: as a Future this provider was never
/// invalidated after `setActiveCycle`, so "Set Active" wrote to the database
/// and neither the launcher sheet nor the Strength Hub ever showed it
/// (found on device 2026-09-02).

final class ActiveStrengthCycleProvider
    extends
        $FunctionalProvider<
          AsyncValue<StrengthCycle?>,
          StrengthCycle?,
          Stream<StrengthCycle?>
        >
    with $FutureModifier<StrengthCycle?>, $StreamProvider<StrengthCycle?> {
  /// The active training cycle, live.
  ///
  /// A stream over [StrengthRoutineRepository.watchCycles] rather than a
  /// one-shot `getActiveCycle()`: as a Future this provider was never
  /// invalidated after `setActiveCycle`, so "Set Active" wrote to the database
  /// and neither the launcher sheet nor the Strength Hub ever showed it
  /// (found on device 2026-09-02).
  ActiveStrengthCycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeStrengthCycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeStrengthCycleHash();

  @$internal
  @override
  $StreamProviderElement<StrengthCycle?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StrengthCycle?> create(Ref ref) {
    return activeStrengthCycle(ref);
  }
}

String _$activeStrengthCycleHash() =>
    r'3153115c9af44fe83fdb69066375231e255fd2f8';

@ProviderFor(yogaSequenceRepository)
final yogaSequenceRepositoryProvider = YogaSequenceRepositoryProvider._();

final class YogaSequenceRepositoryProvider
    extends
        $FunctionalProvider<
          YogaSequenceRepository,
          YogaSequenceRepository,
          YogaSequenceRepository
        >
    with $Provider<YogaSequenceRepository> {
  YogaSequenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yogaSequenceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yogaSequenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<YogaSequenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  YogaSequenceRepository create(Ref ref) {
    return yogaSequenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YogaSequenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YogaSequenceRepository>(value),
    );
  }
}

String _$yogaSequenceRepositoryHash() =>
    r'f22dd0a3d05b303ccdc68af59cce189c89dccf35';

/// Every saved yoga sequence, most recently updated first.
///
/// Stored rows only. `YogaSequenceStarters.starters` is a domain constant
/// and is deliberately **not** merged in here - an empty list means she has
/// saved nothing, and the UI offers a starter separately, saving
/// `starter.copyAsNew()` if she takes it.

@ProviderFor(yogaSequences)
final yogaSequencesProvider = YogaSequencesProvider._();

/// Every saved yoga sequence, most recently updated first.
///
/// Stored rows only. `YogaSequenceStarters.starters` is a domain constant
/// and is deliberately **not** merged in here - an empty list means she has
/// saved nothing, and the UI offers a starter separately, saving
/// `starter.copyAsNew()` if she takes it.

final class YogaSequencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<YogaSequence>>,
          List<YogaSequence>,
          Stream<List<YogaSequence>>
        >
    with
        $FutureModifier<List<YogaSequence>>,
        $StreamProvider<List<YogaSequence>> {
  /// Every saved yoga sequence, most recently updated first.
  ///
  /// Stored rows only. `YogaSequenceStarters.starters` is a domain constant
  /// and is deliberately **not** merged in here - an empty list means she has
  /// saved nothing, and the UI offers a starter separately, saving
  /// `starter.copyAsNew()` if she takes it.
  YogaSequencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yogaSequencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yogaSequencesHash();

  @$internal
  @override
  $StreamProviderElement<List<YogaSequence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<YogaSequence>> create(Ref ref) {
    return yogaSequences(ref);
  }
}

String _$yogaSequencesHash() => r'90aaee364c2ac70c0870af273678ae7dacf4dd9a';

/// One saved sequence, live.
///
/// Derived from `watchSequences()` rather than a one-shot `getSequence` so
/// an editor or runner watching it sees an edit land - the same reason
/// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
/// there).

@ProviderFor(yogaSequence)
final yogaSequenceProvider = YogaSequenceFamily._();

/// One saved sequence, live.
///
/// Derived from `watchSequences()` rather than a one-shot `getSequence` so
/// an editor or runner watching it sees an edit land - the same reason
/// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
/// there).

final class YogaSequenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<YogaSequence?>,
          YogaSequence?,
          Stream<YogaSequence?>
        >
    with $FutureModifier<YogaSequence?>, $StreamProvider<YogaSequence?> {
  /// One saved sequence, live.
  ///
  /// Derived from `watchSequences()` rather than a one-shot `getSequence` so
  /// an editor or runner watching it sees an edit land - the same reason
  /// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
  /// there).
  YogaSequenceProvider._({
    required YogaSequenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'yogaSequenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yogaSequenceHash();

  @override
  String toString() {
    return r'yogaSequenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<YogaSequence?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<YogaSequence?> create(Ref ref) {
    final argument = this.argument as String;
    return yogaSequence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YogaSequenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yogaSequenceHash() => r'3804b8e7b599cba8ab09b13dd1490e146529b08d';

/// One saved sequence, live.
///
/// Derived from `watchSequences()` rather than a one-shot `getSequence` so
/// an editor or runner watching it sees an edit land - the same reason
/// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
/// there).

final class YogaSequenceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<YogaSequence?>, String> {
  YogaSequenceFamily._()
    : super(
        retry: null,
        name: r'yogaSequenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One saved sequence, live.
  ///
  /// Derived from `watchSequences()` rather than a one-shot `getSequence` so
  /// an editor or runner watching it sees an edit land - the same reason
  /// `activeStrengthCycle` is a stream (see its doc for what a Future cost us
  /// there).

  YogaSequenceProvider call(String id) =>
      YogaSequenceProvider._(argument: id, from: this);

  @override
  String toString() => r'yogaSequenceProvider';
}

/// Remembers, per activity type, whether a running session holds the
/// screen on.
///
/// **Known departure from ADR 007**, recorded rather than quietly left, and
/// the same one `nutrition_providers.dart`'s `onlineLookupNoticeStore`
/// documents: the other providers on this surface are typed as `domain/`
/// interfaces, and this one is typed as the concrete `data/` class. It is a
/// handful of device booleans with no second implementation in prospect,
/// and a port for them would be ceremony.
///
/// Degrades to a store with no backing when `sharedPreferencesProvider` was
/// never overridden, the same way `accessibilityRepositoryProvider` does:
/// every tracker reaches this on start, so a widget test that pumps one
/// without wiring preferences would otherwise die on that provider's
/// deliberate `UnimplementedError`. Unreachable in the app — `bootstrap.dart`
/// always overrides it before `runApp`.
///
/// **Only that one case degrades.** Riverpod 3 wraps an error thrown by a
/// dependency in a `ProviderException` before `ref.watch` rethrows it, so
/// `on UnimplementedError` would catch nothing here and `on Object` would
/// swallow every real failure as a silently preference-less app. Unwrap,
/// check, and rethrow anything else.

@ProviderFor(screenAwakePreferenceStore)
final screenAwakePreferenceStoreProvider =
    ScreenAwakePreferenceStoreProvider._();

/// Remembers, per activity type, whether a running session holds the
/// screen on.
///
/// **Known departure from ADR 007**, recorded rather than quietly left, and
/// the same one `nutrition_providers.dart`'s `onlineLookupNoticeStore`
/// documents: the other providers on this surface are typed as `domain/`
/// interfaces, and this one is typed as the concrete `data/` class. It is a
/// handful of device booleans with no second implementation in prospect,
/// and a port for them would be ceremony.
///
/// Degrades to a store with no backing when `sharedPreferencesProvider` was
/// never overridden, the same way `accessibilityRepositoryProvider` does:
/// every tracker reaches this on start, so a widget test that pumps one
/// without wiring preferences would otherwise die on that provider's
/// deliberate `UnimplementedError`. Unreachable in the app — `bootstrap.dart`
/// always overrides it before `runApp`.
///
/// **Only that one case degrades.** Riverpod 3 wraps an error thrown by a
/// dependency in a `ProviderException` before `ref.watch` rethrows it, so
/// `on UnimplementedError` would catch nothing here and `on Object` would
/// swallow every real failure as a silently preference-less app. Unwrap,
/// check, and rethrow anything else.

final class ScreenAwakePreferenceStoreProvider
    extends
        $FunctionalProvider<
          ScreenAwakePreferenceStore,
          ScreenAwakePreferenceStore,
          ScreenAwakePreferenceStore
        >
    with $Provider<ScreenAwakePreferenceStore> {
  /// Remembers, per activity type, whether a running session holds the
  /// screen on.
  ///
  /// **Known departure from ADR 007**, recorded rather than quietly left, and
  /// the same one `nutrition_providers.dart`'s `onlineLookupNoticeStore`
  /// documents: the other providers on this surface are typed as `domain/`
  /// interfaces, and this one is typed as the concrete `data/` class. It is a
  /// handful of device booleans with no second implementation in prospect,
  /// and a port for them would be ceremony.
  ///
  /// Degrades to a store with no backing when `sharedPreferencesProvider` was
  /// never overridden, the same way `accessibilityRepositoryProvider` does:
  /// every tracker reaches this on start, so a widget test that pumps one
  /// without wiring preferences would otherwise die on that provider's
  /// deliberate `UnimplementedError`. Unreachable in the app — `bootstrap.dart`
  /// always overrides it before `runApp`.
  ///
  /// **Only that one case degrades.** Riverpod 3 wraps an error thrown by a
  /// dependency in a `ProviderException` before `ref.watch` rethrows it, so
  /// `on UnimplementedError` would catch nothing here and `on Object` would
  /// swallow every real failure as a silently preference-less app. Unwrap,
  /// check, and rethrow anything else.
  ScreenAwakePreferenceStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenAwakePreferenceStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenAwakePreferenceStoreHash();

  @$internal
  @override
  $ProviderElement<ScreenAwakePreferenceStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScreenAwakePreferenceStore create(Ref ref) {
    return screenAwakePreferenceStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenAwakePreferenceStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenAwakePreferenceStore>(value),
    );
  }
}

String _$screenAwakePreferenceStoreHash() =>
    r'4f2f596bfc8d10453503b6af5c22bbd7ef7595da';

/// Whether [type]'s tracker should keep the screen awake — the value the
/// hub switch renders and the trackers obey.
///
/// `keepAlive` because a tracker holds onto this for the whole of a
/// session, and that outlives the hub screen the switch lives on: an
/// autoDispose family would drop the listener the moment she left the hub,
/// which is exactly when a running workout still needs to hear about a
/// change.

@ProviderFor(ScreenAwakePreference)
final screenAwakePreferenceProvider = ScreenAwakePreferenceFamily._();

/// Whether [type]'s tracker should keep the screen awake — the value the
/// hub switch renders and the trackers obey.
///
/// `keepAlive` because a tracker holds onto this for the whole of a
/// session, and that outlives the hub screen the switch lives on: an
/// autoDispose family would drop the listener the moment she left the hub,
/// which is exactly when a running workout still needs to hear about a
/// change.
final class ScreenAwakePreferenceProvider
    extends $NotifierProvider<ScreenAwakePreference, bool> {
  /// Whether [type]'s tracker should keep the screen awake — the value the
  /// hub switch renders and the trackers obey.
  ///
  /// `keepAlive` because a tracker holds onto this for the whole of a
  /// session, and that outlives the hub screen the switch lives on: an
  /// autoDispose family would drop the listener the moment she left the hub,
  /// which is exactly when a running workout still needs to hear about a
  /// change.
  ScreenAwakePreferenceProvider._({
    required ScreenAwakePreferenceFamily super.from,
    required ActivityType super.argument,
  }) : super(
         retry: null,
         name: r'screenAwakePreferenceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$screenAwakePreferenceHash();

  @override
  String toString() {
    return r'screenAwakePreferenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ScreenAwakePreference create() => ScreenAwakePreference();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenAwakePreferenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$screenAwakePreferenceHash() =>
    r'1edb1267d1678a1147c18f66c75e7335cfa03d69';

/// Whether [type]'s tracker should keep the screen awake — the value the
/// hub switch renders and the trackers obey.
///
/// `keepAlive` because a tracker holds onto this for the whole of a
/// session, and that outlives the hub screen the switch lives on: an
/// autoDispose family would drop the listener the moment she left the hub,
/// which is exactly when a running workout still needs to hear about a
/// change.

final class ScreenAwakePreferenceFamily extends $Family
    with
        $ClassFamilyOverride<
          ScreenAwakePreference,
          bool,
          bool,
          bool,
          ActivityType
        > {
  ScreenAwakePreferenceFamily._()
    : super(
        retry: null,
        name: r'screenAwakePreferenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Whether [type]'s tracker should keep the screen awake — the value the
  /// hub switch renders and the trackers obey.
  ///
  /// `keepAlive` because a tracker holds onto this for the whole of a
  /// session, and that outlives the hub screen the switch lives on: an
  /// autoDispose family would drop the listener the moment she left the hub,
  /// which is exactly when a running workout still needs to hear about a
  /// change.

  ScreenAwakePreferenceProvider call(ActivityType type) =>
      ScreenAwakePreferenceProvider._(argument: type, from: this);

  @override
  String toString() => r'screenAwakePreferenceProvider';
}

/// Whether [type]'s tracker should keep the screen awake — the value the
/// hub switch renders and the trackers obey.
///
/// `keepAlive` because a tracker holds onto this for the whole of a
/// session, and that outlives the hub screen the switch lives on: an
/// autoDispose family would drop the listener the moment she left the hub,
/// which is exactly when a running workout still needs to hear about a
/// change.

abstract class _$ScreenAwakePreference extends $Notifier<bool> {
  late final _$args = ref.$arg as ActivityType;
  ActivityType get type => _$args;

  bool build(ActivityType type);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The current user's preferred unit system, for converting activity (and,
/// via this same composition-surface provider, progress) stats at the
/// presentation boundary. Reads through `profile`'s composition surface
/// (`profile_providers.dart`) - legal per ADR 007 since it's that feature's
/// public provider, not its `data/`/`presentation/`. Defaults to
/// [UnitSystem.metric] until a profile exists (mirrors
/// `OnboardingController`'s default).
///
/// Promoted here from `activity/presentation/activity_list_controller.dart`
/// (F8, review-recommended): this is a composition-surface concern, not
/// screen-specific state, and living here is what let `progress_providers.dart`
/// consume it directly instead of maintaining its own byte-for-byte
/// duplicate (`progressUnitSystemProvider`, now deleted) - ADR 007 only
/// blocked that reuse while this provider lived in `activity`'s
/// `presentation/`, never its `domain/`/composition surface.

@ProviderFor(activityUnitSystem)
final activityUnitSystemProvider = ActivityUnitSystemProvider._();

/// The current user's preferred unit system, for converting activity (and,
/// via this same composition-surface provider, progress) stats at the
/// presentation boundary. Reads through `profile`'s composition surface
/// (`profile_providers.dart`) - legal per ADR 007 since it's that feature's
/// public provider, not its `data/`/`presentation/`. Defaults to
/// [UnitSystem.metric] until a profile exists (mirrors
/// `OnboardingController`'s default).
///
/// Promoted here from `activity/presentation/activity_list_controller.dart`
/// (F8, review-recommended): this is a composition-surface concern, not
/// screen-specific state, and living here is what let `progress_providers.dart`
/// consume it directly instead of maintaining its own byte-for-byte
/// duplicate (`progressUnitSystemProvider`, now deleted) - ADR 007 only
/// blocked that reuse while this provider lived in `activity`'s
/// `presentation/`, never its `domain/`/composition surface.

final class ActivityUnitSystemProvider
    extends
        $FunctionalProvider<
          AsyncValue<UnitSystem>,
          UnitSystem,
          Stream<UnitSystem>
        >
    with $FutureModifier<UnitSystem>, $StreamProvider<UnitSystem> {
  /// The current user's preferred unit system, for converting activity (and,
  /// via this same composition-surface provider, progress) stats at the
  /// presentation boundary. Reads through `profile`'s composition surface
  /// (`profile_providers.dart`) - legal per ADR 007 since it's that feature's
  /// public provider, not its `data/`/`presentation/`. Defaults to
  /// [UnitSystem.metric] until a profile exists (mirrors
  /// `OnboardingController`'s default).
  ///
  /// Promoted here from `activity/presentation/activity_list_controller.dart`
  /// (F8, review-recommended): this is a composition-surface concern, not
  /// screen-specific state, and living here is what let `progress_providers.dart`
  /// consume it directly instead of maintaining its own byte-for-byte
  /// duplicate (`progressUnitSystemProvider`, now deleted) - ADR 007 only
  /// blocked that reuse while this provider lived in `activity`'s
  /// `presentation/`, never its `domain/`/composition surface.
  ActivityUnitSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityUnitSystemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityUnitSystemHash();

  @$internal
  @override
  $StreamProviderElement<UnitSystem> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UnitSystem> create(Ref ref) {
    return activityUnitSystem(ref);
  }
}

String _$activityUnitSystemHash() =>
    r'968bce5768246e408545d13797bd18e1cad82f12';

/// Recomputes [PersonalRecords] (`domain/personal_records.dart`) every time
/// the activity list changes.
///
/// ## Fold, don't batch (F7)
/// On each `watchActivities()` emission, this fetches (via one-shot
/// [ActivityRepository.getSamples], not a per-activity stream subscription)
/// one `recorded` activity's samples at a time and immediately folds them
/// into a running [PersonalRecords] via
/// [foldActivityIntoRecords] - unlike `computePersonalRecords`'s batch
/// form, this never holds more than one activity's sample list in memory
/// at once (the previous activity's samples become unreachable, and
/// GC-eligible, the moment the loop moves on).
///
/// ## Stale-drop (F7)
/// A rescan is a chain of awaits (one `getSamples` per recorded activity),
/// so a burst of rapid `watchActivities()` emissions (e.g. several
/// activities saved in quick succession) can leave more than one rescan
/// in flight at once. Each rescan is tagged with the epoch it started at;
/// `latestEpoch` is bumped synchronously the moment a new emission
/// arrives (*not* when its rescan happens to finish), and a rescan checks
/// its own epoch against it both before starting the next activity's fetch
/// and again right after that fetch resolves - if it's been superseded
/// either time, it abandons silently (adds nothing to `controller`)
/// rather than letting a slow, now-stale rescan's result overwrite a
/// faster, newer one that already landed. This is what keeps the two
/// `getSamples` await points genuinely cheap to abandon at, rather than
/// discovering staleness only once a full rescan has already finished.
///
/// ## The offstage-IndexedStack reality (F7)
/// This provider has no `keepAlive: true` of its own, but that doesn't
/// mean it's cheaply disposed in practice: `app/router` keeps every shell
/// branch's navigator (Home, Activity, Progress, ...) mounted offstage
/// inside an `IndexedStack` rather than tearing it down on tab switch (see
/// `flutter_patterns.md`), so a screen that watches this provider keeps it
/// alive - and rescanning on every activity change - for as long as the
/// app runs, even while its tab is offstage and nothing is visibly
/// listening. The stale-drop above bounds the *cost* of that (an offstage
/// rescan still gets abandoned the instant a newer one supersedes it), but
/// it doesn't stop the rescans from happening at all. A real fix (e.g. a
/// shared activities stream, or genuinely disposing offstage branches) is
/// tracked in `knowledge/product/deferred.md`'s "Offstage IndexedStack
/// keeps Progress providers live" and "Shared activities stream" entries -
/// this wave only closes the "wasted work while superseded" half of that
/// gap, not the "runs at all while offstage" half.
///
/// Exposed here (rather than in a wave-2 `progress` feature) per ADR 007:
/// this feature owns the data the computation is derived from, and another
/// feature may only reach it through this composition surface.

@ProviderFor(personalRecords)
final personalRecordsProvider = PersonalRecordsProvider._();

/// Recomputes [PersonalRecords] (`domain/personal_records.dart`) every time
/// the activity list changes.
///
/// ## Fold, don't batch (F7)
/// On each `watchActivities()` emission, this fetches (via one-shot
/// [ActivityRepository.getSamples], not a per-activity stream subscription)
/// one `recorded` activity's samples at a time and immediately folds them
/// into a running [PersonalRecords] via
/// [foldActivityIntoRecords] - unlike `computePersonalRecords`'s batch
/// form, this never holds more than one activity's sample list in memory
/// at once (the previous activity's samples become unreachable, and
/// GC-eligible, the moment the loop moves on).
///
/// ## Stale-drop (F7)
/// A rescan is a chain of awaits (one `getSamples` per recorded activity),
/// so a burst of rapid `watchActivities()` emissions (e.g. several
/// activities saved in quick succession) can leave more than one rescan
/// in flight at once. Each rescan is tagged with the epoch it started at;
/// `latestEpoch` is bumped synchronously the moment a new emission
/// arrives (*not* when its rescan happens to finish), and a rescan checks
/// its own epoch against it both before starting the next activity's fetch
/// and again right after that fetch resolves - if it's been superseded
/// either time, it abandons silently (adds nothing to `controller`)
/// rather than letting a slow, now-stale rescan's result overwrite a
/// faster, newer one that already landed. This is what keeps the two
/// `getSamples` await points genuinely cheap to abandon at, rather than
/// discovering staleness only once a full rescan has already finished.
///
/// ## The offstage-IndexedStack reality (F7)
/// This provider has no `keepAlive: true` of its own, but that doesn't
/// mean it's cheaply disposed in practice: `app/router` keeps every shell
/// branch's navigator (Home, Activity, Progress, ...) mounted offstage
/// inside an `IndexedStack` rather than tearing it down on tab switch (see
/// `flutter_patterns.md`), so a screen that watches this provider keeps it
/// alive - and rescanning on every activity change - for as long as the
/// app runs, even while its tab is offstage and nothing is visibly
/// listening. The stale-drop above bounds the *cost* of that (an offstage
/// rescan still gets abandoned the instant a newer one supersedes it), but
/// it doesn't stop the rescans from happening at all. A real fix (e.g. a
/// shared activities stream, or genuinely disposing offstage branches) is
/// tracked in `knowledge/product/deferred.md`'s "Offstage IndexedStack
/// keeps Progress providers live" and "Shared activities stream" entries -
/// this wave only closes the "wasted work while superseded" half of that
/// gap, not the "runs at all while offstage" half.
///
/// Exposed here (rather than in a wave-2 `progress` feature) per ADR 007:
/// this feature owns the data the computation is derived from, and another
/// feature may only reach it through this composition surface.

final class PersonalRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersonalRecords>,
          PersonalRecords,
          Stream<PersonalRecords>
        >
    with $FutureModifier<PersonalRecords>, $StreamProvider<PersonalRecords> {
  /// Recomputes [PersonalRecords] (`domain/personal_records.dart`) every time
  /// the activity list changes.
  ///
  /// ## Fold, don't batch (F7)
  /// On each `watchActivities()` emission, this fetches (via one-shot
  /// [ActivityRepository.getSamples], not a per-activity stream subscription)
  /// one `recorded` activity's samples at a time and immediately folds them
  /// into a running [PersonalRecords] via
  /// [foldActivityIntoRecords] - unlike `computePersonalRecords`'s batch
  /// form, this never holds more than one activity's sample list in memory
  /// at once (the previous activity's samples become unreachable, and
  /// GC-eligible, the moment the loop moves on).
  ///
  /// ## Stale-drop (F7)
  /// A rescan is a chain of awaits (one `getSamples` per recorded activity),
  /// so a burst of rapid `watchActivities()` emissions (e.g. several
  /// activities saved in quick succession) can leave more than one rescan
  /// in flight at once. Each rescan is tagged with the epoch it started at;
  /// `latestEpoch` is bumped synchronously the moment a new emission
  /// arrives (*not* when its rescan happens to finish), and a rescan checks
  /// its own epoch against it both before starting the next activity's fetch
  /// and again right after that fetch resolves - if it's been superseded
  /// either time, it abandons silently (adds nothing to `controller`)
  /// rather than letting a slow, now-stale rescan's result overwrite a
  /// faster, newer one that already landed. This is what keeps the two
  /// `getSamples` await points genuinely cheap to abandon at, rather than
  /// discovering staleness only once a full rescan has already finished.
  ///
  /// ## The offstage-IndexedStack reality (F7)
  /// This provider has no `keepAlive: true` of its own, but that doesn't
  /// mean it's cheaply disposed in practice: `app/router` keeps every shell
  /// branch's navigator (Home, Activity, Progress, ...) mounted offstage
  /// inside an `IndexedStack` rather than tearing it down on tab switch (see
  /// `flutter_patterns.md`), so a screen that watches this provider keeps it
  /// alive - and rescanning on every activity change - for as long as the
  /// app runs, even while its tab is offstage and nothing is visibly
  /// listening. The stale-drop above bounds the *cost* of that (an offstage
  /// rescan still gets abandoned the instant a newer one supersedes it), but
  /// it doesn't stop the rescans from happening at all. A real fix (e.g. a
  /// shared activities stream, or genuinely disposing offstage branches) is
  /// tracked in `knowledge/product/deferred.md`'s "Offstage IndexedStack
  /// keeps Progress providers live" and "Shared activities stream" entries -
  /// this wave only closes the "wasted work while superseded" half of that
  /// gap, not the "runs at all while offstage" half.
  ///
  /// Exposed here (rather than in a wave-2 `progress` feature) per ADR 007:
  /// this feature owns the data the computation is derived from, and another
  /// feature may only reach it through this composition surface.
  PersonalRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalRecordsHash();

  @$internal
  @override
  $StreamProviderElement<PersonalRecords> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PersonalRecords> create(Ref ref) {
    return personalRecords(ref);
  }
}

String _$personalRecordsHash() => r'5fb72c3ae8bd23167aedd6ee51d9e06da8df80d0';
