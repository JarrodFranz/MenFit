import 'package:flutter/material.dart';
import 'package:menfit_app/core/errors/error_messages.dart';

/// Runs [action] and, if it throws, surfaces a friendly message via a
/// snackbar instead of letting the error disappear silently.
///
/// Shared by `../profile_screen.dart` and every section widget under this
/// directory - every profile-edit control routes its save through this
/// instead of fire-and-forgetting the update.
Future<void> runProfileUpdate(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on Object catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(userMessageFor(error)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
