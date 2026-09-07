// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_overview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The three facts the home dashboard's "Today" card states, recomputed on
/// every change to any of its three sources.
///
/// Reads the three owning features through their composition surfaces
/// (ADR 007) and hands the result straight to the pure fold in
/// `domain/home_today_overview.dart` — nothing is decided here.
///
/// [localDayProvider] is watched as a **dependency only**, the same
/// midnight-rollover trigger `progress_providers.dart#weeklySummaries` and
/// `streaks_providers.dart#streakResult` use: without it a session left
/// open overnight would keep counting yesterday's workouts, and — because
/// `watchCheckinFor` is subscribed for one fixed day — would keep watching
/// yesterday's check-in row. The day is re-read fresh inside the combiner
/// regardless.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing here is logged or sent to analytics.

@ProviderFor(homeTodayOverview)
final homeTodayOverviewProvider = HomeTodayOverviewProvider._();

/// The three facts the home dashboard's "Today" card states, recomputed on
/// every change to any of its three sources.
///
/// Reads the three owning features through their composition surfaces
/// (ADR 007) and hands the result straight to the pure fold in
/// `domain/home_today_overview.dart` — nothing is decided here.
///
/// [localDayProvider] is watched as a **dependency only**, the same
/// midnight-rollover trigger `progress_providers.dart#weeklySummaries` and
/// `streaks_providers.dart#streakResult` use: without it a session left
/// open overnight would keep counting yesterday's workouts, and — because
/// `watchCheckinFor` is subscribed for one fixed day — would keep watching
/// yesterday's check-in row. The day is re-read fresh inside the combiner
/// regardless.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing here is logged or sent to analytics.

final class HomeTodayOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeTodayOverview>,
          HomeTodayOverview,
          Stream<HomeTodayOverview>
        >
    with
        $FutureModifier<HomeTodayOverview>,
        $StreamProvider<HomeTodayOverview> {
  /// The three facts the home dashboard's "Today" card states, recomputed on
  /// every change to any of its three sources.
  ///
  /// Reads the three owning features through their composition surfaces
  /// (ADR 007) and hands the result straight to the pure fold in
  /// `domain/home_today_overview.dart` — nothing is decided here.
  ///
  /// [localDayProvider] is watched as a **dependency only**, the same
  /// midnight-rollover trigger `progress_providers.dart#weeklySummaries` and
  /// `streaks_providers.dart#streakResult` use: without it a session left
  /// open overnight would keep counting yesterday's workouts, and — because
  /// `watchCheckinFor` is subscribed for one fixed day — would keep watching
  /// yesterday's check-in row. The day is re-read fresh inside the combiner
  /// regardless.
  ///
  /// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
  /// nothing here is logged or sent to analytics.
  HomeTodayOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTodayOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTodayOverviewHash();

  @$internal
  @override
  $StreamProviderElement<HomeTodayOverview> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HomeTodayOverview> create(Ref ref) {
    return homeTodayOverview(ref);
  }
}

String _$homeTodayOverviewHash() => r'322e126b893f4071428293a36b65f9d937bc7ec5';
