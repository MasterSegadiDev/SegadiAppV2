import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/core/security/session_manager.dart';
import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';
import 'package:segadi/features/auth/data/models/user_model.dart';
import 'package:segadi/features/auth/presentation/providers/current_user_provider.dart';

import '../state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final Ref ref;

  AuthNotifier(
    this.loginUseCase,
    this.ref,
  ) : super(AuthState.initial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        status: AuthStatus.loading,
      );

      final session = await loginUseCase(
        username: username,
        password: password,
      );

      await SessionManager.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        user: UserModel(
          id: session.user.id,
          username: session.user.username,
          name: session.user.name,
          email: session.user.email,
          roles: session.user.roles,
          permissions: session.user.permissions,
        ).toJson(),
      );

      ref.read(currentUserProvider.notifier).setUser(session.user);

      await SessionManager.getAccessToken();

      state = state.copyWith(
        status: AuthStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );

      debugPrint('error de login sin mockoon: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await SessionManager.clearSession();

    ref
        .read(
          currentUserProvider.notifier,
        )
        .clear();

    state = state.copyWith(
      status: AuthStatus.initial,
    );
  }
}
