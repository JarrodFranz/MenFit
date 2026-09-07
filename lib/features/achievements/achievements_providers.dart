/// Composition surface for the `achievements` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence and derived
/// state: other features may import this file, never `data/`,
/// `application/` or `presentation/` directly (see
/// `knowledge/decisions/007_cross_feature_providers.md`).
///
/// Everything below the repository is derived, never stored: the badge
/// *catalogue* is code and the badge *progress* is a pure recompute
/// (`data_architecture.md`'s "Derived vs stored" section). The only thing
/// this feature persists is the fact that an award was earned, and when —
/// which is precisely the part that cannot be recomputed, because it is a
/// moment rather than a number.
library;

import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/application/award_detector.dart';
import 'package:menfit_app/features/achievements/data/drift_award_repository.dart';
import 'package:menfit_app/features/achievements/domain/award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'achievements_providers.g.dart';

/// Persistence for earned badges, typed as the domain interface so nothing
/// above `data/` knows Drift is behind it.
@Riverpod(keepAlive: true)
AwardRepository awardRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftAwardRepository(database);
}

/// Every award the user holds, newest first.
@riverpod
Stream<List<BadgeAward>> badgeAwards(Ref ref) {
  return ref.watch(awardRepositoryProvider).watchAwards();
}

/// The calendar day the evaluation is made against.
///
/// A provider rather than a `LocalDate.today()` call inside [badgeInputs]
/// so "today" is an explicit, overridable input — the engine below it is
/// deterministic, and a test that cannot pin today cannot pin a weekly
/// boundary, a season, or an early-morning hour. Same seam as
/// `features/insights/insights_providers.dart`'s `insightsToday`.
@riverpod
LocalDate achievementsToday(Ref ref) => LocalDate.today();

/// Everything the badge engine reads, pre-fetched from the owning
/// features' composition surfaces.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `insights_providers.dart#insightObservations` and
/// `recaps_providers.dart#recapForPeriod`: this walks the user's entire
/// history of activities, check-ins, water days and cycle records, and
/// re-running that on every unrelated log while the achievements screen
/// sits closed would be pure waste. It refreshes when invalidated, when
/// `today` rolls over, and when either of the two derived sources it
/// watches emits — which for a screen opened deliberately is soon enough.
///
/// Every read below is a genuine one-shot `get`, or a `.future` on another
/// feature's provider — never a `watchXxx().first` snapshot: `Stream.first`
/// only completes once it has cancelled its subscription, and cancelling a
/// Drift query stream resolves through a root-zone future that escapes
/// `flutter_test`'s `FakeAsync`. See
/// `features/activity/domain/activity_repository.dart#getActivities`.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged or sent to analytics.
@riverpod
Future<BadgeInputs> badgeInputs(Ref ref) async {
  final today = ref.watch(achievementsTodayProvider);
  final windowStart = today.addDays(-(badgeHistoryWindowDays - 1));

  final activityRepository = ref.watch(activityRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final waterRepository = ref.watch(waterRepositoryProvider);
  final cycleRepository = ref.watch(cycleRepositoryProvider);

  // Best efforts come from `activity`'s own records provider rather than
  // from a second scan of every GPS sample here - that feature owns the
  // computation and already folds it one activity at a time to keep memory
  // flat (see `activity_providers.dart#personalRecords`).
  final records = await ref.watch(personalRecordsProvider.future);
  // Protection comes from `streaks`' single decision source, never a
  // re-derivation - see `streaks_providers.dart#protectedDays`.
  final protectedDays = await ref.watch(protectedDaysProvider.future);

  final activities = await activityRepository.getActivities();
  final checkins = await wellbeingRepository.getRecentCheckins(
    badgeHistoryWindowDays,
    today,
  );
  final waterTotals = await waterRepository.getWaterTotalsForRange(
    windowStart,
    today,
  );
  final cycleRecords = await cycleRepository.getRecords();

  return BadgeInputs(
    today: today,
    activities: activities,
    bestEffortDistancesMetres: records.bestEfforts.keys.toSet(),
    checkinDays: {for (final checkin in checkins) checkin.day},
    waterTotalsByDay: waterTotals,
    cycleRecords: cycleRecords,
    protectedDays: protectedDays,
  );
}

/// Where the user stands on every badge in the catalogue, in catalogue
/// order — the trophy case's whole data source.
@riverpod
Future<List<BadgeProgress>> badgeProgress(Ref ref) async {
  final inputs = await ref.watch(badgeInputsProvider.future);
  return evaluateBadges(inputs: inputs);
}

/// Records newly-crossed awards and reports them back for celebration.
///
/// See [AwardDetector] for where it is meant to be called from. No trigger
/// is wired from here — reaching into another feature's flow belongs to the
/// presentation half of this task.
@riverpod
AwardDetector awardDetector(Ref ref) {
  return AwardDetector(ref.watch(awardRepositoryProvider));
}
