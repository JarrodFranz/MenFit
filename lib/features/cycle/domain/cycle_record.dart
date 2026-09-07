import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'cycle_record.freezed.dart';

/// A user-logged period (menstrual cycle) record.
///
/// Scope note (see `knowledge/domain/womens_health.md`): the v1 cycle
/// feature is **user-logged period tracking only** — start/end dates. No
/// phase estimation, no predictions.
///
/// Mirrors `core/db/tables/cycle_records.dart` one field at a time; mapping
/// to/from the Drift row happens in `data/drift_cycle_repository.dart` so
/// the Drift type never leaks above the data layer (coding_standards.md).
/// [periodStart]/[periodEnd] are [LocalDate]s (user-local calendar days),
/// never [DateTime] instants — see `core/domain/local_date.dart`.
@freezed
abstract class CycleRecord with _$CycleRecord {
  const factory CycleRecord({
    required String id,
    required LocalDate periodStart,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// `null` while the period is ongoing.
    LocalDate? periodEnd,
  }) = _CycleRecord;

  const CycleRecord._();

  /// Whether this period is still ongoing (no end logged yet).
  bool get isOngoing => periodEnd == null;
}
