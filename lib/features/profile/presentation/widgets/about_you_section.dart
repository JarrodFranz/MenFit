import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/profile/domain/profile_validation.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/profile_controller.dart';
import 'package:menfit_app/features/profile/presentation/widgets/run_profile_update.dart';

/// 'About you' section of `../profile_screen.dart`: date of birth, height,
/// weight — every field individually optional, unit-aware (cm vs ft+in, kg
/// vs lb per `UserProfile.unitSystem`), canonical metric storage
/// (`knowledge/product/product_vision.md`).
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): this
/// widget never logs or otherwise surfaces these values outside the normal
/// UI/persistence path.
class AboutYouSection extends ConsumerStatefulWidget {
  const AboutYouSection({required this.profile, super.key});

  final UserProfile? profile;

  @override
  ConsumerState<AboutYouSection> createState() => AboutYouSectionState();
}

class AboutYouSectionState extends ConsumerState<AboutYouSection> {
  late final TextEditingController _heightController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _weightController;
  String? _heightError;
  String? _weightError;

  /// Saves pending height and weight entries if valid.
  Future<bool> savePending() async {
    await _saveHeight(context);
    if (!mounted) return false;
    await _saveWeight(context);
    return _heightError == null && _weightError == null;
  }

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _heightInchesController = TextEditingController();
    _weightController = TextEditingController();
    _resync();
  }

  @override
  void didUpdateWidget(covariant AboutYouSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resync when a different profile identity arrives (freshly created) or
    // the unit system flips (the displayed number must switch units) - but
    // never on an echo of our own save for the same profile in the same
    // units, which would clobber in-progress typing (same reasoning as
    // `profile_screen.dart`'s `_ProfileFormState.didUpdateWidget`).
    final identityChanged = oldWidget.profile?.id != widget.profile?.id;
    final unitsChanged =
        oldWidget.profile?.unitSystem != widget.profile?.unitSystem;
    if (identityChanged || unitsChanged) {
      _resync();
    }
  }

  void _resync() {
    final profile = widget.profile;
    final unitSystem = profile?.unitSystem ?? UnitSystem.metric;
    final heightCm = profile?.heightCm;
    final weightKg = profile?.weightKg;

    if (heightCm == null) {
      _heightController.text = '';
      _heightInchesController.text = '';
    } else if (unitSystem == UnitSystem.imperial) {
      // ...ForDisplay, not cmToFeetInches: it carries the one-decimal
      // rounding into feet, so 179.9 cm shows "5 ft 11.9 in" and never the
      // nonsense "5 ft 12.0 in".
      final (feet, inches) = UnitConversions.cmToFeetInchesForDisplay(
        heightCm,
      );
      _heightController.text = feet.toString();
      _heightInchesController.text = _formatNumber(inches);
    } else {
      _heightController.text = _formatNumber(heightCm);
    }

    if (weightKg == null) {
      _weightController.text = '';
    } else {
      final displayWeight = unitSystem == UnitSystem.imperial
          ? UnitConversions.kgToLb(weightKg)
          : weightKg;
      _weightController.text = _formatNumber(displayWeight);
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final profile = widget.profile;
    final unitSystem = profile?.unitSystem ?? UnitSystem.metric;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About you', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: tokens.spacingSm),
        const _FieldLabel('Date of birth (optional)'),
        SizedBox(height: tokens.spacingXs),
        _DateOfBirthPicker(dateOfBirth: profile?.dateOfBirth),
        SizedBox(height: tokens.spacingLg),
        const _FieldLabel('Height (optional)'),
        SizedBox(height: tokens.spacingXs),
        if (unitSystem == UnitSystem.imperial)
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  key: const Key('profileHeightFeetField'),
                  controller: _heightController,
                  suffixText: 'ft',
                  // Whole feet only: the fractional part belongs in the
                  // inches field, and accepting "5.5" here used to parse
                  // as 0 ft (int.tryParse fails) and silently save a
                  // height of just the inches.
                  allowDecimal: false,
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _NumberField(
                  key: const Key('profileHeightInchesField'),
                  controller: _heightInchesController,
                  suffixText: 'in',
                ),
              ),
            ],
          )
        else
          _NumberField(
            key: const Key('profileHeightField'),
            controller: _heightController,
            suffixText: 'cm',
          ),
        if (_heightError != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingXs),
            child: Text(
              _heightError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        SizedBox(height: tokens.spacingSm),
        _SaveAndClearRow(
          saveLabel: 'Save height',
          clearLabel: 'Clear height',
          onSave: () => _saveHeight(context),
          onClear: profile?.heightCm == null
              ? null
              : () => _clearHeight(context),
        ),
        SizedBox(height: tokens.spacingLg),
        const _FieldLabel('Weight (optional)'),
        SizedBox(height: tokens.spacingXs),
        _NumberField(
          key: const Key('profileWeightField'),
          controller: _weightController,
          suffixText: unitSystem == UnitSystem.imperial ? 'lb' : 'kg',
        ),
        if (_weightError != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingXs),
            child: Text(
              _weightError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        SizedBox(height: tokens.spacingSm),
        _SaveAndClearRow(
          saveLabel: 'Save weight',
          clearLabel: 'Clear weight',
          onSave: () => _saveWeight(context),
          onClear: profile?.weightKg == null
              ? null
              : () => _clearWeight(context),
        ),
      ],
    );
  }

  Future<void> _saveHeight(BuildContext context) async {
    final unitSystem = widget.profile?.unitSystem ?? UnitSystem.metric;
    double? heightCm;
    if (unitSystem == UnitSystem.imperial) {
      // double-then-floor rather than int.tryParse: the field formatter
      // blocks decimals, but a value that arrives any other way should
      // degrade to "5 ft", never to 0 ft.
      final feet = double.tryParse(_heightController.text)?.floor();
      final inches = double.tryParse(_heightInchesController.text);
      if (_heightController.text.trim().isNotEmpty ||
          _heightInchesController.text.trim().isNotEmpty) {
        heightCm = UnitConversions.feetInchesToCm(feet ?? 0, inches ?? 0);
      }
    } else {
      final cm = double.tryParse(_heightController.text);
      if (_heightController.text.trim().isNotEmpty) {
        heightCm = cm;
      }
    }
    // A field left blank is a no-op save, not a clear - use the explicit
    // "Clear" affordance to unset a value that was previously set.
    if (heightCm == null) {
      setState(() => _heightError = null);
      return;
    }

    final validation = validateProfileFields(
      today: LocalDate.today(),
      heightCm: heightCm,
      unitSystem: unitSystem,
    );
    if (!validation.isValid) {
      setState(() => _heightError = validation.heightError);
      return;
    }
    setState(() => _heightError = null);

    await runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(heightCm: heightCm),
    );
  }

  Future<void> _clearHeight(BuildContext context) {
    setState(() => _heightError = null);
    return runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(clearHeightCm: true),
    );
  }

  Future<void> _saveWeight(BuildContext context) async {
    final unitSystem = widget.profile?.unitSystem ?? UnitSystem.metric;
    final entered = double.tryParse(_weightController.text);
    if (entered == null) {
      setState(() => _weightError = null);
      return;
    }
    final weightKg = unitSystem == UnitSystem.imperial
        ? UnitConversions.lbToKg(entered)
        : entered;

    final validation = validateProfileFields(
      today: LocalDate.today(),
      weightKg: weightKg,
      unitSystem: unitSystem,
    );
    if (!validation.isValid) {
      setState(() => _weightError = validation.weightError);
      return;
    }
    setState(() => _weightError = null);

    await runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(weightKg: weightKg),
    );
  }

  Future<void> _clearWeight(BuildContext context) {
    setState(() => _weightError = null);
    return runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(clearWeightKg: true),
    );
  }
}

