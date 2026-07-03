import 'package:flutter/material.dart';
import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';
import 'package:segadi/features/auth/presentation/state/auth_state.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel(
    this.loginUseCase,
  );

  AuthState _state = AuthState.initial();

  AuthState get state => _state;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      _state = AuthState.loading();

      notifyListeners();

      await loginUseCase(
        username: username,
        password: password,
      );

      _state = AuthState.authenticated();

      notifyListeners();
    } catch (e) {
      _state = AuthState.error(
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
}
