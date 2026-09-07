import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/today_protection_sources.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  TodayProtectionSources assemble({
    List<RecoveryDayEntry> recoveryDayEntries = const [],
    Set<LocalDate> flareProtectedDays = const {},
  }) {
    return assembleTodayProtectionSources(
      recoveryDayEntries: recoveryDayEntries,
      flareProtectedDays: flareProtectedDays,
      today: today,
    );
  }

  test('every source empty -> nothing protects today', () {
    final result = assemble();
    expect(result.hasAnySource, isFalse);
    expect(result.hasExplicitRecoveryDay, isFalse);
    expect(result.recoveryNote, isNull);
    expect(result.hasProtectingFlare, isFalse);
  });

  test(
    'an explicit recovery day for today is reported, with its note',
    () {
      final result = assemble(
        recoveryDayEntries: [
          RecoveryDayEntry(day: today, note: 'Sore knees'),
        ],
      );
      expect(result.hasExplicitRecoveryDay, isTrue);
      expect(result.recoveryNote, 'Sore knees');
      expect(result.hasAnySource, isTrue);
    },
  );

  test(
    'an explicit recovery day on a DIFFERENT day does not count as today - '
    'only the exact-today entry resolves',
    () {
      final result = assemble(
        recoveryDayEntries: [
          RecoveryDayEntry(day: today.addDays(-1), note: 'Yesterday'),
        ],
      );
      expect(result.hasExplicitRecoveryDay, isFalse);
      expect(result.recoveryNote, isNull);
    },
  );

  test('a recovery day with no note leaves recoveryNote null', () {
    final result = assemble(
      recoveryDayEntries: [RecoveryDayEntry(day: today)],
    );
    expect(result.hasExplicitRecoveryDay, isTrue);
    expect(result.recoveryNote, isNull);
  });

  test('a protecting flare on today is reported independently', () {
    final result = assemble(flareProtectedDays: {today});
    expect(result.hasProtectingFlare, isTrue);
    expect(result.hasExplicitRecoveryDay, isFalse);
    expect(result.hasAnySource, isTrue);
  });

  test(
    'a protecting flare on a DIFFERENT day does not protect today',
    () {
      final result = assemble(flareProtectedDays: {today.addDays(-1)});
      expect(result.hasProtectingFlare, isFalse);
      expect(result.hasAnySource, isFalse);
    },
  );

  test(
    'both sources active at once are reported independently - this is '
    'exactly the multi-source case the Today sheet lists',
    () {
      final result = assemble(
        recoveryDayEntries: [RecoveryDayEntry(day: today, note: 'Note')],
        flareProtectedDays: {today},
      );
      expect(result.hasExplicitRecoveryDay, isTrue);
      expect(result.recoveryNote, 'Note');
      expect(result.hasProtectingFlare, isTrue);
      expect(result.hasAnySource, isTrue);
    },
  );
}
