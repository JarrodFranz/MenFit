import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// Shown once, before the **first** request this app ever makes to the food
/// database, and not again after that.
///
/// A real gate, not an announcement: [show] completes `false` when the user
/// backs out, and the caller abandons the lookup
/// (`data/online_lookup_notice_store.dart#grantOnlineLookupConsent`). A
/// notice you can only agree to is a delay, not consent.
///
/// It names the four things a person actually needs to decide with — what
/// goes out (all of it: the words or the barcode, **and** the region and
/// language setting), who receives it, what does *not* go out, and what gets
/// kept —
/// because searching a food database is the first time this app sends
/// anything the user typed off her device (ADR 010). The voice is
/// `domain/nutrition_validation.dart`'s: plain, non-clinical, not alarming,
/// and not pleading for a yes.
///
/// ## The "what does not go out" claim is bounded, and says so
///
/// This copy used to read "nothing that identifies you goes with it", which
/// is not true of any HTTP request: the recipient sees the requesting IP
/// address. `core/platform/barcode_scanning.dart` treats exactly that
/// disclosure as material enough to **withhold web barcode scanning over
/// it**, and a consent dialog cannot be more relaxed about a fact than the
/// code two layers down. So the promise is now the one we can actually
/// keep — nothing from her account or her diary — and the address is stated
/// plainly, next to the everyday comparison that makes it proportionate
/// rather than frightening.
class OnlineLookupNoticeDialog extends StatelessWidget {
  const OnlineLookupNoticeDialog({
    required this.attributionName,
    required this.attributionUrl,
    super.key,
  });

  /// The data source's own name, from `FoodDataProvider.attributionName`.
  /// Read from the provider rather than written into this copy so the
  /// screen cannot end up naming a source we no longer use.
  final String attributionName;

  /// The data source's home page, from `FoodDataProvider.attributionUrl`.
  final String attributionUrl;

  /// Returns `true` to go ahead with the lookup, `false` to abandon it —
  /// including when the dialog is dismissed by tapping outside or by the
  /// system back gesture, which are both ways of saying no.
  static Future<bool> show(
    BuildContext context, {
    required String attributionName,
    required String attributionUrl,
  }) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => OnlineLookupNoticeDialog(
        attributionName: attributionName,
        attributionUrl: attributionUrl,
      ),
    );
    return proceed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Looking a food up online'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To find a food you have not saved yet, we send what you '
                'typed — the words, or the barcode — to $attributionName.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              // Named because this dialog's promise is to list everything
              // that goes out, and an unmentioned parameter would make the
              // paragraph below it less believable. A country and a language
              // describe the shelf being searched, not the shopper — see
              // `domain/food_search_region.dart`.
              Text(
                'Your food database region and language setting goes too, so '
                'the results are things you can actually buy and read.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                'Nothing from your account or your diary goes with it. No '
                'name, no account, nothing else you have logged.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                'As with any website you open, $attributionName can see '
                "your device's internet address.",
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                'A result is only kept if you choose to save it. Foods you '
                'have already saved are found on this device, without asking '
                'anyone.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              // The source is named with its address so "a public food
              // database" is checkable rather than a phrase.
              SelectableText(
                attributionUrl,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('onlineLookupNoticeDecline'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          key: const Key('onlineLookupNoticeAccept'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Search online'),
        ),
      ],
    );
  }
}
