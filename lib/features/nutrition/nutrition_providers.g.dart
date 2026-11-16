// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `nutrition` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly.

@ProviderFor(nutritionRepository)
final nutritionRepositoryProvider = NutritionRepositoryProvider._();

/// Composition surface for the `nutrition` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly.

final class NutritionRepositoryProvider
    extends
        $FunctionalProvider<
          NutritionRepository,
          NutritionRepository,
          NutritionRepository
        >
    with $Provider<NutritionRepository> {
  /// Composition surface for the `nutrition` feature (ADR 007).
  ///
  /// The only legal way for another feature (or the composition root's
  /// "Delete my data" flow) to reach this feature's persistence: other
  /// features may import this file, never `data/` or `presentation/`
  /// directly.
  NutritionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionRepositoryHash();

  @$internal
  @override
  $ProviderElement<NutritionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NutritionRepository create(Ref ref) {
    return nutritionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionRepository>(value),
    );
  }
}

String _$nutritionRepositoryHash() =>
    r'010a10931bb2a3eecbbf3c696989e657aaf111f2';

/// Daily hydration and water intake repository.

@ProviderFor(waterRepository)
final waterRepositoryProvider = WaterRepositoryProvider._();

/// Daily hydration and water intake repository.

final class WaterRepositoryProvider
    extends
        $FunctionalProvider<WaterRepository, WaterRepository, WaterRepository>
    with $Provider<WaterRepository> {
  /// Daily hydration and water intake repository.
  WaterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'waterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waterRepositoryHash();

  @$internal
  @override
  $ProviderElement<WaterRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WaterRepository create(Ref ref) {
    return waterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WaterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WaterRepository>(value),
    );
  }
}

String _$waterRepositoryHash() => r'f6fff708994eace151ab7957a55d641f541a209f';

/// Watches water intake in milliliters logged on [day].

@ProviderFor(dayWaterIntake)
final dayWaterIntakeProvider = DayWaterIntakeFamily._();

/// Watches water intake in milliliters logged on [day].

