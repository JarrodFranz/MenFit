import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_screen.dart';

void main() {
  testWidgets('CycleScreen renders error state and Try Again button', (
    tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cycleRecordsControllerProvider.overrideWith(
            () => _FailingCycleRecordsController(onRetry: () => retryCount++),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const CycleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cycleRetryButton')), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(retryCount, 1);

    await tester.tap(find.byKey(const Key('cycleRetryButton')));
    await tester.pumpAndSettle();

    expect(retryCount, 2);
  });
}

class _FailingCycleRecordsController extends CycleRecordsController {
  _FailingCycleRecordsController({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Stream<List<CycleRecord>> build() {
    onRetry();
    return Stream.error(StateError('Simulated cycle records failure'));
  }
}
