import 'package:flutter/material.dart';

/// Shows a single-text-field dialog for naming/renaming a route and
/// resolves to the entered text, or `null` when cancelled.
///
/// The confirm action is disabled while the field is blank: a blank name
/// used to resolve the dialog and then silently do nothing (rename) or
/// quietly substitute a generated name (save), neither of which the user
/// could tell apart from a broken button.
///
/// The [TextEditingController] is owned by the dialog's own State and
/// disposed in its `dispose()` — NOT by the caller after `showDialog`
/// returns. `showDialog`'s future resolves when the pop *starts*, while
/// the dialog subtree keeps listening to the controller through the exit
/// animation; a caller-side dispose at that point throws "used after being
/// disposed" mid-animation (seen wedging widget tests, but a real
/// production crash).
Future<String?> showRouteNameDialog(
  BuildContext context, {
  required String title,
  required String initialName,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _RouteNameDialog(
      title: title,
      initialName: initialName,
    ),
  );
}

class _RouteNameDialog extends StatefulWidget {
  const _RouteNameDialog({required this.title, required this.initialName});

  final String title;
  final String initialName;

  @override
  State<_RouteNameDialog> createState() => _RouteNameDialogState();
}

class _RouteNameDialogState extends State<_RouteNameDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _nameController,
          builder: (context, value, child) => FilledButton(
            onPressed: value.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_nameController.text),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
