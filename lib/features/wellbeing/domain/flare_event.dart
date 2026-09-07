import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';

part 'flare_event.freezed.dart';

/// How severe a logged flare-up was.
enum FlareSeverity {
  mild,
  moderate,
  severe;

  static FlareSeverity fromStorage(String value) {
    return switch (value) {
      'moderate' => FlareSeverity.moderate,
      'severe' => FlareSeverity.severe,
      _ => FlareSeverity.mild,
    };
  }

  String toStorage() => switch (this) {
    FlareSeverity.mild => 'mild',
    FlareSeverity.moderate => 'moderate',
    FlareSeverity.severe => 'severe',
  };

  String get label => switch (this) {
    FlareSeverity.mild => 'Mild',
    FlareSeverity.moderate => 'Moderate',
    FlareSeverity.severe => 'Severe',
  };
}

/// How much a flare-up affected the user's training.
enum FlareImpact {
  none,
  reducedTraining,
  unableToTrain;

  static FlareImpact fromStorage(String value) {
    return switch (value) {
      'reducedTraining' => FlareImpact.reducedTraining,
      'unableToTrain' => FlareImpact.unableToTrain,
      _ => FlareImpact.none,
    };
  }

  String toStorage() => switch (this) {
    FlareImpact.none => 'none',
    FlareImpact.reducedTraining => 'reducedTraining',
    FlareImpact.unableToTrain => 'unableToTrain',
  };

  String get label => switch (this) {
    FlareImpact.none => 'No impact',
    FlareImpact.reducedTraining => 'Reduced my training',
    FlareImpact.unableToTrain => "Couldn't train",
  };
}

/// An optional, non-diagnostic category for a flare-up
/// (`knowledge/product/stage1_audit.md` §5.2: "WITHOUT requiring
/// diagnosis"). Never required — the UI frames this as "What kind of
/// flare-up? (optional)" with a "Prefer not to say" option that maps back
/// to `null`, not to [custom].
enum FlareCategory {
  endometriosis,
  periodSymptoms,
  migraine,
  pelvicPain,
  generalHealth,
  custom;

  static FlareCategory? fromStorage(String? value) {
    if (value == null) return null;
    return switch (value) {
      'endometriosis' => FlareCategory.endometriosis,
      'periodSymptoms' => FlareCategory.periodSymptoms,
      'migraine' => FlareCategory.migraine,
      'pelvicPain' => FlareCategory.pelvicPain,
      'generalHealth' => FlareCategory.generalHealth,
      'custom' => FlareCategory.custom,
      _ => null,
    };
  }

  String toStorage() => switch (this) {
    FlareCategory.endometriosis => 'endometriosis',
    FlareCategory.periodSymptoms => 'periodSymptoms',
    FlareCategory.migraine => 'migraine',
    FlareCategory.pelvicPain => 'pelvicPain',
    FlareCategory.generalHealth => 'generalHealth',
    FlareCategory.custom => 'custom',
  };

  String get label => switch (this) {
    FlareCategory.endometriosis => 'Endometriosis',
    FlareCategory.periodSymptoms => 'Period symptoms',
    FlareCategory.migraine => 'Migraine',
    FlareCategory.pelvicPain => 'Pelvic pain',
    FlareCategory.generalHealth => 'General health',
    FlareCategory.custom => 'Something else',
  };
}

/// The greatest number of calendar days a single flare may cover,
/// inclusive of both endpoints.
///
/// A wide, non-judgemental bound in the same spirit as
/// `features/profile/domain/profile_validation.dart`'s height/weight
/// bounds: it exists to catch a mis-picked year in a date picker, not to
/// police how long anyone's symptoms last. Enforced by
/// `domain/wellbeing_validation.dart#validateFlareEvent`, and applied again
/// defensively when expanding a stored range into days ([FlareEvent.days])
/// so that an already-persisted absurd range — a pre-validation row, or one
/// written by a future import path — can never blow up an in-memory day
/// set.
const int maxFlareRangeDays = 90;

/// A user-logged flare-up: a symptom episode independent of period logging
/// (`knowledge/product/terminology.md`'s "Flare" definition). Never
/// requires naming a diagnosis — [category] is nullable and optional.
///
/// Covers the inclusive calendar-day range `[day, lastDay]`: a flare-up
/// that lasts several days is one record, not one per day. [endDay] is
/// `null` for the single-day case.
///
/// S3-tier data, same handling as `DailyCheckin` and cycle records. Unlike
/// check-ins, multiple flares can be logged for the same [day] — see
/// `domain/wellbeing_repository.dart`'s `saveFlare` dartdoc.
@freezed
abstract class FlareEvent with _$FlareEvent {
  const factory FlareEvent({
    required String id,
    required LocalDate day,
    required FlareSeverity severity,
    required FlareImpact impact,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,
    @Default(<SymptomType>[]) List<SymptomType> symptoms,

    /// The inclusive last day of a multi-day flare. `null` — the default,
    /// and every pre-schema-v9 row — means the flare covers only [day].
    /// Read [lastDay]/[days] rather than this field directly.
    LocalDate? endDay,

    /// `null` when left unset ("Prefer not to say") — never required.
    FlareCategory? category,
    String? notes,

    /// Free-text description when [SymptomType.other] is selected.
    String? customSymptom,
  }) = _FlareEvent;

  const FlareEvent._();

  /// The inclusive last calendar day this flare covers: [endDay] when set,
  /// otherwise [day].
  ///
  /// An [endDay] that sits *before* [day] is impossible through validated
  /// entry (`domain/wellbeing_validation.dart`) but is collapsed back to a
  /// single day here rather than trusted, so a corrupt or imported row
  /// degrades to the safe single-day reading instead of producing an
  /// inverted range.
  LocalDate get lastDay {
    final end = endDay;
    if (end == null || end.isBefore(day)) return day;
    return end;
  }

  /// Every calendar day this flare covers, ascending, inclusive of both
  /// [day] and [lastDay]. A single-day flare yields exactly `[day]`.
  ///
  /// Capped at [maxFlareRangeDays] entries — see that constant's dartdoc.
  List<LocalDate> get days {
    final span = day.difference(lastDay);
    final lastOffset = span < maxFlareRangeDays ? span : maxFlareRangeDays - 1;
    return [for (var i = 0; i <= lastOffset; i++) day.addDays(i)];
  }
}
