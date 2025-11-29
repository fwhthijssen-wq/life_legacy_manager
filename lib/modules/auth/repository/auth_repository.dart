// lib/modules/auth/repository/auth_repository.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_database.dart';
import '../../../core/person_repository.dart';
import '../../person/person_model.dart';
import '../../dossier/dossier_repository.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String passwordHash;
  final String? pinHash;
  final bool isBiometricEnabled;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    this.pinHash,
    this.isBiometricEnabled = false,
  });

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      id: m['id'],
      email: m['email'],
      firstName: m['first_name'],
      lastName: m['last_name'],
      passwordHash: m['password_hash'],
      pinHash: m['pin_hash'],
      isBiometricEnabled: (m['is_biometric_enabled'] ?? 0) == 1,
    );
  }
}

class AuthRepository {
  final Ref ref;
  AuthRepository(this.ref);

  Future<AuthUser?> getUserByEmail(String email) async {
    final db = await AppDatabase.instance.database;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return AuthUser.fromMap(res.first);
  }

  Future<AuthUser?> getUserById(String id) async {
    final db = await AppDatabase.instance.database;
    final res =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return AuthUser.fromMap(res.first);
  }

  Future<String?> register({
    required String firstName,
    String? namePrefix,  // ← NIEUW: optioneel tussenvoegsel
    required String lastName,
    required String email,
    required String password,
    required DateTime birthDate,
    required String gender,
  }) async {
    try {
      print('🔵 Register START');
      
      final db = await AppDatabase.instance.database;
      print('🔵 Database OK');
      
      final userId = const Uuid().v4();
      print('🔵 UserID: $userId');
      
      final hash = sha256.convert(utf8.encode(password)).toString();
      print('🔵 Password hashed');

      await db.insert('users', {
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'birth_date': birthDate.millisecondsSinceEpoch,
        'email': email.toLowerCase(),
        'password_hash': hash,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      print('🔵 User inserted in database');

      // Maak standaard dossier
      final dossier = await DossierRepository.createDossier(
        userId: userId,
        name: 'Mijn Dossier',
        description: 'Standaard dossier',
        icon: 'folder',
        color: 'teal',
      );
      print('🔵 Standaard dossier aangemaakt: ${dossier.id}');

      // Capitalize gender voor PersonModel
      final capitalizedGender = gender.isNotEmpty
          ? gender[0].toUpperCase() + gender.substring(1).toLowerCase()
          : null;

      // User ook opslaan als persoon IN HET DOSSIER (met namePrefix!)
      await PersonRepository.addPerson(
        PersonModel(
          id: userId,
          dossierId: dossier.id,
          firstName: firstName,
          namePrefix: namePrefix,  // ← NIEUW: tussenvoegsel meegeven
          lastName: lastName,
          email: email,
          birthDate: birthDate.toIso8601String(),
          gender: capitalizedGender,
          relation: 'Ikzelf',
        ),
      );
      print('🔵 Person inserted in dossier (met namePrefix: $namePrefix)');

      print('✅ Register SUCCESS - UserID: $userId');
      return userId;
      
    } catch (e, stackTrace) {
      print('❌ Register ERROR: $e');
      print('❌ StackTrace: $stackTrace');
      return null;
    }
  }

  Future<void> setPin(String userId, String pinHash) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'users',
      {'pin_hash': pinHash, 'is_pin_enabled': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> enableBiometrics(String userId) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'users',
      {'is_biometric_enabled': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> disableBiometrics(String userId) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'users',
      {'is_biometric_enabled': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
