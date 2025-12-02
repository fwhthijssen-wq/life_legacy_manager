// lib/modules/household/repository/household_repository.dart

import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/household_member.dart';
import '../models/personal_document.dart';
import '../../person/models/person.dart';

class HouseholdRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ========== HOUSEHOLD MEMBERS ==========

  /// Get all household members for a dossier with person details
  Future<List<Map<String, dynamic>>> getHouseholdMembers(String dossierId) async {
    final database = await _db.database;
    
    // Join household_members with persons to get full details
    final result = await database.rawQuery('''
      SELECT 
        hm.*,
        p.first_name,
        p.name_prefix,
        p.last_name,
        p.gender,
        p.birth_date,
        p.email,
        p.phone,
        p.bsn,
        p.civil_status
      FROM household_members hm
      INNER JOIN persons p ON hm.person_id = p.id
      WHERE hm.dossier_id = ?
      ORDER BY hm.is_primary DESC, p.birth_date ASC
    ''', [dossierId]);
    
    return result;
  }

  /// Add a person to household
  Future<HouseholdMember> addHouseholdMember({
    required String dossierId,
    required String personId,
    required HouseholdRelation relation,
    bool isPrimary = false,
  }) async {
    final database = await _db.database;
    
    final member = HouseholdMember(
      id: const Uuid().v4(),
      dossierId: dossierId,
      personId: personId,
      relation: relation,
      isPrimary: isPrimary,
      createdAt: DateTime.now(),
    );
    
    await database.insert('household_members', member.toMap());
    return member;
  }

  /// Remove person from household
  Future<void> removeHouseholdMember(String id) async {
    final database = await _db.database;
    await database.delete(
      'household_members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update household member relation
  Future<void> updateHouseholdMember(HouseholdMember member) async {
    final database = await _db.database;
    await database.update(
      'household_members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  /// Check if person is already in household
  Future<bool> isPersonInHousehold(String dossierId, String personId) async {
    final database = await _db.database;
    final result = await database.query(
      'household_members',
      where: 'dossier_id = ? AND person_id = ?',
      whereArgs: [dossierId, personId],
    );
    return result.isNotEmpty;
  }

  /// Get primary household member (account holder)
  Future<Map<String, dynamic>?> getPrimaryMember(String dossierId) async {
    final database = await _db.database;
    
    final result = await database.rawQuery('''
      SELECT 
        hm.*,
        p.first_name,
        p.name_prefix,
        p.last_name,
        p.gender,
        p.birth_date,
        p.email,
        p.phone,
        p.bsn,
        p.civil_status
      FROM household_members hm
      INNER JOIN persons p ON hm.person_id = p.id
      WHERE hm.dossier_id = ? AND hm.is_primary = 1
      LIMIT 1
    ''', [dossierId]);
    
    return result.isNotEmpty ? result.first : null;
  }

  // ========== PERSONAL DOCUMENTS ==========

  /// Get all documents for a person
  Future<List<PersonalDocument>> getPersonDocuments(String personId) async {
    final database = await _db.database;
    final result = await database.query(
      'personal_documents',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'document_type ASC, created_at DESC',
    );
    
    return result.map((map) => PersonalDocument.fromMap(map)).toList();
  }

  /// Add a document
  Future<PersonalDocument> addDocument(PersonalDocument document) async {
    final database = await _db.database;
    await database.insert('personal_documents', document.toMap());
    return document;
  }

  /// Update a document
  Future<void> updateDocument(PersonalDocument document) async {
    final database = await _db.database;
    final updatedDocument = document.copyWith(updatedAt: DateTime.now());
    await database.update(
      'personal_documents',
      updatedDocument.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    final database = await _db.database;
    await database.delete(
      'personal_documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get expiring documents (within 90 days)
  Future<List<PersonalDocument>> getExpiringDocuments(String dossierId) async {
    final database = await _db.database;
    
    final now = DateTime.now();
    final threeMonthsFromNow = now.add(const Duration(days: 90));
    
    final result = await database.rawQuery('''
      SELECT pd.*
      FROM personal_documents pd
      INNER JOIN persons p ON pd.person_id = p.id
      INNER JOIN household_members hm ON p.id = hm.person_id
      WHERE hm.dossier_id = ?
        AND pd.expiry_date IS NOT NULL
        AND pd.expiry_date <= ?
        AND pd.expiry_date >= ?
      ORDER BY pd.expiry_date ASC
    ''', [
      dossierId,
      threeMonthsFromNow.toIso8601String(),
      now.toIso8601String(),
    ]);
    
    return result.map((map) => PersonalDocument.fromMap(map)).toList();
  }

  // ========== PERSON INFO (BSN, CIVIL STATUS) ==========

  /// Update person's BSN
  Future<void> updatePersonBSN(String personId, String? bsn) async {
    final database = await _db.database;
    await database.update(
      'persons',
      {'bsn': bsn},
      where: 'id = ?',
      whereArgs: [personId],
    );
  }

  /// Update person's civil status
  Future<void> updatePersonCivilStatus(String personId, String? civilStatus) async {
    final database = await _db.database;
    await database.update(
      'persons',
      {'civil_status': civilStatus},
      where: 'id = ?',
      whereArgs: [personId],
    );
  }
}
