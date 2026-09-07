import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/data/screen_awake_preference_store.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Writes the way the platform actually fails: `setBool` returns `false`
/// rather than throwing (`knowledge/engineering/error_handling.md`). Reads
/// still work, so a test can watch the store refuse to treat that `false`
/// as success.
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
  late ScreenAwakePreferenceStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    store = ScreenAwakePreferenceStore(preferences);
  });

  group('ScreenAwakePreferenceStore', () {
    test('every activity type defaults to on when nothing is stored', () {
      for (final type in ActivityType.values) {
        expect(
          store.isEnabled(type),
          isTrue,
          reason:
              '${type.toStorage()} should default to keeping the screen '
              'awake',
        );
      }
    });

    test('reads back what was written, both ways round', () async {
      await store.setEnabled(ActivityType.run, enabled: false);
      expect(store.isEnabled(ActivityType.run), isFalse);

      await store.setEnabled(ActivityType.run, enabled: true);
      expect(store.isEnabled(ActivityType.run), isTrue);
    });

    test('types do not share a key', () async {
      await store.setEnabled(ActivityType.ride, enabled: false);

      expect(store.isEnabled(ActivityType.ride), isFalse);
      // The point of the setting: a Ride with the phone in a pocket is not
      // a Yoga practice on a mat.
      expect(store.isEnabled(ActivityType.yoga), isTrue);
      expect(store.isEnabled(ActivityType.hiit), isTrue);
    });

    test('stores under the documented per-type key', () async {
      await store.setEnabled(ActivityType.swim, enabled: false);

      expect(preferences.getBool('screen_awake_swim'), isFalse);
      expect(preferences.getBool('screen_awake_run'), isNull);
    });

    test('with no store at all, every type reads as on', () {
      // The shape a widget test lands in when it pumps a tracker without
      // wiring `sharedPreferencesProvider` — see the class doc.
      const none = ScreenAwakePreferenceStore(null);

      for (final type in ActivityType.values) {
        expect(none.isEnabled(type), isTrue);
      }
      expect(
        none.setEnabled(ActivityType.run, enabled: false),
        completes,
      );
    });

    test('a false write is a failure, not silent success', () {
      final failing = ScreenAwakePreferenceStore(_FailingWritePreferences());

      expect(
        () => failing.setEnabled(ActivityType.strength, enabled: false),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
