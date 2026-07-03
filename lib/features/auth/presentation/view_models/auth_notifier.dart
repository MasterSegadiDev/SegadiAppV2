import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/security/session_manager.dart';
import '../../data/models/user_model.dart';
import '../../domain/use_cases/login_usecase.dart';
import '../providers/current_user_provider.dart';
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
    if (state.status == AuthStatus.loading) {
      return;
    }

    state = AuthState.loading();

    try {
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

      ref.read(currentUserProvider.notifier).setUser(
            session.user,
          );

      state = AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await SessionManager.clearSession();

    ref.read(currentUserProvider.notifier).clear();

    state = AuthState.initial();
  }
}
