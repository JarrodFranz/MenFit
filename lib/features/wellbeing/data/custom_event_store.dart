import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/wellbeing/domain/custom_event_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the legacy preference key so existing suggestions remain deletable.
class SharedPreferencesCustomWellbeingEventStore
    implements CustomWellbeingEventStore {
  const SharedPreferencesCustomWellbeingEventStore(this._preferences);

  final SharedPreferences _preferences;
  static const _savedTitlesKey = 'saved_custom_wellbeing_events';

  @override
  List<String> savedTitles() {
    try {
      return List.unmodifiable(
        _preferences.getStringList(_savedTitlesKey) ?? const <String>[],
      );
    } on Object {
      throw const StorageException(message: 'Failed to read saved event names');
    }
  }

  @override
  Future<void> saveTitle(String title) async {
    final current = savedTitles();
    if (current.contains(title)) return;
    await _write([...current, title]);
  }

  @override
  Future<void> removeTitle(String title) async {
    await _write(savedTitles().where((name) => name != title).toList());
  }

  Future<void> _write(List<String> titles) async {
    try {
      final ok = await _preferences.setStringList(_savedTitlesKey, titles);
      if (!ok) throw const StorageException(message: 'Event name write failed');
    } on Object {
      throw const StorageException(
        message: 'Failed to update saved event names',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      final ok = await _preferences.remove(_savedTitlesKey);
      if (!ok) {
        throw const StorageException(message: 'Event name removal failed');
      }
    } on Object {
      throw const StorageException(
        message: 'Failed to clear saved event names',
      );
    }
  }
}
