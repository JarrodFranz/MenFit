import 'dart:convert';

import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/safety/domain/safety_preferences.dart';
import 'package:menfit_app/features/safety/domain/trusted_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persisting trusted emergency contacts and safety preferences.
abstract interface class SafetyRepository {
  /// Returns all persisted trusted contacts.
  List<TrustedContact> getContacts();

  /// Persists the complete list of [contacts].
  Future<void> saveContacts(List<TrustedContact> contacts);

  /// Adds a new [contact]. If marked as primary, clears primary status from
  /// existing contacts.
  Future<void> addContact(TrustedContact contact);

  /// Updates an existing [contact].
  Future<void> updateContact(TrustedContact contact);

  /// Deletes a contact by [contactId].
  Future<void> deleteContact(String contactId);

  /// Designates [contactId] as the primary contact.
  Future<void> setPrimaryContact(String contactId);

  /// Returns the current safety preferences, falling back to defaults.
  SafetyPreferences getPreferences();

  /// Persists updated [preferences].
  Future<void> savePreferences(SafetyPreferences preferences);

  /// Clears all safety data from local storage.
  Future<void> clearAll();
}

/// SharedPreferences implementation of [SafetyRepository].
class LocalSafetyRepository implements SafetyRepository {
  const LocalSafetyRepository(this._preferences);

  final SharedPreferences? _preferences;

  static const String _contactsKey = 'safety_trusted_contacts';
  static const String _preferencesKey = 'safety_preferences';

  @override
  List<TrustedContact> getContacts() {
    final prefs = _preferences;
    if (prefs == null) return const [];

    final rawList = prefs.getStringList(_contactsKey);
    if (rawList == null || rawList.isEmpty) return const [];

    final contacts = <TrustedContact>[];
    for (final rawJson in rawList) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        contacts.add(TrustedContact.fromJson(map));
      } on Object catch (_) {
        // Skip corrupted contact entries gracefully
      }
    }
    return contacts;
  }

  @override
  Future<void> saveContacts(List<TrustedContact> contacts) async {
    final prefs = _preferences;
    if (prefs == null) return;

    final serialized = contacts
        .map((c) => jsonEncode(c.toJson()))
        .toList(growable: false);

    final ok = await prefs.setStringList(_contactsKey, serialized);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist trusted contacts',
      );
    }
  }

  @override
  Future<void> addContact(TrustedContact contact) async {
    final current = getContacts();
    final updated = <TrustedContact>[];

    final isFirstContact = current.isEmpty;
    final shouldBePrimary = contact.isPrimary || isFirstContact;

    for (final existing in current) {
      if (shouldBePrimary && existing.isPrimary) {
        updated.add(existing.copyWith(isPrimary: false));
      } else {
        updated.add(existing);
      }
    }

    updated.add(contact.copyWith(isPrimary: shouldBePrimary));
    await saveContacts(updated);
  }

  @override
  Future<void> updateContact(TrustedContact contact) async {
    final current = getContacts();
    final updated = <TrustedContact>[];

    for (final existing in current) {
      if (existing.id == contact.id) {
        updated.add(contact);
      } else if (contact.isPrimary && existing.isPrimary) {
        updated.add(existing.copyWith(isPrimary: false));
      } else {
        updated.add(existing);
      }
    }

    await saveContacts(updated);
  }

  @override
  Future<void> deleteContact(String contactId) async {
    final current = getContacts();
    final updated = current.where((c) => c.id != contactId).toList();

    // If we deleted the primary contact and other contacts remain,
    // designate the first one as primary.
    if (updated.isNotEmpty && !updated.any((c) => c.isPrimary)) {
      updated[0] = updated[0].copyWith(isPrimary: true);
    }

    await saveContacts(updated);
  }

  @override
  Future<void> setPrimaryContact(String contactId) async {
    final current = getContacts();
    final updated = current
        .map((c) => c.copyWith(isPrimary: c.id == contactId))
        .toList(growable: false);

    await saveContacts(updated);
  }

  @override
  SafetyPreferences getPreferences() {
    final prefs = _preferences;
    if (prefs == null) return const SafetyPreferences();

    final rawJson = prefs.getString(_preferencesKey);
    if (rawJson == null) return const SafetyPreferences();

    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return SafetyPreferences.fromJson(map);
    } on Object catch (_) {
      return const SafetyPreferences();
    }
  }

  @override
  Future<void> savePreferences(SafetyPreferences preferences) async {
    final prefs = _preferences;
    if (prefs == null) return;

    final jsonStr = jsonEncode(preferences.toJson());
    final ok = await prefs.setString(_preferencesKey, jsonStr);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist safety preferences',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    final prefs = _preferences;
    if (prefs == null) return;

    await prefs.remove(_contactsKey);
    await prefs.remove(_preferencesKey);
  }
}
