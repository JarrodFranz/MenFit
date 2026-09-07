import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/home/domain/home_today_overview.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

final _today = LocalDate.fromDateTime(DateTime.utc(2026, 9, 3));

Activity _activity(DateTime startedAtUtc) => Activity(
  id: startedAtUtc.toIso8601String(),
  activityType: ActivityType.run,
  title: 'Run',
  startedAt: startedAtUtc,
  movingTime: const Duration(minutes: 30),
  elapsedTime: const Duration(minutes: 32),
  distanceMeters: 5000,
  source: ActivitySource.manual,
  createdAt: startedAtUtc,
  updatedAt: startedAtUtc,
);

DailyCheckin _checkin({int? energy}) => DailyCheckin(
  id: 'checkin',
  day: _today,
  createdAt: DateTime.utc(2026, 9, 3),
  updatedAt: DateTime.utc(2026, 9, 3),
  energy: energy,
);

void main() {
  group('buildHomeTodayOverview', () {
    test('reports nothing logged on an empty day', () {
      final overview = buildHomeTodayOverview(
        today: _today,
        activities: const [],
        checkin: null,
        recoveryDays: const [],
      );

      expect(overview.checkinLogged, isFalse);
      expect(overview.isRecoveryDay, isFalse);
      expect(overview.workoutsToday, 0);
    });

    test('an empty check-in row is not a logged check-in', () {
      final overview = buildHomeTodayOverview(
        today: _today,
        activities: const [],
        checkin: _checkin(),
        recoveryDays: const [],
      );

      expect(overview.checkinLogged, isFalse);
    });

    test('a check-in with a score is logged', () {
      final overview = buildHomeTodayOverview(
        today: _today,
        activities: const [],
        checkin: _checkin(energy: 4),
        recoveryDays: const [],
      );

      expect(overview.checkinLogged, isTrue);
    });

    test('counts only activities that started on the local day', () {
      final overview = buildHomeTodayOverview(
        today: LocalDate.fromDateTime(DateTime.now()),
        activities: [
          _activity(DateTime.now().toUtc()),
          _activity(DateTime.now().toUtc()),
          _activity(
            DateTime.now().subtract(const Duration(days: 3)).toUtc(),
          ),
        ],
        checkin: null,
        recoveryDays: const [],
      );

      expect(overview.workoutsToday, 2);
    });

    test('an explicit recovery day for today reads as a recovery day', () {
      final overview = buildHomeTodayOverview(
        today: _today,
        activities: const [],
        checkin: null,
        recoveryDays: [RecoveryDayEntry(day: _today)],
      );

      expect(overview.isRecoveryDay, isTrue);
    });

    test('a recovery day on another day does not leak into today', () {
      final overview = buildHomeTodayOverview(
        today: _today,
        activities: const [],
        checkin: null,
        recoveryDays: [RecoveryDayEntry(day: _today.addDays(-1))],
      );

      expect(overview.isRecoveryDay, isFalse);
    });
  });
}
