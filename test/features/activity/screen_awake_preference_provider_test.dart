import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/data/screen_awake_preference_store.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads normally, refuses every write the way the platform does — a
/// `false` return rather than a throw.
class _FailingWritePreferences implements SharedPreferences {
  final Map<String, bool> values = {};

  @override
  bool? getBool(String key) => values[key];

  @override
  Future<bool> setBool(String key, bool value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unexpected ${invocation.memberName}');
}

void main() {
  late SharedPreferences preferences;

  ProviderContainer containerWith(SharedPreferences prefs) {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  group('screenAwakePreferenceProvider', () {
    test('builds from the store, defaulting to on', () {
      final container = containerWith(preferences);

      expect(
        container.read(screenAwakePreferenceProvider(ActivityType.run)),
        isTrue,
      );
    });

    test('builds from what is already stored', () async {
      await ScreenAwakePreferenceStore(
        preferences,
      ).setEnabled(ActivityType.hiit, enabled: false);
      final container = containerWith(preferences);

      expect(
        container.read(screenAwakePreferenceProvider(ActivityType.hiit)),
        isFalse,
      );
    });

    test('set() flips the value and persists it', () async {
      final container = containerWith(preferences);
      final provider = screenAwakePreferenceProvider(ActivityType.yoga);

      await container.read(provider.notifier).set(enabled: false);

      expect(container.read(provider), isFalse);
      expect(preferences.getBool('screen_awake_yoga'), isFalse);
    });

    test('each type is its own instance of the family', () async {
      final container = containerWith(preferences);

      await container
          .read(screenAwakePreferenceProvider(ActivityType.swim).notifier)
          .set(enabled: false);

      expect(
        container.read(screenAwakePreferenceProvider(ActivityType.swim)),
        isFalse,
      );
      expect(
        container.read(screenAwakePreferenceProvider(ActivityType.run)),
        isTrue,
      );
    });

    test('a failed write puts the switch back and rethrows', () async {
      // A switch that stays where she left it while nothing was saved is
      // worse than one that springs back: next session would silently
      // disagree with what the hub shows.
      final container = containerWith(_FailingWritePreferences());
      final provider = screenAwakePreferenceProvider(ActivityType.pilates);
      expect(container.read(provider), isTrue);

      await expectLater(
        container.read(provider.notifier).set(enabled: false),
        throwsA(isA<StorageException>()),
      );
      expect(container.read(provider), isTrue);
    });
  });

  group('screenAwakePreferenceStoreProvider', () {
    test('degrades when preferences were never wired, as widget tests are', () {
      // Every tracker reaches this on start; a widget test that pumps one
      // without wiring SharedPreferences must get defaults, not a crash.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final store = container.read(screenAwakePreferenceStoreProvider);

      expect(store.isEnabled(ActivityType.run), isTrue);
    });

    test('a real failure is not swallowed as "no preferences"', () {
      // Riverpod 3 wraps a dependency's error in a ProviderException before
      // rethrowing it, so the narrowing here has to unwrap: `on Object`
      // would turn any genuine SharedPreferences failure into an app that
      // silently forgets every switch.
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith(
            (ref) => throw StateError('preferences unavailable'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(screenAwakePreferenceStoreProvider),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('preferences unavailable'),
            'carries the original failure rather than degrading',
          ),
        ),
      );
    });
  });
}
