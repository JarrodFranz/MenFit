import 'dart:async';

import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/utils/combine_latest.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/streak_assembly.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/domain/today_protection_sources.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'streaks_providers.g.dart';

/// How long past the exact next-local-midnight instant [localDay] waits
/// before actually re-emitting — a small buffer against clock/scheduling
/// jitter so the underlying [Timer] can never fire a hair early and read
/// yesterday's date.
const Duration _midnightEpsilon = Duration(milliseconds: 500);

/// The real elapsed time from [now] until the next local midnight (00:00:00
/// the day after [now]).
///
/// Deliberately **not** a fixed `Duration(hours: 24)`: a local midnight can
/// be 23 or 25 real hours away on a day a DST transition happens between
/// [now] and it. `DateTime(y, m, d + 1)` resolves to local midnight per the
/// platform's current DST rules for that date (the constructor normalises
/// an out-of-range `day`), and `.difference` on two [DateTime]s is exact
/// wall-clock elapsed time regardless of any DST change spanned in between
/// — the same reasoning as `core/domain/local_date.dart`'s `difference`,
/// just over instants instead of calendar days. A pure function of [now]
/// (no system-clock read) so it's unit-testable across DST-change dates
/// without needing a fake clock.
Duration durationUntilNextLocalMidnight(DateTime now) {
  final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  return nextMidnight.difference(now);
}

/// Emits [LocalDate.today]'s value immediately on listen, then again at
/// every local-midnight rollover for as long as something keeps listening
/// — the S2 fix for staleness across a session left open overnight (see
/// [streakResult]'s dartdoc for how it's consumed).
///
/// `@riverpod` (autoDispose, the default — not `keepAlive`): this
/// provider's only job is feeding [streakResult], which is itself
/// autoDispose, so its lifecycle should match rather than outlive it. The
/// scheduled [Timer] is cancelled from *two* places for belt-and-braces
/// safety - the stream's own `onCancel` (fires once the last listener
/// cancels) and `ref.onDispose` (fires on provider disposal) - covering
/// both a bare `Stream.listen` consumer and a Riverpod-mediated one.
/// `Timer.cancel()` is synchronous (unlike a Drift stream subscription's
/// `cancel()` future - see `flutter development knowledge/
/// testing-pitfalls.md`'s "awaited subscription cancel wedges teardown"
/// entry), so there's no fire-and-forget hazard here: by the time
/// `ref.onDispose` returns, no pending `Timer` survives - exactly what a
/// widget test's end-of-test teardown needs to avoid a false "Timer is
/// still pending" failure.
@riverpod
Stream<LocalDate> localDay(Ref ref) {
  late final StreamController<LocalDate> controller;
  Timer? timer;

  void scheduleNext() {
    timer = Timer(
      durationUntilNextLocalMidnight(DateTime.now()) + _midnightEpsilon,
      () {
        controller.add(LocalDate.today());
        scheduleNext();
      },
    );
  }

  controller = StreamController<LocalDate>(
    onListen: () {
      controller.add(LocalDate.today());
      scheduleNext();
    },
    onCancel: () => timer?.cancel(),
  );
  ref.onDispose(() => timer?.cancel());

  return controller.stream;
}

/// Composition surface for the `streaks` feature (ADR 007).
///
/// The streak *result* is still **derived, never stored**
/// (`data_architecture.md`'s "Derived vs stored" section) —
/// [streakResultProvider] remains a pure recompute with no cache table.
/// S1-2 gives the feature its first genuine `data/` layer
/// ([recoveryRepositoryProvider]) for a different thing: the user's own
/// explicit "I marked this day as recovery" record (see
/// `core/db/tables/recovery_days.dart`'s dartdoc for why that's not a
/// contradiction).
@Riverpod(keepAlive: true)
RecoveryRepository recoveryRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftRecoveryRepository(database);
}

