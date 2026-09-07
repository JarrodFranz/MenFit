import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/safety/data/local_live_tracking_service.dart';
import 'package:menfit_app/features/safety/domain/live_tracking.dart';

void main() {
  group('LiveTrackingToken', () {
    test('generate produces 22-character url-safe string', () {
      final token = LiveTrackingToken.generate();
      expect(token.length, 22);
      expect(LiveTrackingToken.isValid(token), isTrue);
    });

    test('generate produces unique tokens', () {
      final token1 = LiveTrackingToken.generate();
      final token2 = LiveTrackingToken.generate();
      expect(token1, isNot(equals(token2)));
    });

    test('isValid validates proper tokens and rejects invalid ones', () {
      expect(LiveTrackingToken.isValid('abcABC123-_abcABC1234'), isTrue);
      expect(LiveTrackingToken.isValid(''), isFalse);
      expect(LiveTrackingToken.isValid('short'), isFalse);
      expect(LiveTrackingToken.isValid('abcABC123-_abcABC123+'), isFalse);
      expect(LiveTrackingToken.isValid('abcABC123-_abcABC123/'), isFalse);
      expect(LiveTrackingToken.isValid('abcABC123-_abcABC123='), isFalse);
      expect(LiveTrackingToken.isValid('abc ABC123-_abcABC123'), isFalse);
    });
  });

  group('LiveTrackingStatus', () {
    test('fromString parses known and unknown values', () {
      expect(
        LiveTrackingStatus.fromString('active'),
        LiveTrackingStatus.active,
      );
      expect(
        LiveTrackingStatus.fromString('completed'),
        LiveTrackingStatus.completed,
      );
      expect(
        LiveTrackingStatus.fromString('cancelled'),
        LiveTrackingStatus.cancelled,
      );
      expect(
        LiveTrackingStatus.fromString('expired'),
        LiveTrackingStatus.expired,
      );
      expect(
        LiveTrackingStatus.fromString('unknown_val'),
        LiveTrackingStatus.expired,
      );
      expect(LiveTrackingStatus.fromString(null), LiveTrackingStatus.expired);
    });
  });

  group('LiveLocationPacket', () {
    final fix = LocationFix(
      timestamp: DateTime.utc(2026, 9, 7, 10),
      latitude: -33.8688,
      longitude: 151.2093,
      speedMetersPerSecond: 2.78,
      elevationMeters: 45,
      horizontalAccuracyMeters: 4.5,
    );

    test('fromLocationFix constructs correct packet', () {
      final packet = LiveLocationPacket.fromLocationFix(
        fix: fix,
        batteryPercentage: 88,
      );

      expect(packet.latitude, -33.8688);
      expect(packet.longitude, 151.2093);
      expect(packet.speedMetersPerSecond, 2.78);
      expect(packet.batteryPercentage, 88);
      expect(packet.isStationary, isFalse);
      expect(packet.status, LiveTrackingStatus.active);
    });

    test('toJson and fromJson serialize symmetrically', () {
      final original = LiveLocationPacket.fromLocationFix(
        fix: fix,
        batteryPercentage: 75,
        isStationary: true,
      );

      final json = original.toJson();
      final restored = LiveLocationPacket.fromJson(json);

      expect(restored, equals(original));
      expect(restored.batteryPercentage, 75);
      expect(restored.isStationary, isTrue);
    });
  });

  group('LiveTrackingSession', () {
    test('create initializes active session with sensible defaults', () {
      final now = DateTime.utc(2026, 9, 7, 8);
      final session = LiveTrackingSession.create(
        userName: ' Maya ',
        duration: const Duration(hours: 2),
        now: now,
      );

      expect(session.userName, 'Maya');
      expect(session.status, LiveTrackingStatus.active);
      expect(session.startedAt, now);
      expect(session.expiresAt, now.add(const Duration(hours: 2)));
      expect(session.isExpired(now.add(const Duration(hours: 1))), isFalse);
      expect(session.isExpired(now.add(const Duration(hours: 3))), isTrue);
    });

    test('create falls back to Runner if username is empty', () {
      final session = LiveTrackingSession.create(userName: '   ');
      expect(session.userName, 'Runner');
    });

    test('toJson and fromJson round-trip', () {
      final now = DateTime.utc(2026, 9, 7, 8);
      final session = LiveTrackingSession.create(
        userName: 'Sarah',
        now: now,
      );

      final restored = LiveLocationPacket.fromJson(
        LiveLocationPacket.fromLocationFix(
          fix: LocationFix(
            timestamp: now,
            latitude: -33.8688,
            longitude: 151.2093,
          ),
        ).toJson(),
      );
      final sessionWithPacket = session.copyWith(lastPacket: restored);
      final sessionJson = sessionWithPacket.toJson();
      final restoredSession = LiveTrackingSession.fromJson(sessionJson);

      expect(restoredSession.id, session.id);
      expect(restoredSession.token, session.token);
      expect(restoredSession.userName, session.userName);
      expect(restoredSession.status, session.status);
      expect(restoredSession.startedAt, session.startedAt);
      expect(restoredSession.expiresAt, session.expiresAt);
      expect(restoredSession.lastPacket, equals(restored));
    });

    test('copyWith modifies targeted fields', () {
      final session = LiveTrackingSession.create(userName: 'Sarah');
      final updated = session.copyWith(
        status: LiveTrackingStatus.completed,
      );

      expect(updated.id, session.id);
      expect(updated.token, session.token);
      expect(updated.userName, session.userName);
      expect(updated.status, LiveTrackingStatus.completed);
    });
  });

  group('LiveTrackingUrlBuilder', () {
    test('buildUrl produces proper URL format with parameters', () {
      const builder = LiveTrackingUrlBuilder(
        baseUrl: 'https://menfit.app/live_tracker.html',
      );
      final session = LiveTrackingSession.create(
        userName: 'Alice',
        now: DateTime.utc(2026, 9, 7, 9),
        duration: const Duration(hours: 2),
      );

      final url = builder.buildUrl(
        token: session.token,
        runnerName: session.userName,
      );

      expect(url, startsWith('https://menfit.app/live_tracker.html#'));
      expect(url, contains('token=${session.token}'));
      expect(url, contains('runner=Alice'));

      final invitation = builder.formatInvitationMessage(
        userName: session.userName,
        liveTrackingUrl: url,
      );
      expect(invitation, contains('Alice is starting an outdoor run'));
      expect(invitation, contains(url));
    });
  });

  group('LocalLiveTrackingService', () {
    late LocalLiveTrackingService service;

    setUp(() {
      service = LocalLiveTrackingService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts session and notifies stream', () async {
      final events = <LiveTrackingSession?>[];
      final sub = service.watchSession().listen(events.add);

      final session = await service.startSession(userName: 'Elena');

      expect(session.userName, 'Elena');
      expect(session.status, LiveTrackingStatus.active);
      expect(service.currentSession, equals(session));

      await Future<void>.delayed(Duration.zero);
      expect(events.last, equals(session));

      await sub.cancel();
    });

    test('publishFix appends packets and updates current session', () async {
      await service.startSession(userName: 'Elena');

      final fix = LocationFix(
        timestamp: DateTime.utc(2026, 9, 7, 9, 15),
        latitude: -33.8688,
        longitude: 151.2093,
        speedMetersPerSecond: 3.1,
      );

      await service.publishFix(
        fix: fix,
        batteryPercentage: 82,
      );

      expect(service.recordedPackets.length, 1);
      expect(service.recordedPackets.first.latitude, -33.8688);
      expect(service.currentSession?.lastPacket?.latitude, -33.8688);
      expect(service.currentSession?.lastPacket?.batteryPercentage, 82);
    });

    test(
      'completeSession marks status as completed and extends expiry',
      () async {
        final session = await service.startSession(userName: 'Elena');
        expect(session.status, LiveTrackingStatus.active);

        await service.completeSession();

        expect(service.currentSession?.status, LiveTrackingStatus.completed);
      },
    );

    test('cancelSession marks status as cancelled', () async {
      await service.startSession(userName: 'Elena');
      await service.cancelSession();

      expect(service.currentSession?.status, LiveTrackingStatus.cancelled);
    });
  });
}
