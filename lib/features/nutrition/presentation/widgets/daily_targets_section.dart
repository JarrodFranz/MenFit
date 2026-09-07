import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/macro_target_fields.dart';

/// The three macro fields of one representation, already read from their
/// controllers. Which representation is [_DailyTargetsSectionState._mode]'s
/// business, not this record's.
typedef _Macros = ({
  DailyTargetField protein,
  DailyTargetField carbs,
  DailyTargetField fat,
});

/// The daily targets, saved together: calories, plus the three macros in
/// whichever representation the user prefers.
///
/// Every field is optional and a blank one clears that target — "no target"
/// is a permanent, valid state (`domain/nutrition_goals.dart`), so the form
/// never nags for a number and offers **no default split**. Reading and
/// bounds-checking a field is [DailyTargetField.read]'s job; deciding
/// whether three percentages describe a whole day is
/// `domain/nutrition_validation.dart`'s.
///
/// Saved on an explicit button rather than per keystroke, because clearing a
/// field to retype it would otherwise write a cleared target on the way
/// through — the same reason `profile_screen.dart` has a "Save name" button.
///
/// **Both representations are kept.** All six macro controllers live for the
/// lifetime of the section, so switching mode hides fields rather than
/// discarding them, and only the visible mode's fields are validated and
/// written. The other mode's stored numbers are left exactly as they were —
/// neither overwritten from a conversion nor cleared behind the user's back.
///
/// **Macro locks, grams mode only.** Pinning two gram targets lets
/// `domain/macro_targets.dart#solveMacroTargets` work out the third from the
/// day's energy figure; this section keeps the computed value in the free
/// macro's own controller, so saving writes it as an ordinary gram target
/// and every existing rule — blank clears, the bounds check, the explicit
/// Save button — applies to it unchanged. Percent mode is untouched: three
/// shares that must add to 100 already determine the third by arithmetic.
class DailyTargetsSection extends ConsumerStatefulWidget {
  const DailyTargetsSection({required this.goals, super.key});

  final NutritionGoals? goals;

  @override
  ConsumerState<DailyTargetsSection> createState() =>
      _DailyTargetsSectionState();
}

class _DailyTargetsSectionState extends ConsumerState<DailyTargetsSection> {
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _proteinPercent;
  late final TextEditingController _carbPercent;
  late final TextEditingController _fatPercent;

  late MacroTargetMode _mode;
  late MacroLocks _locks;

  /// Set while this section is writing a computed value into a controller,
  /// so the write doesn't come back through [_onTargetInputChanged] as
  /// though the user had typed it. Without it the sync would re-enter itself
  /// once per keystroke, and would call `setState` from `initState`.
  bool _writingComputedValue = false;

  String? _caloriesError;
  String? _proteinError;
  String? _carbsError;
  String? _fatError;
  String? _proteinPercentError;
  String? _carbPercentError;
  String? _fatPercentError;
  String? _sumError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final goals = widget.goals;
    _calories = TextEditingController(text: _text(goals?.calorieTargetKcal));
    _protein = TextEditingController(text: _text(goals?.proteinTargetGrams));
    _carbs = TextEditingController(text: _text(goals?.carbTargetGrams));
    _fat = TextEditingController(text: _text(goals?.fatTargetGrams));
    _proteinPercent = TextEditingController(
      text: _text(goals?.proteinTargetPercent),
    );
    _carbPercent = TextEditingController(text: _text(goals?.carbTargetPercent));
    _fatPercent = TextEditingController(text: _text(goals?.fatTargetPercent));
    _mode = goals?.macroTargetMode ?? MacroTargetMode.grams;
    _locks = goals?.macroLocks ?? MacroLocks.none;

