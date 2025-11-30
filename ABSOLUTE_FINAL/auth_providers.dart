import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import '../state/auth_state.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>((ref) {
  return AuthStateController();
});

// Auth State Controller
class AuthStateController extends StateNotifier<AuthState> {
  AuthStateController() : super(const AuthState(status: AuthStatus.unauthenticated));

  void login(String userId) {
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
    );
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void lock() {
    if (state.status == AuthStatus.authenticated && state.userId != null) {
      state = AuthState(
        status: AuthStatus.locked,
        userId: state.userId,
      );
    }
  }

  void unlock() {
    if (state.status == AuthStatus.locked && state.userId != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: state.userId,
      );
    }
  }

  // For unlock_screen.dart compatibility
  void unlockWithPin(String userId) {
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
    );
  }

  // For unlock_screen.dart compatibility
  void markAsAuthenticated(String userId) {
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
    );
  }
}
