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
    
    // DEBUG: Print database locatie
    print('');
    print('════════════════════════════════════════════');
    print('📁 DATABASE PAD: $path');
    print('════════════════════════════════════════════');
    print('');

    return await openDatabase(
      path,
      version: 8, // ← VERSIE 8: created_at kolom + schema cleanup
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

    // DOSSIERS tabel
    await db.execute('''
      CREATE TABLE dossiers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        type TEXT DEFAULT 'family',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // PERSONS tabel (uitgebreid met contact-velden)
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
        is_contact INTEGER NOT NULL DEFAULT 0,
        contact_categories TEXT,
        created_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');

    // Index voor sneller zoeken
    await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
    await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
    await db.execute('CREATE INDEX idx_persons_contact ON persons(is_contact);');
    
    // HOUSEHOLD_MEMBERS tabel (gezinsleden per dossier)
    await db.execute('''
      CREATE TABLE household_members (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        relation TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
        UNIQUE(dossier_id, person_id)
      );
    ''');
    
    // PERSONAL_DOCUMENTS tabel (documenten per persoon)
    await db.execute('''
      CREATE TABLE personal_documents (
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        document_type TEXT NOT NULL,
        document_number TEXT,
        issue_date TEXT,
        expiry_date TEXT,
        issuing_authority TEXT,
        document_file_path TEXT,
        physical_location TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
      );
    ''');
    
    // Uitbreiding persons tabel met BSN en burgerlijke staat
    await db.execute('ALTER TABLE persons ADD COLUMN bsn TEXT;');
    await db.execute('ALTER TABLE persons ADD COLUMN civil_status TEXT;');
    
    // EMAIL_TEMPLATES tabel
    await db.execute('''
      CREATE TABLE email_templates (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        name TEXT NOT NULL,
        subject TEXT,
        body TEXT,
        mailing_type TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // MAILING_LISTS tabel
    await db.execute('''
      CREATE TABLE mailing_lists (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        contact_ids TEXT,
        mailing_type TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes voor nieuwe tabellen
    await db.execute('CREATE INDEX idx_household_dossier ON household_members(dossier_id);');
    await db.execute('CREATE INDEX idx_household_person ON household_members(person_id);');
    await db.execute('CREATE INDEX idx_documents_person ON personal_documents(person_id);');
    await db.execute('CREATE INDEX idx_templates_dossier ON email_templates(dossier_id);');
    await db.execute('CREATE INDEX idx_templates_type ON email_templates(mailing_type);');
    await db.execute('CREATE INDEX idx_mailing_lists_dossier ON mailing_lists(dossier_id);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade: v$oldVersion → v$newVersion');

    if (oldVersion < 2) {
      print('📊 Upgrading to version 2...');
      
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

      await db.execute('ALTER TABLE persons ADD COLUMN name_prefix TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN dossier_id TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN recovery_phrase_hash TEXT;');

      final users = await db.query('users');
      for (final user in users) {
        final userId = user['id'] as String;
        final dossierId = 'dossier_${userId}_default';
        await db.insert('dossiers', {
          'id': dossierId,
          'user_id': userId,
          'name': 'Mijn Dossier',
          'description': 'Standaard dossier',
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        await db.execute('UPDATE persons SET dossier_id = ? WHERE dossier_id IS NULL', [dossierId]);
      }

      await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
      await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
      print('🎉 Database upgrade naar v2 voltooid!');
    }
    
    if (oldVersion < 3) {
      print('👨‍👩‍👧‍👦 Upgrading to version 3...');
      
      await db.execute('''
        CREATE TABLE household_members (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          person_id TEXT NOT NULL,
          relation TEXT NOT NULL,
          is_primary INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
          FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
          UNIQUE(dossier_id, person_id)
        );
      ''');
      
      await db.execute('''
        CREATE TABLE personal_documents (
          id TEXT PRIMARY KEY,
          person_id TEXT NOT NULL,
          document_type TEXT NOT NULL,
          document_number TEXT,
          issue_date TEXT,
          expiry_date TEXT,
          issuing_authority TEXT,
          document_file_path TEXT,
          physical_location TEXT,
          notes TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
        );
      ''');
      
      await db.execute('ALTER TABLE persons ADD COLUMN bsn TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN civil_status TEXT;');
      
      await db.execute('CREATE INDEX idx_household_dossier ON household_members(dossier_id);');
      await db.execute('CREATE INDEX idx_household_person ON household_members(person_id);');
      await db.execute('CREATE INDEX idx_documents_person ON personal_documents(person_id);');
      
      print('🎉 Database upgrade naar v3 voltooid!');
    }
    
    if (oldVersion < 4) {
      print('📇 Upgrading to version 4: Contacten in persons tabel...');
      
      // Contact-velden toevoegen aan persons tabel
      await db.execute('ALTER TABLE persons ADD COLUMN is_contact INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN contact_category TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_christmas_card INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_newsletter INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_party INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_funeral INTEGER NOT NULL DEFAULT 0;');
      print('✅ Persons tabel uitgebreid met contact-velden');
      
      // Index voor contacten
      await db.execute('CREATE INDEX idx_persons_contact ON persons(is_contact);');
      print('✅ Contact index aangemaakt');
      
      print('🎉 Database upgrade naar v4 voltooid!');
    }
    
    if (oldVersion < 5) {
      print('📧 Upgrading to version 5: Email templates...');
      
      // Email templates tabel
      await db.execute('''
        CREATE TABLE email_templates (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          name TEXT NOT NULL,
          subject TEXT,
          body TEXT,
          mailing_type TEXT,
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
        );
      ''');
      
      // Index voor templates
      await db.execute('CREATE INDEX idx_templates_dossier ON email_templates(dossier_id);');
      await db.execute('CREATE INDEX idx_templates_type ON email_templates(mailing_type);');
      
      print('🎉 Database upgrade naar v5 voltooid!');
    }
    
    if (oldVersion < 6) {
      print('📋 Upgrading to version 6: Mailing lijsten...');
      
      // Mailing lijsten tabel
      await db.execute('''
        CREATE TABLE mailing_lists (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          contact_ids TEXT,
          mailing_type TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
        );
      ''');
      
      // Index voor lijsten
      await db.execute('CREATE INDEX idx_mailing_lists_dossier ON mailing_lists(dossier_id);');
      
      print('🎉 Database upgrade naar v6 voltooid!');
    }
    
    if (oldVersion < 7) {
      print('📋 Upgrading to version 7: Meerdere categorieën per contact...');
      
      // Voeg nieuwe 'categories' kolom toe
      await db.execute('ALTER TABLE persons ADD COLUMN categories TEXT;');
      
      // Migreer bestaande data: kopieer contact_category naar categories
      await db.execute('''
        UPDATE persons 
        SET categories = contact_category 
        WHERE contact_category IS NOT NULL AND contact_category != ''
      ''');
      
      print('🎉 Database upgrade naar v7 voltooid!');
      print('   → Bestaande categorieën gemigreerd naar nieuwe structuur');
    }
    
    if (oldVersion < 8) {
      print('📋 Upgrading to version 8: created_at kolom + schema cleanup...');
      
      // Voeg created_at kolom toe aan persons
      await db.execute('ALTER TABLE persons ADD COLUMN created_at INTEGER;');
      
      // Voeg contact_categories kolom toe (hernoemd van categories)
      try {
        await db.execute('ALTER TABLE persons ADD COLUMN contact_categories TEXT;');
        // Kopieer bestaande categories data
        await db.execute('''
          UPDATE persons 
          SET contact_categories = categories 
          WHERE categories IS NOT NULL AND categories != ''
        ''');
      } catch (e) {
        print('   contact_categories kolom bestaat mogelijk al: $e');
      }
      
      print('🎉 Database upgrade naar v8 voltooid!');
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
