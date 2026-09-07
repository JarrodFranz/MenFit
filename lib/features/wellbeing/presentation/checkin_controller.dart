import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_validation.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkin_controller.freezed.dart';
part 'checkin_controller.g.dart';

/// In-progress state of the check-in sheet.
///
/// Validation is surfaced as typed state fields (`*Error`), not exceptions —
/// same convention as `features/cycle/presentation/period_entry_controller.dart`.
@freezed
abstract class CheckinFormState with _$CheckinFormState {
  const factory CheckinFormState({
    required LocalDate day,
    int? energy,
    int? sleep,
    int? soreness,
    int? stress,
    int? pain,
    @Default(<SymptomType>[]) List<SymptomType> symptoms,
    String? otherSymptom,
    String? dayError,
    String? energyError,
    String? sleepError,
    String? sorenessError,
    String? stressError,
    String? painError,
    @Default(false) bool isSubmitting,
    String? submitError,

    /// Flips to `true` once [CheckinController.save] completes
    /// successfully (whether or not anything was actually persisted — see
    /// its dartdoc's empty-checkin no-op rule) - the sheet listens for this
    /// to close itself, exactly once, instead of the controller closing it
    /// directly (same convention as `PeriodEntryState.didSave`).
    @Default(false) bool didSave,
  }) = _CheckinFormState;
}

/// Drives the check-in sheet (`widgets/checkin_sheet.dart` — home's
/// invite/edit card opens it for `LocalDate.today()`).
///
/// A **family** provider keyed by [day]/[existing]: the day being checked
/// into, and the check-in already logged for it (if any, for pre-filling an
/// edit), are derived once in [build] from the constructor arguments — same
/// reasoning as `PeriodEntryController`'s dartdoc for why this isn't an
/// imperative `loadForEdit(...)` call from `initState`.
@riverpod
class CheckinController extends _$CheckinController {
  String? _editingId;
  DateTime? _editingCreatedAt;

  @override
  CheckinFormState build(LocalDate day, DailyCheckin? existing) {
    _editingId = existing?.id;
    _editingCreatedAt = existing?.createdAt;
    return CheckinFormState(
      day: day,
      energy: existing?.energy,
      sleep: existing?.sleep,
      soreness: existing?.soreness,
      stress: existing?.stress,
      pain: existing?.pain,
      symptoms: existing?.symptoms ?? const [],
      otherSymptom: existing?.customSymptom,
    );
  }

  /// Sets this score to the tapped value, or clears it back to `null` when
  /// the same value is tapped again — "tap again to clear" (every score is
  /// optional). `setSleep`/`setSoreness`/`setStress`/`setPain` below follow
  /// the same rule.
  void setEnergy(int value) => state = state.copyWith(
    energy: state.energy == value ? null : value,
    energyError: null,
  );

  void setSleep(int value) => state = state.copyWith(
    sleep: state.sleep == value ? null : value,
    sleepError: null,
  );

  void setSoreness(int value) => state = state.copyWith(
    soreness: state.soreness == value ? null : value,
    sorenessError: null,
  );

  void setStress(int value) => state = state.copyWith(
    stress: state.stress == value ? null : value,
    stressError: null,
  );

  void setPain(int value) => state = state.copyWith(
    pain: state.pain == value ? null : value,
    painError: null,
  );

  void setOtherSymptom(String value) {
    state = state.copyWith(otherSymptom: value);
  }

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

  /// Builds the [DailyCheckin] the current form state represents, without
  /// saving it — used by the sheet's "Log a flare-up" affordance, which
  /// saves the check-in (if there's anything to save) before opening the
  /// flare dialog.
  DailyCheckin _buildEntity(DateTime now) {
    final hasOther = state.symptoms.contains(SymptomType.other);
    return DailyCheckin(
      id: _editingId ?? EntityId.generate(),
      day: state.day,
      energy: state.energy,
      sleep: state.sleep,
      soreness: state.soreness,
      stress: state.stress,
      pain: state.pain,
      symptoms: state.symptoms,
      customSymptom: hasOther ? state.otherSymptom?.trim() : null,
      createdAt: _editingCreatedAt ?? now,
      updatedAt: now,
    );
  }

  /// Validates and saves the check-in. Returns `true` on success —
  /// including the no-op case where the form is entirely empty (RULING: a
  /// fully blank check-in is never persisted; nothing meaningful for the
  /// user to save yet isn't a *failure* either, so this quietly reports
  /// success rather than surfacing an error). On validation failure, sets
  /// the relevant `*Error` field(s) and returns `false`.
  ///
  /// [markComplete] controls whether a successful save flips
  /// [CheckinFormState.didSave] - the sheet's `ref.listen` treats that flip
  /// as "close me". The sheet's own Save button leaves this `true` (the
  /// default). Its "Log a flare-up" button passes `false`: it saves
  /// whatever's filled in so far (or no-ops quietly, same as any other
  /// call) *without* closing the sheet, so the flare dialog it opens next
  /// appears on top of a still-open sheet rather than a sheet that just
  /// vanished out from under it.
  Future<bool> save({bool markComplete = true}) async {
    final validation = validateDailyCheckin(
      day: state.day,
      today: LocalDate.today(),
      energy: state.energy,
      sleep: state.sleep,
      soreness: state.soreness,
      stress: state.stress,
      pain: state.pain,
    );
    if (!validation.isValid) {
      state = state.copyWith(
        dayError: validation.dayError,
        energyError: validation.energyError,
        sleepError: validation.sleepError,
        sorenessError: validation.sorenessError,
        stressError: validation.stressError,
        painError: validation.painError,
      );
      return false;
    }

    final now = DateTime.now().toUtc();
    final checkin = _buildEntity(now);

    if (checkin.isEmpty) {
      state = state.copyWith(
        didSave: markComplete || state.didSave,
        isSubmitting: false,
      );
      return true;
    }

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final repository = ref.read(wellbeingRepositoryProvider);
      await repository.saveCheckin(checkin);
      state = state.copyWith(
        didSave: markComplete || state.didSave,
        isSubmitting: false,
      );
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
