import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../services/recovery_phrase_service.dart';

/// Auth Repository
/// Handles all authentication-related business logic
class AuthRepository {
  static const _uuid = Uuid();

  /// Register a new user
  Future<String?> registerUser({
    required String firstName,
    String? namePrefix,
    required String lastName,
    required String email,
    required String password,
    String? gender,
    int? birthDate,
  }) async {
    final db = await AppDatabase.instance.database;

    // DEBUG: Toon alle bestaande users
    final allUsers = await db.query('users');
    print('📊 ALLE USERS IN DATABASE: ${allUsers.length}');
    for (var u in allUsers) {
      print('   - ${u['email']}');
    }

    // Check if email already exists
    final existingUsers = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    print('🔍 Check email "$email": gevonden=${existingUsers.length}');

    if (existingUsers.isNotEmpty) {
      print('❌ EMAIL BESTAAT AL!');
      throw Exception('Email already in use');
    }

    // Create user
    final userId = _uuid.v4();
    final passwordHash = _hashPassword(password);
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('users', {
      'id': userId,
      'first_name': firstName,
      'name_prefix': namePrefix,
      'last_name': lastName,
      'email': email.toLowerCase(),
      'password_hash': passwordHash,
      'gender': gender,
      'birth_date': birthDate,
      'is_pin_enabled': 0,
      'is_biometric_enabled': 0,
      'created_at': now,
      'last_login': now,
    });

    return userId;
  }

  /// Login with email and password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (users.isEmpty) {
      return null;
    }

    final user = users.first;
    final storedHash = user['password_hash'] as String;
    final passwordHash = _hashPassword(password);

    if (storedHash != passwordHash) {
      return null;
    }

    // Update last login
    await db.update(
      'users',
      {'last_login': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [user['id']],
    );

    return user['id'] as String;
  }

  /// Setup PIN for a user
  Future<void> setupPin({
    required String userId,
    required String pin,
    bool enableBiometric = false,
  }) async {
    final db = await AppDatabase.instance.database;
    final pinHash = _hashPassword(pin);

    await db.update(
      'users',
      {
        'pin_hash': pinHash,
        'is_pin_enabled': 1,
        'is_biometric_enabled': enableBiometric ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Verify PIN
  Future<bool> verifyPin({
    required String userId,
    required String pin,
  }) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return false;
    }

    final user = users.first;
    final storedHash = user['pin_hash'] as String?;

    if (storedHash == null) {
      return false;
    }

    final pinHash = _hashPassword(pin);
    return storedHash == pinHash;
  }

  /// Check if user has PIN enabled
  Future<bool> hasPinEnabled(String userId) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      columns: ['is_pin_enabled'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return false;
    }

    return users.first['is_pin_enabled'] == 1;
  }

  /// Check if user has biometric enabled
  Future<bool> hasBiometricEnabled(String userId) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      columns: ['is_biometric_enabled'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return false;
    }

    return users.first['is_biometric_enabled'] == 1;
  }

  /// Save recovery phrase hash during registration
  /// 
  /// [userId] - User ID to save recovery phrase for
  /// [phrase] - List of 12 recovery words
  Future<void> saveRecoveryPhrase(String userId, List<String> phrase) async {
    final db = await AppDatabase.instance.database;
    final hash = RecoveryPhraseService.hashPhrase(phrase);
    
    await db.update(
      'users',
      {'recovery_phrase_hash': hash},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Verify recovery phrase and reset password
  /// 
  /// [email] - User's email address
  /// [recoveryPhrase] - List of 12 recovery words
  /// [newPassword] - New password to set
  /// Returns true if successful, throws exception otherwise
  Future<bool> recoverPassword({
    required String email,
    required List<String> recoveryPhrase,
    required String newPassword,
  }) async {
    final db = await AppDatabase.instance.database;
    
    // Get user by email
    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (users.isEmpty) {
      throw Exception('Gebruiker niet gevonden');
    }
    
    final user = users.first;
    final storedHash = user['recovery_phrase_hash'] as String?;
    
    if (storedHash == null || storedHash.isEmpty) {
      throw Exception('Geen recovery phrase ingesteld voor dit account');
    }
    
    // Verify recovery phrase
    final isValid = RecoveryPhraseService.verifyPhrase(recoveryPhrase, storedHash);
    
    if (!isValid) {
      throw Exception('Onjuiste recovery phrase');
    }
    
    // Update password
    final passwordHash = _hashPassword(newPassword);
    await db.update(
      'users',
      {'password_hash': passwordHash},
      where: 'id = ?',
      whereArgs: [user['id']],
    );
    
    return true;
  }

  /// Check if user has recovery phrase set up
  Future<bool> hasRecoveryPhrase(String userId) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      columns: ['recovery_phrase_hash'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return false;
    }

    final hash = users.first['recovery_phrase_hash'] as String?;
    return hash != null && hash.isNotEmpty;
  }

  /// Get user by email (for recovery screen)
  Future<bool> userExistsByEmail(String email) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    return users.isNotEmpty;
  }

  /// Hash a password or PIN using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get user details
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await AppDatabase.instance.database;

    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return null;
    }

    return users.first;
  }
}
