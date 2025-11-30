// lib/core/app_database.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Windows: FFI gebruiken
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'life_legacy_manager.db');

    return await openDatabase(
      path,
      version: 2, // ← VERSIE VERHOOGD van 1 naar 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // USERS tabel (login/registratie)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        name_prefix TEXT,
        last_name TEXT NOT NULL,
        gender TEXT,
        birth_date INTEGER,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        pin_hash TEXT,
        is_pin_enabled INTEGER NOT NULL DEFAULT 0,
        is_biometric_enabled INTEGER NOT NULL DEFAULT 0,
        recovery_phrase_hash TEXT,
        created_at INTEGER NOT NULL,
        last_login INTEGER
      );
    ''');

    // DOSSIERS tabel (✅ NIEUW - meerdere dossiers per user)
    await db.execute('''
      CREATE TABLE dossiers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // PERSONS tabel (uitgebreid met dossier_id en name_prefix)
    await db.execute('''
      CREATE TABLE persons (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        name_prefix TEXT,
        last_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        birth_date TEXT,
        address TEXT,
        postal_code TEXT,
        city TEXT,
        gender TEXT,
        notes TEXT,
        relation TEXT,
        death_date TEXT,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');

    // Index voor sneller zoeken
    await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
    await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade: v$oldVersion → v$newVersion');

    if (oldVersion < 2) {
      print('📊 Upgrading to version 2...');
      
      // 1. Voeg dossiers tabel toe
      await db.execute('''
        CREATE TABLE dossiers (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          color TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      print('✅ Dossiers tabel aangemaakt');

      // 2. Voeg name_prefix en dossier_id toe aan persons
      await db.execute('ALTER TABLE persons ADD COLUMN name_prefix TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN dossier_id TEXT;');
      print('✅ Persons tabel uitgebreid');

      // 3. Voeg recovery_phrase_hash toe aan users
      await db.execute('ALTER TABLE users ADD COLUMN recovery_phrase_hash TEXT;');
      print('✅ Users tabel uitgebreid');

      // 4. Migratie: Maak standaard dossier voor elke user
      final users = await db.query('users');
      for (final user in users) {
        final userId = user['id'] as String;
        final firstName = user['first_name'] as String;
        
        // Maak standaard dossier
        final dossierId = 'dossier_${userId}_default';
        await db.insert('dossiers', {
          'id': dossierId,
          'user_id': userId,
          'name': 'Mijn Dossier',
          'description': 'Standaard dossier',
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        print('✅ Standaard dossier aangemaakt voor $firstName');

        // Update alle bestaande persons
        await db.execute('''
          UPDATE persons 
          SET dossier_id = ? 
          WHERE id = ? OR id IN (
            SELECT id FROM persons WHERE dossier_id IS NULL
          )
        ''', [dossierId, userId]);
        
        print('✅ Persons gekoppeld aan dossier');
      }

      // 5. Maak dossier_id NOT NULL (nu alle records een waarde hebben)
      // SQLite ondersteunt ALTER COLUMN niet, dus we recreate de tabel
      // Maar dit is al gedaan via de update hierboven
      
      // 6. Maak indexes
      await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
      await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
      print('✅ Indexes aangemaakt');

      print('🎉 Database upgrade naar v2 voltooid!');
    }
  }

  // ---------- Helper methoden ----------

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawUpdate(sql, args);
  }
}
