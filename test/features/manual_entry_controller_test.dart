import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_controller.dart';
import 'package:menfit_app/features/activity/presentation/mindful_style_options.dart';

class _FakeActivityRepository implements ActivityRepository {
  final List<Activity> saved = [];
  final _controller = StreamController<List<Activity>>.broadcast();

  @override
  Stream<List<Activity>> watchActivities() async* {
    yield saved;
    yield* _controller.stream;
  }

  @override
  Future<List<Activity>> getActivities() async => List.of(saved);

  @override
  Stream<Activity?> watchActivity(String id) {
    return watchActivities().map((list) {
      final matches = list.where((a) => a.id == id);
      return matches.isEmpty ? null : matches.first;
    });
  }

  @override
  Future<Activity?> getActivity(String id) async {
    final matches = saved.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<void> saveActivity(Activity activity) async {
    saved
      ..removeWhere((a) => a.id == activity.id)
      ..add(activity);
    _controller.add(List.of(saved));
  }

  @override
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  ) async {
    await saveActivity(activity);
    await insertSamples(samples);
  }

  @override
  Future<void> deleteActivity(String id) async {
    saved.removeWhere((a) => a.id == id);
    _controller.add(List.of(saved));
  }

  @override
  Future<void> insertSamples(List<ActivitySample> samples) async {}

  @override
  Stream<List<ActivitySample>> watchSamples(String activityId) =>
      const Stream.empty();

  @override
  Future<List<ActivitySample>> getSamples(String activityId) async => [];

  @override
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> ids,
  ) async => const {};

  @override
  Future<void> deleteAllData() async {
    saved.clear();
    _controller.add(List.of(saved));
  }

  Future<void> close() => _controller.close();
}

