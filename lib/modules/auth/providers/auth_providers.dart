// lib/modules/auth/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';
import '../state/auth_state.dart';
import '../state/auth_state_notifier.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

// Global Auth State
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(ref, repo);
});
