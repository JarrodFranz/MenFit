import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_validation.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flare_controller.freezed.dart';
part 'flare_controller.g.dart';

/// The note written onto recovery days this dialog auto-creates.
///
/// S3: deliberately a fixed, neutral string. A recovery day's note is
/// surfaced verbatim on the wellbeing history screen and in the streak
/// card's "Today" sheet, so it must never carry the flare's symptoms,
/// category, or severity across into those contexts.
const String flareRecoveryDayNote = 'Flare-up';

/// In-progress state of the flare dialog.
///
/// [severity]/[impact] are nullable here (unlike on [FlareEvent] itself,
/// where they're required) — the form starts with neither picked;
/// [validateFlareEvent] requires both before [FlareController.save] will
/// persist.
@freezed
abstract class FlareFormState with _$FlareFormState {
  const factory FlareFormState({
    required LocalDate day,
    FlareSeverity? severity,
    FlareImpact? impact,
    @Default(<SymptomType>[]) List<SymptomType> symptoms,
    String? otherSymptom,
    FlareCategory? category,
    String? notes,

    /// Whether the form is in "Date range" mode. [endDay] is only read
    /// when this is `true` — a flare saved in "Single day" mode always
    /// persists a null `endDay`, so switching to range and back leaves a
    /// single-day flare single-day. Keeping the last-picked [endDay]
    /// around while single-day is selected is what lets the user toggle
    /// back and forth without re-picking it.
    @Default(false) bool isRange,
    LocalDate? endDay,
    String? dayError,
    String? endDayError,
    String? severityError,
    String? impactError,

    /// The "also mark these as recovery days" tick box, or `null` while
    /// the user hasn't touched it — in which case the box shows
    /// [FlareController.rangeFullyMarked] for the range as it stands.
    /// Modelling "untouched" explicitly (rather than seeding a bool at
    /// build time) keeps the default correct as the range changes, without
    /// this controller needing to watch the recovery-day stream.
    bool? markAsRecovery,

    @Default(false) bool isSubmitting,
    String? submitError,

    /// Set when the flare itself saved but updating recovery days failed —
    /// see [FlareController.save]. Distinct from [submitError] because the
    /// flare is *not* rolled back in that case and the copy must say so.
    String? recoveryError,

    /// Flips to `true` once [FlareController.save] persists successfully —
    /// same convention as `CheckinFormState.didSave`.
    @Default(false) bool didSave,

    /// Flips to `true` once [FlareController.delete] succeeds.
    @Default(false) bool didDelete,
  }) = _FlareFormState;
}

/// Drives the flare dialog (`presentation/flare_dialog.dart`).
///
/// A **family** provider keyed by [existing] / [initialDay]: `null` to log a
/// new flare (defaulting to [initialDay] or today), or an existing [FlareEvent]
/// to edit/delete — same family-derives-initial-state reasoning as
/// `CheckinController`/`PeriodEntryController`.
///
/// Reaching into `streaks`' composition surface for
/// `recoveryRepositoryProvider` is ADR-007-legal (a feature may depend on
/// another feature's `<name>_providers.dart`), the same import
/// `wellbeing_screen.dart` already makes.
@riverpod
class FlareController extends _$FlareController {
  String? _editingId;
  DateTime? _editingCreatedAt;

  @override
  FlareFormState build(FlareEvent? existing, [LocalDate? initialDay]) {
    _editingId = existing?.id;
    _editingCreatedAt = existing?.createdAt;
    return FlareFormState(
      day: existing?.day ?? initialDay ?? LocalDate.today(),
      severity: existing?.severity,
      impact: existing?.impact,
      symptoms: existing?.symptoms ?? const [],
      otherSymptom: existing?.customSymptom,
      category: existing?.category,
      notes: existing?.notes,
      isRange: existing?.endDay != null,
      endDay: existing?.endDay,
    );
  }

  bool get isEditing => _editingId != null;

  /// The inclusive last day the form currently covers — [FlareFormState.day]
  /// itself in single-day mode.
  LocalDate get rangeEndDay =>
      state.isRange ? (state.endDay ?? state.day) : state.day;

  /// Every calendar day the form currently covers, ascending and inclusive.
  ///
  /// Mirrors [FlareEvent.days] (including its [maxFlareRangeDays] cap) for a
  /// flare that can't be constructed yet: severity and impact are still
  /// nullable while the form is being filled in, so there is no
  /// [FlareEvent] to ask.
  List<LocalDate> daysInRange() {
    final last = rangeEndDay;
    if (last.isBefore(state.day)) return [state.day];
    final span = state.day.difference(last);
    final lastOffset = span < maxFlareRangeDays ? span : maxFlareRangeDays - 1;
    return [
      for (var offset = 0; offset <= lastOffset; offset++)
        state.day.addDays(offset),
    ];
  }

  /// Whether every day the form currently covers is already in
  /// [markedRecoveryDays] — the tick box's value while the user hasn't
  /// touched it, and the "before" state [save] diffs against.
  bool rangeFullyMarked(Set<LocalDate> markedRecoveryDays) =>
      daysInRange().every(markedRecoveryDays.contains);

  void updateDay(LocalDate value) =>
      state = state.copyWith(day: value, dayError: null, endDayError: null);

