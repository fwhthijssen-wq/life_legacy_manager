import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import '../state/auth_state.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider
// Simple state provider without notifier for now
final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>((ref) {
  return AuthStateController();
});

// Simple Auth State Controller
class AuthStateController extends StateNotifier<AuthState> {
  AuthStateController() : super(const AuthState.unauthenticated());

  void login(String userId) {
    state = AuthState.authenticated(userId);
  }

  void logout() {
    state = const AuthState.unauthenticated();
  }

  void lock() {
    if (state.status == AuthStatus.authenticated) {
      state = AuthState.locked(state.userId!);
    }
  }

  void unlock() {
    if (state.status == AuthStatus.locked) {
      state = AuthState.authenticated(state.userId!);
    }
  }
}
