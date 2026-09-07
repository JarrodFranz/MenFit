import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/safety/domain/safety_checkin_engine.dart';

void main() {
  group('SafetyCheckinEngine', () {
    const engine = SafetyCheckinEngine();

    test('formatMapsUrl generates expected google maps link', () {
      final url = SafetyCheckinEngine.formatMapsUrl(-33.8688, 151.2093);
      expect(url, 'https://maps.google.com/?q=-33.8688,151.2093');
    });

    test('hasMoved detects movement when speed exceeds threshold', () {
      final anchor = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10),
        latitude: -33.8688,
        longitude: 151.2093,
        speedMetersPerSecond: 0.2,
      );
      final current = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10, 1),
        latitude: -33.8688,
        longitude: 151.2093,
        speedMetersPerSecond: 1.5,
      );

      expect(engine.hasMoved(currentFix: current, anchorFix: anchor), isTrue);
    });

    test('hasMoved detects movement when distance exceeds radius', () {
      final anchor = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10),
        latitude: -33.8688,
        longitude: 151.2093,
      );
      // Roughly 50 meters away
      final current = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10, 1),
        latitude: -33.8684,
        longitude: 151.2093,
      );

      expect(engine.hasMoved(currentFix: current, anchorFix: anchor), isTrue);
    });

    test('hasMoved returns false for stationary GPS jitter', () {
      final anchor = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10),
        latitude: -33.868800,
        longitude: 151.209300,
        speedMetersPerSecond: 0.1,
      );
      // Roughly ~2 meters away
      final current = LocationFix(
        timestamp: DateTime.utc(2026, 9, 4, 10, 1),
        latitude: -33.868815,
        longitude: 151.209305,
        speedMetersPerSecond: 0.2,
      );

      expect(engine.hasMoved(currentFix: current, anchorFix: anchor), isFalse);
    });

    test('isInactivityTriggered evaluates stationary duration correctly', () {
      final base = DateTime(2026, 9, 4, 10);

      expect(
        engine.isInactivityTriggered(
          now: base.add(const Duration(minutes: 3)),
          stationarySince: base,
          inactivityThreshold: const Duration(minutes: 4),
        ),
        isFalse,
      );

      expect(
        engine.isInactivityTriggered(
          now: base.add(const Duration(minutes: 4)),
          stationarySince: base,
          inactivityThreshold: const Duration(minutes: 4),
        ),
        isTrue,
      );

      expect(
        engine.isInactivityTriggered(
          now: base.add(const Duration(minutes: 5)),
          stationarySince: null,
          inactivityThreshold: const Duration(minutes: 4),
        ),
        isFalse,
      );
    });

    test('isCheckinOverdue evaluates deadline correctly', () {
      final deadline = DateTime(2026, 9, 4, 11);

      expect(
        engine.isCheckinOverdue(
          now: DateTime(2026, 9, 4, 10, 59),
          deadline: deadline,
        ),
        isFalse,
      );

      expect(
        engine.isCheckinOverdue(
          now: DateTime(2026, 9, 4, 11, 1),
          deadline: deadline,
        ),
        isTrue,
      );

      expect(
        engine.isCheckinOverdue(
          now: DateTime(2026, 9, 4, 11, 1),
          deadline: null,
        ),
        isFalse,
      );
    });

    test('generateEmergencyMessage formats text for inactivity alert', () {
      final msg = engine.generateEmergencyMessage(
        userName: 'Alice',
        timestamp: DateTime(2026, 9, 4, 10, 30),
        latitude: -33.8688,
        longitude: 151.2093,
      );

      expect(msg, contains('MenFit Safety Alert:'));
      expect(
        msg,
        contains(
          'Alice has stopped moving during an outdoor run at ',
        ),
      );
      expect(
        msg,
        contains(
          'and has not responded to safety checks.',
        ),
      );
      expect(
        msg,
        contains(
          'Last known location: https://maps.google.com/?q=-33.8688,151.2093',
        ),
      );
    });

    test('generateEmergencyMessage includes custom note when provided', () {
      final msg = engine.generateEmergencyMessage(
        userName: 'Alice',
        timestamp: DateTime(2026, 9, 4, 10, 30),
        latitude: -33.8688,
        longitude: 151.2093,
        reason: SafetyAlertReason.manualSos,
        customMessage: 'Running through Centennial Park',
      );

      expect(msg, contains('MenFit Emergency SOS:'));
      expect(msg, contains('Note: Running through Centennial Park'));
    });

    test(
      'generateEmergencyMessage includes live tracking link when provided',
      () {
        final msg = engine.generateEmergencyMessage(
          userName: 'Alice',
          timestamp: DateTime(2026, 9, 4, 10, 30),
          latitude: -33.8688,
          longitude: 151.2093,
          liveTrackingUrl: 'https://menfit.app/live_tracker.html?token=xyz123',
        );

        expect(
          msg,
          contains(
            'Live tracking: https://menfit.app/live_tracker.html?token=xyz123',
          ),
        );
      },
    );
  });
}
