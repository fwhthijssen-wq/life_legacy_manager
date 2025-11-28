// lib/modules/auth/services/auth_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../repository/auth_repository.dart';
import '../state/auth_state_notifier.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final notifier = ref.watch(authStateProvider.notifier);
  return AuthService(repo, notifier);
});

class AuthService {
  final AuthRepository repo;
  final AuthStateNotifier notifier;

  AuthService(this.repo, this.notifier);

  Future<bool> login(String email, String password) {
    return notifier.login(email, password);
  }

  Future<void> setPin(String userId, String pin) async {
    await notifier.setPin(userId, pin);
  }

  Future<bool> unlockWithPin(String pin) async {
    return notifier.unlockWithPin(pin);
  }

  void logout() {
    notifier.logout();
  }
}
