// lib/modules/auth/state/auth_state_notifier.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';
import '../../../core/app_database.dart';
import 'auth_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository repo;

  AuthStateNotifier(this.ref, this.repo)
      : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<bool> login(String email, String password) async {
    final hashed = sha256.convert(utf8.encode(password)).toString();
    final user = await repo.getUserByEmail(email);

    if (user == null) return false;
    if (user.passwordHash != hashed) return false;

    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: user.id,
    );

    return true;
  }

  Future<void> setPin(String userId, String pin) async {
    final hashed = sha256.convert(utf8.encode(pin)).toString();
    await repo.setPin(userId, hashed);
  }

  Future<bool> unlockWithPin(String pin) async {
    try {
      print('🔵 Unlock with PIN - START');
      
      // Hash de ingevoerde PIN
      final hashedPin = sha256.convert(utf8.encode(pin)).toString();
      print('🔵 PIN hashed: ${hashedPin.substring(0, 10)}...');

      // Haal de user op uit database (we nemen de eerste, want er is er maar 1)
      final db = await AppDatabase.instance.database;
      final users = await db.query('users', limit: 1);

      if (users.isEmpty) {
        print('❌ No users found in database');
        return false;
      }

      final user = users.first;
      final storedPinHash = user['pin_hash'] as String?;
      final userId = user['id'] as String;

      print('🔵 User found: $userId');
      print('🔵 Stored PIN hash: ${storedPinHash?.substring(0, 10)}...');

      if (storedPinHash == null) {
        print('❌ No PIN set for this user');
        return false;
      }

      if (storedPinHash != hashedPin) {
        print('❌ PIN mismatch');
        return false;
      }

      print('✅ PIN correct! Unlocking...');

      // PIN is correct → update auth state
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
      );

      return true;
    } catch (e, stackTrace) {
      print('❌ Unlock error: $e');
      print('❌ StackTrace: $stackTrace');
      return false;
    }
  }

  void markAsAuthenticated() {
    // Voor biometrie: gewoon authenticeren zonder PIN check
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}