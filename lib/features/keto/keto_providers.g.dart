// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keto_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ketoneRepository)
final ketoneRepositoryProvider = KetoneRepositoryProvider._();

final class KetoneRepositoryProvider
    extends
        $FunctionalProvider<
          KetoneRepository,
          KetoneRepository,
          KetoneRepository
        >
    with $Provider<KetoneRepository> {
  KetoneRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ketoneRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ketoneRepositoryHash();

  @$internal
  @override
  $ProviderElement<KetoneRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KetoneRepository create(Ref ref) {
    return ketoneRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KetoneRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KetoneRepository>(value),
    );
  }
}

String _$ketoneRepositoryHash() => r'd18e566acc6878bf2e7d659086d559a574fa2e44';

@ProviderFor(ketoneReadings)
final ketoneReadingsProvider = KetoneReadingsFamily._();

final class KetoneReadingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<KetoneReading>>,
          List<KetoneReading>,
          Stream<List<KetoneReading>>
        >
    with
        $FutureModifier<List<KetoneReading>>,
        $StreamProvider<List<KetoneReading>> {
  KetoneReadingsProvider._({
    required KetoneReadingsFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'ketoneReadingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ketoneReadingsHash();

  @override
  String toString() {
    return r'ketoneReadingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<KetoneReading>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<KetoneReading>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return ketoneReadings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is KetoneReadingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ketoneReadingsHash() => r'11b0f1503cf1d56a0a83fd0b42cad9879696e81e';

final class KetoneReadingsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<KetoneReading>>, LocalDate> {
  KetoneReadingsFamily._()
    : super(
        retry: null,
        name: r'ketoneReadingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  KetoneReadingsProvider call(LocalDate day) =>
      KetoneReadingsProvider._(argument: day, from: this);

  @override
  String toString() => r'ketoneReadingsProvider';
}
