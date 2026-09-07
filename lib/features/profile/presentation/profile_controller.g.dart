// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the local user's profile and exposes an update operation.
///
/// `null` data means no profile exists yet (before onboarding creates
/// one) - the profile screen and any other consumer must handle that case.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Watches the local user's profile and exposes an update operation.
///
/// `null` data means no profile exists yet (before onboarding creates
/// one) - the profile screen and any other consumer must handle that case.
final class ProfileControllerProvider
    extends $StreamNotifierProvider<ProfileController, UserProfile?> {
  /// Watches the local user's profile and exposes an update operation.
  ///
  /// `null` data means no profile exists yet (before onboarding creates
  /// one) - the profile screen and any other consumer must handle that case.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'8b3138953fdc5fcfbe20b181f67af0340a9bfa96';

/// Watches the local user's profile and exposes an update operation.
///
/// `null` data means no profile exists yet (before onboarding creates
/// one) - the profile screen and any other consumer must handle that case.

abstract class _$ProfileController extends $StreamNotifier<UserProfile?> {
  Stream<UserProfile?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile?>, UserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile?>, UserProfile?>,
              AsyncValue<UserProfile?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
