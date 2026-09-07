import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:menfit_app/features/recaps/recaps_widgets.dart';

/// Tapping a history row builds that period's recap on demand, which is
/// slow enough to be measured in seconds on a long history
/// (`recaps_providers.dart#recapForPeriod`). The row therefore has to say
/// it's working, refuse a second tap while it is, and surface a failure as
/// a message rather than an unhandled async error.
final RecapPeriod _period = RecapPeriod.forMonth(LocalDate(2026, 7, 15));

/// [buildRecap] stands in for the real (slow) recap build and is called
/// afresh on every provider build, so a retry after a failure really does
/// run it again.
Widget _app({required Future<CycleRecap?> Function() buildRecap}) {
  return ProviderScope(
    overrides: [
      recentRecapPeriodsProvider.overrideWith((ref) async => [_period]),
      recapForPeriodProvider(_period).overrideWith((ref) => buildRecap()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: RecapHistorySection()),
    ),
  );
}

Finder get _row => find.byType(ListTile);

/// Dismisses whatever SnackBar is showing deterministically — its
/// auto-dismiss timer lives in the real zone and would still be pending at
/// teardown otherwise (same idiom as `test/features/routes_flow_test.dart`).
Future<void> _clearSnackBars(WidgetTester tester) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .clearSnackBars();
  await tester.pump();
}

void main() {
  testWidgets('a tap shows a progress indicator in place of the chevron '
      'and blocks a second tap', (tester) async {
    final pending = Completer<CycleRecap?>();
    await tester.pumpWidget(_app(buildRecap: () => pending.future));
    await tester.pumpAndSettle();

    expect(find.text('Your July'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(_row);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byIcon(Icons.chevron_right_rounded),
      findsNothing,
      reason: 'the spinner replaces the chevron rather than joining it',
    );
    expect(
      tester.widget<ListTile>(_row).onTap,
      isNull,
      reason: 'a second tap must not start a second build',
    );

    // Sparse period: no story to push, so the row just explains itself and
    // becomes tappable again.
    pending.complete(null);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.textContaining('not quite enough logged'), findsOneWidget);
    expect(tester.widget<ListTile>(_row).onTap, isNotNull);
    expect(tester.takeException(), isNull);

    await _clearSnackBars(tester);
  });

  testWidgets('a failed build surfaces the standard error message and '
      'leaves the row usable', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      _app(
        buildRecap: () async {
          builds++;
          throw const StorageException(message: 'simulated read failure');
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_row);
    await tester.pumpAndSettle();

    final expectedMessage = userMessageFor(
      const StorageException(message: 'simulated read failure'),
    );
    expect(
      find.text(expectedMessage),
      findsOneWidget,
      // Also the guard for `recaps_providers.dart#_noRetry`: with
      // Riverpod 3's default retry policy the provider sits in
      // `AsyncLoading(retrying: true)` behind an exponential backoff
      // instead of completing, so `.future` never resolves, the catch
      // never runs, and this finds nothing.
      reason:
          'the failure reaches the user on the first attempt, not after '
          "Riverpod's ~38s of silent retries",
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'the failure is caught at the tap, never left unhandled',
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<ListTile>(_row).onTap, isNotNull);
    expect(
      builds,
      1,
      reason: 'one tap is one build - nothing is retrying behind it',
    );
    await _clearSnackBars(tester);

    // And the retry the row now invites really re-runs the build rather
    // than resolving straight back out of the provider's cached failure.
    await tester.tap(_row);
    await tester.pumpAndSettle();

    expect(builds, 2);
    expect(find.text(expectedMessage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _clearSnackBars(tester);
  });

  testWidgets('an empty history renders nothing at all', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recentRecapPeriodsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: RecapHistorySection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Cycle in Motion'), findsNothing);
    expect(_row, findsNothing);
  });
}
