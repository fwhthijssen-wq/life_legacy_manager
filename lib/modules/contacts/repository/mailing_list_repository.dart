// lib/modules/contacts/repository/mailing_list_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/mailing_list_model.dart';

/// Provider voor MailingListRepository
final mailingListRepositoryProvider = Provider<MailingListRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MailingListRepository(db);
});

/// Provider voor mailing lijsten van een dossier
final mailingListsProvider = FutureProvider.family<List<MailingListModel>, String>((ref, dossierId) async {
  final repository = ref.read(mailingListRepositoryProvider);
  return repository.getListsForDossier(dossierId);
});

/// Repository voor mailing lijsten
class MailingListRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  MailingListRepository(this._db);

  /// Haal alle lijsten op voor een dossier
  Future<List<MailingListModel>> getListsForDossier(String dossierId) async {
    final results = await _db.query(
      'mailing_lists',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'name',
    );
    
    return results.map((map) => MailingListModel.fromMap(map)).toList();
  }

  /// Haal een specifieke lijst op
  Future<MailingListModel?> getList(String listId) async {
    final results = await _db.query(
      'mailing_lists',
      where: 'id = ?',
      whereArgs: [listId],
    );
    
    if (results.isEmpty) return null;
    return MailingListModel.fromMap(results.first);
  }

  /// Maak een nieuwe lijst aan
  Future<MailingListModel> createList({
    required String dossierId,
    required String name,
    String? description,
    required List<String> contactIds,
    String? mailingType,
    String emoji = '📋',
  }) async {
    final now = DateTime.now();
    final list = MailingListModel(
      id: _uuid.v4(),
      dossierId: dossierId,
      name: name,
      description: description,
      contactIds: contactIds,
      mailingType: mailingType,
      emoji: emoji,
      createdAt: now,
    );
    
    print('📋 Mailing lijst opslaan: ${list.name} met ${list.contactCount} contacten');
    print('   → dossier_id: $dossierId');
    print('   → contact_ids: ${list.contactIds.join(",")}');
    
    await _db.insert('mailing_lists', list.toMap());
    
    // Controleer of de lijst daadwerkelijk is opgeslagen
    final check = await getListsForDossier(dossierId);
    print('   ✓ Opgeslagen! Totaal ${check.length} lijsten voor dit dossier.');
    
    return list;
  }

  /// Haal contacten van een lijst op
  Future<List<String>> getListContacts(String listId) async {
    final list = await getList(listId);
    return list?.contactIds ?? [];
  }

  /// Update een bestaande lijst (met model)
  Future<void> updateListModel(MailingListModel list) async {
    final updated = list.copyWith(updatedAt: DateTime.now());
    
    await _db.update(
      'mailing_lists',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  /// Update een lijst met individuele parameters
  Future<void> updateList({
    required String listId,
    required String name,
    required String emoji,
    required List<String> contactIds,
    String? description,
  }) async {
    await _db.update(
      'mailing_lists',
      {
        'name': name,
        'emoji': emoji,
        'contact_ids': contactIds.join(','),
        'description': description,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  /// Update alleen de contacten in een lijst
  Future<void> updateListContacts(String listId, List<String> contactIds) async {
    await _db.update(
      'mailing_lists',
      {
        'contact_ids': contactIds.join(','),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  /// Verwijder een lijst
  Future<void> deleteList(String listId) async {
    await _db.delete(
      'mailing_lists',
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  /// Controleer of een naam al bestaat
  Future<bool> nameExists(String dossierId, String name, {String? excludeId}) async {
    final results = await _db.query(
      'mailing_lists',
      where: excludeId != null 
          ? 'dossier_id = ? AND name = ? AND id != ?'
          : 'dossier_id = ? AND name = ?',
      whereArgs: excludeId != null 
          ? [dossierId, name, excludeId]
          : [dossierId, name],
    );
    
    return results.isNotEmpty;
  }
}

