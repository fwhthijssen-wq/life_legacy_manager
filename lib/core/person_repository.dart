// lib/core/person_repository.dart

import 'package:sqflite/sqflite.dart';
import '../modules/person/person_model.dart';
import 'app_database.dart';

class PersonRepository {
  static Future<Database> _getDb() async {
    return await AppDatabase.instance.database;
  }

  static Future<void> addPerson(PersonModel person) async {
    final db = await _getDb();
    await db.insert(
      'persons',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<PersonModel>> getAllPersons() async {
    final db = await _getDb();
    final maps = await db.query('persons');
    return maps.map((m) => PersonModel.fromMap(m)).toList();
  }

  static Future<PersonModel?> getPersonById(String id) async {
    final db = await _getDb();
    final maps =
        await db.query('persons', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return PersonModel.fromMap(maps.first);
  }

  static Future<void> updatePerson(PersonModel updated) async {
    final db = await _getDb();
    await db.update(
      'persons',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  static Future<void> deletePerson(String id) async {
    final db = await _getDb();
    await db.delete(
      'persons',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
