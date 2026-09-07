// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One challenge, watched by id — what the detail screen is looking at.
///
/// Presentation-layer rather than part of the feature's composition
/// surface (`challenges_providers.dart`) for the same reason as
/// `features/weight/presentation/weight_history_providers.dart`: no other
/// feature has any business asking for one challenge by id, and ADR 007's
/// surface is for what crosses feature boundaries, not for everything
/// this feature happens to need.
///
/// Emits `null` when the row is gone — a challenge deleted while a screen
/// held its id — so the detail screen can say so rather than throw.

@ProviderFor(challengeDetail)
final challengeDetailProvider = ChallengeDetailFamily._();

/// One challenge, watched by id — what the detail screen is looking at.
///
/// Presentation-layer rather than part of the feature's composition
/// surface (`challenges_providers.dart`) for the same reason as
/// `features/weight/presentation/weight_history_providers.dart`: no other
/// feature has any business asking for one challenge by id, and ADR 007's
/// surface is for what crosses feature boundaries, not for everything
/// this feature happens to need.
///
/// Emits `null` when the row is gone — a challenge deleted while a screen
/// held its id — so the detail screen can say so rather than throw.

final class ChallengeDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Challenge?>,
          Challenge?,
          Stream<Challenge?>
        >
    with $FutureModifier<Challenge?>, $StreamProvider<Challenge?> {
  /// One challenge, watched by id — what the detail screen is looking at.
  ///
  /// Presentation-layer rather than part of the feature's composition
  /// surface (`challenges_providers.dart`) for the same reason as
  /// `features/weight/presentation/weight_history_providers.dart`: no other
  /// feature has any business asking for one challenge by id, and ADR 007's
  /// surface is for what crosses feature boundaries, not for everything
  /// this feature happens to need.
  ///
  /// Emits `null` when the row is gone — a challenge deleted while a screen
  /// held its id — so the detail screen can say so rather than throw.
  ChallengeDetailProvider._({
    required ChallengeDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'challengeDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$challengeDetailHash();

  @override
  String toString() {
    return r'challengeDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Challenge?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Challenge?> create(Ref ref) {
    final argument = this.argument as String;
    return challengeDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$challengeDetailHash() => r'fab081b1c828ff71585f24f01fda60e6a1c9b3dd';

/// One challenge, watched by id — what the detail screen is looking at.
///
/// Presentation-layer rather than part of the feature's composition
/// surface (`challenges_providers.dart`) for the same reason as
/// `features/weight/presentation/weight_history_providers.dart`: no other
/// feature has any business asking for one challenge by id, and ADR 007's
/// surface is for what crosses feature boundaries, not for everything
/// this feature happens to need.
///
/// Emits `null` when the row is gone — a challenge deleted while a screen
/// held its id — so the detail screen can say so rather than throw.

final class ChallengeDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Challenge?>, String> {
  ChallengeDetailFamily._()
    : super(
        retry: null,
        name: r'challengeDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One challenge, watched by id — what the detail screen is looking at.
  ///
  /// Presentation-layer rather than part of the feature's composition
  /// surface (`challenges_providers.dart`) for the same reason as
  /// `features/weight/presentation/weight_history_providers.dart`: no other
  /// feature has any business asking for one challenge by id, and ADR 007's
  /// surface is for what crosses feature boundaries, not for everything
  /// this feature happens to need.
  ///
  /// Emits `null` when the row is gone — a challenge deleted while a screen
  /// held its id — so the detail screen can say so rather than throw.

  ChallengeDetailProvider call(String challengeId) =>
      ChallengeDetailProvider._(argument: challengeId, from: this);

  @override
  String toString() => r'challengeDetailProvider';
}
