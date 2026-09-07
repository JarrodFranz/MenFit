import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/onboarding/onboarding_providers.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:menfit_app/features/safety/safety_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/settings/presentation/widgets/data_export_tile.dart';
import 'package:menfit_app/features/settings/presentation/widgets/data_import_tile.dart';
import 'package:menfit_app/features/settings/presentation/widgets/food_search_region_tile.dart';
import 'package:menfit_app/features/settings/presentation/widgets/garmin_connect_dialog.dart';
import 'package:menfit_app/features/settings/settings_providers.dart';

/// Settings screen: profile entry point, the working theme-mode selector
/// (which proves state management + persistence end to end), and the
/// "Delete my data" flow.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final themeModeAsync = ref.watch(themeModeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.spacingMd),
          children: [
            Text(
              'Account & Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                subtitle: const Text('Name, units, and weekly goal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const SettingsProfileRouteData().go(context),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Fitness & Connected Devices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.sync_outlined),
                    title: const Text('Sync Fitness Device'),
                    subtitle: const Text(
                      'Read daily steps and active energy from Health '
                      'Connect / Apple Health',
                    ),
                    value: ref.watch(fitnessDeviceSyncControllerProvider),
                    onChanged: (enabled) async {
                      if (enabled) {
                        final ok = await ref
                            .read(healthSyncProvider.notifier)
                            .requestPermissions();
                        if (ok && context.mounted) {
                          await ref
                              .read(
                                fitnessDeviceSyncControllerProvider.notifier,
                              )
                              .toggle(enabled: true);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Health permissions were not granted. Open '
                                  'Health Connect / Apple Health settings to allow '
                                  'access.',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                        }
                      } else {
                        await ref
                            .read(fitnessDeviceSyncControllerProvider.notifier)
                            .toggle(enabled: false);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.watch_outlined),
                    title: const Text('Wearables & Watch Companion'),
                    subtitle: const Text(
                      'Garmin Connect auto-sync, Apple Watch, WearOS & live HR '
                      'sensors',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => const SettingsWearablesRouteData().go(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Garmin Connect'),
                    subtitle: const Text(
                      'Step-by-step instructions for linking Garmin Connect',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showGarminConnectDialog(context),
                  ),
                  const Divider(height: 1),

                  SwitchListTile(
                    secondary: const Icon(Icons.local_fire_department_outlined),
                    title: const Text('Workout Energy Estimates'),
                    subtitle: const Text(
                      'Show estimated energy used (kcal range) on logged '
                      'runs and walks. Off by default.',
                    ),
                    value: ref.watch(activityEnergyEstimatesControllerProvider),
                    onChanged: (enabled) async {
                      await ref
                          .read(
                            activityEnergyEstimatesControllerProvider.notifier,
                          )
                          .toggle(enabled: enabled);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            themeModeAsync.when(
              data: (mode) => _ThemeModeSelector(selected: mode),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(userMessageFor(error)),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Automatic Cycle & Monthly Recaps'),
                subtitle: const Text(
                  'Show an interactive story summary at the end of each '
                  'cycle and month',
                ),
                value: ref.watch(showAutomaticRecapsControllerProvider),
                onChanged: (enabled) async {
                  await ref
                      .read(showAutomaticRecapsControllerProvider.notifier)
                      .toggle(enabled: enabled);
                },
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Nutrition & Foods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu_outlined),
                title: const Text('My Foods Catalogue'),
                subtitle: const Text(
                  'View, edit, and manage custom and saved foods',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    const NutritionManageFoodsRouteData().push<void>(context),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Accessibility',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.accessibility_new_outlined),
                title: const Text('Accessibility & Display'),
                subtitle: const Text(
                  'Color blindness, high contrast, text size, and motion',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const SettingsAccessibilityRouteData().go(context),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Safety & Live Tracking',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Safety & Emergency Contacts'),
                subtitle: const Text(
                  'Trusted contacts, check-in timer, and inactivity SOS alerts',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const SettingsSafetyRouteData().go(context),
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'Data & Privacy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.shield_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Local & Private Data'),
                    subtitle: const Text(
                      'Your health, activity, and cycle data is stored '
                      'privately on this device.',
                    ),
                  ),
                  const Divider(height: 1),
                  // Here rather than under a nutrition heading: it decides
                  // what a food search sends off this device, which is the
                  // section this card is.
                  const FoodSearchRegionTile(),
                  const Divider(height: 1),
                  // Export and import: backup & restore data safely (ADR 015).
                  const DataExportTile(),
                  const Divider(height: 1),
                  const DataImportTile(),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacingMd,
                      vertical: tokens.spacingSm,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(
                            color: colorScheme.error.withValues(alpha: 0.5),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: tokens.spacingSm,
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: const Text('Delete my data'),
                        onPressed: () => _confirmAndDeleteData(context, ref),
                      ),
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

  /// Confirms with the user, then wipes every category of local data this
  /// app persists (the table-by-table sequence lives in
  /// `DeleteMyDataService`, ordered S3 first per
  /// `knowledge/engineering/security_and_privacy.md`), then resets the
  /// remaining SharedPreferences-backed UI preferences and the onboarding
  /// flag. Once that flag clears, the router's redirect (see
  /// `app/router/router.dart`) naturally sends the user back to
  /// onboarding - no explicit navigation needed here.
  Future<void> _confirmAndDeleteData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete my data?'),
        content: const Text(
          'This permanently deletes everything stored on this device: '
          'your profile (name, unit system, weekly goal), your logged '
          'activities and GPS routes, your saved routes, your logged '
          'cycle/period data, your check-ins and symptoms/flare-ups, your '
          'marked recovery days, your food diary (logged entries, saved '
          'foods, and nutrition targets), your weight history, your synced '
          'step history, your earned achievements, your buddy challenges, '
          'and your app preferences (theme). This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // The actual table-by-table wipe (ordering and rationale documented
      // there, not here) lives in `DeleteMyDataService` so it can be
      // exercised by a test with no widget tree - see
      // `features/settings/application/delete_my_data_service.dart` and
      // `test/features/settings/delete_my_data_covers_every_table_test.dart`.
      await ref.read(deleteMyDataServiceProvider).run();
      await ref.read(themeModeControllerProvider.notifier).clearAll();
      await ref
          .read(activityEnergyEstimatesControllerProvider.notifier)
          .toggle(enabled: false);
      await ref
          .read(fitnessDeviceSyncControllerProvider.notifier)
          .toggle(enabled: false);
      await ref.read(safetyRepositoryProvider).clearAll();
      await ref.read(onboardingStatusProvider.notifier).markIncomplete();
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
}

class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector({required this.selected});

  final ThemeMode selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        final mode = selection.first;
        unawaited(
          ref.read(themeModeControllerProvider.notifier).setThemeMode(mode),
        );
      },
    );
  }
}
