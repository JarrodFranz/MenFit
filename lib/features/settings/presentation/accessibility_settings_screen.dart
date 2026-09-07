import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';

/// Screen allowing users to configure visual, motion, tactile, and
/// screen reader accessibility options.
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final prefs = ref.watch(accessibilityControllerProvider);
    final controller = ref.read(accessibilityControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacingMd),
          children: [
            // Interactive Live Preview
            _LivePreviewCard(prefs: prefs),
            SizedBox(height: tokens.spacingLg),

            // Visual & Sight Options
            Text(
              'Visual & Sight',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Color Vision Mode'),
                    subtitle: Text(prefs.colorBlindness.description),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spacingMd,
                      0,
                      tokens.spacingMd,
                      tokens.spacingSm,
                    ),
                    child: Wrap(
                      spacing: tokens.spacingSm,
                      runSpacing: tokens.spacingSm,
                      children: ColorBlindnessMode.values.map((mode) {
                        final isSelected = prefs.colorBlindness == mode;
                        return ChoiceChip(
                          label: Text(mode.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              unawaited(controller.setColorBlindness(mode));
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.contrast),
                    title: const Text('High Contrast'),
                    subtitle: const Text(
                      'Boosts borders, card separation and text contrast.',
                    ),
                    value: prefs.highContrast,
                    onChanged: (enabled) =>
                        unawaited(controller.setHighContrast(enabled: enabled)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.format_size),
                    title: const Text('Text Size Scale'),
                    subtitle: Text(prefs.textScale.description),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spacingMd,
                      0,
                      tokens.spacingMd,
                      tokens.spacingSm,
                    ),
                    child: SegmentedButton<TextScalePreset>(
                      // The selected-check icon stole enough width at 150%
                      // that "150%" wrapped to "150 / %" - the fill colour
                      // already marks the selection (seen on device).
                      showSelectedIcon: false,
                      segments: TextScalePreset.values.map((preset) {
                        return ButtonSegment(
                          value: preset,
                          label: Text(
                            preset.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      selected: {prefs.textScale},
                      onSelectionChanged: (selected) {
                        if (selected.isNotEmpty) {
                          unawaited(controller.setTextScale(selected.first));
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.format_bold),
                    title: const Text('Bold Text'),
                    subtitle: const Text(
                      'Increases font thickness throughout the app for '
                      'improved legibility.',
                    ),
                    value: prefs.boldText,
                    onChanged: (enabled) =>
                        unawaited(controller.setBoldText(enabled: enabled)),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingLg),

            // Motion & Physical Interaction
            Text(
              'Motion & Touch',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.motion_photos_off_outlined),
                    title: const Text('Reduce Motion'),
                    subtitle: const Text(
                      'Minimizes transitions, animated rings, and pulsing '
                      'effects for vestibular comfort.',
                    ),
                    value: prefs.reduceMotion,
                    onChanged: (enabled) =>
                        unawaited(controller.setReduceMotion(enabled: enabled)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.touch_app_outlined),
                    title: const Text('Large Touch Targets'),
                    subtitle: const Text(
                      'Enforces a minimum 48×48 dp bounding area for '
                      'interactive buttons and chips.',
                    ),
                    value: prefs.largeTouchTargets,
                    onChanged: (enabled) => unawaited(
                      controller.setLargeTouchTargets(enabled: enabled),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.vibration_outlined),
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text(
                      'Vibrates on workout timer intervals, lap taps, '
                      'and activity completions.',
                    ),
                    value: prefs.hapticFeedback,
                    onChanged: (enabled) => unawaited(
                      controller.setHapticFeedback(enabled: enabled),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Sound cues'),
                    subtitle: const Text(
                      'Play a soft chime at pose transitions and interval '
                      'boundaries.',
                    ),
                    value: prefs.soundCues,
                    onChanged: (enabled) =>
                        unawaited(controller.setSoundCues(enabled: enabled)),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingLg),

            // Screen Reader & Semantics
            Text(
              'Screen Reader & Audio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                secondary: const Icon(Icons.record_voice_over_outlined),
                title: const Text('Enhanced Semantics'),
                // "workout splits" was in this sentence and was never
                // built. A settings screen that promises a screen-reader
                // feature the app does not have is worse than one that
                // promises less: the user turns it on, hears nothing new on
                // the split list, and reasonably concludes the whole switch
                // is broken. It now names exactly what it delivers.
                subtitle: const Text(
                  'Provides detailed TalkBack / VoiceOver descriptions '
                  'for charts and calendar days.',
                ),
                value: prefs.enhancedSemantics,
                onChanged: (enabled) => unawaited(
                  controller.setEnhancedSemantics(enabled: enabled),
                ),
              ),
            ),
            SizedBox(height: tokens.spacingLg),

            // Reset Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
              ),
              onPressed: () async {
                await controller.resetDefaults();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Accessibility settings reset to default'),
                      duration: Duration(seconds: 2),
                    ),
                  );
              },
              icon: const Icon(Icons.restart_alt, size: 20),
              label: const Text('Reset Accessibility Defaults'),
            ),
            SizedBox(height: tokens.spacingLg),
          ],
        ),
      ),
    );
  }
}

/// Live interactive card demonstrating the currently active accessibility
/// theme, colorblind palette, and text scaling in real time.
class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.prefs});

  final AccessibilityPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : const Color(0xFFF9F7FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: prefs.highContrast
              ? (theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
              : const Color(0xFFE4DCE6),
          width: prefs.highContrast ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live Preview',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${prefs.colorBlindness.label} · ${prefs.textScale.label}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            // Sample text preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.white,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(
                  color: prefs.highContrast
                      ? (theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                      : const Color(0xFFECE7EE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empowering movement for every body.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: prefs.boldText
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next session: 45-minute moderate strength block',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            // Color palette swatches
            Text(
              'Colorblind-Safe Intensity Indicators:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SwatchChip(
                  label: 'Easy',
                  icon: Icons.self_improvement_outlined,
                  color: tokens.intensityEasy,
                ),
                _SwatchChip(
                  label: 'Moderate',
                  icon: Icons.directions_run_outlined,
                  color: tokens.intensityModerate,
                ),
                _SwatchChip(
                  label: 'Hard',
                  icon: Icons.local_fire_department_outlined,
                  color: tokens.intensityHard,
                ),
                _SwatchChip(
                  label: 'Recovery',
                  icon: Icons.bedtime_outlined,
                  color: tokens.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchChip extends StatelessWidget {
  const _SwatchChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
