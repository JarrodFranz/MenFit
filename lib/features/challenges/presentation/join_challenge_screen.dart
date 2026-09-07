import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/challenges/application/challenge_code_service.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/domain/challenge_validation.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// Joins the challenge a pasted code describes.
///
/// Reached at `/challenges/join`.
///
/// ## The code is decoded as they type
///
/// `decodeChallengeCode` is pure and local (`domain/challenge_codes.dart`)
/// — no network, no database — so there is no reason to make them press a
/// button to find out whether the string they pasted is the right one. A
/// good code shows what it describes; a bad one says which of the five
/// things went wrong, in words that never blame them for what a chat app
/// did to a string in transit
/// (`challenges_copy.dart#joinCodeRejectionMessage`).
class JoinChallengeScreen extends ConsumerStatefulWidget {
  const JoinChallengeScreen({super.key});

  @override
  ConsumerState<JoinChallengeScreen> createState() =>
      _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends ConsumerState<JoinChallengeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  ChallengeBlueprint? _preview;
  CodeRejection? _rejection;
  ChallengeValidation _validation = const ChallengeValidation();
  String? _saveError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String raw) {
    if (raw.trim().isEmpty) {
      setState(() {
        _preview = null;
        _rejection = null;
      });
      return;
    }
    final decoded = decodeChallengeCode(raw.trim());
    setState(() {
      switch (decoded) {
        case CodeDecoded<ChallengeBlueprint>(:final value):
          _preview = value;
          _rejection = null;
        case CodeRejected<ChallengeBlueprint>(:final reason):
          _preview = null;
          _rejection = reason;
      }
    });
  }

  Future<void> _submit() async {
    final today = ref.read(challengesTodayProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _saveError = null;
      _isSubmitting = true;
    });

    JoinChallengeResult result;
    try {
      result = await ref
          .read(challengeCodeServiceProvider)
          .joinFromCode(
            _codeController.text.trim(),
            displayName: _nameController.text,
            today: today,
          );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _saveError = userMessageFor(error);
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ChallengeJoined():
        messenger.showSnackBar(
          const SnackBar(content: Text(joinedMessage)),
        );
        navigator.pop();
      case ChallengeAlreadyJoined():
        messenger.showSnackBar(
          const SnackBar(content: Text(alreadyJoinedMessage)),
        );
        navigator.pop();
      case ChallengeCodeUnusable(:final reason):
        setState(() {
          _preview = null;
          _rejection = reason;
        });
      case ChallengeJoinRejected(:final validation):
        setState(() => _validation = validation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(title: const Text(joinChallengeTitle)),
      body: SafeArea(
        // Pinned to the top: a Center around a shrink-wrapping scroll view
        // floats short content mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('joinCodeField'),
                    controller: _codeController,
                    autofocus: true,
                    maxLines: 2,
                    minLines: 1,
                    onChanged: _onCodeChanged,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: joinCodeFieldLabel,
                      helperText: joinCodeHelper,
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  if (_rejection case final rejection?)
                    FieldErrorText(joinCodeRejectionMessage(rejection)),
                  if (_preview case final preview?)
                    _CodePreview(blueprint: preview),
                  SizedBox(height: tokens.spacingMd),
                  TextField(
                    key: const Key('joinNameField'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: displayNameFieldLabel,
                      helperText: displayNameHelper,
                      errorText: _validation.displayNameError,
                    ),
                  ),
                  if (_validation.windowError case final error?) ...[
                    SizedBox(height: tokens.spacingSm),
                    FieldErrorText(error),
                  ],
                  if (_validation.targetError case final error?) ...[
                    SizedBox(height: tokens.spacingSm),
                    FieldErrorText(error),
                  ],
                  if (_saveError case final error?) ...[
                    SizedBox(height: tokens.spacingSm),
                    FieldErrorText(error),
                  ],
                  SizedBox(height: tokens.spacingLg),
                  FilledButton(
                    key: const Key('joinSubmitButton'),
                    onPressed: _isSubmitting || _preview == null
                        ? null
                        : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(joinSubmitLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the pasted code turned out to describe.
class _CodePreview extends StatelessWidget {
  const _CodePreview({required this.blueprint});

  final ChallengeBlueprint blueprint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Container(
      key: const Key('joinCodePreview'),
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        joinCodePreviewLine(blueprint),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