final class DayWaterIntakeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Watches water intake in milliliters logged on [day].
  DayWaterIntakeProvider._({
    required DayWaterIntakeFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'dayWaterIntakeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayWaterIntakeHash();

  @override
  String toString() {
    return r'dayWaterIntakeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return dayWaterIntake(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayWaterIntakeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayWaterIntakeHash() => r'66e618caf6b85e4c48bff28d0efeb059dde86761';

/// Watches water intake in milliliters logged on [day].

final class DayWaterIntakeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, LocalDate> {
  DayWaterIntakeFamily._()
    : super(
        retry: null,
        name: r'dayWaterIntakeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches water intake in milliliters logged on [day].

  DayWaterIntakeProvider call(LocalDate day) =>
      DayWaterIntakeProvider._(argument: day, from: this);

  @override
  String toString() => r'dayWaterIntakeProvider';
}

/// The single-row nutrition targets/preferences repository — see
/// [nutritionRepositoryProvider]'s dartdoc for the composition-surface
/// rule this shares.

@ProviderFor(nutritionGoalsRepository)
final nutritionGoalsRepositoryProvider = NutritionGoalsRepositoryProvider._();

/// The single-row nutrition targets/preferences repository — see
/// [nutritionRepositoryProvider]'s dartdoc for the composition-surface
/// rule this shares.

final class NutritionGoalsRepositoryProvider
    extends
        $FunctionalProvider<
          NutritionGoalsRepository,
          NutritionGoalsRepository,
          NutritionGoalsRepository
        >
    with $Provider<NutritionGoalsRepository> {
  /// The single-row nutrition targets/preferences repository — see
  /// [nutritionRepositoryProvider]'s dartdoc for the composition-surface
  /// rule this shares.
  NutritionGoalsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NutritionGoalsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NutritionGoalsRepository create(Ref ref) {
    return nutritionGoalsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionGoalsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionGoalsRepository>(value),
    );
  }
}

String _$nutritionGoalsRepositoryHash() =>
    r'9e8d24c11ed19239f251962791a5de26a8d0ea7b';

/// The external food database used for barcode lookups and product search.
///
/// **FatSecret is the primary catalogue, Open Food Facts the backup**,
/// whenever FatSecret is configured (ADR 016) — a
/// `FallbackFoodDataProvider` wraps the two, and everything above `data/`
/// sees one [FoodDataProvider] regardless of which one actually answered a
/// given lookup. With no FatSecret proxy configured, Open Food Facts
/// is the only provider, exactly as before this wave.
///
/// Typed as the domain interface so nothing above `data/` knows which
/// provider is in use (ADR 007); swapping providers is a change to this one
/// function. `keepAlive` for the same reason as the other services here —
/// each concrete service holds a `Dio` client whose connection pool should
/// outlive a single screen.
///
/// `kIsWeb` is supplied here rather than read inside the service because
/// `domain/` may not import Flutter: the service takes the answer as a
/// flag, and this composition surface is where the platform question is
/// legal to ask.
///
/// What `useLegacySearch` selects is the **search endpoint**, not whether
/// search works: browsers cannot reach Search-a-licious (no CORS header),
/// so on web the Open Food Facts service uses its legacy CGI search on the
/// same host the product API already uses. `OpenFoodFactsService.search`
/// documents the trade and the conditions under which that fallback should
/// be deleted.

@ProviderFor(foodDataProvider)
final foodDataProviderProvider = FoodDataProviderProvider._();

/// The external food database used for barcode lookups and product search.
///
/// **FatSecret is the primary catalogue, Open Food Facts the backup**,
/// whenever FatSecret is configured (ADR 016) — a
/// `FallbackFoodDataProvider` wraps the two, and everything above `data/`
/// sees one [FoodDataProvider] regardless of which one actually answered a
/// given lookup. With no FatSecret proxy configured, Open Food Facts
/// is the only provider, exactly as before this wave.
///
/// Typed as the domain interface so nothing above `data/` knows which
/// provider is in use (ADR 007); swapping providers is a change to this one
/// function. `keepAlive` for the same reason as the other services here —
/// each concrete service holds a `Dio` client whose connection pool should
/// outlive a single screen.
///
/// `kIsWeb` is supplied here rather than read inside the service because
/// `domain/` may not import Flutter: the service takes the answer as a
/// flag, and this composition surface is where the platform question is
/// legal to ask.
///
/// What `useLegacySearch` selects is the **search endpoint**, not whether
/// search works: browsers cannot reach Search-a-licious (no CORS header),
/// so on web the Open Food Facts service uses its legacy CGI search on the
/// same host the product API already uses. `OpenFoodFactsService.search`
/// documents the trade and the conditions under which that fallback should
/// be deleted.

final class FoodDataProviderProvider
    extends
        $FunctionalProvider<
          FoodDataProvider,
          FoodDataProvider,
          FoodDataProvider
        >
    with $Provider<FoodDataProvider> {
  /// The external food database used for barcode lookups and product search.
  ///
  /// **FatSecret is the primary catalogue, Open Food Facts the backup**,
  /// whenever FatSecret is configured (ADR 016) — a
  /// `FallbackFoodDataProvider` wraps the two, and everything above `data/`
  /// sees one [FoodDataProvider] regardless of which one actually answered a
  /// given lookup. With no FatSecret proxy configured, Open Food Facts
  /// is the only provider, exactly as before this wave.
  ///
  /// Typed as the domain interface so nothing above `data/` knows which
  /// provider is in use (ADR 007); swapping providers is a change to this one
  /// function. `keepAlive` for the same reason as the other services here —
  /// each concrete service holds a `Dio` client whose connection pool should
  /// outlive a single screen.
  ///
  /// `kIsWeb` is supplied here rather than read inside the service because
  /// `domain/` may not import Flutter: the service takes the answer as a
  /// flag, and this composition surface is where the platform question is
  /// legal to ask.
  ///
  /// What `useLegacySearch` selects is the **search endpoint**, not whether
  /// search works: browsers cannot reach Search-a-licious (no CORS header),
  /// so on web the Open Food Facts service uses its legacy CGI search on the
  /// same host the product API already uses. `OpenFoodFactsService.search`
  /// documents the trade and the conditions under which that fallback should
  /// be deleted.
  FoodDataProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodDataProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodDataProviderHash();

  @$internal
  @override
  $ProviderElement<FoodDataProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoodDataProvider create(Ref ref) {
    return foodDataProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodDataProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodDataProvider>(value),
    );
  }
}

String _$foodDataProviderHash() => r'61c2fc4adee96086a7abe8fe0ed0687c951c98bc';

/// Remembers whether the first-run online-lookup notice has been shown.
///
/// Device-local and tiny, so `shared_preferences` rather than the database
/// — see [OnlineLookupNoticeStore]. Exposed here because the notice gates
/// every outbound lookup this feature makes, from both the picker's search
/// and the barcode flow.
///
/// **Known departure from ADR 007**, recorded rather than quietly left: the
/// other providers on this surface are typed as `domain/` interfaces so
/// nothing above `data/` knows what backs them, and this one is typed as
/// the concrete `data/` class. It is a single device preference with no
/// second implementation in prospect, and a port for one boolean would be
/// ceremony; the cost is that a substitute has to stand in for a concrete
/// class rather than implement a port. Worth revisiting if anything else
/// ever needs to be remembered here.

@ProviderFor(onlineLookupNoticeStore)
final onlineLookupNoticeStoreProvider = OnlineLookupNoticeStoreProvider._();

/// Remembers whether the first-run online-lookup notice has been shown.
///
/// Device-local and tiny, so `shared_preferences` rather than the database
/// — see [OnlineLookupNoticeStore]. Exposed here because the notice gates
/// every outbound lookup this feature makes, from both the picker's search
/// and the barcode flow.
///
/// **Known departure from ADR 007**, recorded rather than quietly left: the
/// other providers on this surface are typed as `domain/` interfaces so
/// nothing above `data/` knows what backs them, and this one is typed as
/// the concrete `data/` class. It is a single device preference with no
/// second implementation in prospect, and a port for one boolean would be
/// ceremony; the cost is that a substitute has to stand in for a concrete
/// class rather than implement a port. Worth revisiting if anything else
/// ever needs to be remembered here.

final class OnlineLookupNoticeStoreProvider
    extends
        $FunctionalProvider<
          OnlineLookupNoticeStore,
          OnlineLookupNoticeStore,
          OnlineLookupNoticeStore
        >
    with $Provider<OnlineLookupNoticeStore> {
  /// Remembers whether the first-run online-lookup notice has been shown.
  ///
  /// Device-local and tiny, so `shared_preferences` rather than the database
  /// — see [OnlineLookupNoticeStore]. Exposed here because the notice gates
  /// every outbound lookup this feature makes, from both the picker's search
  /// and the barcode flow.
  ///
  /// **Known departure from ADR 007**, recorded rather than quietly left: the
  /// other providers on this surface are typed as `domain/` interfaces so
  /// nothing above `data/` knows what backs them, and this one is typed as
  /// the concrete `data/` class. It is a single device preference with no
  /// second implementation in prospect, and a port for one boolean would be
  /// ceremony; the cost is that a substitute has to stand in for a concrete
  /// class rather than implement a port. Worth revisiting if anything else
  /// ever needs to be remembered here.
  OnlineLookupNoticeStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineLookupNoticeStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineLookupNoticeStoreHash();

  @$internal
  @override
  $ProviderElement<OnlineLookupNoticeStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnlineLookupNoticeStore create(Ref ref) {
    return onlineLookupNoticeStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineLookupNoticeStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnlineLookupNoticeStore>(value),
    );
  }
}

String _$onlineLookupNoticeStoreHash() =>
    r'18b4592049d77303510334e46a294dbbdfb4c689';

/// Remembers the food-database region chosen in Settings.
///
/// Typed as the concrete `data/` class for the same reason, and with the
/// same acknowledged cost, as [onlineLookupNoticeStoreProvider] above: it is
/// one device preference with no second implementation in prospect.

@ProviderFor(foodSearchRegionStore)
final foodSearchRegionStoreProvider = FoodSearchRegionStoreProvider._();

/// Remembers the food-database region chosen in Settings.
///
/// Typed as the concrete `data/` class for the same reason, and with the
/// same acknowledged cost, as [onlineLookupNoticeStoreProvider] above: it is
/// one device preference with no second implementation in prospect.

final class FoodSearchRegionStoreProvider
    extends
        $FunctionalProvider<
          FoodSearchRegionStore,
          FoodSearchRegionStore,
          FoodSearchRegionStore
        >
    with $Provider<FoodSearchRegionStore> {
  /// Remembers the food-database region chosen in Settings.
  ///
  /// Typed as the concrete `data/` class for the same reason, and with the
  /// same acknowledged cost, as [onlineLookupNoticeStoreProvider] above: it is
  /// one device preference with no second implementation in prospect.
  FoodSearchRegionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSearchRegionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSearchRegionStoreHash();

  @$internal
  @override
  $ProviderElement<FoodSearchRegionStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FoodSearchRegionStore create(Ref ref) {
    return foodSearchRegionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodSearchRegionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodSearchRegionStore>(value),
    );
  }
}

