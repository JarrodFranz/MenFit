import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_editor/yoga_pose_list.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequence_editor_sheet.dart';

import 'fake_yoga_sequence_repository.dart';

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

  /// Opens the editor the way the app does — through `showAppBottomSheet` —
  /// rather than pumping the widget bare, so `Navigator.pop` on save has a
  /// real route to close.
  Future<void> openEditor(
    WidgetTester tester, {
    YogaSequence? sequence,
    Size surface = const Size(400, 1000),
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
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => YogaSequenceEditorSheet.show(
                    context,
                    sequence: sequence,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Pose names are deliberately absent from `YogaPoseCatalogue.commonPoses`:
  /// a matching name opens the `Autocomplete` options overlay, which floats
  /// over the dialog's own actions and makes "Save pose" unhittable. The
  /// catalogue is exercised on purpose in its own test below.
  Future<void> addPose(
    WidgetTester tester, {
    required String name,
    int? presetHold,
    YogaPoseSide side = YogaPoseSide.none,
  }) async {
    await tester.tap(find.byKey(const Key('yogaAddPoseButton')));
    await tester.pumpAndSettle();

    if (presetHold != null) {
      await tester.tap(find.byKey(ValueKey('yogaHoldPreset_$presetHold')));
      await tester.pumpAndSettle();
    }
    if (side != YogaPoseSide.none) {
      await tester.tap(
        find.text(side == YogaPoseSide.left ? 'Left' : 'Right'),
      );
      await tester.pumpAndSettle();
    }

    await tester.enterText(find.byKey(const Key('yogaPoseNameField')), name);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save pose'));
    await tester.pumpAndSettle();
  }

  List<YogaPose> posesOnScreen(WidgetTester tester) =>
      tester.widget<YogaPoseList>(find.byType(YogaPoseList)).poses;

  FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const Key('yogaSequenceSaveButton')),
  );

  YogaSequence seeded() => YogaSequence.create(
    name: 'Evening unwind',
    description: 'Slower floor work',
    style: 'Yin',
    // Deliberately not the default 5, so the total-duration
    // assertions below would fail if the transition were ignored.
    transitionSeconds: 10,
    poses: const [
      YogaPose(name: 'Long fold', holdSeconds: 45),
      YogaPose(name: 'Deep twist', holdSeconds: 30),
      YogaPose(name: 'Final rest', holdSeconds: 60),
    ],
  );

  testWidgets('opens titled "New sequence" with an empty form', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('New sequence'), findsOneWidget);
    expect(find.text('Poses (0)'), findsOneWidget);
    expect(find.text('Total 00:00'), findsOneWidget);
  });

  testWidgets('adds a pose through the dialog with a preset hold', (
    tester,
  ) async {
    await openEditor(tester);

    await addPose(tester, name: 'Long twist', presetHold: 45);

    expect(find.text('Poses (1)'), findsOneWidget);
    expect(find.text('Long twist'), findsOneWidget);
    expect(find.text('45s hold'), findsOneWidget);
    // One pose, so no transition is counted.
    expect(find.text('Total 00:45'), findsOneWidget);
    expect(posesOnScreen(tester).single.holdSeconds, 45);
  });

  testWidgets('the pose name field autocompletes over the catalogue', (
    tester,
  ) async {
    await openEditor(tester);
    await tester.tap(find.byKey(const Key('yogaAddPoseButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('yogaPoseNameField')), 'warr');
    await tester.pumpAndSettle();

    expect(find.text('Warrior I'), findsOneWidget);
    expect(find.text('Warrior II'), findsOneWidget);
  });

  testWidgets('every pose row offers a drag handle, and reordering '
      'changes the order', (tester) async {
    await openEditor(tester, sequence: seeded());

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));

    // The reorder callback is invoked directly rather than through a
    // synthesised drag: `onReorderItem`'s index arithmetic is what this
    // asserts, and a pointer-level drag on a `ReorderableListView` inside a
    // `DraggableScrollableSheet` is a test of the drag recogniser, not of
    // the editor.
    tester.widget<YogaPoseList>(find.byType(YogaPoseList)).onReorder(0, 2);
    await tester.pumpAndSettle();

    expect(
      posesOnScreen(tester).map((p) => p.name).toList(),
      ['Deep twist', 'Final rest', 'Long fold'],
    );
  });

  testWidgets('a pose can be removed', (tester) async {
    await openEditor(tester, sequence: seeded());

    await tester.tap(find.byTooltip('Remove Deep twist'));
    await tester.pumpAndSettle();

    expect(
      posesOnScreen(tester).map((p) => p.name).toList(),
      ['Long fold', 'Final rest'],
    );
    expect(find.text('Poses (2)'), findsOneWidget);
  });

  testWidgets('duplicate-for-other-side mirrors the side and inserts after', (
    tester,
  ) async {
    await openEditor(tester);
    await addPose(
      tester,
      name: 'Side stretch',
      presetHold: 30,
      side: YogaPoseSide.left,
    );

    // Only a one-sided pose gets the affordance.
    await tester.tap(
      find.byTooltip('Duplicate Side stretch, left for the other side'),
    );
    await tester.pumpAndSettle();

    final poses = posesOnScreen(tester);
    expect(poses, hasLength(2));
    expect(poses[0].side, YogaPoseSide.left);
    expect(poses[1].side, YogaPoseSide.right);
    expect(poses[1].name, 'Side stretch');
    expect(poses[1].holdSeconds, 30);
    expect(find.text('Side stretch, right'), findsOneWidget);
  });

  testWidgets('a pose with no side has no duplicate affordance', (
    tester,
  ) async {
    await openEditor(tester);
    await addPose(tester, name: 'Long twist', presetHold: 30);

    expect(find.byIcon(Icons.flip), findsNothing);
  });

  testWidgets('Save is disabled until valid, showing the first problem', (
    tester,
  ) async {
    await openEditor(tester);

    expect(saveButton(tester).onPressed, isNull);
    expect(find.text('Give the sequence a name.'), findsOneWidget);
    // One problem at a time: the pose complaint waits its turn.
    expect(find.text('Add at least one pose.'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('yogaSequenceNameField')),
      'Evening unwind',
    );
    await tester.pumpAndSettle();

    expect(saveButton(tester).onPressed, isNull);
    expect(find.text('Add at least one pose.'), findsOneWidget);

    await addPose(tester, name: 'Long twist', presetHold: 30);

    expect(saveButton(tester).onPressed, isNotNull);
    expect(find.text('Add at least one pose.'), findsNothing);
  });

  testWidgets('the saved sequence matches the form', (tester) async {
    await openEditor(tester);

    await tester.enterText(
      find.byKey(const Key('yogaSequenceNameField')),
      'Evening unwind',
    );
    await tester.enterText(
      find.byKey(const Key('yogaSequenceDescriptionField')),
      'Slower floor work',
    );
    await tester.tap(find.byKey(const ValueKey('yogaEditorStyle_Yin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('yogaEditorTransition_3')));
    await tester.pumpAndSettle();

    await addPose(tester, name: 'Long fold', presetHold: 60);
    await addPose(tester, name: 'Final rest', presetHold: 90);

    // 60 + 90 holds plus one 3s transition.
    expect(find.text('Total 02:33'), findsOneWidget);

    await tester.tap(find.byKey(const Key('yogaSequenceSaveButton')));
    await tester.pumpAndSettle();

    final saved = repository.sequences.single;
    expect(saved.name, 'Evening unwind');
    expect(saved.description, 'Slower floor work');
    expect(saved.style, 'Yin');
    expect(saved.transitionSeconds, 3);
    expect(saved.poses.map((p) => p.name).toList(), [
      'Long fold',
      'Final rest',
    ]);
    expect(saved.poses.map((p) => p.holdSeconds).toList(), [60, 90]);
    expect(find.text('Saved "Evening unwind"'), findsOneWidget);
    // The sheet closed behind the snackbar.
    expect(find.text('New sequence'), findsNothing);
  });

  testWidgets('a deselected style is cleared, not silently kept', (
    tester,
  ) async {
    final existing = seeded();
    await openEditor(tester, sequence: existing);

    await tester.tap(find.byKey(const ValueKey('yogaEditorStyle_Yin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('yogaSequenceSaveButton')));
    await tester.pumpAndSettle();

    expect(repository.sequences.single.style, isNull);
  });

  testWidgets('edit mode pre-fills, keeps the id and bumps updatedAt', (
    tester,
  ) async {
    final existing = seeded();
    await openEditor(tester, sequence: existing);

    expect(find.text('Edit sequence'), findsOneWidget);
    expect(find.text('Evening unwind'), findsOneWidget);
    expect(find.text('Poses (3)'), findsOneWidget);
    // 45 + 30 + 60 holds plus two 10s transitions.
    expect(find.text('Total 02:35'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('yogaSequenceNameField')),
      'Evening unwind v2',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('yogaSequenceSaveButton')));
    await tester.pumpAndSettle();

    final saved = repository.sequences.single;
    expect(saved.id, existing.id);
    expect(saved.name, 'Evening unwind v2');
    expect(saved.createdAt, existing.createdAt);
    expect(
      saved.updatedAt.isAfter(existing.updatedAt) ||
          saved.updatedAt.isAtSameMomentAs(existing.updatedAt),
      isTrue,
    );
    expect(saved.poses, existing.poses);
  });

  testWidgets('survives 320dp at 150% text without overflowing', (
    tester,
  ) async {
    await openEditor(
      tester,
      sequence: seeded(),
      surface: const Size(320, 1200),
      textScaler: const TextScaler.linear(1.5),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed save says so and leaves Save usable', (tester) async {
    repository.failWrites = true;
    await openEditor(tester, sequence: seeded());

    await tester.tap(find.byKey(const Key('yogaSequenceSaveButton')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Something went wrong saving your data. Please try '
        'again.',
      ),
      findsOneWidget,
    );
    // The sheet is still open on the draft they typed...
    expect(find.text('Edit sequence'), findsOneWidget);
    // ...and Save is a button again, not a permanently dead one.
    expect(saveButton(tester).onPressed, isNotNull);

    repository.failWrites = false;
    await tester.tap(find.byKey(const Key('yogaSequenceSaveButton')));
    await tester.pumpAndSettle();

    expect(repository.sequences, hasLength(1));
    expect(find.text('Edit sequence'), findsNothing);
  });
}
