import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// Composition surface for the `progress` feature (ADR 007).
///
/// A derived feature with no `data/` layer at all (same shape as
/// `features/streaks/`) - this provider *is* the entire feature surface. It
/// watches `activity`'s composition surface for the activity list (never its
/// `data/` - ADR 007) and recomputes [WeeklySummary]s on every change.
///
/// Also watches `streaks`' `localDayProvider` (legal: another feature's
/// composition surface, never its data/presentation) purely as a
/// local-midnight-rollover trigger - the same "watch for dependency only,
/// re-read `LocalDate.today()` fresh inside" pattern as
/// `streaks_providers.dart#streakResult` (see that provider's dartdoc for
/// why watching the emitted value alone wouldn't be enough: without this,
/// a session left open overnight with no new activity would keep showing
/// yesterday's "this week" until something else happened to change).
@riverpod
Stream<List<WeeklySummary>> weeklySummaries(Ref ref) {
  final repository = ref.watch(activityRepositoryProvider);
  ref.watch(localDayProvider);

  return repository.watchActivities().map(
    (activities) => computeWeeklySummaries(
      activities: activities,
      today: LocalDate.today(),
    ),
  );
}

/// All activities stream for multi-domain progress overview aggregations.
@riverpod
Stream<List<Activity>> progressActivities(Ref ref) {
  return ref.watch(activityRepositoryProvider).watchActivities();
}

/// Recent check-ins for the progress overview.
@riverpod
Stream<List<DailyCheckin>> progressRecentCheckins(
  Ref ref, {
  required int days,
  required LocalDate today,
}) {
  return ref
      .watch(wellbeingRepositoryProvider)
      .watchRecentCheckins(days, today);
}

/// Recent flares for the progress overview.
@riverpod
Stream<List<FlareEvent>> progressRecentFlares(
  Ref ref, {
  required int days,
  required LocalDate today,
}) {
  return ref.watch(wellbeingRepositoryProvider).watchRecentFlares(days, today);
}
