// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_coaching_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioCoachingRepository)
final audioCoachingRepositoryProvider = AudioCoachingRepositoryProvider._();

final class AudioCoachingRepositoryProvider
    extends
        $FunctionalProvider<
          AudioCoachingRepository,
          AudioCoachingRepository,
          AudioCoachingRepository
        >
    with $Provider<AudioCoachingRepository> {
  AudioCoachingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioCoachingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioCoachingRepositoryHash();

  @$internal
  @override
  $ProviderElement<AudioCoachingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioCoachingRepository create(Ref ref) {
    return audioCoachingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioCoachingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioCoachingRepository>(value),
    );
  }
}

String _$audioCoachingRepositoryHash() =>
    r'37da5c141622f99594c921483a63c7c96ccc52b8';

@ProviderFor(AudioCoachingController)
final audioCoachingControllerProvider = AudioCoachingControllerProvider._();

final class AudioCoachingControllerProvider
    extends $NotifierProvider<AudioCoachingController, AudioCoachingSettings> {
  AudioCoachingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioCoachingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioCoachingControllerHash();

  @$internal
  @override
  AudioCoachingController create() => AudioCoachingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioCoachingSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioCoachingSettings>(value),
    );
  }
}

String _$audioCoachingControllerHash() =>
    r'9bce9ee0ac36519b127476690e1ac29999b9cf3d';

abstract class _$AudioCoachingController
    extends $Notifier<AudioCoachingSettings> {
  AudioCoachingSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AudioCoachingSettings, AudioCoachingSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioCoachingSettings, AudioCoachingSettings>,
              AudioCoachingSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
