import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/safety/domain/safety_checkin_engine.dart';
import 'package:menfit_app/features/safety/presentation/widgets/safety_warning_dialog.dart';

void main() {
  group('SafetyWarningDialog', () {
    testWidgets('renders inactivity warning content and handles callbacks', (
      tester,
    ) async {
      var dismissed = false;
      var triggeredSos = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SafetyWarningDialog(
              reason: SafetyAlertReason.inactivity,
              secondsRemaining: 42,
              onDismissSafe: () => dismissed = true,
              onTriggerSos: () => triggeredSos = true,
            ),
          ),
        ),
      );

      expect(find.text('Are You OK?'), findsOneWidget);
      expect(find.text('42s'), findsOneWidget);
      expect(
        find.text(
          'FemFit noticed you have stopped moving for several minutes.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text("I'm OK — Continue Workout"));
      expect(dismissed, isTrue);

      await tester.tap(find.text('Send Emergency SOS Now'));
      expect(triggeredSos, isTrue);
    });

    testWidgets('renders check-in deadline content with extend button', (
      tester,
    ) async {
      var extended = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SafetyWarningDialog(
              reason: SafetyAlertReason.checkinDeadline,
              secondsRemaining: 30,
              onDismissSafe: () {},
              onTriggerSos: () {},
              onExtendDeadline: () => extended = true,
            ),
          ),
        ),
      );

      expect(find.text('Check-in Overdue'), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
      expect(find.text('Add 15 Minutes to Check-in'), findsOneWidget);

      await tester.tap(find.text('Add 15 Minutes to Check-in'));
      expect(extended, isTrue);
    });
  });
}
