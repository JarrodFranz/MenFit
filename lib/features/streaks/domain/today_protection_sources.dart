import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/period_days.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';

part 'today_protection_sources.freezed.dart';

/// Which of today's independent protection sources
/// (`domain/streak_assembly.dart`'s three-source union) are currently
/// active — the per-source breakdown `StreakResult.todayStatus`
/// deliberately doesn't expose (`home/presentation/widgets/streak_card.dart`
/// 's `_ProtectedStreakCard` dartdoc: the card stays source-agnostic on
/// sight, by design). Powers the streak card's "Today" management sheet —
/// the one surface where a user *asks* to see why today is protected.
///
/// Multiple sources can be active simultaneously (e.g. an explicit
/// recovery day AND a protecting flare, both independently true) — that's
/// exactly why this is a struct of independent booleans rather than a
/// single `enum` "the reason".
@freezed
abstract class TodayProtectionSources with _$TodayProtectionSources {
  const factory TodayProtectionSources({
    required bool hasExplicitRecoveryDay,
    required bool hasProtectingFlare,
    required bool isPeriodProtected,

    /// The note attached when marking today via `hasExplicitRecoveryDay`,
    /// if any. Always `null` when `hasExplicitRecoveryDay` is `false`.
    String? recoveryNote,
  }) = _TodayProtectionSources;

  const TodayProtectionSources._();

  /// Whether at least one source currently protects today — mirrors
  /// `StreakResult.isProtectedToday` but computed independently (from the
  /// same per-source union `assembleTodayProtectionSources` resolves, the
  /// same one `domain/streak_assembly.dart#assembleStreakResult` folds into
  /// its `protectedDays` set), so a sheet built from this stays consistent
  /// with the streak card without needing to also watch `StreakResult`.
  bool get hasAnySource =>
      hasExplicitRecoveryDay || hasProtectingFlare || isPeriodProtected;
}

/// Assembles [TodayProtectionSources] for [today] from the same per-source
/// raw data `domain/streak_assembly.dart#assembleStreakResult` draws its
/// `protectedDays` union from — just resolved **per source** instead of
/// unioned, since the "Today" sheet needs to say *which* sources apply, not
/// just whether the day is protected overall. Deliberately a pure function
/// (same "no Riverpod/Drift" testability reasoning as
/// `assembleStreakResult` itself) — `streaks_providers.dart` supplies the
/// already-loaded stream values.
TodayProtectionSources assembleTodayProtectionSources({
  required List<RecoveryDayEntry> recoveryDayEntries,
  required Set<LocalDate> flareProtectedDays,
  required List<CycleRecord> records,
  required bool pausingEnabled,
  required LocalDate today,
}) {
  RecoveryDayEntry? todayEntry;
  for (final entry in recoveryDayEntries) {
    if (entry.day == today) {
      todayEntry = entry;
      break;
    }
  }

  return TodayProtectionSources(
    hasExplicitRecoveryDay: todayEntry != null,
    recoveryNote: todayEntry?.note,
    hasProtectingFlare: flareProtectedDays.contains(today),
    isPeriodProtected: pausingEnabled && isPeriodDay(today, records, today),
  );
}
