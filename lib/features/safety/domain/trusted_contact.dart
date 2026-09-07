import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:meta/meta.dart';

/// Relationship of a trusted contact to the user.
enum ContactRelationship {
  partner('Partner'),
  parent('Parent'),
  family('Family Member'),
  friend('Friend'),
  other('Other');

  const ContactRelationship(this.label);
  final String label;

  static ContactRelationship fromString(String? value) {
    if (value == null) return ContactRelationship.other;
    return ContactRelationship.values.firstWhere(
      (r) =>
          r.name.toLowerCase() == value.toLowerCase() ||
          r.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ContactRelationship.other,
    );
  }
}

/// A designated emergency contact stored on-device for safety check-ins and
/// SOS alerts.
@immutable
class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship = ContactRelationship.other,
    this.isPrimary = false,
  });

  factory TrustedContact.create({
    required String name,
    required String phone,
    ContactRelationship relationship = ContactRelationship.other,
    bool isPrimary = false,
  }) {
    return TrustedContact(
      id: EntityId.generate(),
      name: name.trim(),
      phone: phone.trim(),
      relationship: relationship,
      isPrimary: isPrimary,
    );
  }

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: ContactRelationship.fromString(
        json['relationship'] as String?,
      ),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  /// Unique identifier.
  final String id;

  /// Full name of the contact.
  final String name;

  /// Phone number used for SMS alerts and quick dialing.
  final String phone;

  /// Relationship to the runner.
  final ContactRelationship relationship;

  /// Whether this contact is the primary recipient for emergency dispatch.
  final bool isPrimary;

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phone,
    ContactRelationship? relationship,
    bool? isPrimary,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relationship': relationship.name,
    'isPrimary': isPrimary,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          relationship == other.relationship &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode => Object.hash(id, name, phone, relationship, isPrimary);
}
