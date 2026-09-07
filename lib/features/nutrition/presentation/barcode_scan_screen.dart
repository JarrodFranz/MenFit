import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/core/platform/barcode_scanning.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;

/// Full-screen camera preview that pops a validated, canonical barcode string
/// back to whoever pushed it, or `null` when the user backs out.
///
/// ```dart
/// final code = await Navigator.of(context).push<String>(
///   MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
/// );
/// ```
///
/// **This is the only file in the app that may import
/// `package:mobile_scanner`.** Everything above it deals in
/// `domain/barcode.dart` types and plain strings, so if the package is
/// abandoned (it has changed hands before) the migration is this one file and
/// nothing else — the same containment rule
/// `platform/location/geolocator_location_adapter.dart` applies to geolocator
/// (architecture_overview.md rule 4).
///
/// Pushed imperatively rather than routed: it is a modal picker that *returns
/// a value*, and go_router's typed routes have no return channel. It is also
/// never a deep link — a URL that silently opens someone's camera is exactly
/// the thing not to build.
///
/// ## S2 handling
///
/// A scanned barcode identifies a product the user is about to eat. It is
/// never logged, never put in an exception message, never sent to analytics,
/// and never rendered on this screen. The only thing that happens to a
/// detected code is validation and a pop.
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen>
    with WidgetsBindingObserver {
  /// `null` on platforms without a scanner. Constructing a
  /// [scanner.MobileScannerController] there is not a no-op — the platform
  /// interface has no registered implementation and throws
  /// `UnimplementedError` on first use — so the unsupported branch must never
  /// build one, not merely never show it.
  scanner.MobileScannerController? _controller;

  /// Latch: the detection stream fires on every frame that still contains the
  /// barcode, so a lone `pop` would fire again during the pop animation and
  /// tear down whatever route ended up underneath. Once true, nothing pops
  /// again.
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    if (!barcodeScanningSupported) return;

    WidgetsBinding.instance.addObserver(this);
    _controller = scanner.MobileScannerController(
      // Product symbologies only. Restricting the set is not just a
      // performance nicety: food packaging carries QR codes and Code 128
      // batch codes too, and popping one of those would look like a
      // successful scan right up until the lookup failed.
      formats: const [
        scanner.BarcodeFormat.ean13,
        scanner.BarcodeFormat.ean8,
        scanner.BarcodeFormat.upcA,
        scanner.BarcodeFormat.upcE,
      ],
    );
  }

  /// Stops the camera when the app leaves the foreground and starts it again
  /// on return.
  ///
  /// `MobileScanner`'s own `useAppLifecycleState` handling only applies when
  /// no controller is passed to it, and we pass one — so this is manual, and
  /// omitting it is the documented cause of a black preview after
  /// backgrounding (the texture is released by the OS and never re-acquired).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    // Nothing to suspend before the permission prompt has been answered, and
    // calling start() then would race the prompt.
    if (controller == null || !controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.start());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  void _onDetect(scanner.BarcodeCapture capture) {
    if (_popped || !mounted) return;

    for (final detected in capture.barcodes) {
      final raw = detected.rawValue;
      if (raw == null) continue;

      // Validate before popping. A partially-read label, a decoder guess, or
      // a symbology we did not ask for all reach here as strings; passing one
      // up would push a malformed code into the catalogue rather than simply
      // failing to scan. An invalid detection is ignored and the camera keeps
      // looking, which is what the user expects to happen anyway.
      final barcode = Barcode.tryParse(
        raw,
        scannedAs: _symbologyOf(detected.format),
      );
      if (barcode == null) continue;

      _popped = true;
      Navigator.of(context).pop(barcode.digits);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan barcode'),
        actions: [
          if (controller != null) _TorchButton(controller: controller),
        ],
      ),
      body: SafeArea(
        child: controller == null
            ? const _UnavailableView(
                icon: Icons.no_photography_outlined,
                title: 'Scanning needs a phone camera',
                body:
                    "This device can't scan barcodes, but you can type one in "
                    'by hand — every barcode works that way.',
              )
            : Column(
                children: [
                  Expanded(
                    child: scanner.MobileScanner(
                      controller: controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) => _UnavailableView(
                        icon: _errorIcon(error.errorCode),
                        title: _errorTitle(error.errorCode),
                        body: _errorBody(error.errorCode),
                      ),
                    ),
                  ),
                  const _OnDeviceNote(),
                ],
              ),
      ),
    );
  }
}

