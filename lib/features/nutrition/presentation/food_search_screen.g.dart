// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Foods matching [query], for the picker.
///
/// A blank query deliberately lists the catalogue rather than nothing — see
/// `domain/nutrition_repository.dart#searchFoods`.

@ProviderFor(foodSearchResults)
final foodSearchResultsProvider = FoodSearchResultsFamily._();

/// Foods matching [query], for the picker.
///
/// A blank query deliberately lists the catalogue rather than nothing — see
/// `domain/nutrition_repository.dart#searchFoods`.

final class FoodSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Food>>,
          List<Food>,
          FutureOr<List<Food>>
        >
    with $FutureModifier<List<Food>>, $FutureProvider<List<Food>> {
  /// Foods matching [query], for the picker.
  ///
  /// A blank query deliberately lists the catalogue rather than nothing — see
  /// `domain/nutrition_repository.dart#searchFoods`.
  FoodSearchResultsProvider._({
    required FoodSearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'foodSearchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodSearchResultsHash();

  @override
  String toString() {
    return r'foodSearchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Food>> create(Ref ref) {
    final argument = this.argument as String;
    return foodSearchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FoodSearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodSearchResultsHash() => r'801b138435c106d0c75c5f5c8863690008b3d928';

/// Foods matching [query], for the picker.
///
/// A blank query deliberately lists the catalogue rather than nothing — see
/// `domain/nutrition_repository.dart#searchFoods`.

final class FoodSearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Food>>, String> {
  FoodSearchResultsFamily._()
    : super(
        retry: null,
        name: r'foodSearchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Foods matching [query], for the picker.
  ///
  /// A blank query deliberately lists the catalogue rather than nothing — see
  /// `domain/nutrition_repository.dart#searchFoods`.

  FoodSearchResultsProvider call(String query) =>
      FoodSearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'foodSearchResultsProvider';
}
