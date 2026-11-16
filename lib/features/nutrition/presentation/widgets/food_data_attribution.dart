import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// Names the food database a screen is showing data from, with an address
/// that reaches it.
///
/// **A licence obligation, not decoration.** Open Food Facts data is ODbL,
/// which requires attribution wherever the data is used, and requires a link
/// to the specific source record when reproducing information about a
/// particular product (ADR 010) — which is what [url] carries on the review
/// screen. Every surface that renders provider data has to include one of
/// these; removing it is a licence breach, not a visual tidy-up.
///
/// The address is rendered as [SelectableText] the user can copy rather
/// than as a tappable link: `url_launcher` is not a dependency and adding
/// one has to go through the `package-evaluation` workflow, which was out
/// of scope for S1-5. Copyable text satisfies "a link to the source" in
/// substance; a tap would satisfy it better.
// TODO(menfit): evaluate url_launcher and make this address tappable.
class FoodDataAttribution extends StatelessWidget {
  const FoodDataAttribution({
    required this.name,
    required this.url,
    super.key,
  });

  /// From `FoodDataProvider.attributionName` — read from the provider
  /// rather than hard-coded, so no screen can end up crediting a source we
  /// no longer use.
  final String name;

  /// From `FoodDataProvider.attributionUrl`, or `productPageUrl(barcode)`
  /// when a screen is showing one particular product.
  final String url;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name == 'FatSecret'
                ? 'Powered by fatsecret Platform API'
                : 'Food data from $name',
            style: style,
          ),
          SizedBox(height: tokens.spacingXs),
          SelectableText(
            name == 'FatSecret' ? 'https://platform.fatsecret.com' : url,
            style: style,
          ),
        ],
      ),
    );
  }
}
