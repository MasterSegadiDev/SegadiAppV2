import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  AuthStatus authStatus = AuthStatus.checking;

  AuthProvider(this.repository) {
    checkAuthStatus();
  }
  void setAuthenticated(bool isAuthenticated) {
    authStatus = isAuthenticated
        ? AuthStatus.authenticated
        : AuthStatus.notAuthenticated;

    // Crucial: esto notifica a GoRouter para que haga el redirect
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = await repository.getPersistedToken();
    authStatus = (token != null)
        ? AuthStatus.authenticated
        : AuthStatus.notAuthenticated;
    notifyListeners();
  }

  Future<void> login(String user, String password) async {
    final token = await repository.login(user, password);
    if (token != null) {
      authStatus = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();

    authStatus = AuthStatus.notAuthenticated;

    notifyListeners();
  }
}
