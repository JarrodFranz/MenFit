import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';

part 'daily_checkin.freezed.dart';

/// A user-logged daily wellbeing check-in.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): treated
/// with the same "no logs/analytics, hard delete" handling as cycle data —
/// see `data/drift_wellbeing_repository.dart`.
///
/// Fast and fully optional (`knowledge/product/terminology.md`'s
/// "Check-in" definition): every score field is nullable, and [isEmpty]
/// tells the controller when there's genuinely nothing to save. One
/// check-in exists per calendar [day] — see
/// `domain/wellbeing_repository.dart`'s `saveCheckin` dartdoc for the
/// upsert-by-day rule.
@freezed
abstract class DailyCheckin with _$DailyCheckin {
  const factory DailyCheckin({
    required String id,
    required LocalDate day,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// 1-5, higher is better. `null` when not answered.
    int? energy,

    /// 1-5, higher is better. `null` when not answered.
    int? sleep,

    /// 1-5, higher is worse (more soreness). `null` when not answered.
    int? soreness,

    /// 1-5, higher is worse (more stress). `null` when not answered.
    int? stress,

    /// 1-5, higher is worse (more pain). `null` when not answered.
    int? pain,
    @Default(<SymptomType>[]) List<SymptomType> symptoms,

    /// Free-text description when [SymptomType.other] is selected.
    String? customSymptom,
  }) = _DailyCheckin;

  const DailyCheckin._();

  /// Whether this check-in has nothing recorded — no scores, no symptoms.
  /// `WellbeingRepository.saveCheckin` callers use this to skip saving a
  /// fully-blank check-in as a no-op (see `presentation/checkin_controller.dart`).
  bool get isEmpty =>
      energy == null &&
      sleep == null &&
      soreness == null &&
      stress == null &&
      pain == null &&
      symptoms.isEmpty &&
      (customSymptom == null || customSymptom!.trim().isEmpty);
}
