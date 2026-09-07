import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'wellbeing_event.freezed.dart';

/// Categories of discrete life events a user can track in Wellbeing.
enum WellbeingEventType {
  intimacy,
  injury,
  holiday,
  other;

  static WellbeingEventType fromStorage(String value) {
    return switch (value) {
      'intimacy' => WellbeingEventType.intimacy,
      'injury' => WellbeingEventType.injury,
      'holiday' => WellbeingEventType.holiday,
      _ => WellbeingEventType.other,
    };
  }

  String toStorage() => switch (this) {
    WellbeingEventType.intimacy => 'intimacy',
    WellbeingEventType.injury => 'injury',
    WellbeingEventType.holiday => 'holiday',
    WellbeingEventType.other => 'other',
  };

  String get defaultTitle => switch (this) {
    WellbeingEventType.intimacy => 'Intimacy',
    WellbeingEventType.injury => 'Injury',
    WellbeingEventType.holiday => 'Holiday',
    WellbeingEventType.other => 'Other Event',
  };
}

/// A user-logged discrete life event in Wellbeing.
@freezed
abstract class WellbeingEvent with _$WellbeingEvent {
  const factory WellbeingEvent({
    required String id,
    required LocalDate day,
    required WellbeingEventType type,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isCustomSaved,
    String? notes,
  }) = _WellbeingEvent;

  const WellbeingEvent._();
}
