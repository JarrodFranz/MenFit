import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';

/// Types a barcode in by hand, and pops the **canonical digits** back — or
/// `null` when the user backs out.
///
/// ```dart
/// final code = await BarcodeEntryDialog.show(context);
/// ```
///
/// **Manual entry is the primary path, not a fallback.** It is the only path
/// on Windows and Web (`core/platform/barcode_scanning.dart`), and it is
/// what is left everywhere else when camera permission is refused or the
/// label is scuffed, curved, or under cling film. So this is offered on
/// **every** platform and is never gated on `barcodeScanningSupported` —
/// gating it would take the feature away from two of the four targets.
///
/// What pops back is `Barcode.digits`, not what was typed: a UPC-A and its
/// EAN-13 spelling are the same product and must not become two catalogue
/// rows (`domain/barcode.dart`).
///
/// ## S2 handling
///
/// A barcode names a product the user is about to eat. Nothing here logs it,
/// and no message repeats the digits — every error string comes from
/// [validateBarcode], whose copy rules forbid interpolating the input.
class BarcodeEntryDialog extends StatefulWidget {
  const BarcodeEntryDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const BarcodeEntryDialog(),
    );
  }

  @override
  State<BarcodeEntryDialog> createState() => _BarcodeEntryDialogState();
}

class _BarcodeEntryDialogState extends State<BarcodeEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  /// `null` until the first attempt — the field doesn't mark a half-typed
  /// barcode wrong while it is still being typed, the same rule the food
  /// form follows (`presentation/food_form_controller.dart`).
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final validation = validateBarcode(_controller.text);
    final barcode = validation.barcode;
    if (barcode == null) {
      setState(() => _error = validation.error);
      return;
    }
    Navigator.of(context).pop(barcode.digits);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter a barcode'),
      content: SizedBox(
        width: 360,
        child: TextField(
          key: const Key('barcodeEntryField'),
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          // Digits only, so the keyboard and the field agree with
          // `validateBarcode` instead of accepting text it will reject.
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Barcode',
            helperText: 'The long number under the stripes on the packet',
            errorText: _error,
          ),
          onSubmitted: (_) => _submit(),
          // Clearing the message as they type keeps the dialog from arguing
          // with a barcode that is only half entered.
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('barcodeEntrySubmit'),
          onPressed: _submit,
          child: const Text('Look it up'),
        ),
      ],
    );
  }
}
