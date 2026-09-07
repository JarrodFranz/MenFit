import 'package:flutter/material.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

/// Types a start point in, as an alternative to tapping the map.
///
/// The map is pointer-only: `flutter_map`'s tap handler has no keyboard
/// equivalent, so without this a keyboard or switch-control user who can't
/// use "Use my location" (denied permission, or a platform that can't
/// resolve one at all) has no way to choose a start point. Two ordinary
/// text fields in a dialog is the smallest thing that fixes that; it isn't
/// meant to be the primary path.
///
/// Resolves to the entered point, or `null` when cancelled. The
/// [TextEditingController]s are owned and disposed by the dialog's own
/// State, for the reason spelled out in `route_name_dialog.dart`.
Future<GeoPoint?> showStartPointDialog(
  BuildContext context, {
  GeoPoint? initial,
}) {
  return showDialog<GeoPoint>(
    context: context,
    builder: (dialogContext) => _StartPointDialog(initial: initial),
  );
}

class _StartPointDialog extends StatefulWidget {
  const _StartPointDialog({this.initial});

  final GeoPoint? initial;

  @override
  State<_StartPointDialog> createState() => _StartPointDialogState();
}

class _StartPointDialogState extends State<_StartPointDialog> {
  late final TextEditingController _latitude = TextEditingController(
    text: widget.initial?.latitude.toString() ?? '',
  );
  late final TextEditingController _longitude = TextEditingController(
    text: widget.initial?.longitude.toString() ?? '',
  );

  String? _latitudeError;
  String? _longitudeError;

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void _submit() {
    final latitude = _parse(_latitude.text, limit: 90);
    final longitude = _parse(_longitude.text, limit: 180);
    if (latitude == null || longitude == null) {
      setState(() {
        _latitudeError = latitude == null
            ? 'Enter a latitude between -90 and 90.'
            : null;
        _longitudeError = longitude == null
            ? 'Enter a longitude between -180 and 180.'
            : null;
      });
      return;
    }
    Navigator.of(
      context,
    ).pop(GeoPoint(latitude: latitude, longitude: longitude));
  }

  /// Parses a coordinate component, or `null` when it isn't a real number
  /// within +/- [limit].
  static double? _parse(String value, {required double limit}) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || !parsed.isFinite || parsed.abs() > limit) return null;
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter a start point'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _latitude,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: 'Latitude',
                errorText: _latitudeError,
              ),
            ),
            TextField(
              controller: _longitude,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: 'Longitude',
                errorText: _longitudeError,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Use this point')),
      ],
    );
  }
}
