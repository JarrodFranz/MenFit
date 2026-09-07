// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_day_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which calendar day the diary is showing.
///
/// Starts at today and never moves past it: `validateNutritionEntry` rejects
/// a future day, so offering one would be offering a dead end. Browsing
/// backwards is unbounded — an empty past day is a perfectly good answer.

@ProviderFor(SelectedNutritionDay)
final selectedNutritionDayProvider = SelectedNutritionDayProvider._();

/// Which calendar day the diary is showing.
///
/// Starts at today and never moves past it: `validateNutritionEntry` rejects
/// a future day, so offering one would be offering a dead end. Browsing
/// backwards is unbounded — an empty past day is a perfectly good answer.
final class SelectedNutritionDayProvider
    extends $NotifierProvider<SelectedNutritionDay, LocalDate> {
  /// Which calendar day the diary is showing.
  ///
  /// Starts at today and never moves past it: `validateNutritionEntry` rejects
  /// a future day, so offering one would be offering a dead end. Browsing
  /// backwards is unbounded — an empty past day is a perfectly good answer.
  SelectedNutritionDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNutritionDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNutritionDayHash();

  @$internal
  @override
  SelectedNutritionDay create() => SelectedNutritionDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDate>(value),
    );
  }
}

String _$selectedNutritionDayHash() =>
    r'297b7a76b800444c35c8cbf1eea8a70a206d7466';

/// Which calendar day the diary is showing.
///
/// Starts at today and never moves past it: `validateNutritionEntry` rejects
/// a future day, so offering one would be offering a dead end. Browsing
/// backwards is unbounded — an empty past day is a perfectly good answer.

abstract class _$SelectedNutritionDay extends $Notifier<LocalDate> {
  LocalDate build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LocalDate, LocalDate>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocalDate, LocalDate>,
              LocalDate,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
