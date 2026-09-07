import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';

/// A started mindful session must open on defaults the picker can actually
/// show as selected. [MindfulStyles] is the single source of truth for both
/// lists, so a default that is not a member of them renders as no chip
/// chosen — and the session saves a focus area the user never picked and
/// cannot see. Pilates used to default to 'Core & Pelvic Floor', which
/// [MindfulStyles.focusAreas] has never offered.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  for (final type in const [ActivityType.yoga, ActivityType.pilates]) {
    test('${type.label} opens on a style and focus area the picker offers', () {
      final c = container();
      c
          .read(mindfulTrackerControllerProvider.notifier)
          .startSessionIfNeeded(type);
      final state = c.read(mindfulTrackerControllerProvider);

      expect(MindfulStyles.stylesFor(type), contains(state.style));
      expect(MindfulStyles.focusAreas, contains(state.focusArea));
    });
  }

  test('pilates defaults to the Core & Spine focus area', () {
    final c = container();
    c
        .read(mindfulTrackerControllerProvider.notifier)
        .startSessionIfNeeded(ActivityType.pilates);

    expect(
      c.read(mindfulTrackerControllerProvider).focusArea,
      'Core & Spine',
    );
  });
}
