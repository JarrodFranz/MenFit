// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FoodFormController)
final foodFormControllerProvider = FoodFormControllerFamily._();

final class FoodFormControllerProvider
    extends $NotifierProvider<FoodFormController, FoodFormState> {
  FoodFormControllerProvider._({
    required FoodFormControllerFamily super.from,
    required FoodFormSeed? super.argument,
  }) : super(
         retry: null,
         name: r'foodFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodFormControllerHash();

  @override
  String toString() {
    return r'foodFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FoodFormController create() => FoodFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FoodFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodFormControllerHash() =>
    r'1393551e7465286478d9af3db6a9977f5b8510e3';

final class FoodFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FoodFormController,
          FoodFormState,
          FoodFormState,
          FoodFormState,
          FoodFormSeed?
        > {
  FoodFormControllerFamily._()
    : super(
        retry: null,
        name: r'foodFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FoodFormControllerProvider call(FoodFormSeed? seed) =>
      FoodFormControllerProvider._(argument: seed, from: this);

  @override
  String toString() => r'foodFormControllerProvider';
}

abstract class _$FoodFormController extends $Notifier<FoodFormState> {
  late final _$args = ref.$arg as FoodFormSeed?;
  FoodFormSeed? get seed => _$args;

  FoodFormState build(FoodFormSeed? seed);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FoodFormState, FoodFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FoodFormState, FoodFormState>,
              FoodFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