/// Maps `mobile_scanner`'s symbology to the domain's.
///
/// Only the four we asked for can arrive; anything else is a decoder
/// surprise and gets no hint, which leaves [Barcode.tryParse] to judge it on
/// length and check digit alone.
BarcodeSymbology? _symbologyOf(scanner.BarcodeFormat format) =>
    switch (format) {
      scanner.BarcodeFormat.ean13 => BarcodeSymbology.ean13,
      scanner.BarcodeFormat.ean8 => BarcodeSymbology.ean8,
      scanner.BarcodeFormat.upcA => BarcodeSymbology.upcA,
      scanner.BarcodeFormat.upcE => BarcodeSymbology.upcE,
      _ => null,
    };

IconData _errorIcon(scanner.MobileScannerErrorCode code) => switch (code) {
  scanner.MobileScannerErrorCode.permissionDenied =>
    Icons.no_photography_outlined,
  scanner.MobileScannerErrorCode.unsupported => Icons.videocam_off_outlined,
  _ => Icons.error_outline,
};

String _errorTitle(scanner.MobileScannerErrorCode code) => switch (code) {
  scanner.MobileScannerErrorCode.permissionDenied => 'Camera access is off',
  scanner.MobileScannerErrorCode.unsupported => 'No camera to scan with',
  _ => "The camera didn't start",
};

/// Every one of these ends with the way forward, because there always is one:
/// the barcode can be typed. A scanner that dead-ends on a refused permission
/// turns a two-second annoyance into a lost feature.
String _errorBody(scanner.MobileScannerErrorCode code) => switch (code) {
  scanner.MobileScannerErrorCode.permissionDenied =>
    'FemFit needs camera access to read a barcode. You can turn it on in your '
        'device settings — or just type the barcode in instead.',
  scanner.MobileScannerErrorCode.unsupported =>
    "This device doesn't have a camera the scanner can use. Typing the "
        'barcode in works just as well.',
  _ =>
    'Something got in the way of the camera. Try again in a moment, or type '
        'the barcode in instead.',
};

/// The on-device promise, shown the whole time the camera is open.
///
/// It is true — Android decodes with ML Kit's bundled model and iOS with
/// Apple Vision, both entirely on the device, and `returnImage` is left off so
/// frames are not even handed to Dart — and it is worth saying at the moment
/// the camera opens rather than in a settings screen nobody visits.
class _OnDeviceNote extends StatelessWidget {
  const _OnDeviceNote();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: colors.onSurfaceVariant),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Text(
              'Point the camera at the barcode. Scanning happens on your '
              'device — no photo or video is saved or uploaded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown instead of a preview whenever there is no camera to show: an
/// unsupported platform, a refused permission, or a camera that failed to
/// start. Always offers the manual route out.
class _UnavailableView extends StatelessWidget {
  const _UnavailableView({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: tokens.spacingMd),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.spacingLg),
                // Pops `null`, the same as cancelling. The caller's own
                // manual-entry field is what the user lands back on, so there
                // is no second result type to carry: "I didn't scan anything"
                // is the whole message.
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.keyboard_outlined),
                  label: const Text('Type it in instead'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Torch toggle. Supermarket aisles are darker than they look and a shelf
/// shadow across a barcode is the usual reason a scan will not take.
class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final scanner.MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<scanner.MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final torch = state.torchState;
        final unavailable = torch == scanner.TorchState.unavailable;
        final isOn = torch == scanner.TorchState.on;

        return IconButton(
          onPressed: unavailable
              ? null
              : () => unawaited(controller.toggleTorch()),
          tooltip: isOn ? 'Turn off the light' : 'Turn on the light',
          icon: Icon(isOn ? Icons.flashlight_on : Icons.flashlight_off),
        );
      },
    );
  }
}
