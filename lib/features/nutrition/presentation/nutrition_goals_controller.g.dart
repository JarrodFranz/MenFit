// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goals_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the single nutrition-goals row and exposes a merging update.
///
/// Same shape as `ProfileController`, for the same two reasons: every field
/// is optional so an update has to merge rather than replace, and a nullable
/// field needs a `clear*` flag because `null` alone can't say whether the
/// caller meant "leave it" or "unset it".
///
/// Updates are serialised through [_tail] so two controls saved in quick
/// succession (the activity-level chip and the hide-calories switch, say)
/// can't both merge onto the same stale row and clobber each other.

@ProviderFor(NutritionGoalsController)
final nutritionGoalsControllerProvider = NutritionGoalsControllerProvider._();

/// Watches the single nutrition-goals row and exposes a merging update.
///
/// Same shape as `ProfileController`, for the same two reasons: every field
/// is optional so an update has to merge rather than replace, and a nullable
/// field needs a `clear*` flag because `null` alone can't say whether the
/// caller meant "leave it" or "unset it".
///
/// Updates are serialised through [_tail] so two controls saved in quick
/// succession (the activity-level chip and the hide-calories switch, say)
/// can't both merge onto the same stale row and clobber each other.
final class NutritionGoalsControllerProvider
    extends $StreamNotifierProvider<NutritionGoalsController, NutritionGoals?> {
  /// Watches the single nutrition-goals row and exposes a merging update.
  ///
  /// Same shape as `ProfileController`, for the same two reasons: every field
  /// is optional so an update has to merge rather than replace, and a nullable
  /// field needs a `clear*` flag because `null` alone can't say whether the
  /// caller meant "leave it" or "unset it".
  ///
  /// Updates are serialised through [_tail] so two controls saved in quick
  /// succession (the activity-level chip and the hide-calories switch, say)
  /// can't both merge onto the same stale row and clobber each other.
  NutritionGoalsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalsControllerHash();

  @$internal
  @override
  NutritionGoalsController create() => NutritionGoalsController();
}

String _$nutritionGoalsControllerHash() =>
    r'fa38f52cf7b94caebc32408a627ee9947691efd9';

/// Watches the single nutrition-goals row and exposes a merging update.
///
/// Same shape as `ProfileController`, for the same two reasons: every field
/// is optional so an update has to merge rather than replace, and a nullable
/// field needs a `clear*` flag because `null` alone can't say whether the
/// caller meant "leave it" or "unset it".
///
/// Updates are serialised through [_tail] so two controls saved in quick
/// succession (the activity-level chip and the hide-calories switch, say)
/// can't both merge onto the same stale row and clobber each other.

abstract class _$NutritionGoalsController
    extends $StreamNotifier<NutritionGoals?> {
  Stream<NutritionGoals?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NutritionGoals?>, NutritionGoals?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NutritionGoals?>, NutritionGoals?>,
              AsyncValue<NutritionGoals?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
