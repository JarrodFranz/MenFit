// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copy_meal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The meals that have something to copy into [day] from the day before it.
///
/// A stream over the previous day's entries, so the affordance appears and
/// disappears as that day changes underneath the diary rather than as a
/// snapshot taken when the screen was built.
///
/// **Never for a day in the future.** The diary refuses future days outright
/// (`domain/nutrition_validation.dart`) and the day selector is capped at
/// today, so this is belt and braces — but "copy yesterday into tomorrow" is
/// a meaningless offer and the guard costs one comparison.

@ProviderFor(copyableMeals)
final copyableMealsProvider = CopyableMealsFamily._();

/// The meals that have something to copy into [day] from the day before it.
///
/// A stream over the previous day's entries, so the affordance appears and
/// disappears as that day changes underneath the diary rather than as a
/// snapshot taken when the screen was built.
///
/// **Never for a day in the future.** The diary refuses future days outright
/// (`domain/nutrition_validation.dart`) and the day selector is capped at
/// today, so this is belt and braces — but "copy yesterday into tomorrow" is
/// a meaningless offer and the guard costs one comparison.

final class CopyableMealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<MealType>>,
          Set<MealType>,
          Stream<Set<MealType>>
        >
    with $FutureModifier<Set<MealType>>, $StreamProvider<Set<MealType>> {
  /// The meals that have something to copy into [day] from the day before it.
  ///
  /// A stream over the previous day's entries, so the affordance appears and
  /// disappears as that day changes underneath the diary rather than as a
  /// snapshot taken when the screen was built.
  ///
  /// **Never for a day in the future.** The diary refuses future days outright
  /// (`domain/nutrition_validation.dart`) and the day selector is capped at
  /// today, so this is belt and braces — but "copy yesterday into tomorrow" is
  /// a meaningless offer and the guard costs one comparison.
  CopyableMealsProvider._({
    required CopyableMealsFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'copyableMealsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$copyableMealsHash();

  @override
  String toString() {
    return r'copyableMealsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<MealType>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<MealType>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return copyableMeals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CopyableMealsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$copyableMealsHash() => r'bb75413734293e2cbe68f6466bddceb73ec1f0d1';

/// The meals that have something to copy into [day] from the day before it.
///
/// A stream over the previous day's entries, so the affordance appears and
/// disappears as that day changes underneath the diary rather than as a
/// snapshot taken when the screen was built.
///
/// **Never for a day in the future.** The diary refuses future days outright
/// (`domain/nutrition_validation.dart`) and the day selector is capped at
/// today, so this is belt and braces — but "copy yesterday into tomorrow" is
/// a meaningless offer and the guard costs one comparison.

final class CopyableMealsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<MealType>>, LocalDate> {
  CopyableMealsFamily._()
    : super(
        retry: null,
        name: r'copyableMealsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The meals that have something to copy into [day] from the day before it.
  ///
  /// A stream over the previous day's entries, so the affordance appears and
  /// disappears as that day changes underneath the diary rather than as a
  /// snapshot taken when the screen was built.
  ///
  /// **Never for a day in the future.** The diary refuses future days outright
  /// (`domain/nutrition_validation.dart`) and the day selector is capped at
  /// today, so this is belt and braces — but "copy yesterday into tomorrow" is
  /// a meaningless offer and the guard costs one comparison.

  CopyableMealsProvider call(LocalDate day) =>
      CopyableMealsProvider._(argument: day, from: this);

  @override
  String toString() => r'copyableMealsProvider';
}

/// Copies one meal forward from the day before [day].
///
/// ## Why this copies rather than re-logs
///
/// Each source entry is duplicated **as it stands** — its own snapshot of
/// the food's name, brand, serving description, per-serving nutrition and
/// serving weight, plus the exact amount and unit they typed. The referenced
/// food is deliberately never re-read: an entry's snapshot is the record of
/// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
/// yesterday" means the same numbers, not today's corrected definition of
/// them. It follows that a source entry whose food has since been edited,
/// or deleted, or which never had one at all (a quick add), copies across
/// perfectly well.
///
/// Only the identity fields move: a fresh id, the new [day], and fresh
/// timestamps. Yesterday's rows are read and never written.
///
/// [state] is whether a copy is in flight, per (day, meal), so the button
/// can be disabled while it runs and a double tap cannot log the meal twice.

@ProviderFor(CopyMealController)
final copyMealControllerProvider = CopyMealControllerFamily._();

/// Copies one meal forward from the day before [day].
///
/// ## Why this copies rather than re-logs
///
/// Each source entry is duplicated **as it stands** — its own snapshot of
/// the food's name, brand, serving description, per-serving nutrition and
/// serving weight, plus the exact amount and unit they typed. The referenced
/// food is deliberately never re-read: an entry's snapshot is the record of
/// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
/// yesterday" means the same numbers, not today's corrected definition of
/// them. It follows that a source entry whose food has since been edited,
/// or deleted, or which never had one at all (a quick add), copies across
/// perfectly well.
///
/// Only the identity fields move: a fresh id, the new [day], and fresh
/// timestamps. Yesterday's rows are read and never written.
///
/// [state] is whether a copy is in flight, per (day, meal), so the button
/// can be disabled while it runs and a double tap cannot log the meal twice.
final class CopyMealControllerProvider
    extends $NotifierProvider<CopyMealController, bool> {
  /// Copies one meal forward from the day before [day].
  ///
  /// ## Why this copies rather than re-logs
  ///
  /// Each source entry is duplicated **as it stands** — its own snapshot of
  /// the food's name, brand, serving description, per-serving nutrition and
  /// serving weight, plus the exact amount and unit they typed. The referenced
  /// food is deliberately never re-read: an entry's snapshot is the record of
  /// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
  /// yesterday" means the same numbers, not today's corrected definition of
  /// them. It follows that a source entry whose food has since been edited,
  /// or deleted, or which never had one at all (a quick add), copies across
  /// perfectly well.
  ///
  /// Only the identity fields move: a fresh id, the new [day], and fresh
  /// timestamps. Yesterday's rows are read and never written.
  ///
  /// [state] is whether a copy is in flight, per (day, meal), so the button
  /// can be disabled while it runs and a double tap cannot log the meal twice.
  CopyMealControllerProvider._({
    required CopyMealControllerFamily super.from,
    required (LocalDate, MealType) super.argument,
  }) : super(
         retry: null,
         name: r'copyMealControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$copyMealControllerHash();

  @override
  String toString() {
    return r'copyMealControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CopyMealController create() => CopyMealController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CopyMealControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$copyMealControllerHash() =>
    r'e3052fc9a0171f81f13b3304e5198011042466a3';

/// Copies one meal forward from the day before [day].
///
/// ## Why this copies rather than re-logs
///
/// Each source entry is duplicated **as it stands** — its own snapshot of
/// the food's name, brand, serving description, per-serving nutrition and
/// serving weight, plus the exact amount and unit they typed. The referenced
/// food is deliberately never re-read: an entry's snapshot is the record of
/// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
/// yesterday" means the same numbers, not today's corrected definition of
/// them. It follows that a source entry whose food has since been edited,
/// or deleted, or which never had one at all (a quick add), copies across
/// perfectly well.
///
/// Only the identity fields move: a fresh id, the new [day], and fresh
/// timestamps. Yesterday's rows are read and never written.
///
/// [state] is whether a copy is in flight, per (day, meal), so the button
/// can be disabled while it runs and a double tap cannot log the meal twice.

final class CopyMealControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CopyMealController,
          bool,
          bool,
          bool,
          (LocalDate, MealType)
        > {
  CopyMealControllerFamily._()
    : super(
        retry: null,
        name: r'copyMealControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Copies one meal forward from the day before [day].
  ///
  /// ## Why this copies rather than re-logs
  ///
  /// Each source entry is duplicated **as it stands** — its own snapshot of
  /// the food's name, brand, serving description, per-serving nutrition and
  /// serving weight, plus the exact amount and unit they typed. The referenced
  /// food is deliberately never re-read: an entry's snapshot is the record of
  /// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
  /// yesterday" means the same numbers, not today's corrected definition of
  /// them. It follows that a source entry whose food has since been edited,
  /// or deleted, or which never had one at all (a quick add), copies across
  /// perfectly well.
  ///
  /// Only the identity fields move: a fresh id, the new [day], and fresh
  /// timestamps. Yesterday's rows are read and never written.
  ///
  /// [state] is whether a copy is in flight, per (day, meal), so the button
  /// can be disabled while it runs and a double tap cannot log the meal twice.

  CopyMealControllerProvider call(LocalDate day, MealType meal) =>
      CopyMealControllerProvider._(argument: (day, meal), from: this);

  @override
  String toString() => r'copyMealControllerProvider';
}

/// Copies one meal forward from the day before [day].
///
/// ## Why this copies rather than re-logs
///
/// Each source entry is duplicated **as it stands** — its own snapshot of
/// the food's name, brand, serving description, per-serving nutrition and
/// serving weight, plus the exact amount and unit they typed. The referenced
/// food is deliberately never re-read: an entry's snapshot is the record of
/// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
/// yesterday" means the same numbers, not today's corrected definition of
/// them. It follows that a source entry whose food has since been edited,
/// or deleted, or which never had one at all (a quick add), copies across
/// perfectly well.
///
/// Only the identity fields move: a fresh id, the new [day], and fresh
/// timestamps. Yesterday's rows are read and never written.
///
/// [state] is whether a copy is in flight, per (day, meal), so the button
/// can be disabled while it runs and a double tap cannot log the meal twice.

abstract class _$CopyMealController extends $Notifier<bool> {
  late final _$args = ref.$arg as (LocalDate, MealType);
  LocalDate get day => _$args.$1;
  MealType get meal => _$args.$2;

  bool build(LocalDate day, MealType meal);
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
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
