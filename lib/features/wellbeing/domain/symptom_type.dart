/// A symptom a user can attach to a daily check-in or a flare event.
///
/// Shared vocabulary (`knowledge/product/terminology.md`): a small, closed
/// set of plain-English symptom labels used by both the wellbeing feature
/// (check-ins, flares) and, per the cycle feature's roadmap note in
/// `knowledge/product/stage1_audit.md`, future cycle-record symptom fields.
/// This is a `domain/` import, legal for another feature to depend on per
/// ADR 007's "features may depend on another feature's domain/" rule.
enum SymptomType {
  cramping,
  backPain,
  fatigue,
  bloating,
  giSymptoms,
  headache,
  other;

  /// Parses the persisted string form, defaulting to [other] for any
  /// unrecognised value.
  static SymptomType fromStorage(String value) {
    return switch (value) {
      'cramping' => SymptomType.cramping,
      'backPain' => SymptomType.backPain,
      'fatigue' => SymptomType.fatigue,
      'bloating' => SymptomType.bloating,
      'giSymptoms' => SymptomType.giSymptoms,
      'headache' => SymptomType.headache,
      _ => SymptomType.other,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    SymptomType.cramping => 'cramping',
    SymptomType.backPain => 'backPain',
    SymptomType.fatigue => 'fatigue',
    SymptomType.bloating => 'bloating',
    SymptomType.giSymptoms => 'giSymptoms',
    SymptomType.headache => 'headache',
    SymptomType.other => 'other',
  };

  /// Warm, plain-English display label (`knowledge/product/terminology.md`:
  /// "UI copy uses plain, warm language").
  String get label => switch (this) {
    SymptomType.cramping => 'Muscle cramps',
    SymptomType.backPain => 'Back pain',
    SymptomType.fatigue => 'Fatigue',
    SymptomType.bloating => 'Bloating',
    SymptomType.giSymptoms => 'Tummy troubles',
    SymptomType.headache => 'Headache',
    SymptomType.other => 'Other',
  };
}
