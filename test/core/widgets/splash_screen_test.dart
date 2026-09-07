import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/splash_screen.dart';

void main() {
  testWidgets(
    'FemFitSplashScreen renders title, tagline and triggers callback',
    (tester) async {
      var isLoaded = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: FemFitSplashScreen(
            duration: const Duration(milliseconds: 500),
            onLoaded: () {
              isLoaded = true;
            },
          ),
        ),
      );

      // Initial frame
      await tester.pump();
      expect(find.text('FemFit'), findsOneWidget);
      expect(find.text('Empowering Every Stride & Cycle'), findsOneWidget);
      expect(isLoaded, isFalse);

      // Advance past duration
      await tester.pump(const Duration(milliseconds: 600));
      expect(isLoaded, isTrue);
    },
  );
}
