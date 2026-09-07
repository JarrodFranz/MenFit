import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_screen.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequences_card.dart';

import '../../../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'fake_yoga_sequence_repository.dart';

class _FakeLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

void main() {
  late FakeYogaSequenceRepository repository;

  setUp(() {
    repository = FakeYogaSequenceRepository();
  });

  tearDown(() async {
    await repository.dispose();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// The card on its own: no Drift, so no drift timers to flush.
  Future<void> pumpCard(
    WidgetTester tester, {
    Size surface = const Size(400, 900),
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    tester.view
      ..physicalSize = surface
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          yogaSequenceRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: YogaSequencesCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('YogaSequencesCard', () {
    testWidgets('titles itself and says what a sequence is', (tester) async {
      await pumpCard(tester);

      expect(find.text('Sequences'), findsOneWidget);
      expect(
        find.text('Poses with timed holds and a chime between them'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('yogaNewSequenceButton')), findsOneWidget);
    });

    testWidgets('an empty list offers both starters', (tester) async {
      await pumpCard(tester);

      expect(find.text('Add Morning flow'), findsOneWidget);
      expect(find.text('Add Wind down'), findsOneWidget);
      // The starters themselves are never rows.
      expect(repository.sequences, isEmpty);
    });

    testWidgets('adding a starter saves a COPY, not the starter', (
      tester,
    ) async {
      await pumpCard(tester);

      await tester.tap(find.text('Add Morning flow'));
      await tester.pumpAndSettle();

      expect(repository.sequences, hasLength(1));
      final saved = repository.sequences.single;
      expect(saved.name, 'Morning flow');
      expect(
        saved.id,
        isNot(YogaSequenceStarters.morningFlowId),
        reason: 'A starter id must never reach the database.',
      );
      expect(saved.poses, YogaSequenceStarters.morningFlow.poses);
      expect(saved.style, YogaSequenceStarters.morningFlow.style);
      expect(find.text('Added "Morning flow"'), findsOneWidget);
    });

    testWidgets('a listed sequence shows "N poses · mm:ss"', (tester) async {
      repository.seed([
        YogaSequence.create(
          name: 'Evening unwind',
          style: 'Yin',
          // Not the default 5: the summary must actually add the gaps.
          transitionSeconds: 10,
          poses: const [
            YogaPose(name: "Child's Pose", holdSeconds: 60),
            YogaPose(name: 'Cat-Cow', holdSeconds: 45),
            YogaPose(name: 'Supine Twist', holdSeconds: 40),
          ],
        ),
      ]);

      await pumpCard(tester);

      expect(find.text('Evening unwind'), findsOneWidget);
      // 60 + 45 + 40 holds, plus two 10s transitions = 165s.
      expect(find.text('3 poses · 02:45'), findsOneWidget);
      expect(find.text('Yin'), findsOneWidget);
      expect(find.text('Practise'), findsOneWidget);
      // The starter offer is gone once she has one of her own.
      expect(find.text('Add Morning flow'), findsNothing);
    });

    testWidgets('one pose reads "1 pose", not "1 poses"', (tester) async {
      repository.seed([
        YogaSequence.create(
          name: 'Just a hold',
          poses: const [YogaPose(name: 'Legs Up the Wall', holdSeconds: 300)],
        ),
      ]);

      await pumpCard(tester);

      // A single pose has no transition after it.
      expect(find.text('1 pose · 05:00'), findsOneWidget);
    });

    testWidgets('delete asks first, then offers Undo that restores the row', (
      tester,
    ) async {
      final sequence = YogaSequence.create(
        name: 'Evening unwind',
        poses: const [YogaPose(name: 'Cat-Cow', holdSeconds: 45)],
      );
      repository.seed([sequence]);

      await pumpCard(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this sequence?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.sequences, isEmpty);
      expect(find.text('Deleted "Evening unwind"'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(repository.sequences, hasLength(1));
      expect(
        repository.sequences.single.id,
        sequence.id,
        reason: 'Undo restores the row, it does not make a near-copy.',
      );
    });

    /// `userMessageFor(StorageException)`.
    const storageMessage =
        'Something went wrong saving your data. Please try again.';

    testWidgets('a starter that fails to save says so', (tester) async {
      repository.failWrites = true;
      await pumpCard(tester);

      await tester.tap(find.text('Add Morning flow'));
      await tester.pumpAndSettle();

      expect(find.text(storageMessage), findsOneWidget);
      // Not the success line: the row does not exist.
      expect(find.text('Added "Morning flow"'), findsNothing);
      expect(repository.sequences, isEmpty);
    });

    testWidgets('a delete that fails says so instead of claiming success', (
      tester,
    ) async {
      final sequence = YogaSequence.create(
        name: 'Evening unwind',
        poses: const [YogaPose(name: 'Cat-Cow', holdSeconds: 45)],
      );
      repository.seed([sequence]);
      await pumpCard(tester);
      repository.failWrites = true;

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text(storageMessage), findsOneWidget);
      expect(find.text('Deleted "Evening unwind"'), findsNothing);
      expect(repository.sequences, hasLength(1));
    });

    testWidgets('an Undo that fails says so rather than lying', (tester) async {
      final sequence = YogaSequence.create(
        name: 'Evening unwind',
        poses: const [YogaPose(name: 'Cat-Cow', holdSeconds: 45)],
      );
      repository.seed([sequence]);
      await pumpCard(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(repository.sequences, isEmpty);

      // The restore is the write that fails; she has already been told the
      // sequence is gone, so a silent failure here reads as "restored".
      repository.failWrites = true;
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text(storageMessage), findsOneWidget);
      expect(repository.sequences, isEmpty);
    });

    testWidgets('survives 320dp at 150% text without overflowing', (
      tester,
    ) async {
      repository.seed([
        YogaSequence.create(
          name: 'A deliberately long sequence name for the narrow case',
          style: 'Restorative',
          poses: const [
            YogaPose(
              name: 'Reclined Butterfly',
              holdSeconds: 90,
              side: YogaPoseSide.left,
            ),
            YogaPose(name: 'Corpse Pose (Savasana)', holdSeconds: 120),
          ],
        ),
      ]);

      await pumpCard(
        tester,
        surface: const Size(320, 1600),
        textScaler: const TextScaler.linear(1.5),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Yoga hub', () {
    late db.AppDatabase database;

    setUp(() {
      database = db.AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> pumpHub(WidgetTester tester, ActivityType type) async {
      tester.view
        ..physicalSize = const Size(420, 2400)
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
            yogaSequenceRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: ExerciseHubScreen(type: type),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows all seven yoga styles and the Sequences card', (
      tester,
    ) async {
      await pumpHub(tester, ActivityType.yoga);

      for (final style in MindfulStyles.yogaStyles) {
        expect(
          find.byKey(ValueKey('mindfulStyleChip_$style')),
          findsOneWidget,
          reason: '$style has no chip on the Yoga hub.',
        );
      }
      expect(find.byType(YogaSequencesCard), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('pilates gets its five styles and no Sequences card', (
      tester,
    ) async {
      await pumpHub(tester, ActivityType.pilates);

      for (final style in MindfulStyles.pilatesStyles) {
        expect(
          find.byKey(ValueKey('mindfulStyleChip_$style')),
          findsOneWidget,
        );
      }
      expect(find.byType(YogaSequencesCard), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('with no history the style tile is honest, not "Flow"', (
      tester,
    ) async {
      await pumpHub(tester, ActivityType.yoga);

      expect(find.text('Most practised style'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Flow'), findsNothing);

      await flushDriftTimers(tester);
    });
  });
}
