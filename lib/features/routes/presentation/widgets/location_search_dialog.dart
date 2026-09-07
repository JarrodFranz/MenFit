import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/routes/data/location_search_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

/// Shows a dialog to search for a location, park, city, or address.
Future<LocationSearchResult?> showLocationSearchDialog(
  BuildContext context, {
  GeoPoint? proximity,
}) {
  return showDialog<LocationSearchResult>(
    context: context,
    builder: (dialogContext) => _LocationSearchDialog(proximity: proximity),
  );
}

class _LocationSearchDialog extends ConsumerStatefulWidget {
  const _LocationSearchDialog({this.proximity});

  final GeoPoint? proximity;

  @override
  ConsumerState<_LocationSearchDialog> createState() =>
      _LocationSearchDialogState();
}

class _LocationSearchDialogState extends ConsumerState<_LocationSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<LocationSearchResult> _results = const [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = const [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final service = ref.read(locationSearchServiceProvider);

        final results = await service.search(
          trimmed,
          proximity: widget.proximity,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _results = results;
          });
        }
      } on Object catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e.toString();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Search location or address'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Bondi Beach, Central Park…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  _onQueryChanged('');
                                },
                              )
                            : null),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _onQueryChanged,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (int i = 0; i < _results.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(
                      _results[i].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: _results[i].secondaryText != null
                        ? Text(
                            _results[i].secondaryText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(_results[i]),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
