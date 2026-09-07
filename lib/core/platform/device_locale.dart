import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_locale.g.dart';

/// The device's language and country, as two plain strings.
///
/// A deliberately tiny value type rather than `dart:ui`'s [Locale]: the code
/// that consumes this lives in feature `domain/` layers, which may not import
/// Flutter (`knowledge/architecture/architecture_overview.md`, rule 1). This
/// is the adapter boundary — Flutter's locale goes in, two strings come out.
@immutable
class DeviceLocale {
  const DeviceLocale({required this.languageCode, this.countryCode});

  /// ISO 639 language code as the platform reports it (`en`, `de`, `bg`).
  /// Not normalised here; consumers decide what a usable code is.
  final String languageCode;

  /// ISO 3166 region code (`AU`, `GB`), or `null` where the platform reports
  /// a bare language. A language with no country is normal — it is what a
  /// device set to "English" with no region gives.
  final String? countryCode;

  @override
  bool operator ==(Object other) =>
      other is DeviceLocale &&
      other.languageCode == languageCode &&
      other.countryCode == countryCode;

  @override
  int get hashCode => Object.hash(languageCode, countryCode);

  @override
  String toString() {
    final region = countryCode == null ? '' : '-$countryCode';
    return 'DeviceLocale($languageCode$region)';
  }
}

/// The locale the platform currently reports for this device.
///
/// Read from the platform dispatcher rather than from a `BuildContext`'s
/// `Localizations` on purpose: this answers "where is this phone", which is a
/// device fact available before any widget is built, whereas the context
/// answer is "which of *our* supported locales did we resolve to" — and this
/// app ships one. The two would differ on an Australian phone the moment a
/// second app locale is added, and the food database wants the device's.
DeviceLocale readDeviceLocale() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  return DeviceLocale(
    languageCode: locale.languageCode,
    countryCode: locale.countryCode,
  );
}

/// [readDeviceLocale] as a provider, so tests and future in-app overrides can
/// substitute one without reaching into the binding.
///
/// `keepAlive` because it is read from app-scoped services and the platform
/// value does not change under us within a session. A device whose locale is
/// changed while the app runs keeps the old value until restart — acceptable
/// for a search default that is also user-overridable in Settings, and the
/// alternative (a `WidgetsBindingObserver` here) would put a listener in a
/// leaf accessor.
@Riverpod(keepAlive: true)
DeviceLocale deviceLocale(Ref ref) => readDeviceLocale();