/// Formats [value] without a trailing `.0` for whole numbers, one decimal
/// place otherwise.
String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.suffixText,
    this.allowDecimal = true,
    super.key,
  });

  final TextEditingController controller;
  final String suffixText;

  /// Whether a decimal point may be typed. `false` for whole-unit fields
  /// (feet), where a fractional entry has no parse and would be dropped.
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$'),
        ),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixText: suffixText,
      ),
    );
  }
}

class _SaveAndClearRow extends StatelessWidget {
  const _SaveAndClearRow({
    required this.saveLabel,
    required this.clearLabel,
    required this.onSave,
    this.onClear,
  });

  final String saveLabel;
  final String clearLabel;
  final VoidCallback onSave;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    // Wrap, not Row: "Save height"/"Clear height" (longer than the original
    // bare "Save"/"Clear") overflow a Row's fixed width on a narrow (~400dp)
    // phone screen - Wrap lets the Clear button fall to its own line
    // instead.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(onPressed: onSave, child: Text(saveLabel)),
        if (onClear != null)
          TextButton(onPressed: onClear, child: Text(clearLabel)),
      ],
    );
  }
}

class _DateOfBirthPicker extends ConsumerWidget {
  const _DateOfBirthPicker({required this.dateOfBirth});

  final LocalDate? dateOfBirth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: InkWell(
        key: const Key('profileDateOfBirthField'),
        onTap: () => _pick(context, ref),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateOfBirth == null
                  ? 'Not set'
                  : DateFormat.yMMMd().format(
                      DateTime(
                        dateOfBirth!.year,
                        dateOfBirth!.month,
                        dateOfBirth!.day,
                      ),
                    ),
            ),
            Row(
              children: [
                if (dateOfBirth != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear date of birth',
                    onPressed: () => runProfileUpdate(
                      context,
                      () => ref
                          .read(profileControllerProvider.notifier)
                          .updateProfile(clearDateOfBirth: true),
                    ),
                  ),
                const Icon(Icons.edit_calendar_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final today = LocalDate.today();
    final initial = dateOfBirth ?? today.addDays(-365 * 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked == null || !context.mounted) return;

    await runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            dateOfBirth: LocalDate(picked.year, picked.month, picked.day),
          ),
    );
  }
}
