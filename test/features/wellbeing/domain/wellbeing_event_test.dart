import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';

void main() {
  group('WellbeingEventType', () {
    test('toStorage and fromStorage roundtrip for all values', () {
      for (final type in WellbeingEventType.values) {
        final storage = type.toStorage();
        expect(WellbeingEventType.fromStorage(storage), type);
      }
    });

    test('fromStorage falls back to other for unknown strings', () {
      expect(
        WellbeingEventType.fromStorage('unknown'),
        WellbeingEventType.other,
      );
      expect(WellbeingEventType.fromStorage(''), WellbeingEventType.other);
    });

    test('defaultTitle provides readable names', () {
      expect(WellbeingEventType.intimacy.defaultTitle, 'Intimacy');
      expect(WellbeingEventType.injury.defaultTitle, 'Injury');
      expect(WellbeingEventType.holiday.defaultTitle, 'Holiday');
      expect(WellbeingEventType.other.defaultTitle, 'Other Event');
    });
  });

  group('WellbeingEvent', () {
    test('instantiates with expected properties and defaults', () {
      final now = DateTime.utc(2026, 9);
      final event = WellbeingEvent(
        id: 'event-1',
        day: LocalDate(2026, 9, 1),
        type: WellbeingEventType.intimacy,
        title: 'Intimacy',
        createdAt: now,
        updatedAt: now,
      );

      expect(event.id, 'event-1');
      expect(event.day, LocalDate(2026, 9, 1));
      expect(event.type, WellbeingEventType.intimacy);
      expect(event.title, 'Intimacy');
      expect(event.isCustomSaved, isFalse);
      expect(event.notes, isNull);
      expect(event.createdAt, now);
      expect(event.updatedAt, now);
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.utc(2026, 9);
      final event = WellbeingEvent(
        id: 'event-1',
        day: LocalDate(2026, 9, 1),
        type: WellbeingEventType.holiday,
        title: 'Beach Trip',
        isCustomSaved: true,
        notes: 'Relaxing weekend',
        createdAt: now,
        updatedAt: now,
      );

      final updated = event.copyWith(
        title: 'Mountain Trip',
        notes: null,
      );

      expect(updated.title, 'Mountain Trip');
      expect(updated.notes, isNull);
      expect(updated.type, WellbeingEventType.holiday);
      expect(updated.isCustomSaved, isTrue);
    });
  });
}