String _$foodSearchRegionStoreHash() =>
    r'fed248685007342daf5ec22e1f5d7102b94e6604';

/// The region food-database **searches** are confined to.
///
/// Defaults to the device's country when this app covers it
/// (`FoodSearchRegion.forCountryCode`) and to `anywhere` otherwise, until the
/// user picks one in Settings — at which point their choice wins permanently,
/// including a deliberate choice of `anywhere`.
///
/// Defaulting from the device rather than shipping `anywhere` is the actual
/// fix for the reported bug: nobody would have found a setting they did not
/// know they needed, and the failure ("why is this Bulgarian?") does not
/// point at a region control.
///
/// This lives on the composition surface, not in `presentation/`, because
/// the Settings screen — another feature — has to reach it, and ADR 007 says
/// this file is the only door in.

@ProviderFor(FoodSearchRegionController)
final foodSearchRegionControllerProvider =
    FoodSearchRegionControllerProvider._();

/// The region food-database **searches** are confined to.
///
/// Defaults to the device's country when this app covers it
/// (`FoodSearchRegion.forCountryCode`) and to `anywhere` otherwise, until the
/// user picks one in Settings — at which point their choice wins permanently,
/// including a deliberate choice of `anywhere`.
///
/// Defaulting from the device rather than shipping `anywhere` is the actual
/// fix for the reported bug: nobody would have found a setting they did not
/// know they needed, and the failure ("why is this Bulgarian?") does not
/// point at a region control.
///
/// This lives on the composition surface, not in `presentation/`, because
/// the Settings screen — another feature — has to reach it, and ADR 007 says
/// this file is the only door in.
final class FoodSearchRegionControllerProvider
    extends $NotifierProvider<FoodSearchRegionController, FoodSearchRegion> {
  /// The region food-database **searches** are confined to.
  ///
  /// Defaults to the device's country when this app covers it
  /// (`FoodSearchRegion.forCountryCode`) and to `anywhere` otherwise, until the
  /// user picks one in Settings — at which point their choice wins permanently,
  /// including a deliberate choice of `anywhere`.
  ///
  /// Defaulting from the device rather than shipping `anywhere` is the actual
  /// fix for the reported bug: nobody would have found a setting they did not
  /// know they needed, and the failure ("why is this Bulgarian?") does not
  /// point at a region control.
  ///
  /// This lives on the composition surface, not in `presentation/`, because
  /// the Settings screen — another feature — has to reach it, and ADR 007 says
  /// this file is the only door in.
  FoodSearchRegionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSearchRegionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSearchRegionControllerHash();

  @$internal
  @override
  FoodSearchRegionController create() => FoodSearchRegionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodSearchRegion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodSearchRegion>(value),
    );
  }
}

