/// Composition surface for the `insights` feature (ADR 007).
///
/// The only legal way for another feature (`home` and `progress`, which
/// mount this feature's discovery section through `insights_widgets.dart`)
/// to reach this feature's logic — other features may import this file,
/// never `application/` or `presentation/` directly.
///
/// This feature has no `data/` layer of its own and stores nothing: it is
/// a read-only view assembled from four other features' composition
/// surfaces (`activity`, `nutrition`, `wellbeing`, `cycle`), the same
/// derived shape as `progress` and `recaps`.
library;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/application/insight_observation_mapper.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/insight_engine.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_providers.g.dart';

/// The calendar day the insight window ends on.
///
/// A provider rather than a `LocalDate.today()` call inside
/// [insightObservations] so "today" is an explicit, overridable input: the
/// engine below it is deterministic, and a test that cannot pin the last
/// day of the window cannot pin the window at all. Same seam as
/// `features/streaks/streaks_providers.dart`'s `localDay`, without the
/// midnight timer — a 90-day window whose end rolls over a few hours late
/// changes nothing a user would notice.
@riverpod
LocalDate insightsToday(Ref ref) => LocalDate.today();

/// The last [insightWindowDays] days of the user's own logs, reduced to the
/// engine's [DailyObservation] input.
///
/// One-shot (`Future`, not `Stream`) for the same reason as
/// `features/recaps/recaps_providers.dart#recapForPeriod`: this walks 90
/// days of activities, diary entries, water totals, check-ins and cycle
/// records, and re-running that aggregation on every unrelated log while
/// Home sits offstage would be pure waste. It refreshes when it is
/// invalidated or its repositories change, which for a discovery surface is
/// soon enough.
///
/// Every source is read through the owning feature's composition surface
/// (ADR 007), never a `data/` import.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing in this provider or below it is logged, and nothing reaches
/// analytics.
@riverpod
Future<List<DailyObservation>> insightObservations(Ref ref) async {
  final today = ref.watch(insightsTodayProvider);
  final start = today.addDays(-(insightWindowDays - 1));

  final activityRepository = ref.watch(activityRepositoryProvider);
  final nutritionRepository = ref.watch(nutritionRepositoryProvider);
  final goalsRepository = ref.watch(nutritionGoalsRepositoryProvider);
  final waterRepository = ref.watch(waterRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final cycleRepository = ref.watch(cycleRepositoryProvider);

  // Every read below is a genuine one-shot `get`, never a
  // `watchXxx().first` snapshot: `Stream.first` only completes once it has
  // cancelled its subscription, and cancelling a Drift query stream
  // resolves through a root-zone future that escapes `flutter_test`'s
  // `FakeAsync` — under a widget test the await never completes while the
  // test pumps, and the stranded half-run query then deadlocks
  // `AppDatabase.close()` in `tearDown`. See
  // `features/activity/domain/activity_repository.dart#getActivities`.
  final activities = await activityRepository.getActivities();
  final entries = await nutritionRepository.getEntriesForRange(start, today);
  final goals = await goalsRepository.getGoals();
  final waterTotals = await waterRepository.getWaterTotalsForRange(
    start,
    today,
  );
  final checkins = await wellbeingRepository.getRecentCheckins(
    insightWindowDays,
    today,
  );
  final cycleRecords = await cycleRepository.getRecords();

  // Phase is derived per day from logged records only. With no records the
  // map stays empty, every day's phase is `null`, and every cycle
  // comparison excludes itself — cycle tracking is opt-in and every
  // consumer of it degrades to silence (`knowledge/domain/womens_health.md`
  // rule 4).
  //
  // `CyclePhase.none` is left **out** of the map rather than stored: it is
  // the engine's "no phase known for this day" (`getDayStatus` returns it
  // for any day before the earliest usable anchor), and an absent day is
  // how every consumer spells "unknown" — `DailyObservation.cyclePhase` is
  // nullable for exactly that. Storing `none` would make those days look
  // like a tracked group. Same skip as
  // `features/recaps/recaps_providers.dart#recapForPeriod`.
  final phaseByDay = <LocalDate, CyclePhase>{};
  if (cycleRecords.isNotEmpty) {
    final engine = CyclePredictionEngine();
    for (var day = start; !day.isAfter(today); day = day.addDays(1)) {
      final phase = engine
          .getDayStatus(date: day, records: cycleRecords, today: today)
          .phase;
      if (phase == CyclePhase.none) continue;
      phaseByDay[day] = phase;
    }
  }

  return buildDailyObservations(
    today: today,
    activities: activities,
    nutritionEntries: entries,
    nutritionGoals: goals,
    waterTotalsByDay: waterTotals,
    checkins: checkins,
    phaseByDay: phaseByDay,
  );
}

/// Every pattern in the user's own data that clears
/// `InsightThresholds`, strongest first, capped by the engine at
/// `InsightThresholds.maxSimultaneousInsights`.
///
/// An empty list is the normal state for most users most of the time, and
/// the UI renders exactly nothing for it — see
/// `presentation/widgets/insight_discovery_section.dart`.
@riverpod
Future<List<PersonalInsight>> personalInsights(Ref ref) async {
  final observations = await ref.watch(insightObservationsProvider.future);
  return const InsightEngine().evaluate(observations);
}
