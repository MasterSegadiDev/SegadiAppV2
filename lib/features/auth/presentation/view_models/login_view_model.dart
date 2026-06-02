import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:segadi/core/errors/failures.dart';
import 'package:segadi/features/auth/domain/entities/auth_result.dart';
import 'package:segadi/features/auth/domain/entities/auth_token.dart';
import 'package:segadi/features/auth/presentation/providers/auth_provider.dart';

import '../../domain/use_cases/login_use_case.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthProvider? _authProvider;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  LoginViewModel({
    required this.loginUseCase,
  });

  void setAuthProvider(
    AuthProvider authProvider,
  ) {
    _authProvider = authProvider;
  }

  // Future<bool> login() async {
  //   _errorMessage = null;

  //   _isLoading = true;

  //   notifyListeners();

  //   final Either<Failure, AuthToken> result = await loginUseCase.execute(
  //     usernameController.text.trim(),
  //     passwordController.text.trim(),
  //   );

  //   _isLoading = false;

  //   return result.fold(
  //     (failure) {
  //       _errorMessage = failure.message;

  //       notifyListeners();

  //       return false;
  //     },
  //     (token) {
  //       debugPrint(
  //         "Login token: ${token.accessToken}",
  //       );

  //       _authProvider?.setAuthenticated(true);

  //       notifyListeners();

  //       return true;
  //     },
  //   );
  // }

  String _currentRole = '';
  String get currentRole => _currentRole;

  Future<bool> login() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final Either<Failure, AuthResult> result = await loginUseCase.execute(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (authResult) {
        debugPrint("Login token: ${authResult.token.accessToken}");

        // --- CÓDIGO CONCRETO PARA ROLES SIMULADOS ---
        // Extraemos el rol basándonos en el texto que escribieron en el controlador
        final userText = usernameController.text.trim().toLowerCase();

        if (userText == 'trailer') {
          _currentRole = 'OPERADOR_TRAILER';
        } else if (userText == 'grua') {
          _currentRole = 'OPERADOR_GRUA';
        } else {
          _currentRole =
              'OPERADOR_TRAILER'; // Rol por defecto para que no truene
        }
        // --------------------------------------------

        _authProvider?.setAuthenticated(true);
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();

    passwordController.dispose();

    super.dispose();
  }
}