void main() {
  late _FakeActivityRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeActivityRepository();
    container = ProviderContainer(
      overrides: [activityRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(repository.close);
  });

  ManualEntryController controller() =>
      container.read(manualEntryControllerProvider.notifier);

  void fillValidForm() {
    controller()
      ..updateHours(0)
      ..updateMinutes(30)
      ..updateSeconds(0)
      ..updateDistanceInput('5.0');
  }

  group('validation', () {
    test('a future startedAt is rejected with dateTimeError set', () async {
      fillValidForm();
      final notifier = controller()
        ..updateStartedAt(DateTime.now().add(const Duration(days: 1)));

      final result = await notifier.save(UnitSystem.metric);

      expect(result, isFalse);
      expect(
        container.read(manualEntryControllerProvider).dateTimeError,
        isNotNull,
      );
      expect(repository.saved, isEmpty);
    });

    test(
      'a zero (default) duration is rejected with durationError set',
      () async {
        final notifier = controller()..updateDistanceInput('5.0');
        // Duration is left at its default 0h 0m 0s.

        final result = await notifier.save(UnitSystem.metric);

        expect(result, isFalse);
        expect(
          container.read(manualEntryControllerProvider).durationError,
          isNotNull,
        );
        expect(repository.saved, isEmpty);
      },
    );

    test(
      'an unparseable distance is rejected with distanceError set',
      () async {
        final notifier = controller()
          ..updateHours(0)
          ..updateMinutes(30)
          ..updateSeconds(0)
          ..updateDistanceInput('not a number');

        final result = await notifier.save(UnitSystem.metric);

        expect(result, isFalse);
        expect(
          container.read(manualEntryControllerProvider).distanceError,
          isNotNull,
        );
        expect(repository.saved, isEmpty);
      },
    );

    test('a negative distance is rejected with distanceError set', () async {
      final notifier = controller()
        ..updateHours(0)
        ..updateMinutes(30)
        ..updateSeconds(0)
        ..updateDistanceInput('-5');

      final result = await notifier.save(UnitSystem.metric);

      expect(result, isFalse);
      expect(
        container.read(manualEntryControllerProvider).distanceError,
        isNotNull,
      );
    });

    test('distance parses correctly under the metric unit system', () async {
      fillValidForm(); // distanceInput '5.0'

      await controller().save(UnitSystem.metric);

      expect(repository.saved.single.distanceMeters, closeTo(5000, 0.001));
    });

    test('distance parses correctly under the imperial unit system', () async {
      final notifier = controller()
        ..updateHours(0)
        ..updateMinutes(30)
        ..updateSeconds(0)
        ..updateDistanceInput('5.0'); // 5 miles

      await notifier.save(UnitSystem.imperial);

      // 5 miles -> 5 * 1.609344 km -> * 1000 m.
      expect(
        repository.saved.single.distanceMeters,
        closeTo(5 * 1.609344 * 1000, 0.01),
      );
    });
  });

  group('successful save', () {
    test('a valid form persists an activity via the repository', () async {
      fillValidForm();
      final notifier = controller()
        ..updateTitle('Long run')
        ..updateNotes('Felt good');

      final result = await notifier.save(UnitSystem.metric);

      expect(result, isTrue);
      expect(container.read(manualEntryControllerProvider).didSave, isTrue);
      expect(repository.saved, hasLength(1));
      final saved = repository.saved.single;
      expect(saved.title, 'Long run');
      expect(saved.notes, 'Felt good');
      expect(saved.movingTime, const Duration(minutes: 30));
      expect(saved.elapsedTime, const Duration(minutes: 30));
      expect(saved.source, ActivitySource.manual);
      expect(saved.id, isNotEmpty);
    });

    test('a blank title falls back to a time-of-day default', () async {
      fillValidForm();
      final notifier = controller()
        ..updateStartedAt(DateTime(2026, 1, 1, 7)) // 7am -> Morning
        ..updateActivityType(ActivityType.walk);

      await notifier.save(UnitSystem.metric);

      expect(repository.saved.single.title, 'Morning Walk');
    });

    test('blank notes are stored as null, not an empty string', () async {
      fillValidForm();

      await controller().save(UnitSystem.metric);

      expect(repository.saved.single.notes, isNull);
    });
  });

  group('editing an activity with a legacy mindful style', () {
    // MindfulStyles' vocabulary has been renamed at least once (the hub
    // used to offer 'Restorative Yin' as one chip; MindfulStyles now
    // offers 'Restorative' and 'Yin' separately). style/focusArea are
    // free-form persisted strings, so an activity saved under the old
    // label must still load and show that label — never silently drop or
    // remap it.
    test(
      'loadForEdit preserves a style the current list no longer offers '
      "('Restorative Yin')",
      () {
        final legacyActivity = Activity(
          id: 'legacy-1',
          activityType: ActivityType.yoga,
          title: 'Evening Yoga',
          startedAt: DateTime.utc(2026, 1, 1, 18),
          movingTime: const Duration(minutes: 45),
          elapsedTime: const Duration(minutes: 45),
          distanceMeters: 0,
          source: ActivitySource.manual,
          createdAt: DateTime.utc(2026, 1, 1, 18),
          updatedAt: DateTime.utc(2026, 1, 1, 18),
          workoutDetails: const MindfulWorkoutDetails(
            style: 'Restorative Yin',
            focusArea: 'Hips & Spine',
          ),
        );

        controller().loadForEdit(legacyActivity, UnitSystem.metric);
        final state = container.read(manualEntryControllerProvider);

        expect(state.mindfulStyle, 'Restorative Yin');
        expect(state.mindfulFocusArea, 'Hips & Spine');
        // The screen's chip list must still offer the saved value,
        // appended, rather than dropping or remapping it (see
        // mindful_style_options.dart).
        expect(
          mindfulStyleChoices(state.activityType, state.mindfulStyle),
          contains('Restorative Yin'),
        );
        expect(
          mindfulFocusAreaChoices(state.mindfulFocusArea),
          contains('Hips & Spine'),
        );
      },
    );

    test('saving without changing the style keeps the legacy label', () async {
      final legacyActivity = Activity(
        id: 'legacy-2',
        activityType: ActivityType.yoga,
        title: 'Evening Yoga',
        startedAt: DateTime.utc(2026, 1, 1, 18),
        movingTime: const Duration(minutes: 45),
        elapsedTime: const Duration(minutes: 45),
        distanceMeters: 0,
        source: ActivitySource.manual,
        createdAt: DateTime.utc(2026, 1, 1, 18),
        updatedAt: DateTime.utc(2026, 1, 1, 18),
        workoutDetails: const MindfulWorkoutDetails(
          style: 'Restorative Yin',
          focusArea: 'Hips & Spine',
        ),
      );
      await repository.saveActivity(legacyActivity);

      final notifier = controller()
        ..loadForEdit(legacyActivity, UnitSystem.metric);
      await notifier.save(UnitSystem.metric);

      final saved = repository.saved.single.workoutDetails;
      expect(saved, isA<MindfulWorkoutDetails>());
      final details = saved! as MindfulWorkoutDetails;
      expect(details.style, 'Restorative Yin');
      expect(details.focusArea, 'Hips & Spine');
    });
  });

  group('changing the activity type', () {
    test('clears a yoga style when the entry becomes Pilates', () {
      controller()
        ..updateActivityType(ActivityType.yoga)
        ..updateMindfulStyle('Vinyasa')
        ..updateActivityType(ActivityType.pilates);

      final state = container.read(manualEntryControllerProvider);
      expect(state.activityType, ActivityType.pilates);
      expect(
        state.mindfulStyle,
        isEmpty,
        reason: 'A Pilates entry must not show Vinyasa as chosen.',
      );
      // And with nothing chosen, no chip is preselected and none is blank.
      final choices = mindfulStyleChoices(
        state.activityType,
        state.mindfulStyle,
      );
      expect(choices, MindfulStyles.pilatesStyles);
      expect(choices.contains(state.mindfulStyle), isFalse);
    });

    test('clears the default style too — it was never chosen', () {
      // A fresh form defaults to 'Vinyasa'; arriving on the Pilates hub
      // through setInitialType must not carry it in.
      controller().setInitialType(ActivityType.pilates);

      expect(
        container.read(manualEntryControllerProvider).mindfulStyle,
        isEmpty,
      );
    });

    test('keeps a style the new type also offers', () {
      controller()
        ..updateMindfulStyle('Yin')
        ..updateActivityType(ActivityType.yoga);

      expect(
        container.read(manualEntryControllerProvider).mindfulStyle,
        'Yin',
      );
    });

    test('keeps a legacy label belonging to neither vocabulary', () {
      controller()
        ..updateMindfulStyle('Restorative Yin')
        ..updateActivityType(ActivityType.pilates);

      expect(
        container.read(manualEntryControllerProvider).mindfulStyle,
        'Restorative Yin',
      );
    });

    test('leaves the focus area alone — both types share one list', () {
      controller()
        ..updateMindfulFocusArea('Hip Opening')
        ..updateActivityType(ActivityType.pilates);

      expect(
        container.read(manualEntryControllerProvider).mindfulFocusArea,
        'Hip Opening',
      );
    });
  });
}
