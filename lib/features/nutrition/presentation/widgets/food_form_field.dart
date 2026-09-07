import 'package:flutter/material.dart';

/// The semantics label read out beside a value a scan was unsure of.
///
/// A visual marker alone would be invisible to a screen-reader user on the
/// one screen where an unchecked number becomes a saved food.
const lowConfidenceSemanticsLabel = 'low confidence, please check';

/// One text field of the food form.
///
/// Owns its own [TextEditingController] so the value can be replaced from
/// outside — a label scan fills blanks, and the field has to show what the
/// state now holds — while never fighting the cursor of someone typing:
/// [value] is only assigned into the controller when the two have actually
/// diverged.
class FoodFormTextField extends StatefulWidget {
  const FoodFormTextField({
    required this.fieldKey,
    required this.label,
    required this.onChanged,
    super.key,
    this.helperText,
    this.errorText,
    this.value,
    this.numeric = false,
    this.lowConfidence = false,
  });

  final String fieldKey;
  final String label;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final String? errorText;
  final String? value;
  final bool numeric;

  /// Marks the field as read off a label with a poor score (ADR 012).
  ///
  /// It is a pointer, not a verdict: every scanned value is reviewed
  /// regardless, and this only says which one to look at first.
  final bool lowConfidence;

  @override
  State<FoodFormTextField> createState() => _FoodFormTextFieldState();
}

class _FoodFormTextFieldState extends State<FoodFormTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant FoodFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
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
      key: Key(widget.fieldKey),
      controller: _controller,
      keyboardType: widget.numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        suffixIcon: widget.lowConfidence
            ? Semantics(
                label: lowConfidenceSemanticsLabel,
                child: Icon(
                  key: Key('${widget.fieldKey}LowConfidence'),
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              )
            : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
