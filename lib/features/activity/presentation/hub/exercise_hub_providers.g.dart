// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_hub_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams all activities matching [ActivityType], ordered chronologically.

@ProviderFor(exerciseHubActivities)
final exerciseHubActivitiesProvider = ExerciseHubActivitiesFamily._();

/// Streams all activities matching [ActivityType], ordered chronologically.

final class ExerciseHubActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Activity>>,
          List<Activity>,
          Stream<List<Activity>>
        >
    with $FutureModifier<List<Activity>>, $StreamProvider<List<Activity>> {
  /// Streams all activities matching [ActivityType], ordered chronologically.
  ExerciseHubActivitiesProvider._({
    required ExerciseHubActivitiesFamily super.from,
    required ActivityType super.argument,
  }) : super(
         retry: null,
         name: r'exerciseHubActivitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseHubActivitiesHash();

  @override
  String toString() {
    return r'exerciseHubActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Activity>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Activity>> create(Ref ref) {
    final argument = this.argument as ActivityType;
    return exerciseHubActivities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseHubActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseHubActivitiesHash() =>
    r'551d71cbf6742905cb15808b121e5a0f3d0f3169';

/// Streams all activities matching [ActivityType], ordered chronologically.

final class ExerciseHubActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Activity>>, ActivityType> {
  ExerciseHubActivitiesFamily._()
    : super(
        retry: null,
        name: r'exerciseHubActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams all activities matching [ActivityType], ordered chronologically.

  ExerciseHubActivitiesProvider call(ActivityType type) =>
      ExerciseHubActivitiesProvider._(argument: type, from: this);

  @override
  String toString() => r'exerciseHubActivitiesProvider';
}

/// Calculates aggregated statistics for [ActivityType].

@ProviderFor(exerciseHubStats)
final exerciseHubStatsProvider = ExerciseHubStatsFamily._();

/// Calculates aggregated statistics for [ActivityType].

final class ExerciseHubStatsProvider
    extends
        $FunctionalProvider<
          ExerciseHubStats,
          ExerciseHubStats,
          ExerciseHubStats
        >
    with $Provider<ExerciseHubStats> {
  /// Calculates aggregated statistics for [ActivityType].
  ExerciseHubStatsProvider._({
    required ExerciseHubStatsFamily super.from,
    required ActivityType super.argument,
  }) : super(
         retry: null,
         name: r'exerciseHubStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseHubStatsHash();

  @override
  String toString() {
    return r'exerciseHubStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ExerciseHubStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExerciseHubStats create(Ref ref) {
    final argument = this.argument as ActivityType;
    return exerciseHubStats(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseHubStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseHubStats>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseHubStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseHubStatsHash() => r'6628ceb428f65b380107f45f15e2aea25b762744';

/// Calculates aggregated statistics for [ActivityType].

final class ExerciseHubStatsFamily extends $Family
    with $FunctionalFamilyOverride<ExerciseHubStats, ActivityType> {
  ExerciseHubStatsFamily._()
    : super(
        retry: null,
        name: r'exerciseHubStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Calculates aggregated statistics for [ActivityType].

  ExerciseHubStatsProvider call(ActivityType type) =>
      ExerciseHubStatsProvider._(argument: type, from: this);

  @override
  String toString() => r'exerciseHubStatsProvider';
}
