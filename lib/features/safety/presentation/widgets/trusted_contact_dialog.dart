import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';

/// Shows a dialog for creating or editing a [TrustedContact].
///
/// Resolves to the saved [TrustedContact], or `null` if cancelled.
Future<TrustedContact?> showTrustedContactDialog(
  BuildContext context, {
  TrustedContact? initialContact,
}) {
  return showDialog<TrustedContact>(
    context: context,
    builder: (dialogContext) =>
        TrustedContactDialog(initialContact: initialContact),
  );
}

class TrustedContactDialog extends StatefulWidget {
  const TrustedContactDialog({super.key, this.initialContact});

  final TrustedContact? initialContact;

  @override
  State<TrustedContactDialog> createState() => _TrustedContactDialogState();
}

class _TrustedContactDialogState extends State<TrustedContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late ContactRelationship _relationship;
  late bool _isPrimary;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialContact?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialContact?.phone ?? '',
    );
    _relationship =
        widget.initialContact?.relationship ?? ContactRelationship.other;
    _isPrimary = widget.initialContact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final contact = widget.initialContact != null
        ? widget.initialContact!.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            relationship: _relationship,
            isPrimary: _isPrimary,
          )
        : TrustedContact.create(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            relationship: _relationship,
            isPrimary: _isPrimary,
          );

    Navigator.of(context).pop(contact);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final isEditing = widget.initialContact != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Sarah Connor',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: tokens.spacingSm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. +61 400 000 000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: tokens.spacingSm),
              DropdownButtonFormField<ContactRelationship>(
                initialValue: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
                items: ContactRelationship.values.map((rel) {
                  return DropdownMenuItem(
                    value: rel,
                    child: Text(rel.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _relationship = val);
                  }
                },
              ),
              SizedBox(height: tokens.spacingSm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Primary Contact'),
                subtitle: const Text(
                  'Default recipient for quick emergency alerts',
                ),
                value: _isPrimary,
                onChanged: (val) => setState(() => _isPrimary = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
