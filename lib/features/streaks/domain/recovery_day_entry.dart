import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'recovery_day_entry.freezed.dart';

/// A user-logged protected recovery day, as a full record (day + optional
/// note) — the shape `RecoveryRepository.watchRecoveryDayEntries` emits.
///
/// Superset of what `RecoveryRepository.watchRecoveryDays` exposes (a bare
/// `Set<LocalDate>`, the streak engine's only need — see
/// `domain/streak_assembly.dart`): surfaces that also need the note (the
/// streak card's "Today" management sheet, and the wellbeing history
/// list's recovery-day rows) watch this instead.
@freezed
abstract class RecoveryDayEntry with _$RecoveryDayEntry {
  const factory RecoveryDayEntry({required LocalDate day, String? note}) =
      _RecoveryDayEntry;
}
