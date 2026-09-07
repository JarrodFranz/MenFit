import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:menfit_app/features/progress/presentation/widgets/stat_tiles_row.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<void> pumpAt360(
    WidgetTester tester,
    List<WeeklySummary> summaries,
  ) async {
    // 360dp-wide is a common narrow-phone width - the three tiles below
    // (with the row's inter-tile spacing) land right around the ~98dp
    // per-tile width this wave's brief calls out.
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: StatTilesRow(
              summaries: summaries,
              unitSystem: UnitSystem.metric,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'at a 360dp-wide surface, a large delta renders compactly with no '
    'overflow (F6)',
    (tester) async {
      final thisWeekMonday = mondayOf(LocalDate.today());
      final lastWeekMonday = thisWeekMonday.addDays(-7);
      final summaries = [
        WeeklySummary(
          weekStart: lastWeekMonday,
          distanceMeters: 5000,
          movingTime: const Duration(minutes: 30),
          activityCount: 2,
        ),
        WeeklySummary(
          weekStart: thisWeekMonday,
          // A big jump - the previous "+12.40 km vs last week" phrasing
          // would not fit an ~98dp tile at all.
          distanceMeters: 17400,
          movingTime: const Duration(hours: 1, minutes: 47),
          activityCount: 5,
        ),
      ];

      await pumpAt360(tester, summaries);

      expect(tester.takeException(), isNull);

      // Compact delta text, visible on screen, plus this week's own
      // one-decimal value line (F6).
      expect(find.text('▲ 12.4 km'), findsOneWidget);
      expect(find.text('17.4 km'), findsOneWidget);

      // The full "vs last week" phrasing still exists, just as a tooltip.
      expect(find.byTooltip('+12.4 km vs last week'), findsOneWidget);
    },
  );

  testWidgets(
    'a "same as last week" delta renders as a compact neutral marker, no '
    'overflow',
    (tester) async {
      final thisWeekMonday = mondayOf(LocalDate.today());
      final lastWeekMonday = thisWeekMonday.addDays(-7);
      final summaries = [
        WeeklySummary(
          weekStart: lastWeekMonday,
          distanceMeters: 5000,
          movingTime: const Duration(minutes: 30),
          activityCount: 2,
        ),
        WeeklySummary(
          weekStart: thisWeekMonday,
          distanceMeters: 5000,
          movingTime: const Duration(minutes: 30),
          activityCount: 2,
        ),
      ];

      await pumpAt360(tester, summaries);

      expect(tester.takeException(), isNull);
      expect(find.text('· same'), findsNWidgets(3));
    },
  );
}
