import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/keto_providers.dart';
import 'package:menfit_app/features/keto/presentation/keto_screen.dart';
import 'package:menfit_app/features/keto/presentation/ketone_reading_dialog.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

void main() {
  final futureDay = LocalDate.today().addDays(30);

  Future<void> verifyPickerAndCancel(WidgetTester tester) async {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.initialDate, DateUtils.dateOnly(DateTime.now()));
    expect(picker.lastDate, picker.initialDate);
    await tester.tap(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('screen picker tolerates a selected day after clock rollback', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedNutritionDayProvider.overrideWith(
            () => _FutureSelectedDay(futureDay),
          ),
          ketoneReadingsProvider.overrideWith(
            (ref, day) => Stream.value(<KetoneReading>[]),
          ),
          dayNutritionTotalsProvider.overrideWith(
            (ref, day) => Stream.value(DayNutritionTotals.empty()),
          ),
          nutritionGoalsProvider.overrideWith((ref) => Stream.value(null)),
          dayCalorieTargetProvider.overrideWithValue(const DayCalorieTarget()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const KetoScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(futureDay.toIso()));
    await verifyPickerAndCancel(tester);
    expect(find.text(futureDay.toIso()), findsOneWidget);
  });

  testWidgets('editor picker cancel preserves an archived future day', (
    tester,
  ) async {
    final stamp = DateTime.utc(futureDay.year, futureDay.month, futureDay.day);
    final reading = KetoneReading(
      id: 'clock-skew-reading',
      day: futureDay,
      measuredAt: stamp,
      type: KetoneMeasurementType.blood,
      result: '0.10',
      createdAt: stamp,
      updatedAt: stamp,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: KetoneReadingDialog(day: futureDay, existing: reading),
          ),
        ),
      ),
    );
    final dateLabel = 'Date: ${futureDay.toIso()}';
    await tester.ensureVisible(find.text(dateLabel));
    await tester.tap(find.text(dateLabel));
    await verifyPickerAndCancel(tester);
    expect(find.text(dateLabel), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '0.10',
    );
  });
}

class _FutureSelectedDay extends SelectedNutritionDay {
  _FutureSelectedDay(this.day);

  final LocalDate day;

  @override
  LocalDate build() => day;
}
