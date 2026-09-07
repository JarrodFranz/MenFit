import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/audio/silent_cue_player.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/safety/domain/safety_checkin_engine.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';
import 'package:menfit_app/features/safety/safety_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/platform/sharing/fake_sharing_adapter.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;

  @override
  Future<UserProfile?> getProfile() async => profile;

  @override
  Stream<UserProfile?> watchProfile() => Stream.value(profile);

  @override
  Future<void> saveProfile(UserProfile profile) async {
    this.profile = profile;
  }

  @override
  Future<void> deleteAllData() async {
    profile = null;
  }
}

void main() {
  group('Safety Providers', () {
    late SharedPreferences prefs;
    late FakeSharingAdapter fakeSharing;
    late _FakeProfileRepository fakeProfileRepo;
    late DateTime fakeNow;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      fakeSharing = FakeSharingAdapter();
      fakeProfileRepo = _FakeProfileRepository();
      fakeNow = DateTime(2026, 9, 4, 10);
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sharingAdapterProvider.overrideWithValue(fakeSharing),
          audioCuePlayerProvider.overrideWithValue(const SilentCuePlayer()),
          recordingClockProvider.overrideWithValue(() => fakeNow),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('TrustedContactsController manages contacts correctly', () async {
      final container = createContainer();
      final controller = container.read(
        trustedContactsControllerProvider.notifier,
      );

      expect(container.read(trustedContactsControllerProvider), isEmpty);

      final contact = TrustedContact.create(
        name: 'Sarah Connor',
        phone: '0400000000',
        relationship: ContactRelationship.family,
      );

      await controller.addContact(contact);
      var contacts = container.read(trustedContactsControllerProvider);
      expect(contacts.length, 1);
      expect(contacts.first.name, 'Sarah Connor');
      expect(contacts.first.isPrimary, isTrue);

      final contact2 = TrustedContact.create(
        name: 'John Connor',
        phone: '0411111111',
      );
      await controller.addContact(contact2);
      contacts = container.read(trustedContactsControllerProvider);
      expect(contacts.length, 2);

      await controller.setPrimary(contacts[1].id);
      contacts = container.read(trustedContactsControllerProvider);
      expect(
        contacts.firstWhere((c) => c.name == 'John Connor').isPrimary,
        isTrue,
      );
      expect(
        contacts.firstWhere((c) => c.name == 'Sarah Connor').isPrimary,
        isFalse,
      );

      await controller.deleteContact(contacts[1].id);
      contacts = container.read(trustedContactsControllerProvider);
      expect(contacts.length, 1);
      expect(contacts.first.name, 'Sarah Connor');
      expect(contacts.first.isPrimary, isTrue);
    });

    test('SafetyPreferencesController updates settings', () async {
      final container = createContainer();
      final controller = container.read(
        safetyPreferencesControllerProvider.notifier,
      );

      expect(
        container.read(safetyPreferencesControllerProvider).checkinTimerEnabled,
        isTrue,
      );

      await controller.toggleCheckinTimer(enabled: false);
      expect(
        container.read(safetyPreferencesControllerProvider).checkinTimerEnabled,
        isFalse,
      );

      await controller.setDefaultDuration(60);
      expect(
        container
            .read(safetyPreferencesControllerProvider)
            .defaultExpectedMinutes,
        60,
      );

      await controller.toggleInactivityAlert(enabled: false);
      expect(
        container
            .read(safetyPreferencesControllerProvider)
            .inactivityAlertEnabled,
        isFalse,
      );

      await controller.setInactivityThreshold(5);
      expect(
        container
            .read(safetyPreferencesControllerProvider)
            .inactivityThresholdMinutes,
        5,
      );

      await controller.setWarningCountdown(30);
      expect(
        container
            .read(safetyPreferencesControllerProvider)
            .warningCountdownSeconds,
        30,
      );

      await controller.setCustomMessage('Test custom note');
      expect(
        container.read(safetyPreferencesControllerProvider).customMessage,
        'Test custom note',
      );
    });

    test('SafetyMonitorController arms and detects inactivity', () async {
      final container = createContainer();
      final controller = container.read(
        safetyMonitorControllerProvider.notifier,
      );

      final fix1 = LocationFix(
        timestamp: fakeNow,
        latitude: -33.8688,
        longitude: 151.2093,
      );
      controller
        ..arm(expectedDuration: const Duration(minutes: 45))
        ..updateLocation(fix1);
      var state = container.read(safetyMonitorControllerProvider);
      expect(state.isActive, isTrue);
      expect(state.expectedDuration, const Duration(minutes: 45));
      expect(state.checkinDeadline, fakeNow.add(const Duration(minutes: 45)));
      expect(state.isWarningActive, isFalse);

      // Advance time by 3 minutes (inactivity threshold is default 4 min)
      fakeNow = fakeNow.add(const Duration(minutes: 3));
      controller.evaluateTimers(fakeNow);
      state = container.read(safetyMonitorControllerProvider);
      expect(state.isWarningActive, isFalse);

      // Advance time to 4 minutes (threshold met)
      fakeNow = fakeNow.add(const Duration(minutes: 1));
      controller.evaluateTimers(fakeNow);
      state = container.read(safetyMonitorControllerProvider);
      expect(state.isWarningActive, isTrue);
      expect(state.warningReason, SafetyAlertReason.inactivity);

      // User dismisses warning
      controller.dismissWarning();
      state = container.read(safetyMonitorControllerProvider);
      expect(state.isWarningActive, isFalse);
      expect(state.lastMovementAt, fakeNow);
    });

    test(
      'SafetyMonitorController triggers SOS when countdown ticks to zero',
      () async {
        final container = createContainer();
        final controller =
            container.read(safetyMonitorControllerProvider.notifier)
              ..arm()
              ..updateLocation(
                LocationFix(
                  timestamp: fakeNow,
                  latitude: -33.8688,
                  longitude: 151.2093,
                ),
              );

        fakeNow = fakeNow.add(const Duration(minutes: 5));
        controller.evaluateTimers(fakeNow);

        var state = container.read(safetyMonitorControllerProvider);
        expect(state.isWarningActive, isTrue);

        // Tick countdown down to 1
        while (container
                .read(safetyMonitorControllerProvider)
                .warningSecondsRemaining >
            1) {
          await controller.tickCountdown();
        }

        // Final tick triggers SOS
        await controller.tickCountdown();

        state = container.read(safetyMonitorControllerProvider);
        expect(state.isWarningActive, isFalse);
        expect(state.isSosDispatched, isTrue);
        expect(state.dispatchedMessage, contains('MenFit Safety Alert:'));
        expect(
          state.dispatchedMessage,
          contains('https://maps.google.com/?q=-33.8688,151.2093'),
        );
        expect(fakeSharing.shareCount, 1);
        expect(fakeSharing.textShares.first.text, state.dispatchedMessage);
      },
    );

    test('SafetyMonitorController manual SOS dispatch works anytime', () async {
      final container = createContainer();
      final controller =
          container.read(safetyMonitorControllerProvider.notifier)
            ..arm()
            ..updateLocation(
              LocationFix(
                timestamp: fakeNow,
                latitude: -33.8688,
                longitude: 151.2093,
              ),
            );

      final msg = await controller.triggerSos();

      final state = container.read(safetyMonitorControllerProvider);
      expect(state.isSosDispatched, isTrue);
      expect(msg, contains('MenFit Emergency SOS:'));
      expect(fakeSharing.shareCount, 1);
    });

    test('Live tracking providers resolve correctly', () async {
      final container = createContainer();
      final urlBuilder = container.read(liveTrackingUrlBuilderProvider);
      expect(urlBuilder.baseUrl, 'https://live.menfit.app/track');

      final service = container.read(liveTrackingServiceProvider);
      // Keep provider subscribed to stream
      final subscription = container.listen(
        activeLiveTrackingSessionProvider,
        (prev, next) {},
      );
      addTearDown(subscription.close);

      final session = await service.startSession(userName: 'Tester');
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(activeLiveTrackingSessionProvider).value?.id,
        session.id,
      );
    });
  });
}
