// lib/modules/contacts/repository/contact_repository.dart

import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ========== CREATE ==========

  /// Voeg een nieuw contact toe
  Future<Contact> addContact({
    required String dossierId,
    required String name,
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
    String? country,
    String? email,
    String? phone,
    String? mobile,
    ContactCategory category = ContactCategory.other,
    String? notes,
    bool forFuneral = false,
    bool forNewsletter = false,
    bool forParty = false,
  }) async {
    final database = await _db.database;

    final contact = Contact(
      id: const Uuid().v4(),
      dossierId: dossierId,
      name: name,
      street: street,
      houseNumber: houseNumber,
      postalCode: postalCode,
      city: city,
      country: country ?? 'Nederland',
      email: email,
      phone: phone,
      mobile: mobile,
      category: category,
      notes: notes,
      forFuneral: forFuneral,
      forNewsletter: forNewsletter,
      forParty: forParty,
      createdAt: DateTime.now(),
    );

    await database.insert('contacts', contact.toMap());
    return contact;
  }

  // ========== READ ==========

  /// Haal alle contacten op voor een dossier
  Future<List<Contact>> getContacts(String dossierId) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Haal contacten op per categorie
  Future<List<Contact>> getContactsByCategory(
    String dossierId,
    ContactCategory category,
  ) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ? AND category = ?',
      whereArgs: [dossierId, category.name],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Haal contacten op voor rouwkaarten
  Future<List<Contact>> getFuneralContacts(String dossierId) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ? AND for_funeral = 1',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Haal contacten op voor nieuwsbrief
  Future<List<Contact>> getNewsletterContacts(String dossierId) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ? AND for_newsletter = 1',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Haal contacten op voor feestjes
  Future<List<Contact>> getPartyContacts(String dossierId) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ? AND for_party = 1',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Zoek contacten op naam
  Future<List<Contact>> searchContacts(String dossierId, String query) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'dossier_id = ? AND name LIKE ?',
      whereArgs: [dossierId, '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  /// Haal een specifiek contact op
  Future<Contact?> getContact(String contactId) async {
    final database = await _db.database;
    final result = await database.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Contact.fromMap(result.first);
  }

  /// Tel contacten per dossier
  Future<int> getContactCount(String dossierId) async {
    final database = await _db.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM contacts WHERE dossier_id = ?',
      [dossierId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Tel contacten per categorie
  Future<Map<ContactCategory, int>> getContactCountByCategory(
    String dossierId,
  ) async {
    final database = await _db.database;
    final result = await database.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM contacts 
      WHERE dossier_id = ? 
      GROUP BY category
    ''', [dossierId]);

    final counts = <ContactCategory, int>{};
    for (final row in result) {
      final category = ContactCategoryExtension.fromString(row['category'] as String?);
      counts[category] = (row['count'] as int?) ?? 0;
    }
    return counts;
  }

  // ========== UPDATE ==========

  /// Update een contact
  Future<void> updateContact(Contact contact) async {
    final database = await _db.database;
    final updatedContact = contact.copyWith(updatedAt: DateTime.now());
    await database.update(
      'contacts',
      updatedContact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// Toggle rouwkaart selectie
  Future<void> toggleFuneral(String contactId, bool value) async {
    final database = await _db.database;
    await database.update(
      'contacts',
      {
        'for_funeral': value ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// Toggle nieuwsbrief selectie
  Future<void> toggleNewsletter(String contactId, bool value) async {
    final database = await _db.database;
    await database.update(
      'contacts',
      {
        'for_newsletter': value ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// Toggle feestje selectie
  Future<void> toggleParty(String contactId, bool value) async {
    final database = await _db.database;
    await database.update(
      'contacts',
      {
        'for_party': value ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// Bulk update categorie
  Future<void> bulkUpdateCategory(
    List<String> contactIds,
    ContactCategory category,
  ) async {
    final database = await _db.database;
    for (final id in contactIds) {
      await database.update(
        'contacts',
        {
          'category': category.name,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ========== DELETE ==========

  /// Verwijder een contact
  Future<void> deleteContact(String contactId) async {
    final database = await _db.database;
    await database.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  /// Verwijder meerdere contacten
  Future<void> deleteContacts(List<String> contactIds) async {
    final database = await _db.database;
    for (final id in contactIds) {
      await database.delete(
        'contacts',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}