/// Recomputes a [StreakResult] on every change to activities, recovery
/// days, protecting flare days (F1: unwindowed — see
/// `WellbeingRepository.watchProtectingFlareDays`'s dartdoc), cycle
/// records, the streak-pausing preference, or the local calendar day
/// rolling over. Watches `activity`'s, `cycle`'s, and `wellbeing`'s
/// composition surfaces (never their `data/` — ADR 007) plus this
/// feature's own [recoveryRepositoryProvider].
///
/// S2 (fixed): a review previously found this dartdoc's old claim -
/// "a recompute that happens to straddle local midnight still evaluates
/// against the correct today" - didn't actually hold for a session left
/// open with nothing else changing overnight: [LocalDate.today] being read
/// fresh *inside the combiner* only helps if the combiner runs again, and
/// with no source-stream change there was nothing to trigger that. The
/// actual fix is watching [localDayProvider] below: it ticks over exactly
/// at local midnight (see its dartdoc), and `ref.watch` on a provider whose
/// value changes rebuilds this whole provider function - which
/// resubscribes every source stream from scratch. That's a deliberately
/// simpler fix than threading a sixth stream through the combinator: these
/// repository streams are cheap to resubscribe (a Drift `.watch()` just
/// re-runs its query; the prefs stream re-seeds its current value), and it
/// happens at most once a day. [LocalDate.today] is still also read fresh
/// inside the combiner on every recompute, as a second, cheap layer of
/// defence.
@riverpod
Stream<StreakResult> streakResult(Ref ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final recoveryRepository = ref.watch(recoveryRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final cycleRepository = ref.watch(cycleRepositoryProvider);
  // Dependency-only watch: the emitted LocalDate itself isn't needed here
  // (LocalDate.today() below reads it fresh regardless) - this exists
  // purely so a local-midnight tick rebuilds this provider. See the
  // dartdoc above.
  ref.watch(localDayProvider);

  return combineLatest5(
    activityRepository.watchActivities(),
    recoveryRepository.watchRecoveryDays(),
    // F1: unwindowed (see the provider's own dartdoc), unlike the plain
    // `watchRecentFlares` the wellbeing history screen uses - flare-based
    // streak protection must never expire.
    wellbeingRepository.watchProtectingFlareDays(),
    cycleRepository.watchRecords(),
    cycleRepository.watchStreakPausingEnabled(),
    (activities, recoveryDays, flareProtectedDays, records, pausingEnabled) =>
        assembleStreakResult(
          activities: activities,
          recoveryDays: recoveryDays,
          flareProtectedDays: flareProtectedDays,
          records: records,
          pausingEnabled: pausingEnabled,
          today: LocalDate.today(),
        ),
  );
}

/// Watches every logged recovery day as full records (day + note),
/// unwindowed — a thin pass-through onto
/// [RecoveryRepository.watchRecoveryDayEntries] (see its own dartdoc for
/// why it's unwindowed). Consumed directly by [todayProtectionSourcesProvider]
/// below, and by the wellbeing history screen, which filters the result to
/// its own 30-day window client-side rather than needing a second,
/// windowed repository query for what stays a small dataset in practice.
@riverpod
Stream<List<RecoveryDayEntry>> recoveryDayEntries(Ref ref) {
  final repository = ref.watch(recoveryRepositoryProvider);
  return repository.watchRecoveryDayEntries();
}

/// Every day the streak engine treats as protected recovery, as of today —
/// `domain/streak_assembly.dart`'s [assembleProtectedDays] over the same
/// three sources [streakResult] folds into its own `protectedDays`.
///
/// Exposed on the composition surface (ADR 007) because "was this day
/// protected" is a question other features legitimately have to ask:
/// `achievements` needs it so a period week cannot void a week of its
/// cycle-aware consistency ladder
/// (`features/achievements/domain/weekly_walking_rule.dart`). Handing over
/// the answer rather than the sources is the point — a second feature
/// re-deriving "protected" from recovery days, flares and the pausing
/// toggle would be a second definition, and the two would eventually
/// disagree.
///
/// Same midnight-rollover handling as [streakResult]: a dependency-only
/// watch on [localDayProvider] forces a full resubscribe at local midnight,
/// and [LocalDate.today] is read fresh inside the combiner regardless.
@riverpod
Stream<Set<LocalDate>> protectedDays(Ref ref) {
  final recoveryRepository = ref.watch(recoveryRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final cycleRepository = ref.watch(cycleRepositoryProvider);
  ref.watch(localDayProvider);

  return combineLatest4(
    recoveryRepository.watchRecoveryDays(),
    wellbeingRepository.watchProtectingFlareDays(),
    cycleRepository.watchRecords(),
    cycleRepository.watchStreakPausingEnabled(),
    (recoveryDays, flareProtectedDays, records, pausingEnabled) =>
        assembleProtectedDays(
          recoveryDays: recoveryDays,
          flareProtectedDays: flareProtectedDays,
          records: records,
          pausingEnabled: pausingEnabled,
          today: LocalDate.today(),
        ),
  );
}

/// The per-source breakdown of what's protecting *today* specifically —
/// `domain/today_protection_sources.dart`'s [TodayProtectionSources],
/// assembled by [assembleTodayProtectionSources] from the same raw
/// per-source data [streakResultProvider] above draws its `protectedDays`
/// union from, just resolved per-source instead of unioned. Powers the
/// streak card's "Today" management sheet
/// (`features/home/presentation/widgets/today_sheet.dart`) — the engine
/// itself stays untouched; this is a second, independent derived view over
/// the same sources.
///
/// Same midnight-rollover handling as [streakResultProvider]: a
/// dependency-only watch on [localDayProvider] forces a full resubscribe of
/// the underlying streams at local midnight, and [LocalDate.today] is read
/// fresh inside the combiner on every recompute regardless.
@riverpod
Stream<TodayProtectionSources> todayProtectionSources(Ref ref) {
  final recoveryRepository = ref.watch(recoveryRepositoryProvider);
  final wellbeingRepository = ref.watch(wellbeingRepositoryProvider);
  final cycleRepository = ref.watch(cycleRepositoryProvider);
  ref.watch(localDayProvider);

  return combineLatest4(
    recoveryRepository.watchRecoveryDayEntries(),
    wellbeingRepository.watchProtectingFlareDays(),
    cycleRepository.watchRecords(),
    cycleRepository.watchStreakPausingEnabled(),
    (entries, flareProtectedDays, records, pausingEnabled) =>
        assembleTodayProtectionSources(
          recoveryDayEntries: entries,
          flareProtectedDays: flareProtectedDays,
          records: records,
          pausingEnabled: pausingEnabled,
          today: LocalDate.today(),
        ),
  );
}
