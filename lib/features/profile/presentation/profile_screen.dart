import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/profile_controller.dart';
import 'package:menfit_app/features/profile/presentation/widgets/about_you_section.dart';
import 'package:menfit_app/features/profile/presentation/widgets/run_profile_update.dart';
import 'package:menfit_app/features/profile/presentation/widgets/training_section.dart';

/// View/edit screen for the local user's profile. Reached from Settings.
///
/// Organised into clean, accessible card sections with a top AppBar save
/// affordance providing immediate visual feedback when saved.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return profileAsync.when(
      data: (profile) => _ProfileForm(profile: profile),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(userMessageFor(error)),
        ),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile});

  final UserProfile? profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _nameController;
  final _aboutYouKey = GlobalKey<AboutYouSectionState>();
  bool _saved = false;
  bool _isSaving = false;
  Timer? _savedTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.displayName ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync the field when a *different* profile identity arrives
    // (e.g. it was just created) - never clobber in-progress typing when a
    // rebuild is just an echo of our own save.
    if (oldWidget.profile?.id != widget.profile?.id) {
      _nameController.text = widget.profile?.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _savedTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await ref
            .read(profileControllerProvider.notifier)
            .updateProfile(displayName: name);
      }
      final aboutYouSuccess =
          await _aboutYouKey.currentState?.savePending() ?? true;
      if (!mounted) return;
      if (aboutYouSuccess) {
        setState(() => _saved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _savedTimer?.cancel();
        _savedTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saved = false);
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              key: const Key('profileSaveButton'),
              onPressed: _isSaving ? null : _saveAll,
              icon: Icon(
                _saved ? Icons.check_circle : Icons.save_outlined,
                color: _saved ? colorScheme.primary : null,
                size: 20,
              ),
              label: Text(
                _saved ? 'Saved' : 'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _saved ? colorScheme.primary : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: _fields(context, tokens),
          ),
        ),
      ),
    );
  }

  Widget _fields(BuildContext context, AppTokens tokens) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: colorScheme.primary),
                    SizedBox(width: tokens.spacingSm),
                    Text(
                      'Display name',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                TextField(
                  key: const Key('profileNameField'),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => _saveName(context, value),
                ),
                SizedBox(height: tokens.spacingSm),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: () => _saveName(context, _nameController.text),
                    child: const Text('Save name'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: AboutYouSection(
              key: _aboutYouKey,
              profile: widget.profile,
            ),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: TrainingSection(profile: widget.profile),
          ),
        ),
      ],
    );
  }

  Future<void> _saveName(BuildContext context, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return Future<void>.value();
    return runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(displayName: trimmed),
    );
  }
}
