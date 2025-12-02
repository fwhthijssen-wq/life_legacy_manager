// lib/modules/dossier/dossier_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_database.dart';
import 'dossier_model.dart';

class DossierRepository {
  static Future<Database> _getDb() async {
    return await AppDatabase.instance.database;
  }

  /// Maak een nieuw dossier
  static Future<DossierModel> createDossier({
    required String userId,
    required String name,
    String? description,
    String? icon,
    String? color,
    DossierType type = DossierType.family,
  }) async {
    final db = await _getDb();
    
    final dossier = DossierModel(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      icon: icon,
      color: color,
      type: type,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await db.insert('dossiers', dossier.toMap());
    return dossier;
  }

  /// Haal alle dossiers op voor een user
  static Future<List<DossierModel>> getDossiersForUser(String userId) async {
    final db = await _getDb();
    final maps = await db.query(
      'dossiers',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => DossierModel.fromMap(m)).toList();
  }

  /// Haal een specifiek dossier op
  static Future<DossierModel?> getDossierById(String dossierId) async {
    final db = await _getDb();
    final maps = await db.query(
      'dossiers',
      where: 'id = ?',
      whereArgs: [dossierId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DossierModel.fromMap(maps.first);
  }

  /// Update een dossier
  static Future<void> updateDossier(DossierModel dossier) async {
    final db = await _getDb();
    await db.update(
      'dossiers',
      dossier.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [dossier.id],
    );
  }

  /// Verwijder een dossier (soft delete)
  static Future<void> deleteDossier(String dossierId) async {
    final db = await _getDb();
    await db.update(
      'dossiers',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [dossierId],
    );
  }

  /// Hard delete (voor testing/development)
  static Future<void> hardDeleteDossier(String dossierId) async {
    final db = await _getDb();
    // Dit verwijdert ook alle gekoppelde persons (CASCADE)
    await db.delete(
      'dossiers',
      where: 'id = ?',
      whereArgs: [dossierId],
    );
  }

  /// Tel aantal personen in dossier
  static Future<int> getPersonCountInDossier(String dossierId) async {
    final db = await _getDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM persons WHERE dossier_id = ?',
      [dossierId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
