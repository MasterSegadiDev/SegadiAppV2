enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
    );
  }

  factory AuthState.authenticated() {
    return const AuthState(
      status: AuthStatus.authenticated,
    );
  }
  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }
  factory AuthState.error({required String errorMessage}) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: errorMessage,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
