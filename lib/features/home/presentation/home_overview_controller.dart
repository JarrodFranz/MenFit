import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/utils/combine_latest.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/home/domain/home_today_overview.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_overview_controller.g.dart';

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
@riverpod
Stream<HomeTodayOverview> homeTodayOverview(Ref ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final recoveryRepository = ref.watch(recoveryRepositoryProvider);
  ref.watch(localDayProvider);

  return combineLatest3(
    activityRepository.watchActivities(),
    wellbeingRepository.watchCheckinFor(LocalDate.today()),
    recoveryRepository.watchRecoveryDayEntries(),
    (activities, checkin, recoveryDays) => buildHomeTodayOverview(
      today: LocalDate.today(),
      activities: activities,
      checkin: checkin,
      recoveryDays: recoveryDays,
    ),
  );
}
