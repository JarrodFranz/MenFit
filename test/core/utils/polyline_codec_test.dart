import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/utils/polyline_codec.dart';

void main() {
  group('encodePolyline', () {
    test('encodes the canonical reference vector exactly', () {
      // The worked example from the polyline algorithm's own spec.
      const points = <PolylinePoint>[
        (latitude: 38.5, longitude: -120.2),
        (latitude: 40.7, longitude: -120.95),
        (latitude: 43.252, longitude: -126.453),
      ];
      expect(encodePolyline(points), '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    });

    test('encodes an empty list to the empty string', () {
      expect(encodePolyline(const []), '');
    });

    test('encodes a single point (the spec example first pair)', () {
      expect(
        encodePolyline(const [(latitude: 38.5, longitude: -120.2)]),
        '_p~iF~ps|U',
      );
    });
  });

  group('decodePolyline', () {
    test('decodes the canonical reference vector exactly', () {
      final points = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(points, const <PolylinePoint>[
        (latitude: 38.5, longitude: -120.2),
        (latitude: 40.7, longitude: -120.95),
        (latitude: 43.252, longitude: -126.453),
      ]);
    });

    test('decodes the empty string to an empty list', () {
      expect(decodePolyline(''), isEmpty);
    });

    test('throws FormatException for a truncated chunk', () {
      // A chunk with the continuation bit set but nothing after it.
      expect(() => decodePolyline('_'), throwsFormatException);
    });

    test('throws FormatException for a dangling latitude', () {
      // '?' alone decodes one complete value (a latitude) with no
      // longitude following it.
      expect(() => decodePolyline('?'), throwsFormatException);
    });
  });

  group('round-trips', () {
    test('exact at 5-decimal precision incl. negative coords', () {
      const points = <PolylinePoint>[
        (latitude: 51.50735, longitude: -0.12776),
        (latitude: -33.86882, longitude: 151.20929),
        (latitude: 0.0, longitude: 0.0),
        (latitude: -0.00001, longitude: 0.00001),
        (latitude: 89.99999, longitude: -179.99999),
        (latitude: -89.99999, longitude: 179.99999),
      ];
      expect(decodePolyline(encodePolyline(points)), points);
    });

    test('values are quantised to 5 decimals (the format precision bound)', () {
      // 1e-6 is below the format's resolution: encoding rounds it away.
      final decoded = decodePolyline(
        encodePolyline(const [(latitude: 51.5000004, longitude: -0.1000004)]),
      );
      expect(decoded, const <PolylinePoint>[(latitude: 51.5, longitude: -0.1)]);
    });

    test('a long alternating-sign path round-trips exactly', () {
      final points = <PolylinePoint>[
        for (var i = 0; i < 250; i++)
          (
            latitude: (i.isEven ? 1 : -1) * (i * 0.01337 % 90),
            longitude: (i.isOdd ? 1 : -1) * (i * 0.02713 % 180),
          ),
      ];
      // Quantise the fixture itself to 5 decimals first - the codec's
      // guarantee is exactness at the format's precision, not beyond it.
      final quantised = <PolylinePoint>[
        for (final p in points)
          (
            latitude: (p.latitude * 1e5).round() / 1e5,
            longitude: (p.longitude * 1e5).round() / 1e5,
          ),
      ];
      expect(decodePolyline(encodePolyline(quantised)), quantised);
    });
  });
}
