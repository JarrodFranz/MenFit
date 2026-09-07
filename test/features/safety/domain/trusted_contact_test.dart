import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';

void main() {
  group('TrustedContact', () {
    test('create generates unique id and trims whitespace', () {
      final contact = TrustedContact.create(
        name: '  Jane Doe  ',
        phone: '  +15551234567 ',
        relationship: ContactRelationship.partner,
        isPrimary: true,
      );

      expect(contact.id, isNotEmpty);
      expect(contact.name, 'Jane Doe');
      expect(contact.phone, '+15551234567');
      expect(contact.relationship, ContactRelationship.partner);
      expect(contact.isPrimary, isTrue);
    });

    test('toJson and fromJson round-trip accurately', () {
      const original = TrustedContact(
        id: 'tc-123',
        name: 'Alex Smith',
        phone: '0412345678',
        relationship: ContactRelationship.friend,
      );

      final json = original.toJson();
      final restored = TrustedContact.fromJson(json);

      expect(restored, original);
      expect(restored.id, 'tc-123');
      expect(restored.name, 'Alex Smith');
      expect(restored.phone, '0412345678');
      expect(restored.relationship, ContactRelationship.friend);
      expect(restored.isPrimary, isFalse);
    });

    test('copyWith updates specified fields only', () {
      const contact = TrustedContact(
        id: 'tc-1',
        name: 'Sam',
        phone: '111',
        relationship: ContactRelationship.parent,
      );

      final updated = contact.copyWith(name: 'Sam Junior', isPrimary: true);

      expect(updated.id, 'tc-1');
      expect(updated.name, 'Sam Junior');
      expect(updated.phone, '111');
      expect(updated.relationship, ContactRelationship.parent);
      expect(updated.isPrimary, isTrue);
    });

    test('ContactRelationship parses correctly from strings', () {
      expect(
        ContactRelationship.fromString('Partner'),
        ContactRelationship.partner,
      );
      expect(
        ContactRelationship.fromString('partner'),
        ContactRelationship.partner,
      );
      expect(
        ContactRelationship.fromString('family'),
        ContactRelationship.family,
      );
      expect(
        ContactRelationship.fromString('unknown_value'),
        ContactRelationship.other,
      );
      expect(ContactRelationship.fromString(null), ContactRelationship.other);
    });
  });
}
