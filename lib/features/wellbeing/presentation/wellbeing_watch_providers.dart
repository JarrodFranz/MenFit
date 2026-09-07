import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wellbeing_watch_providers.g.dart';

/// Watches the check-in logged for [day], if any. Used by the home
/// check-in card (today) and the check-in sheet (pre-filling an edit).
@riverpod
Stream<DailyCheckin?> checkinForDay(Ref ref, LocalDate day) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchCheckinFor(day);
}

/// Watches every flare logged on [day]. Used by the home check-in card
/// (today's flare chip) and the wellbeing history screen.
@riverpod
Stream<List<FlareEvent>> flaresOnDay(Ref ref, LocalDate day) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchFlaresOn(day);
}

/// Watches every check-in within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.
@riverpod
Stream<List<DailyCheckin>> recentCheckins(Ref ref, int days) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchRecentCheckins(days, LocalDate.today());
}

/// Watches every flare logged within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.
@riverpod
Stream<List<FlareEvent>> recentFlares(Ref ref, int days) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchRecentFlares(days, LocalDate.today());
}

/// Watches every check-in in the inclusive range `[from, to]`, oldest
/// first. Used by the wellbeing calendar, which needs whichever month is
/// on screen rather than a window ending today.
@riverpod
Stream<List<DailyCheckin>> checkinsForRange(
  Ref ref,
  LocalDate from,
  LocalDate to,
) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchCheckinsForRange(from, to);
}

/// Watches every flare overlapping the inclusive range `[from, to]`,
/// oldest start day first. Used by the wellbeing calendar.
@riverpod
Stream<List<FlareEvent>> flaresForRange(
  Ref ref,
  LocalDate from,
  LocalDate to,
) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchFlaresForRange(from, to);
}

/// Watches every event logged on [day]. Used by day details and sheets.
@riverpod
Stream<List<WellbeingEvent>> eventsOnDay(Ref ref, LocalDate day) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchEventsOn(day);
}

/// Watches every event in the inclusive range `[from, to]`.
/// Used by calendars to render event glyphs.
@riverpod
Stream<List<WellbeingEvent>> eventsForRange(
  Ref ref,
  LocalDate from,
  LocalDate to,
) {
  final repository = ref.watch(wellbeingRepositoryProvider);
  return repository.watchEventsForRange(from, to);
}
