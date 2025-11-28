// lib/modules/auth/state/auth_state_notifier.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';
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
    final hashed = sha256.convert(utf8.encode(pin)).toString();
    final user = await repo.getUserById(state.userId!);

    if (user == null) return false;
    if (user.pinHash != hashed) return false;

    state = state.copyWith(status: AuthStatus.authenticated);
    return true;
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