  void updateEndDay(LocalDate value) =>
      state = state.copyWith(endDay: value, endDayError: null);

  void setRangeMode({required bool isRange}) {
    state = state.copyWith(
      isRange: isRange,
      // Switching into range mode with nothing picked yet starts as a
      // one-day range rather than an empty control.
      endDay: state.endDay ?? state.day,
      endDayError: null,
    );
  }

  void setSeverity(FlareSeverity value) =>
      state = state.copyWith(severity: value, severityError: null);

  void setImpact(FlareImpact value) =>
      state = state.copyWith(impact: value, impactError: null);

  /// `null` maps to "Prefer not to say" — never required.
  void setCategory(FlareCategory? value) =>
      state = state.copyWith(category: value);

  void updateNotes(String value) =>
      state = state.copyWith(notes: value.isEmpty ? null : value);

  void setMarkAsRecovery({required bool value}) =>
      state = state.copyWith(markAsRecovery: value, recoveryError: null);

  void setOtherSymptom(String value) =>
      state = state.copyWith(otherSymptom: value);

  void toggleSymptom(SymptomType symptom) {
    final current = List<SymptomType>.of(state.symptoms);
    if (current.contains(symptom)) {
      current.remove(symptom);
      if (symptom == SymptomType.other) {
        state = state.copyWith(symptoms: current, otherSymptom: null);
        return;
      }
    } else {
      current.add(symptom);
    }
    state = state.copyWith(symptoms: current);
  }

  /// Validates and saves the flare, then applies the "also mark these as
  /// recovery days" tick box. Returns `true` only when both steps
  /// succeeded.
  ///
  /// [markedRecoveryDays] is the set of days already marked as recovery,
  /// read by the dialog from `streaks`' `recoveryDayEntriesProvider`. It is
  /// both the tick box's untouched default and the "before" value this
  /// diffs against, so a save that doesn't change the box writes nothing to
  /// the recovery table — importantly, re-saving an already-marked flare
  /// never re-stamps [flareRecoveryDayNote] over a note the user set
  /// elsewhere.
  ///
  /// The recovery step runs **after** the flare is persisted and never
  /// rolls it back: if marking fails, the flare stays saved,
  /// [FlareFormState.recoveryError] is set (so the dialog stays open and
  /// says so), and `didSave` is deliberately left `false`. Re-pressing save
  /// then updates the same flare row rather than creating a second one —
  /// [_editingId] is adopted on first successful save for exactly that
  /// reason.
  Future<bool> save({
    Set<LocalDate> markedRecoveryDays = const <LocalDate>{},
  }) async {
    final endDay = state.isRange ? rangeEndDay : null;
    final validation = validateFlareEvent(
      day: state.day,
      today: LocalDate.today(),
      endDay: endDay,
      severity: state.severity,
      impact: state.impact,
    );
    if (!validation.isValid) {
      state = state.copyWith(
        dayError: validation.dayError,
        endDayError: validation.endDayError,
        severityError: validation.severityError,
        impactError: validation.impactError,
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      submitError: null,
      recoveryError: null,
    );
    try {
      final repository = ref.read(wellbeingRepositoryProvider);
      final now = DateTime.now().toUtc();
      final hasOther = state.symptoms.contains(SymptomType.other);
      final flare = FlareEvent(
        id: _editingId ?? EntityId.generate(),
        day: state.day,
        endDay: endDay,
        severity: state.severity!,
        impact: state.impact!,
        symptoms: state.symptoms,
        customSymptom: hasOther ? state.otherSymptom?.trim() : null,
        category: state.category,
        notes: state.notes,
        createdAt: _editingCreatedAt ?? now,
        updatedAt: now,
      );

      await repository.saveFlare(flare);
      _editingId = flare.id;
      _editingCreatedAt = flare.createdAt;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }

    final applied = await _applyRecoveryMarking(markedRecoveryDays);
    if (!applied) return false;

    state = state.copyWith(didSave: true, isSubmitting: false);
    return true;
  }

  /// Applies the tick box to the recovery-day records for the saved range.
  /// Returns `false` (with [FlareFormState.recoveryError] set) if the write
  /// failed — the caller must not undo the flare save in that case.
  Future<bool> _applyRecoveryMarking(Set<LocalDate> markedRecoveryDays) async {
    final wasMarked = rangeFullyMarked(markedRecoveryDays);
    final wantsMarked = state.markAsRecovery ?? wasMarked;
    if (wantsMarked == wasMarked) return true;

    try {
      final repository = ref.read(recoveryRepositoryProvider);
      if (wantsMarked) {
        await repository.markRecoveryDays(
          state.day,
          rangeEndDay,
          note: flareRecoveryDayNote,
        );
      } else {
        await repository.unmarkRecoveryDays(state.day, rangeEndDay);
      }
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        recoveryError: userMessageFor(error),
      );
      return false;
    }
  }

  /// Deletes the flare being edited. No-op (returns `false`) when this
  /// controller is logging a new flare rather than editing an existing one.
  Future<bool> delete() async {
    final id = _editingId;
    if (id == null) return false;

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final repository = ref.read(wellbeingRepositoryProvider);
      await repository.deleteFlare(id);
      state = state.copyWith(didDelete: true, isSubmitting: false);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }
  }
}
