import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/safety/domain/safety_preferences.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';
import 'package:menfit_app/features/safety/presentation/widgets/trusted_contact_dialog.dart';
import 'package:menfit_app/features/safety/safety_providers.dart';

/// Settings screen for managing emergency contacts, safety check-in timer,
/// and inactivity SOS alert preferences.
class SafetySettingsScreen extends ConsumerWidget {
  const SafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final contacts = ref.watch(trustedContactsControllerProvider);
    final prefs = ref.watch(safetyPreferencesControllerProvider);
    final contactsController = ref.read(
      trustedContactsControllerProvider.notifier,
    );
    final prefsController = ref.read(
      safetyPreferencesControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety & Emergency Contacts'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacingMd),
          children: [
            // Privacy Banner
            _PrivacyBanner(tokens: tokens, colorScheme: colorScheme),
            SizedBox(height: tokens.spacingLg),

            // Section 1: Trusted Contacts
            _SectionHeader(
              title: 'Trusted Contacts',
              actionLabel: '+ Add Contact',
              onAction: () async {
                final newContact = await showTrustedContactDialog(context);
                if (newContact != null) {
                  await contactsController.addContact(newContact);
                }
              },
            ),
            SizedBox(height: tokens.spacingSm),
            _ContactsCard(
              contacts: contacts,
              tokens: tokens,
              colorScheme: colorScheme,
              onEdit: (contact) async {
                final updated = await showTrustedContactDialog(
                  context,
                  initialContact: contact,
                );
                if (updated != null) {
                  await contactsController.updateContact(updated);
                }
              },
              onDelete: (contactId) async {
                await contactsController.deleteContact(contactId);
              },
              onSetPrimary: (contactId) async {
                await contactsController.setPrimary(contactId);
              },
            ),
            SizedBox(height: tokens.spacingLg),

            // Section 2: Safety Check-in Timer
            const _SectionHeader(title: 'Safety Check-in Timer'),
            SizedBox(height: tokens.spacingSm),
            _CheckinTimerCard(
              prefs: prefs,
              tokens: tokens,
              colorScheme: colorScheme,
              onToggle: (enabled) {
                unawaited(prefsController.toggleCheckinTimer(enabled: enabled));
              },
              onSelectDuration: (mins) {
                unawaited(prefsController.setDefaultDuration(mins));
              },
            ),
            SizedBox(height: tokens.spacingLg),

            // Section 3: Inactivity SOS Alert
            const _SectionHeader(title: 'Inactivity SOS Alert'),
            SizedBox(height: tokens.spacingSm),
            _InactivityAlertCard(
              prefs: prefs,
              tokens: tokens,
              colorScheme: colorScheme,
              onToggle: (enabled) {
                unawaited(
                  prefsController.toggleInactivityAlert(enabled: enabled),
                );
              },
              onSelectThreshold: (mins) {
                unawaited(prefsController.setInactivityThreshold(mins));
              },
              onSelectCountdown: (secs) {
                unawaited(prefsController.setWarningCountdown(secs));
              },
            ),
            SizedBox(height: tokens.spacingLg),

            // Section 4: Emergency Message Preview & Test
            const _SectionHeader(title: 'Emergency Message Preview'),
            SizedBox(height: tokens.spacingSm),
            _MessagePreviewCard(
              prefs: prefs,
              tokens: tokens,
              colorScheme: colorScheme,
              onUpdateCustomMessage: (msg) {
                unawaited(prefsController.setCustomMessage(msg));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner({required this.tokens, required this.colorScheme});

  final AppTokens tokens;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              color: colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '100% On-Device & Private',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacingXs),
                  Text(
                    'Your emergency contacts and location never leave this '
                    'phone. Alerts are sent directly through your phone’s '
                    'native SMS or share menu.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsCard extends StatelessWidget {
  const _ContactsCard({
    required this.contacts,
    required this.tokens,
    required this.colorScheme,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  final List<TrustedContact> contacts;
  final AppTokens tokens;
  final ColorScheme colorScheme;
  final ValueChanged<TrustedContact> onEdit;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onSetPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (contacts.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 40,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                'No Emergency Contacts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.spacingXs),
              Text(
                'Add trusted contacts to be notified if you stop moving or '
                'miss a check-in deadline.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < contacts.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ContactTile(
              contact: contacts[i],
              tokens: tokens,
              colorScheme: colorScheme,
              onEdit: () => onEdit(contacts[i]),
              onDelete: () => onDelete(contacts[i].id),
              onSetPrimary: () => onSetPrimary(contacts[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.tokens,
    required this.colorScheme,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  final TrustedContact contact;
  final AppTokens tokens;
  final ColorScheme colorScheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: contact.isPrimary
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Icon(
          contact.isPrimary ? Icons.star : Icons.person_outline,
          color: contact.isPrimary
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              contact.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (contact.isPrimary) ...[
            SizedBox(width: tokens.spacingXs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRIMARY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text('${contact.relationship.label} • ${contact.phone}'),
      trailing: PopupMenuButton<String>(
        onSelected: (val) {
          switch (val) {
            case 'edit':
              onEdit();
            case 'primary':
              onSetPrimary();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          if (!contact.isPrimary)
            const PopupMenuItem(
              value: 'primary',
              child: Text('Set as Primary'),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CheckinTimerCard extends StatelessWidget {
  const _CheckinTimerCard({
    required this.prefs,
    required this.tokens,
    required this.colorScheme,
    required this.onToggle,
    required this.onSelectDuration,
  });

  final SafetyPreferences prefs;
  final AppTokens tokens;
  final ColorScheme colorScheme;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onSelectDuration;

  static const _durations = [30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Safety Check-in Timer'),
            subtitle: const Text(
              'Prompts for your estimated workout duration and alerts contacts '
              'if you do not return in time.',
            ),
            value: prefs.checkinTimerEnabled,
            onChanged: onToggle,
          ),
          if (prefs.checkinTimerEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Expected Duration',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  Wrap(
                    spacing: tokens.spacingSm,
                    children: _durations.map((mins) {
                      final isSelected = prefs.defaultExpectedMinutes == mins;
                      return ChoiceChip(
                        label: Text('${mins}m'),
                        selected: isSelected,
                        onSelected: (_) => onSelectDuration(mins),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InactivityAlertCard extends StatelessWidget {
  const _InactivityAlertCard({
    required this.prefs,
    required this.tokens,
    required this.colorScheme,
    required this.onToggle,
    required this.onSelectThreshold,
    required this.onSelectCountdown,
  });

  final SafetyPreferences prefs;
  final AppTokens tokens;
  final ColorScheme colorScheme;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onSelectThreshold;
  final ValueChanged<int> onSelectCountdown;

  static const _thresholds = [3, 4, 5, 10];
  static const _countdowns = [30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Stationary Inactivity Detection'),
            subtitle: const Text(
              'Triggers an alert countdown if you stop moving '
              'unexpectedly during an outdoor GPS activity.',
            ),
            value: prefs.inactivityAlertEnabled,
            onChanged: onToggle,
          ),
          if (prefs.inactivityAlertEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stationary Wait Time',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  Wrap(
                    spacing: tokens.spacingSm,
                    children: _thresholds.map((mins) {
                      final isSelected =
                          prefs.inactivityThresholdMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        onSelected: (_) => onSelectThreshold(mins),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: tokens.spacingMd),
                  Text(
                    'Warning Countdown Grace Period',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  Wrap(
                    spacing: tokens.spacingSm,
                    children: _countdowns.map((secs) {
                      final isSelected = prefs.warningCountdownSeconds == secs;
                      return ChoiceChip(
                        label: Text('${secs}s'),
                        selected: isSelected,
                        onSelected: (_) => onSelectCountdown(secs),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessagePreviewCard extends ConsumerStatefulWidget {
  const _MessagePreviewCard({
    required this.prefs,
    required this.tokens,
    required this.colorScheme,
    required this.onUpdateCustomMessage,
  });

  final SafetyPreferences prefs;
  final AppTokens tokens;
  final ColorScheme colorScheme;
  final ValueChanged<String?> onUpdateCustomMessage;

  @override
  ConsumerState<_MessagePreviewCard> createState() =>
      _MessagePreviewCardState();
}

class _MessagePreviewCardState extends ConsumerState<_MessagePreviewCard> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(
      text: widget.prefs.customMessage ?? '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(safetyCheckinEngineProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final userName = profileAsync.value?.displayName ?? 'Runner';

    final previewMessage = engine.generateEmergencyMessage(
      userName: userName,
      timestamp: DateTime.now(),
      latitude: -33.8688,
      longitude: 151.2093,
      customMessage: widget.prefs.customMessage,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(widget.tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(widget.tokens.spacingMd),
              decoration: BoxDecoration(
                color: widget.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(widget.tokens.radiusSm),
                border: Border.all(
                  color: widget.colorScheme.outlineVariant,
                ),
              ),
              child: SelectableText(
                previewMessage,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: widget.tokens.spacingMd),
            TextField(
              controller: _customController,
              decoration: const InputDecoration(
                labelText: 'Optional Custom Note / Medical Info',
                hintText: 'e.g. Asthmatic, carrying inhaler',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              onSubmitted: widget.onUpdateCustomMessage,
              onEditingComplete: () {
                widget.onUpdateCustomMessage(_customController.text);
              },
            ),
            SizedBox(height: widget.tokens.spacingMd),
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined),
              label: const Text('Test Send SOS Alert'),
              onPressed: () {
                unawaited(
                  ref
                      .read(sharingAdapterProvider)
                      .shareText(
                        previewMessage,
                        subject: 'FemFit Safety Alert (Test)',
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
