import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/safety/data/safety_repository.dart';
import 'package:menfit_app/features/safety/domain/safety_preferences.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalSafetyRepository', () {
    late SharedPreferences prefs;
    late LocalSafetyRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = LocalSafetyRepository(prefs);
    });

    test('getContacts returns empty list when none persisted', () {
      expect(repo.getContacts(), isEmpty);
    });

    test('addContact sets first contact as primary automatically', () async {
      final contact = TrustedContact.create(
        name: 'Jane',
        phone: '123',
        relationship: ContactRelationship.partner,
      );

      await repo.addContact(contact);
      final contacts = repo.getContacts();

      expect(contacts.length, 1);
      expect(contacts.first.name, 'Jane');
      expect(contacts.first.isPrimary, isTrue);
    });

    test('addContact ensures only one primary contact exists', () async {
      final contact1 = TrustedContact.create(name: 'Jane', phone: '123');
      final contact2 = TrustedContact.create(
        name: 'Bob',
        phone: '456',
        isPrimary: true,
      );

      await repo.addContact(contact1);
      await repo.addContact(contact2);

      final contacts = repo.getContacts();
      expect(contacts.length, 2);
      expect(contacts.firstWhere((c) => c.name == 'Jane').isPrimary, isFalse);
      expect(contacts.firstWhere((c) => c.name == 'Bob').isPrimary, isTrue);
    });

    test('updateContact modifies contact fields', () async {
      final contact = TrustedContact.create(name: 'Jane', phone: '123');
      await repo.addContact(contact);

      final created = repo.getContacts().first;
      final updated = created.copyWith(name: 'Jane Doe', phone: '999');
      await repo.updateContact(updated);

      final loaded = repo.getContacts().first;
      expect(loaded.name, 'Jane Doe');
      expect(loaded.phone, '999');
    });

    test(
      'deleteContact removes contact and promotes next if primary',
      () async {
        final c1 = TrustedContact.create(
          name: 'Jane',
          phone: '123',
          isPrimary: true,
        );
        final c2 = TrustedContact.create(
          name: 'Bob',
          phone: '456',
        );

        await repo.addContact(c1);
        await repo.addContact(c2);

        final loaded = repo.getContacts();
        final idToDelete = loaded.firstWhere((c) => c.name == 'Jane').id;

        await repo.deleteContact(idToDelete);

        final remaining = repo.getContacts();
        expect(remaining.length, 1);
        expect(remaining.first.name, 'Bob');
        expect(remaining.first.isPrimary, isTrue);
      },
    );

    test('setPrimaryContact updates primary flag', () async {
      final c1 = TrustedContact.create(name: 'Jane', phone: '123');
      final c2 = TrustedContact.create(name: 'Bob', phone: '456');

      await repo.addContact(c1);
      await repo.addContact(c2);

      final bob = repo.getContacts().firstWhere((c) => c.name == 'Bob');
      await repo.setPrimaryContact(bob.id);

      final loaded = repo.getContacts();
      expect(loaded.firstWhere((c) => c.name == 'Bob').isPrimary, isTrue);
      expect(loaded.firstWhere((c) => c.name == 'Jane').isPrimary, isFalse);
    });

    test('getPreferences returns defaults when empty', () {
      final prefs = repo.getPreferences();
      expect(prefs.checkinTimerEnabled, isTrue);
      expect(prefs.defaultExpectedMinutes, 45);
      expect(prefs.inactivityAlertEnabled, isTrue);
      expect(prefs.inactivityThresholdMinutes, 4);
    });

    test('savePreferences and getPreferences round-trip', () async {
      const custom = SafetyPreferences(
        checkinTimerEnabled: false,
        defaultExpectedMinutes: 60,
        inactivityThresholdMinutes: 5,
        warningCountdownSeconds: 30,
        customMessage: 'Running trail',
      );

      await repo.savePreferences(custom);
      final loaded = repo.getPreferences();

      expect(loaded, custom);
    });

    test('clearAll wipes both contacts and preferences', () async {
      await repo.addContact(TrustedContact.create(name: 'Jane', phone: '123'));
      await repo.savePreferences(
        const SafetyPreferences(defaultExpectedMinutes: 90),
      );

      await repo.clearAll();

      expect(repo.getContacts(), isEmpty);
      expect(repo.getPreferences().defaultExpectedMinutes, 45);
    });
  });
}
