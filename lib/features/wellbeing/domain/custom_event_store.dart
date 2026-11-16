/// Device-local reusable life-event names, treated as sensitive wellbeing data.
abstract interface class CustomWellbeingEventStore {
  /// Returns saved names in insertion order.
  List<String> savedTitles();

  /// Remembers a name without adding duplicates.
  Future<void> saveTitle(String title);

  /// Forgets a suggestion without changing recorded events.
  Future<void> removeTitle(String title);

  /// Forgets all suggestions during deletion of the user's data.
  Future<void> clear();
}
