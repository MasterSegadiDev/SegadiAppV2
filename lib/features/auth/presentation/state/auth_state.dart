enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState._({required this.status, this.errorMessage});

  const AuthState.initial() : this._(status: AuthStatus.initial);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.error({required this.errorMessage})
      : status = AuthStatus.error;

  bool get isLoading => status == AuthStatus.loading;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get hasError => status == AuthStatus.error;
}
