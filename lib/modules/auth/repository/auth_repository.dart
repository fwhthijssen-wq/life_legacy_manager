import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_database.dart';
import '../../../core/person_repository.dart';
import '../../person/person_model.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String passwordHash;
  final String? pinHash;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    this.pinHash,
  });

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      id: m['id'],
      email: m['email'],
      firstName: m['first_name'],
      lastName: m['last_name'],
      passwordHash: m['password_hash'],
      pinHash: m['pin_hash'],
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
    required String lastName,
    required String email,
    required String password,
    required DateTime birthDate,
    required String gender,
  }) async {
    final db = await AppDatabase.instance.database;
    final userId = const Uuid().v4();
    final hash = sha256.convert(utf8.encode(password)).toString();

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

    // user ook opslaan als persoon:
    await PersonRepository.addPerson(
      PersonModel(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        birthDate: birthDate.toIso8601String(),
      ),
    );

    return userId;
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
}