String _$foodSearchRegionControllerHash() =>
    r'5e925ba0ea5cfb94283c0c1bbe66c30c9a0cb7f6';

/// The region food-database **searches** are confined to.
///
/// Defaults to the device's country when this app covers it
/// (`FoodSearchRegion.forCountryCode`) and to `anywhere` otherwise, until the
/// user picks one in Settings — at which point their choice wins permanently,
/// including a deliberate choice of `anywhere`.
///
/// Defaulting from the device rather than shipping `anywhere` is the actual
/// fix for the reported bug: nobody would have found a setting they did not
/// know they needed, and the failure ("why is this Bulgarian?") does not
/// point at a region control.
///
/// This lives on the composition surface, not in `presentation/`, because
/// the Settings screen — another feature — has to reach it, and ADR 007 says
/// this file is the only door in.

abstract class _$FoodSearchRegionController
    extends $Notifier<FoodSearchRegion> {
  FoodSearchRegion build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FoodSearchRegion, FoodSearchRegion>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FoodSearchRegion, FoodSearchRegion>,
              FoodSearchRegion,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The region **and** language every food-database request carries.
///
/// The language is not user-selectable: this app ships one locale, so the
/// only honest answer to "what language do you read" is the device's. It is
/// separate from the region because the two genuinely differ — a German
/// speaker shopping in Australia wants Australian products with German names
/// where records have them.

@ProviderFor(foodSearchScope)
final foodSearchScopeProvider = FoodSearchScopeProvider._();

/// The region **and** language every food-database request carries.
///
/// The language is not user-selectable: this app ships one locale, so the
/// only honest answer to "what language do you read" is the device's. It is
/// separate from the region because the two genuinely differ — a German
/// speaker shopping in Australia wants Australian products with German names
/// where records have them.

final class FoodSearchScopeProvider
    extends
        $FunctionalProvider<FoodSearchScope, FoodSearchScope, FoodSearchScope>
    with $Provider<FoodSearchScope> {
  /// The region **and** language every food-database request carries.
  ///
  /// The language is not user-selectable: this app ships one locale, so the
  /// only honest answer to "what language do you read" is the device's. It is
  /// separate from the region because the two genuinely differ — a German
  /// speaker shopping in Australia wants Australian products with German names
  /// where records have them.
  FoodSearchScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSearchScopeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSearchScopeHash();

  @$internal
  @override
  $ProviderElement<FoodSearchScope> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoodSearchScope create(Ref ref) {
    return foodSearchScope(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodSearchScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodSearchScope>(value),
    );
  }
}

String _$foodSearchScopeHash() => r'6535c2a939e16ef31dbf573e324c4454c03d700a';

/// Every food in the user's catalogue, name ascending.

@ProviderFor(foods)
final foodsProvider = FoodsProvider._();

/// Every food in the user's catalogue, name ascending.

final class FoodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Food>>,
          List<Food>,
          Stream<List<Food>>
        >
    with $FutureModifier<List<Food>>, $StreamProvider<List<Food>> {
  /// Every food in the user's catalogue, name ascending.
  FoodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodsHash();

  @$internal
  @override
  $StreamProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Food>> create(Ref ref) {
    return foods(ref);
  }
}

String _$foodsHash() => r'579474fe3f9c8c7ff2608cbbabbff3fcccc542b3';

/// The foods most recently logged from, most recent first.
///
/// A **stream**, deliberately. The picker can log a food and come straight
/// back to itself, and it can create one from the food-database review
/// screen; a one-shot future would show a stale list after either and stay
/// stale until the screen was rebuilt. `watchRecentFoods` is watched by
/// Drift over both `foods` and `nutrition_entries`, so nothing here has to
/// remember to invalidate it (`data/drift_nutrition_repository.dart`).

@ProviderFor(recentFoods)
final recentFoodsProvider = RecentFoodsProvider._();

/// The foods most recently logged from, most recent first.
///
/// A **stream**, deliberately. The picker can log a food and come straight
/// back to itself, and it can create one from the food-database review
/// screen; a one-shot future would show a stale list after either and stay
/// stale until the screen was rebuilt. `watchRecentFoods` is watched by
/// Drift over both `foods` and `nutrition_entries`, so nothing here has to
/// remember to invalidate it (`data/drift_nutrition_repository.dart`).

final class RecentFoodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Food>>,
          List<Food>,
          Stream<List<Food>>
        >
    with $FutureModifier<List<Food>>, $StreamProvider<List<Food>> {
  /// The foods most recently logged from, most recent first.
  ///
  /// A **stream**, deliberately. The picker can log a food and come straight
  /// back to itself, and it can create one from the food-database review
  /// screen; a one-shot future would show a stale list after either and stay
  /// stale until the screen was rebuilt. `watchRecentFoods` is watched by
  /// Drift over both `foods` and `nutrition_entries`, so nothing here has to
  /// remember to invalidate it (`data/drift_nutrition_repository.dart`).
  RecentFoodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentFoodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentFoodsHash();

  @$internal
  @override
  $StreamProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Food>> create(Ref ref) {
    return recentFoods(ref);
  }
}

String _$recentFoodsHash() => r'34426dd01652cf76ef58791a6eccb8b174d50eb0';

/// The user's nutrition goals, or `null` when none have ever been saved.
///
/// `null` is an expected state, not an error — see
/// `domain/nutrition_repository.dart#watchGoals`.

@ProviderFor(nutritionGoals)
final nutritionGoalsProvider = NutritionGoalsProvider._();

/// The user's nutrition goals, or `null` when none have ever been saved.
///
/// `null` is an expected state, not an error — see
/// `domain/nutrition_repository.dart#watchGoals`.

final class NutritionGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NutritionGoals?>,
          NutritionGoals?,
          Stream<NutritionGoals?>
        >
    with $FutureModifier<NutritionGoals?>, $StreamProvider<NutritionGoals?> {
  /// The user's nutrition goals, or `null` when none have ever been saved.
  ///
  /// `null` is an expected state, not an error — see
  /// `domain/nutrition_repository.dart#watchGoals`.
  NutritionGoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalsHash();

  @$internal
  @override
  $StreamProviderElement<NutritionGoals?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NutritionGoals?> create(Ref ref) {
    return nutritionGoals(ref);
  }
}

String _$nutritionGoalsHash() => r'4a494948e37d359798ef19c29c78092cfeda77b0';

/// Shared rendering gate: unknown preferences hide calories. A resolved null
/// goals row means no preference; refresh/error retains the last known choice.

@ProviderFor(hideCalorieNumbers)
final hideCalorieNumbersProvider = HideCalorieNumbersProvider._();

/// Shared rendering gate: unknown preferences hide calories. A resolved null
/// goals row means no preference; refresh/error retains the last known choice.

final class HideCalorieNumbersProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Shared rendering gate: unknown preferences hide calories. A resolved null
  /// goals row means no preference; refresh/error retains the last known choice.
  HideCalorieNumbersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hideCalorieNumbersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hideCalorieNumbersHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hideCalorieNumbers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hideCalorieNumbersHash() =>
    r'9d0a1dbe6aec72a26ba89dd311e2276aaa8f9b8b';

/// Every diary entry logged on [day], grouped by meal.

@ProviderFor(nutritionEntries)
final nutritionEntriesProvider = NutritionEntriesFamily._();

/// Every diary entry logged on [day], grouped by meal.

final class NutritionEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NutritionEntry>>,
          List<NutritionEntry>,
          Stream<List<NutritionEntry>>
        >
    with
        $FutureModifier<List<NutritionEntry>>,
        $StreamProvider<List<NutritionEntry>> {
  /// Every diary entry logged on [day], grouped by meal.
  NutritionEntriesProvider._({
    required NutritionEntriesFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'nutritionEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionEntriesHash();

  @override
  String toString() {
    return r'nutritionEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NutritionEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NutritionEntry>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return nutritionEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionEntriesHash() => r'73ab4e78091be6b4eef9c84deb3176a481b9865c';

/// Every diary entry logged on [day], grouped by meal.

final class NutritionEntriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NutritionEntry>>, LocalDate> {
  NutritionEntriesFamily._()
    : super(
        retry: null,
        name: r'nutritionEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every diary entry logged on [day], grouped by meal.

  NutritionEntriesProvider call(LocalDate day) =>
      NutritionEntriesProvider._(argument: day, from: this);

  @override
  String toString() => r'nutritionEntriesProvider';
}

/// [day]'s totals — overall and per meal — recomputed on every change to
/// that day's entries.
///
/// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
/// 's "Derived vs stored" section): totals are a pure function of the
/// entries, computed here on demand, with no cache table. Note this is a
/// different thing from each entry's per-serving *snapshot*, which is
/// stored precisely because it must not be recomputed — see
/// `core/db/tables/nutrition_entries.dart`.

@ProviderFor(dayNutritionTotals)
final dayNutritionTotalsProvider = DayNutritionTotalsFamily._();

/// [day]'s totals — overall and per meal — recomputed on every change to
/// that day's entries.
///
/// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
/// 's "Derived vs stored" section): totals are a pure function of the
/// entries, computed here on demand, with no cache table. Note this is a
/// different thing from each entry's per-serving *snapshot*, which is
/// stored precisely because it must not be recomputed — see
/// `core/db/tables/nutrition_entries.dart`.

final class DayNutritionTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayNutritionTotals>,
          DayNutritionTotals,
          Stream<DayNutritionTotals>
        >
    with
        $FutureModifier<DayNutritionTotals>,
        $StreamProvider<DayNutritionTotals> {
  /// [day]'s totals — overall and per meal — recomputed on every change to
  /// that day's entries.
  ///
  /// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
  /// 's "Derived vs stored" section): totals are a pure function of the
  /// entries, computed here on demand, with no cache table. Note this is a
  /// different thing from each entry's per-serving *snapshot*, which is
  /// stored precisely because it must not be recomputed — see
  /// `core/db/tables/nutrition_entries.dart`.
  DayNutritionTotalsProvider._({
    required DayNutritionTotalsFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'dayNutritionTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayNutritionTotalsHash();

  @override
  String toString() {
    return r'dayNutritionTotalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DayNutritionTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DayNutritionTotals> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return dayNutritionTotals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayNutritionTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayNutritionTotalsHash() =>
    r'6c554085a0b0ebe5095554c31984bf730af43d5b';

/// [day]'s totals — overall and per meal — recomputed on every change to
/// that day's entries.
///
/// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
/// 's "Derived vs stored" section): totals are a pure function of the
/// entries, computed here on demand, with no cache table. Note this is a
/// different thing from each entry's per-serving *snapshot*, which is
/// stored precisely because it must not be recomputed — see
/// `core/db/tables/nutrition_entries.dart`.

final class DayNutritionTotalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DayNutritionTotals>, LocalDate> {
  DayNutritionTotalsFamily._()
    : super(
        retry: null,
        name: r'dayNutritionTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [day]'s totals — overall and per meal — recomputed on every change to
  /// that day's entries.
  ///
  /// **Derived, never stored** (`knowledge/architecture/data_architecture.md`
  /// 's "Derived vs stored" section): totals are a pure function of the
  /// entries, computed here on demand, with no cache table. Note this is a
  /// different thing from each entry's per-serving *snapshot*, which is
  /// stored precisely because it must not be recomputed — see
  /// `core/db/tables/nutrition_entries.dart`.

  DayNutritionTotalsProvider call(LocalDate day) =>
      DayNutritionTotalsProvider._(argument: day, from: this);

  @override
  String toString() => r'dayNutritionTotalsProvider';
}

/// Range totals and daily averages over [start] to [end] inclusive.

@ProviderFor(rangeNutritionTotals)
final rangeNutritionTotalsProvider = RangeNutritionTotalsFamily._();

/// Range totals and daily averages over [start] to [end] inclusive.

final class RangeNutritionTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RangeNutritionTotals>,
          RangeNutritionTotals,
          Stream<RangeNutritionTotals>
        >
    with
        $FutureModifier<RangeNutritionTotals>,
        $StreamProvider<RangeNutritionTotals> {
  /// Range totals and daily averages over [start] to [end] inclusive.
  RangeNutritionTotalsProvider._({
    required RangeNutritionTotalsFamily super.from,
    required ({LocalDate start, LocalDate end}) super.argument,
  }) : super(
         retry: null,
         name: r'rangeNutritionTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rangeNutritionTotalsHash();

  @override
  String toString() {
    return r'rangeNutritionTotalsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<RangeNutritionTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RangeNutritionTotals> create(Ref ref) {
    final argument = this.argument as ({LocalDate start, LocalDate end});
    return rangeNutritionTotals(ref, start: argument.start, end: argument.end);
  }

  @override
  bool operator ==(Object other) {
    return other is RangeNutritionTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rangeNutritionTotalsHash() =>
    r'80bb20d2a37162bb005834301ff5b8a1fddee629';

/// Range totals and daily averages over [start] to [end] inclusive.

final class RangeNutritionTotalsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<RangeNutritionTotals>,
          ({LocalDate start, LocalDate end})
        > {
  RangeNutritionTotalsFamily._()
    : super(
        retry: null,
        name: r'rangeNutritionTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Range totals and daily averages over [start] to [end] inclusive.

  RangeNutritionTotalsProvider call({
    required LocalDate start,
    required LocalDate end,
  }) => RangeNutritionTotalsProvider._(
    argument: (start: start, end: end),
    from: this,
  );

  @override
  String toString() => r'rangeNutritionTotalsProvider';
}

/// The user's estimated BMR and TDEE, or a [NoEnergyEstimate] naming what's
/// missing.
///
/// Combines the profile (height, weight, date of birth — S1-3) with the
/// nutrition goals' chosen activity level. Watches `profile`'s composition
/// surface, never its `data/` (ADR 007).
///
/// Every emission is an estimate, never a measurement, and never medical
/// advice — `knowledge/research/nutrition_energy_estimates.md` documents
/// the equation, the male-coefficient assumption, and the error margins
/// the UI must not paper over.

@ProviderFor(energyEstimate)
final energyEstimateProvider = EnergyEstimateProvider._();

/// The user's estimated BMR and TDEE, or a [NoEnergyEstimate] naming what's
/// missing.
///
/// Combines the profile (height, weight, date of birth — S1-3) with the
/// nutrition goals' chosen activity level. Watches `profile`'s composition
/// surface, never its `data/` (ADR 007).
///
/// Every emission is an estimate, never a measurement, and never medical
/// advice — `knowledge/research/nutrition_energy_estimates.md` documents
/// the equation, the male-coefficient assumption, and the error margins
/// the UI must not paper over.

final class EnergyEstimateProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnergyEstimateResult>,
          EnergyEstimateResult,
          Stream<EnergyEstimateResult>
        >
    with
        $FutureModifier<EnergyEstimateResult>,
        $StreamProvider<EnergyEstimateResult> {
  /// The user's estimated BMR and TDEE, or a [NoEnergyEstimate] naming what's
  /// missing.
  ///
  /// Combines the profile (height, weight, date of birth — S1-3) with the
  /// nutrition goals' chosen activity level. Watches `profile`'s composition
  /// surface, never its `data/` (ADR 007).
  ///
  /// Every emission is an estimate, never a measurement, and never medical
  /// advice — `knowledge/research/nutrition_energy_estimates.md` documents
  /// the equation, the male-coefficient assumption, and the error margins
  /// the UI must not paper over.
  EnergyEstimateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'energyEstimateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$energyEstimateHash();

  @$internal
  @override
  $StreamProviderElement<EnergyEstimateResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EnergyEstimateResult> create(Ref ref) {
    return energyEstimate(ref);
  }
}

String _$energyEstimateHash() => r'6aa9675ecdee8733bb4806d0029ca289c82da7ad';

/// The daily calorie target the user's goals resolve to — including the
/// **floored** outcome when the requested deficit would go below their
/// estimated resting needs.
///
/// The floor rule and its explanation live entirely in
/// `domain/calorie_target.dart`; this provider only feeds it. UI code
/// switches on the sealed [CalorieTargetOutcome] and must handle
/// [FlooredCalorieTarget] by *explaining* it — that is the point of the
/// typed result (product decision 2).
///
/// Built from the same two source streams as [energyEstimateProvider]
/// rather than layered on top of it — a second independent derived view
/// over shared sources, the same arrangement as `streaks`'
/// `streakResultProvider` and `todayProtectionSourcesProvider`. Composing
/// providers here would mean turning a stream back into a single future and
/// losing every later emission.

@ProviderFor(calorieTarget)
final calorieTargetProvider = CalorieTargetProvider._();

/// The daily calorie target the user's goals resolve to — including the
/// **floored** outcome when the requested deficit would go below their
/// estimated resting needs.
///
/// The floor rule and its explanation live entirely in
/// `domain/calorie_target.dart`; this provider only feeds it. UI code
/// switches on the sealed [CalorieTargetOutcome] and must handle
/// [FlooredCalorieTarget] by *explaining* it — that is the point of the
/// typed result (product decision 2).
///
/// Built from the same two source streams as [energyEstimateProvider]
/// rather than layered on top of it — a second independent derived view
/// over shared sources, the same arrangement as `streaks`'
/// `streakResultProvider` and `todayProtectionSourcesProvider`. Composing
/// providers here would mean turning a stream back into a single future and
/// losing every later emission.

final class CalorieTargetProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalorieTargetOutcome>,
          CalorieTargetOutcome,
          Stream<CalorieTargetOutcome>
        >
    with
        $FutureModifier<CalorieTargetOutcome>,
        $StreamProvider<CalorieTargetOutcome> {
  /// The daily calorie target the user's goals resolve to — including the
  /// **floored** outcome when the requested deficit would go below their
  /// estimated resting needs.
  ///
  /// The floor rule and its explanation live entirely in
  /// `domain/calorie_target.dart`; this provider only feeds it. UI code
  /// switches on the sealed [CalorieTargetOutcome] and must handle
  /// [FlooredCalorieTarget] by *explaining* it — that is the point of the
  /// typed result (product decision 2).
  ///
  /// Built from the same two source streams as [energyEstimateProvider]
  /// rather than layered on top of it — a second independent derived view
  /// over shared sources, the same arrangement as `streaks`'
  /// `streakResultProvider` and `todayProtectionSourcesProvider`. Composing
  /// providers here would mean turning a stream back into a single future and
  /// losing every later emission.
  CalorieTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calorieTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calorieTargetHash();

  @$internal
  @override
  $StreamProviderElement<CalorieTargetOutcome> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CalorieTargetOutcome> create(Ref ref) {
    return calorieTarget(ref);
  }
}

String _$calorieTargetHash() => r'ec072364408ad7e98342340f7d5192bbde753658';

/// Resolves the target the diary shows: the user's own calorie target when
/// they set one, otherwise whatever the energy estimate resolves to.
///
/// The user's explicit number wins deliberately — it is the one figure here
/// they actually chose, and quietly overriding it with an estimate would be
/// the app arguing with them. When it is in force the floor is not applied
/// to it and no floor explanation is shown, because the floor is a rule
/// about what *this app suggests*, not a limit imposed on the user's own
/// entry (`knowledge/research/nutrition_energy_estimates.md`).

@ProviderFor(dayCalorieTarget)
final dayCalorieTargetProvider = DayCalorieTargetProvider._();

/// Resolves the target the diary shows: the user's own calorie target when
/// they set one, otherwise whatever the energy estimate resolves to.
///
/// The user's explicit number wins deliberately — it is the one figure here
/// they actually chose, and quietly overriding it with an estimate would be
/// the app arguing with them. When it is in force the floor is not applied
/// to it and no floor explanation is shown, because the floor is a rule
/// about what *this app suggests*, not a limit imposed on the user's own
/// entry (`knowledge/research/nutrition_energy_estimates.md`).

final class DayCalorieTargetProvider
    extends
        $FunctionalProvider<
          DayCalorieTarget,
          DayCalorieTarget,
          DayCalorieTarget
        >
    with $Provider<DayCalorieTarget> {
  /// Resolves the target the diary shows: the user's own calorie target when
  /// they set one, otherwise whatever the energy estimate resolves to.
  ///
  /// The user's explicit number wins deliberately — it is the one figure here
  /// they actually chose, and quietly overriding it with an estimate would be
  /// the app arguing with them. When it is in force the floor is not applied
  /// to it and no floor explanation is shown, because the floor is a rule
  /// about what *this app suggests*, not a limit imposed on the user's own
  /// entry (`knowledge/research/nutrition_energy_estimates.md`).
  DayCalorieTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dayCalorieTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dayCalorieTargetHash();

  @$internal
  @override
  $ProviderElement<DayCalorieTarget> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DayCalorieTarget create(Ref ref) {
    return dayCalorieTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DayCalorieTarget value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DayCalorieTarget>(value),
    );
  }
}

String _$dayCalorieTargetHash() => r'035bd97d30f7dc834472f133fd619f9c2ac9a9a9';

/// Evaluates 7-day nutrition and protein consistency achievements.
///
/// The protein axis is read against [dayCalorieTargetProvider], not
/// `goals.calorieTargetKcal` directly — same rule as `MacrosTodayCard`'s
/// energy line: that provider is the one place "the user’s own target, else the
/// estimate with the BMR floor applied" is decided, so a percent-mode
/// protein split derives against the same figure the diary shows rather
/// than a second, potentially disagreeing definition.

@ProviderFor(fuelingConsistency)
final fuelingConsistencyProvider = FuelingConsistencyProvider._();

/// Evaluates 7-day nutrition and protein consistency achievements.
///
/// The protein axis is read against [dayCalorieTargetProvider], not
/// `goals.calorieTargetKcal` directly — same rule as `MacrosTodayCard`'s
/// energy line: that provider is the one place "the user’s own target, else the
/// estimate with the BMR floor applied" is decided, so a percent-mode
/// protein split derives against the same figure the diary shows rather
/// than a second, potentially disagreeing definition.

final class FuelingConsistencyProvider
    extends
        $FunctionalProvider<
          AsyncValue<FuelingConsistencyResult>,
          FuelingConsistencyResult,
          Stream<FuelingConsistencyResult>
        >
    with
        $FutureModifier<FuelingConsistencyResult>,
        $StreamProvider<FuelingConsistencyResult> {
  /// Evaluates 7-day nutrition and protein consistency achievements.
  ///
  /// The protein axis is read against [dayCalorieTargetProvider], not
  /// `goals.calorieTargetKcal` directly — same rule as `MacrosTodayCard`'s
  /// energy line: that provider is the one place "the user’s own target, else the
  /// estimate with the BMR floor applied" is decided, so a percent-mode
  /// protein split derives against the same figure the diary shows rather
  /// than a second, potentially disagreeing definition.
  FuelingConsistencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelingConsistencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelingConsistencyHash();

  @$internal
  @override
  $StreamProviderElement<FuelingConsistencyResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FuelingConsistencyResult> create(Ref ref) {
    return fuelingConsistency(ref);
  }
}

String _$fuelingConsistencyHash() =>
    r'c3bcb1e254228d4ba0f595a8e2ba4afd409072fb';

/// Evaluates micronutrient adequacy items for [day].

@ProviderFor(dayMicronutrientAdequacy)
final dayMicronutrientAdequacyProvider = DayMicronutrientAdequacyFamily._();

/// Evaluates micronutrient adequacy items for [day].

final class DayMicronutrientAdequacyProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MicronutrientAdequacyItem>>,
          List<MicronutrientAdequacyItem>,
          FutureOr<List<MicronutrientAdequacyItem>>
        >
    with
        $FutureModifier<List<MicronutrientAdequacyItem>>,
        $FutureProvider<List<MicronutrientAdequacyItem>> {
  /// Evaluates micronutrient adequacy items for [day].
  DayMicronutrientAdequacyProvider._({
    required DayMicronutrientAdequacyFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'dayMicronutrientAdequacyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayMicronutrientAdequacyHash();

  @override
  String toString() {
    return r'dayMicronutrientAdequacyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MicronutrientAdequacyItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MicronutrientAdequacyItem>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return dayMicronutrientAdequacy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayMicronutrientAdequacyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayMicronutrientAdequacyHash() =>
    r'e5243ede397f1890f7f6a3182bcdcd1fa20dc12f';

/// Evaluates micronutrient adequacy items for [day].

final class DayMicronutrientAdequacyFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<MicronutrientAdequacyItem>>,
          LocalDate
        > {
  DayMicronutrientAdequacyFamily._()
    : super(
        retry: null,
        name: r'dayMicronutrientAdequacyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Evaluates micronutrient adequacy items for [day].

  DayMicronutrientAdequacyProvider call(LocalDate day) =>
      DayMicronutrientAdequacyProvider._(argument: day, from: this);

  @override
  String toString() => r'dayMicronutrientAdequacyProvider';
}