    // Both derived views — the percent mode's grams lines and the grams
    // mode's computed macro — are functions of these fields *as typed*, so
    // they have to move while the user types rather than only after a save.
    // Otherwise the number she is choosing between is the one thing the form
    // won't show her.
    for (final controller in [
      _calories,
      _protein,
      _carbs,
      _fat,
      _proteinPercent,
      _carbPercent,
      _fatPercent,
    ]) {
      controller.addListener(_onTargetInputChanged);
    }
    // Seed the computed field from the saved locks before the first frame.
    // Safe here precisely because of [_writingComputedValue]: a `setState`
    // out of `initState` would be an error.
    _syncComputedMacro();
  }

  @override
  void didUpdateWidget(covariant DailyTargetsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reseed when a *different* goals row arrives (it was just
    // created), never on the echo of our own save — that would clobber
    // whatever the user has half-typed. Same rule as `_ProfileForm`.
    if (oldWidget.goals?.id == widget.goals?.id) return;
    final goals = widget.goals;
    _calories.text = _text(goals?.calorieTargetKcal);
    _protein.text = _text(goals?.proteinTargetGrams);
    _carbs.text = _text(goals?.carbTargetGrams);
    _fat.text = _text(goals?.fatTargetGrams);
    _proteinPercent.text = _text(goals?.proteinTargetPercent);
    _carbPercent.text = _text(goals?.carbTargetPercent);
    _fatPercent.text = _text(goals?.fatTargetPercent);
    _mode = goals?.macroTargetMode ?? MacroTargetMode.grams;
    _locks = goals?.macroLocks ?? MacroLocks.none;
    _syncComputedMacro();
  }

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _proteinPercent.dispose();
    _carbPercent.dispose();
    _fatPercent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    // The resolved target stands in as the energy basis when the user has
    // set no calorie target of her own, so a change to it moves the computed
    // macro. `listen` rather than only `watch` because that move has to
    // write into a text controller, which a build must never do.
    ref.listen<AsyncValue<CalorieTargetOutcome>>(
      calorieTargetProvider,
      (_, _) => _recomputeComputedMacro(),
    );
    final solution = _solveLocks();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily targets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              'All optional. Leave any of them blank and the diary just '
              "won't show a target for it.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            TargetField(
              fieldKey: 'calorieTargetField',
              label: 'Calories (kcal)',
              controller: _calories,
              errorText: _caloriesError,
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Protein, carbs and fat',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: tokens.spacingSm),
            MacroTargetModeToggle(mode: _mode, onChanged: _setMode),
            SizedBox(height: tokens.spacingMd),
            if (_mode == MacroTargetMode.grams)
              MacroGramFields(
                protein: _protein,
                carbs: _carbs,
                fat: _fat,
                locks: _locks,
                onLockChanged: _setLock,
                computedMacro: solution is SolvedMacroTarget
                    ? solution.macro
                    : null,
                computedNote: solution is SolvedMacroTarget
                    ? _computedNoteFor(solution)
                    : null,
                note: macroLockNote(
                  solution,
                  locks: _locks,
                  hideCalorieNumbers: widget.goals?.hideCalorieNumbers ?? false,
                ),
                proteinError: _proteinError,
                carbsError: _carbsError,
                fatError: _fatError,
              )
            else
              MacroPercentFields(
                protein: _proteinPercent,
                carbs: _carbPercent,
                fat: _fatPercent,
                derived: _derivedGrams(),
                hideCalorieNumbers: widget.goals?.hideCalorieNumbers ?? false,
                proteinError: _proteinPercentError,
                carbsError: _carbPercentError,
                fatError: _fatPercentError,
                sumError: _sumError,
              ),
            SizedBox(height: tokens.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  key: const Key('calculateTargetsButton'),
                  onPressed: _onCalculatePressed,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate'),
                ),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: const Text('Save targets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onCalculatePressed() {
    if (_mode == MacroTargetMode.percent) {
      if (_locks.isEmpty) {
        _writingComputedValue = true;
        try {
          _proteinPercent.text = standardProteinPercent.round().toString();
          _carbPercent.text = standardCarbPercent.round().toString();
          _fatPercent.text = standardFatPercent.round().toString();
        } finally {
          _writingComputedValue = false;
        }
        setState(() {});
        return;
      }
    }

    final outcome = calculateMacroTargets(
      locks: _locks,
      calorieTargetKcal: _basisCalorieTargetKcal(),
      resolvedTarget: ref.read(calorieTargetProvider).value,
      proteinTargetGrams: _read(_protein, max: maxMacroTargetGrams).value,
      carbTargetGrams: _read(_carbs, max: maxMacroTargetGrams).value,
      fatTargetGrams: _read(_fat, max: maxMacroTargetGrams).value,
    );

    switch (outcome) {
      case CalculatedCalories(:final caloriesKcal):
        _calories.text = caloriesKcal.toString();
        _recomputeComputedMacro();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recalculated daily calorie target: $caloriesKcal kcal',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      case CalculatedMacroGrams(
        :final proteinGrams,
        :final carbGrams,
        :final fatGrams,
      ):
        _writingComputedValue = true;
        try {
          if (!_locks.protein && proteinGrams != null) {
            _protein.text = _gramsText(proteinGrams);
          }
          if (!_locks.carbs && carbGrams != null) {
            _carbs.text = _gramsText(carbGrams);
          }
          if (!_locks.fat && fatGrams != null) {
            _fat.text = _gramsText(fatGrams);
          }
        } finally {
          _writingComputedValue = false;
        }
        _recomputeComputedMacro();
      case NoCalculateBasis(:final message):
      case CalculateError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  void _onTargetInputChanged() {
    // Our own write into the computed field, echoed back. Acting on it would
    // recurse, and during `initState` it would `setState` too early.
    if (_writingComputedValue) return;
    if (_mode == MacroTargetMode.percent) {
      setState(() {});
      return;
    }
    _recomputeComputedMacro();
  }

  /// Re-solves the locks, writes the answer into the free macro's field, and
  /// rebuilds so the note follows.
  ///
  /// Never called from `build` — it writes to a [TextEditingController],
  /// which notifies listeners synchronously.
  void _recomputeComputedMacro() {
    _syncComputedMacro();
    if (mounted) setState(() {});
  }

  /// Puts the solved gram figure in the free macro's controller, so it is
  /// the same field, the same bounds check and the same save path as a
  /// number the user typed herself.
  ///
  /// Does nothing unless exactly one macro is free and the arithmetic works
  /// out — an over-budget or underdetermined set leaves every field as the
  /// user left it, and the section's note explains why.
  void _syncComputedMacro() {
    final solution = _solveLocks();
    if (solution is! SolvedMacroTarget) return;
    final controller = _controllerFor(solution.macro);
    final text = _gramsText(solution.grams);
    if (controller.text == text) return;
    _writingComputedValue = true;
    try {
      controller.text = text;
    } finally {
      _writingComputedValue = false;
    }
  }

  /// Locks or unlocks one macro. Locking a second one hands the third to the
  /// solver; unlocking hands it back to the user, with the last computed
  /// number left in place as an ordinary editable target.
  void _setLock(MacroNutrient macro, {required bool locked}) {
    _locks = _locks.withLock(macro, locked: locked);
    _recomputeComputedMacro();
  }

  /// Switching representation only changes which fields are on screen. The
  /// hidden set's controllers keep their text, and any error still showing
  /// belonged to the set the user just left. The lock set is kept too — it
  /// belongs to the grams fields, which are still holding their numbers.
  void _setMode(MacroTargetMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _proteinError = null;
      _carbsError = null;
      _fatError = null;
      _proteinPercentError = null;
      _carbPercentError = null;
      _fatPercentError = null;
      _sumError = null;
    });
  }

  /// The grams the typed percentages currently work out to.
  ///
  /// The calorie basis is read from the field **as typed** whenever that
  /// field is readable — including blank, which means "no calorie target"
  /// and hands the basis to the estimate. Only an unreadable field falls
  /// back to the saved figure, so what the user sees here is what pressing
  /// Save would give her.
  MacroTargetGramsOutcome _derivedGrams() {
    return deriveMacroTargetGrams(
      calorieTargetKcal: _basisCalorieTargetKcal(),
      resolvedTarget: ref.watch(calorieTargetProvider).value,
      proteinTargetPercent: _readPercent(_proteinPercent).value,
      carbTargetPercent: _readPercent(_carbPercent).value,
      fatTargetPercent: _readPercent(_fatPercent).value,
    );
  }

  /// Where the locked gram targets currently leave the day's energy.
  ///
  /// Reads the fields as typed, exactly as [_derivedGrams] does, so the
  /// computed macro tracks the calorie target and the locked values while
  /// they are being edited rather than only after a save. Uses `ref.read`
  /// because this also runs outside `build`; `build`'s `ref.listen` is what
  /// keeps it in step with the resolved target.
  MacroLockSolution _solveLocks() {
    return solveMacroTargets(
      locks: _locks,
      calorieTargetKcal: _basisCalorieTargetKcal(),
      resolvedTarget: ref.read(calorieTargetProvider).value,
      proteinTargetGrams: _read(_protein, max: maxMacroTargetGrams).value,
      carbTargetGrams: _read(_carbs, max: maxMacroTargetGrams).value,
      fatTargetGrams: _read(_fat, max: maxMacroTargetGrams).value,
    );
  }

  /// The calorie target the derived views work from: the field **as typed**
  /// whenever it is readable — including blank, which means "no calorie
  /// target" and hands the basis to the estimate. Only an unreadable field
  /// falls back to the saved figure, so what the user sees is what pressing
  /// Save would give her.
  int? _basisCalorieTargetKcal() {
    final calories = _read(_calories, max: maxCalorieTargetKcal);
    return calories.isValid
        ? calories.value?.round()
        : widget.goals?.calorieTargetKcal;
  }

  /// The line under the computed field. Names the basis in words only — no
  /// energy figure, so it is safe under the hide-calorie-numbers preference
  /// without a second wording.
  String _computedNoteFor(SolvedMacroTarget solution) {
    final basis = solution.basisIsEstimated
        ? 'your estimated daily target'
        : 'your calorie target';
    return 'Worked out from $basis and the two you locked.';
  }

  TextEditingController _controllerFor(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => _protein,
    MacroNutrient.carbs => _carbs,
    MacroNutrient.fat => _fat,
  };

  Future<void> _save() async {
    final calories = _read(_calories, max: maxCalorieTargetKcal);
    setState(() => _caloriesError = calories.error);

    // Only the visible representation is read, checked and written. The
    // other one's stored numbers stay exactly as they are — a mode the user
    // isn't looking at is not a form she just submitted.
    final macros = _mode == MacroTargetMode.grams
        ? _readValidGrams()
        : _readValidPercentages();
    if (!calories.isValid || macros == null) return;

    setState(() => _isSaving = true);
    try {
      await _write(calories, macros);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Reads the grams fields and shows their errors, returning `null` when
  /// any of them can't be read.
  _Macros? _readValidGrams() {
    final macros = (
      protein: _read(_protein, max: maxMacroTargetGrams),
      carbs: _read(_carbs, max: maxMacroTargetGrams),
      fat: _read(_fat, max: maxMacroTargetGrams),
    );
    setState(() {
      _proteinError = macros.protein.error;
      _carbsError = macros.carbs.error;
      _fatError = macros.fat.error;
    });
    return _allValid(macros) ? macros : null;
  }

  /// Reads the percentage fields, shows their errors *and* the split's, and
  /// returns `null` unless all four are clear.
  _Macros? _readValidPercentages() {
    final macros = (
      protein: _readPercent(_proteinPercent),
      carbs: _readPercent(_carbPercent),
      fat: _readPercent(_fatPercent),
    );
    // The split rule only means anything once every field is a number, so
    // an unreadable field reports itself first and the sum waits its turn.
    final readable = _allValid(macros);
    final split = readable
        ? validateMacroTargetPercentages(
            proteinPercent: macros.protein.value,
            carbPercent: macros.carbs.value,
            fatPercent: macros.fat.value,
          )
        : const MacroPercentValidation();

    setState(() {
      _proteinPercentError = macros.protein.error ?? split.proteinError;
      _carbPercentError = macros.carbs.error ?? split.carbError;
      _fatPercentError = macros.fat.error ?? split.fatError;
      _sumError = split.sumError;
    });
    return readable && split.isValid ? macros : null;
  }

  Future<void> _write(DailyTargetField calories, _Macros macros) {
    final controller = ref.read(nutritionGoalsControllerProvider.notifier);
    final isGrams = _mode == MacroTargetMode.grams;
    return controller.updateGoals(
      calorieTargetKcal: calories.value?.round(),
      clearCalorieTarget: calories.value == null,
      macroTargetMode: _mode,
      macroLocks: _locks,
      proteinTargetGrams: isGrams ? macros.protein.value : null,
      clearProteinTarget: isGrams && macros.protein.value == null,
      carbTargetGrams: isGrams ? macros.carbs.value : null,
      clearCarbTarget: isGrams && macros.carbs.value == null,
      fatTargetGrams: isGrams ? macros.fat.value : null,
      clearFatTarget: isGrams && macros.fat.value == null,
      proteinTargetPercent: isGrams ? null : macros.protein.value,
      clearProteinPercentTarget: !isGrams && macros.protein.value == null,
      carbTargetPercent: isGrams ? null : macros.carbs.value,
      clearCarbPercentTarget: !isGrams && macros.carbs.value == null,
      fatTargetPercent: isGrams ? null : macros.fat.value,
      clearFatPercentTarget: !isGrams && macros.fat.value == null,
    );
  }

  static bool _allValid(_Macros macros) =>
      macros.protein.isValid && macros.carbs.isValid && macros.fat.isValid;

  static DailyTargetField _read(
    TextEditingController controller, {
    required double max,
  }) => DailyTargetField.read(controller.text, max: max);

  static DailyTargetField _readPercent(TextEditingController controller) =>
      DailyTargetField.read(
        controller.text,
        max: maxMacroTargetPercent,
        tooLargeMessage: macroPercentTooLargeMessage,
      );

  static String _text(num? value) {
    if (value == null) return '';
    return value == value.round() ? value.round().toString() : value.toString();
  }

  /// A solved gram figure as the field should hold it: one decimal at most,
  /// so `2000 / 3` lands in the box as `66.7` rather than as seventeen
  /// digits of float. What is shown is what gets saved.
  static String _gramsText(double grams) {
    final rounded = double.parse(grams.toStringAsFixed(1));
    return _text(rounded);
  }
}
