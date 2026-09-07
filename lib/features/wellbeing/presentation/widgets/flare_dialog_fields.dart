import 'package:flutter/material.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';

/// The "also mark these as recovery days" tick box.
///
/// Copy follows `knowledge/product/terminology.md`'s "Protected Recovery"
/// framing — recovery maintains the streak, is never a failure, and needs no
/// proof. The subtitle states the destructive half plainly: unticking
/// removes the recovery record on every date the flare covers, including any
/// note the user attached to it from another screen.
class RecoveryDaysCheckbox extends StatelessWidget {
  const RecoveryDaysCheckbox({
    required this.value,
    required this.isRange,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final bool isRange;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? (next) => onChanged(next ?? false) : null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        isRange
            ? 'Also mark these as recovery days'
            : 'Also mark this as a recovery day',
      ),
      subtitle: Text(
        isRange
            ? 'Recovery days keep your streak going and need no proof. '
                  'Unticking removes the recovery day on every date this '
                  'flare-up covers, along with any note saved on those days.'
            : 'Recovery days keep your streak going and need no proof. '
                  'Unticking removes the recovery day on this date, along '
                  'with any note saved on it.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// A single tappable "how did this affect training" option — a hand-rolled
/// selectable row rather than [RadioListTile] so this dialog doesn't need
/// to depend on a group-value ancestor widget for a simple 3-option choice.
class ImpactOption extends StatelessWidget {
  const ImpactOption({
    required this.impact,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final FlareImpact impact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(impact.label)),
          ],
        ),
      ),
    );
  }
}
