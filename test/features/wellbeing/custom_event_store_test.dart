import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/wellbeing/data/custom_event_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The store that owns `saved_custom_wellbeing_events` — the reusable custom
/// life-event names. Read/append/clear, plus the one thing that made it a
/// store instead of a `const` in the event dialog:
/// Delete my data reaches the store through its composition provider.
class _Preferences extends Mock implements SharedPreferences {}

void main() {
  Future<SharedPreferencesCustomWellbeingEventStore> storeWith(
    Map<String, Object> initial,
  ) async {
    SharedPreferences.setMockInitialValues(initial);
    return SharedPreferencesCustomWellbeingEventStore(
      await SharedPreferences.getInstance(),
    );
  }

  for (final throwsError in [false, true]) {
    test(
      'failed writes and deletion are typed (throws: $throwsError)',
      () async {
        final prefs = _Preferences();
        when(() => prefs.getStringList(any())).thenReturn(['Physio visit']);
        if (throwsError) {
          when(() => prefs.setStringList(any(), any()))
              .thenThrow(StateError('private text'));
          when(() => prefs.remove(any())).thenThrow(StateError('private text'));
        } else {
          when(() => prefs.setStringList(any(), any()))
              .thenAnswer((_) async => false);
          when(() => prefs.remove(any())).thenAnswer((_) async => false);
        }
        final store = SharedPreferencesCustomWellbeingEventStore(prefs);
        for (final operation in [
          () => store.saveTitle('Beach holiday'),
          () => store.removeTitle('Physio visit'),
          store.clear,
        ]) {
          await expectLater(operation(), throwsA(isA<StorageException>()));
        }
      },
    );
  }

  test('a fresh install has no saved names', () async {
    final store = await storeWith({});
    expect(store.savedTitles(), isEmpty);
  });

  test('a saved name is read back, oldest first', () async {
    final store = await storeWith({});

    await store.saveTitle('Beach holiday');
    await store.saveTitle('Sprained ankle');

    expect(store.savedTitles(), ['Beach holiday', 'Sprained ankle']);
  });

  test('saving the same name twice does not duplicate the chip', () async {
    final store = await storeWith({});

    await store.saveTitle('Beach holiday');
    await store.saveTitle('Beach holiday');

    expect(store.savedTitles(), ['Beach holiday']);
  });

  test('remove forgets only the selected name', () async {
    final store = await storeWith({});
    await store.saveTitle('Physio visit');
    await store.saveTitle('Beach holiday');
    await store.removeTitle('Physio visit');
    expect(store.savedTitles(), ['Beach holiday']);
    await store.removeTitle('Already absent');
    expect(store.savedTitles(), ['Beach holiday']);
  });

  test('clear forgets every saved name', () async {
    final store = await storeWith({
      'saved_custom_wellbeing_events': <String>[
        'Physio visit',
        'Beach holiday',
      ],
    });
    expect(store.savedTitles(), hasLength(2));

    await store.clear();

    expect(
      store.savedTitles(),
      isEmpty,
      reason:
          'these are free-text labels for S3 wellbeing events; surviving a '
          '"Delete my data" is exactly the bug this store was added to fix',
    );
  });

  test(
    'clear on an install that never saved a name is not a failure',
    () async {
      final store = await storeWith({});
      await expectLater(store.clear(), completes);
    },
  );

  test('the key this store owns is the one the audit classifies', () async {
    final store = await storeWith({});
    await store.saveTitle('Beach holiday');

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('saved_custom_wellbeing_events'),
      ['Beach holiday'],
      reason:
          'delete_my_data_covers_every_pref_key_test.dart classifies this '
          'exact key name — renaming it here without renaming it there would '
          'leave the old key on every existing install, uncleared',
    );
  });
}
