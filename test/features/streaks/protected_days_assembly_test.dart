import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/streak_assembly.dart';

/// `assembleProtectedDays` is the single decision source for "is this day
/// protected", shared by the streak engine and by the achievements
/// feature's consistency ladder. `streak_assembly_test.dart` already covers
/// what protection *does* to a streak; this file pins the set itself,
/// because a second consumer now reads it directly.
void main() {
  final today = LocalDate(2026, 8, 26);

  Set<LocalDate> assemble({
    Set<LocalDate> recoveryDays = const {},
    Set<LocalDate> flareProtectedDays = const {},
  }) {
    return assembleProtectedDays(
      recoveryDays: recoveryDays,
      flareProtectedDays: flareProtectedDays,
      today: today,
    );
  }

  test('no source at all is an empty set', () {
    expect(assemble(), isEmpty);
  });

  test('the two sources union, neither of them requiring the other', () {
    final days = assemble(
      recoveryDays: {LocalDate(2026, 8, 20)},
      flareProtectedDays: {LocalDate(2026, 8, 21)},
    );
    expect(days, {LocalDate(2026, 8, 20), LocalDate(2026, 8, 21)});
  });

  test('a recovery day alone protects, with no flare anywhere', () {
    expect(
      assemble(recoveryDays: {LocalDate(2026, 8, 20)}),
      {LocalDate(2026, 8, 20)},
    );
  });

  test('a flare-protected day alone protects, with no recovery day', () {
    expect(
      assemble(flareProtectedDays: {LocalDate(2026, 8, 21)}),
      {LocalDate(2026, 8, 21)},
    );
  });

  test('sources far in the past are not clipped away by a recent one', () {
    // Neither source is windowed: a day protected two years ago is still in
    // the set alongside one from yesterday.
    final days = assemble(
      recoveryDays: {LocalDate(2026, 8, 25)},
      flareProtectedDays: {LocalDate(2024, 1, 3)},
    );
    expect(days, {LocalDate(2024, 1, 3), LocalDate(2026, 8, 25)});
  });

  test('overlapping sources collapse rather than double-counting', () {
    final day = LocalDate(2026, 8, 24);
    final days = assemble(
      recoveryDays: {day},
      flareProtectedDays: {day},
    );
    expect(days, {day});
  });
}
