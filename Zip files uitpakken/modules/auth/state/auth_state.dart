enum AuthStatus {
  unauthenticated,
  authenticated,
  locked,
}

class AuthState {
  final AuthStatus status;
  final String? userId;

  const AuthState({
    required this.status,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}
