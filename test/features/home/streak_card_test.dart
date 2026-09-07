import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/home/presentation/widgets/streak_card.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';

/// A `RecoveryRepository` double that records calls instead of touching a
/// real database - `StreakCard`'s recovery action/undo affordances are
/// pure UI-triggered calls, so no repository behaviour needs exercising
/// here (that's `recovery_repository_test.dart`'s job).
class _FakeRecoveryRepository implements RecoveryRepository {
  final List<String> calls = [];

  @override
  Stream<Set<LocalDate>> watchRecoveryDays() => Stream.value(const {});

  @override
  Stream<List<RecoveryDayEntry>> watchRecoveryDayEntries() =>
      Stream.value(const []);

  @override
  Future<void> markRecoveryDay(LocalDate day, {String? note}) async {
    calls.add('mark:$day');
  }

  @override
  Future<void> markRecoveryDays(
    LocalDate from,
    LocalDate to, {
    String? note,
  }) async {
    calls.add('markRange:$from..$to');
  }

  @override
  Future<void> unmarkRecoveryDay(LocalDate day) async {
    calls.add('unmark:$day');
  }

  @override
  Future<void> unmarkRecoveryDays(LocalDate from, LocalDate to) async {
    calls.add('unmarkRange:$from..$to');
  }

  @override
  Future<void> deleteAllData() async {
    calls.add('deleteAllData');
  }
}

void main() {
  Widget buildApp(
    StreakResult result, {
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        streakResultProvider.overrideWith((ref) => Stream.value(result)),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: StreakCard()),
      ),
    );
  }

  testWidgets('normal state shows the current and longest streak', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const StreakResult(
          currentStreak: 5,
          longestStreak: 12,
          todayStatus: DayStatus.completedActivity,
          todaySatisfied: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('5-day streak'), findsOneWidget);
    expect(find.text('Longest: 12 days'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    // Today is already completedActivity, so no protected copy and no
    // recovery-day action.
    expect(find.textContaining('Recovery day'), findsNothing);
    expect(find.text('Make today a recovery day'), findsNothing);
  });

  testWidgets(
    'today-satisfied state shows the affirmation alongside the streak',
    (tester) async {
      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 3,
            longestStreak: 3,
            todayStatus: DayStatus.completedActivity,
            todaySatisfied: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3-day streak'), findsOneWidget);
      expect(find.textContaining("You've moved today"), findsOneWidget);
    },
  );

  testWidgets(
    'empty/unscheduled state invites the user to start a streak, and '
    'offers the recovery-day action',
    (tester) async {
      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 0,
            longestStreak: 0,
            todayStatus: DayStatus.unscheduled,
            todaySatisfied: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Log an activity to start your streak'),
        findsOneWidget,
      );
      expect(find.textContaining('-day streak'), findsNothing);
      expect(find.text('Make today a recovery day'), findsOneWidget);
    },
  );

  testWidgets(
    'unscheduled state with an existing streak still offers the '
    'recovery-day action',
    (tester) async {
      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 4,
            longestStreak: 6,
            todayStatus: DayStatus.unscheduled,
            todaySatisfied: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4-day streak'), findsOneWidget);
      expect(find.text('Make today a recovery day'), findsOneWidget);
    },
  );

  testWidgets(
    'protected state shows the recovery copy, keeps the count safe, and '
    'uses a neutral (never period-coloured) tint',
    (tester) async {
      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 7,
            longestStreak: 10,
            todayStatus: DayStatus.protectedRecovery,
            todaySatisfied: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Recovery day — your 7-day streak is safe'),
        findsOneWidget,
      );
      expect(
        find.text("Recovery days don't break your streak."),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      // Never "frozen"/"excused"/"failed" - see terminology.md.
      expect(find.textContaining('frozen'), findsNothing);
      expect(find.textContaining('freeze'), findsNothing);
      expect(find.textContaining('excused'), findsNothing);
      expect(find.textContaining('failed'), findsNothing);
      // No source-specific wording (period/flare) - the card is
      // deliberately source-agnostic (RULING §6).
      expect(find.textContaining('period'), findsNothing);
      // Already protected today - the recovery action isn't offered again.
      expect(find.text('Make today a recovery day'), findsNothing);

      final icon = tester.widget<Icon>(find.byIcon(Icons.shield_outlined));
      final colorScheme = Theme.of(
        tester.element(find.byType(StreakCard)),
      ).colorScheme;
      expect(icon.color, colorScheme.primary);
    },
  );

  testWidgets(
    'protected state with a zero current streak never claims a "0-day '
    'streak" is safe',
    (tester) async {
      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 0,
            longestStreak: 4,
            todayStatus: DayStatus.protectedRecovery,
            todaySatisfied: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recovery day'), findsOneWidget);
      expect(
        find.text("Recovery days don't break your streak."),
        findsOneWidget,
      );
      expect(find.textContaining('0-day streak'), findsNothing);
      expect(find.textContaining('is safe'), findsNothing);
    },
  );

  testWidgets(
    'loading provider state renders the quiet shell, not a spinner',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakResultProvider.overrideWith(
              (ref) => const Stream<StreakResult>.empty(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: StreakCard()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Streak'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'tapping "Make today a recovery day" marks the day and shows an '
    'undo snackbar; tapping Undo un-marks it',
    (tester) async {
      final fakeRepository = _FakeRecoveryRepository();

      await tester.pumpWidget(
        buildApp(
          const StreakResult(
            currentStreak: 2,
            longestStreak: 5,
            todayStatus: DayStatus.unscheduled,
            todaySatisfied: false,
          ),
          extraOverrides: [
            recoveryRepositoryProvider.overrideWithValue(fakeRepository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Make today a recovery day'));
      await tester.pumpAndSettle();

      final today = LocalDate.today();
      expect(fakeRepository.calls, ['mark:$today']);
      expect(find.text('Recovery day marked'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(fakeRepository.calls, ['mark:$today', 'unmark:$today']);
    },
  );

  testWidgets(
    'error provider state renders the quiet shell, not error text',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakResultProvider.overrideWith(
              (ref) => Stream<StreakResult>.error('boom'),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: StreakCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Streak'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
      expect(find.textContaining('error'), findsNothing);
      expect(find.textContaining('Error'), findsNothing);
    },
  );
}
