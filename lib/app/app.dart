import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';

/// The root application widget.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode =
        ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final accessibility = ref.watch(accessibilityControllerProvider);

    return MaterialApp.router(
      title: AppEnv.instance.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accessibility),
      darkTheme: AppTheme.dark(accessibility),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final currentMediaQuery = MediaQuery.of(context);
        final baseScale = currentMediaQuery.textScaler.scale(1);
        final userScaleFactor = accessibility.textScale.scaleFactor;
        // The larger of the two, never a replacement of the OS setting.
        //
        // The presets are absolute percentages of the app's own type scale
        // ("115%", "150%"), not multipliers, so *multiplying* would take an
        // OS at 200% to 300% — a size no layout survives and no user asked
        // for. But picking the app's value outright made an in-app choice
        // able to shrink text below what the system was already rendering:
        // OS 130% + app "Large (115%)" used to resolve to 1.15, so an
        // accessibility control reduced accessibility. `max` honours
        // whichever request is stronger and can never regress below the OS.
        final targetScale = math.max(baseScale, userScaleFactor);

        return MediaQuery(
          data: currentMediaQuery.copyWith(
            textScaler: TextScaler.linear(targetScale),
            boldText: accessibility.boldText || currentMediaQuery.boldText,
            disableAnimations:
                accessibility.reduceMotion ||
                currentMediaQuery.disableAnimations,
            highContrast:
                accessibility.highContrast || currentMediaQuery.highContrast,
          ),
          child: child,
        );
      },
    );
  }
}
