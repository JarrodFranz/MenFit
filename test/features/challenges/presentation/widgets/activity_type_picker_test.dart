import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/activity_type_picker.dart';

void main() {
  group('ActivityTypePicker', () {
    testWidgets('renders chips with showCheckmark set to false', (
      tester,
    ) async {
      ActivityType? toggled;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ActivityTypePicker(
              selected: const {ActivityType.run},
              onToggle: (type) => toggled = type,
            ),
          ),
        ),
      );

      final chipFinder = find.byType(FilterChip);
      expect(chipFinder, findsWidgets);

      final runChip = tester.widget<FilterChip>(
        find.byKey(const Key('challengeActivityChip_run')),
      );
      expect(runChip.showCheckmark, isFalse);
      expect(runChip.selected, isTrue);

      // Tap walk chip
      await tester.tap(find.byKey(const Key('challengeActivityChip_walk')));
      expect(toggled, ActivityType.walk);
    });
  });
}
