import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/barcode_scanning.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/presentation/barcode_scan_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

/// The barcode field, and — on a phone — the button that fills it from the
/// camera.
///
/// Present on every route into this form: a blank new food, a provider record
/// under review, a barcode the database had never heard of, and an existing
/// food opened for editing. A food's barcode is what makes the next scan of
/// it find it locally and make no network request at all (ADR 010), so being
/// able to add one to a food typed in by hand is the point.
///
/// **The field is on every platform; the Scan button is not.** Manual entry is
/// the documented primary path — the only one on Windows and Web, and the one
/// left everywhere else when the camera is refused or the label is scuffed
/// (`core/platform/barcode_scanning.dart`,
/// `presentation/barcode_entry_dialog.dart`). Gating the field on a camera
/// would take the feature away from two of the four targets.
class FoodBarcodeSection extends ConsumerWidget {
  const FoodBarcodeSection({required this.seed, super.key});

  final FoodFormSeed? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(foodFormControllerProvider(seed));
    final controller = ref.read(foodFormControllerProvider(seed).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Barcode', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BarcodeField(
                value: state.barcode,
                errorText: state.barcodeError,
                onChanged: controller.updateBarcode,
              ),
            ),
            if (barcodeScanningSupported) ...[
              SizedBox(width: tokens.spacingSm),
              Padding(
                padding: EdgeInsets.only(top: tokens.spacingSm),
                child: OutlinedButton.icon(
                  key: const Key('foodBarcodeScanButton'),
                  onPressed: () => _scan(context, controller),
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('Scan'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Pushes the existing scanner on the **root** navigator and takes the
  /// canonical digits it pops.
  ///
  /// Root rather than the shell branch for the same reason every modal here
  /// does it (architecture_overview.md): a branch-level route is clipped
  /// above the navigation bar, and a full-screen camera preview with the tabs
  /// still live underneath is not a viewfinder.
  Future<void> _scan(
    BuildContext context,
    FoodFormController controller,
  ) async {
    final digits = await Navigator.of(context, rootNavigator: true)
        .push<String>(
          MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
        );
    // Backing out pops null, which means "I didn't scan anything" and must
    // not wipe a barcode she had already typed.
    if (digits == null) return;
    controller.updateBarcode(digits);
  }
}

/// Text field for the barcode, owning its own controller so the value can be
/// replaced by a scan and cleared by the button in the field.
class _BarcodeField extends StatefulWidget {
  const _BarcodeField({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_BarcodeField> createState() => _BarcodeFieldState();
}

class _BarcodeFieldState extends State<_BarcodeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _BarcodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when the state has moved somewhere the field is not — a scan
    // result or a clear. Assigning on every rebuild would fight the cursor.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('foodBarcodeField'),
      controller: _controller,
      keyboardType: TextInputType.number,
      // Digits only, so the keyboard and the field agree with
      // `validateBarcode` instead of accepting text it will reject.
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Barcode (optional)',
        helperText:
            'The long number under the stripes — a scan finds this '
            'food instantly next time.',
        helperMaxLines: 2,
        errorText: widget.errorText,
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                key: const Key('foodBarcodeClearButton'),
                tooltip: 'Clear the barcode',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              ),
      ),
      onChanged: (value) {
        // Rebuilds so the clear button appears with the first digit and goes
        // away with the last.
        setState(() {});
        widget.onChanged(value);
      },
    );
  }
}
