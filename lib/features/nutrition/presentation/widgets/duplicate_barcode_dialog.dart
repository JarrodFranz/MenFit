import 'package:flutter/material.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';

/// What to do about a barcode that already belongs to a food in the
/// catalogue.
///
/// [useExisting] is only ever offered on the **create** path — see
/// [DuplicateBarcodeDialog.isEditingExistingFood].
enum DuplicateBarcodeChoice { useExisting, saveAnyway, keepEditing }

/// The collision prompt shown when a save would attach a barcode already
/// held by a different food in the catalogue.
///
/// ## Two different collisions, two different dialogs
///
/// **Creating a food** ([isEditingExistingFood] false): the barcode belongs
/// to someone else's row, and all three choices mean something real — keep
/// typing, hand back the food already saved with this code, or accept two
/// rows for one product (a shop re-using a code, or a recipe change, are
/// both legitimate reasons to want that).
///
/// **Editing a food** ([isEditingExistingFood] true):
/// [DuplicateBarcodeChoice.useExisting] is not offered at all. It would pop
/// the *other* food and silently discard every edit made to *this* one —
/// the collision has nothing to do with what she is editing, so "use the
/// one I already have" is not a sensible answer to it. The only choices are
/// keeping editing, or attaching the barcode to this food anyway — which is
/// **not a new row**, it is the same in-place update
/// `FoodFormController.save` always performs on the edit path, now carrying
/// the barcode. The button is never labelled "save as a new food" here,
/// because it isn't one.
///
/// ## Copy rules
///
/// The digits are **never** shown or repeated (S2 —
/// `knowledge/engineering/security_and_privacy.md`, and `domain/barcode.dart`
/// applies the same rule to every validation message). The food's own name is
/// the only identifying thing here, and it is the thing that actually helps:
/// "you already have Porridge oats with this barcode" is answerable, where
/// thirteen digits are not. [Food.displayName] (name plus brand, when there
/// is one) is used everywhere [existing] is named — in the body and on any
/// button — not the bare name, so two products that happen to share a name
/// are still told apart.
///
/// Neither option is presented as the mistake on the create path. Two rows
/// for one product is usually accidental, but it is legitimately what
/// someone wants — so "save it anyway" is a plain choice, not a warning to
/// click through.
class DuplicateBarcodeDialog extends StatelessWidget {
  const DuplicateBarcodeDialog({
    required this.existing,
    required this.isEditingExistingFood,
    super.key,
  });

  /// The catalogue food that already carries the barcode about to be saved.
  final Food existing;

  /// Whether the form raising this dialog is editing an existing food
  /// (`FoodFormSeed.existingFoodId != null`) rather than creating one — see
  /// the class doc for why this changes which choices are offered.
  final bool isEditingExistingFood;

  static Future<DuplicateBarcodeChoice?> show(
    BuildContext context,
    Food existing, {
    required bool isEditingExistingFood,
  }) {
    // Root navigator by default, which is what this needs
    // (architecture_overview.md) — a branch-level dialog would sit under the
    // navigation bar with the tabs live beneath the scrim.
    return showDialog<DuplicateBarcodeChoice>(
      context: context,
      builder: (_) => DuplicateBarcodeDialog(
        existing: existing,
        isEditingExistingFood: isEditingExistingFood,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isEditingExistingFood) {
      return AlertDialog(
        title: const Text('Another food already has this barcode'),
        content: Text(
          "'${existing.displayName}' is already saved with this barcode. "
          'You can keep editing, or save this barcode here anyway — it '
          'stays on this food, not a new one.',
        ),
        actions: [
          TextButton(
            key: const Key('duplicateBarcodeKeepEditing'),
            onPressed: () =>
                Navigator.of(context).pop(DuplicateBarcodeChoice.keepEditing),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            key: const Key('duplicateBarcodeSaveAnyway'),
            onPressed: () =>
                Navigator.of(context).pop(DuplicateBarcodeChoice.saveAnyway),
            child: const Text('Save with this barcode anyway'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('You already have this one'),
      content: Text(
        "'${existing.displayName}' is saved with this barcode already. "
        'You can use it, or add this as a separate food.',
      ),
      actions: [
        TextButton(
          key: const Key('duplicateBarcodeKeepEditing'),
          onPressed: () =>
              Navigator.of(context).pop(DuplicateBarcodeChoice.keepEditing),
          child: const Text('Keep editing'),
        ),
        TextButton(
          key: const Key('duplicateBarcodeSaveAnyway'),
          onPressed: () =>
              Navigator.of(context).pop(DuplicateBarcodeChoice.saveAnyway),
          child: const Text('Save as a new food anyway'),
        ),
        FilledButton(
          key: const Key('duplicateBarcodeUseExisting'),
          onPressed: () =>
              Navigator.of(context).pop(DuplicateBarcodeChoice.useExisting),
          child: Text("Use '${existing.displayName}'"),
        ),
      ],
    );
  }
}
