import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/routes/data/location_search_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/presentation/widgets/location_search_dialog.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

class _FakeSearchService extends LocationSearchService {
  _FakeSearchService(this.results) : super(dio: Dio(), apiKey: '');

  final List<LocationSearchResult> results;

  @override
  Future<List<LocationSearchResult>> search(
    String query, {
    GeoPoint? proximity,
    String? countryCode,
  }) async {
    return results;
  }
}

void main() {
  testWidgets(
    'LocationSearchDialog renders and scrolls results without overflow '
    'on small viewports with keyboard',
    (tester) async {
      // Simulate small constrained viewport (e.g. phone screen with
      // keyboard up)
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyResults = [
        const LocationSearchResult(
          name: 'Rumbek North',
          point: GeoPoint(latitude: 6.8, longitude: 29.6),
          secondaryText: 'Rumbek North, EB, South Sudan',
        ),
        const LocationSearchResult(
          name: 'North Lakes',
          point: GeoPoint(latitude: -27.23, longitude: 153.01),
          secondaryText: 'North Lakes, QLD, Australia',
        ),
        const LocationSearchResult(
          name: 'North Lakes',
          point: GeoPoint(latitude: 28.1, longitude: -82.4),
          secondaryText: 'North Lakes, Lake Magdalene, FL, US',
        ),
        const LocationSearchResult(
          name: 'North Arm Cove',
          point: GeoPoint(latitude: -32.69, longitude: 152.05),
          secondaryText: 'North Arm Cove, NSW, Australia',
        ),
      ];

      LocationSearchResult? selected;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            locationSearchServiceProvider.overrideWithValue(
              _FakeSearchService(dummyResults),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    selected = await showLocationSearchDialog(context);
                  },
                  child: const Text('Open Search'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Search location or address'), findsOneWidget);

      // Type query
      await tester.enterText(find.byType(TextField), 'North');
      // Wait for debounce timer (350ms)
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // All search results are rendered
      expect(find.text('North Lakes'), findsWidgets);
      expect(find.text('Rumbek North'), findsOneWidget);

      // Verify no RenderFlex overflow error was thrown by tapping an item
      await tester.tap(find.text('North Lakes').first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name, 'North Lakes');
      expect(selected!.point.latitude, -27.23);
    },
  );
}
