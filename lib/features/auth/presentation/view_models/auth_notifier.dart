import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';

import '../../../../core/security/permission_codes.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../core/security/providers/permission_service_provider.dart';

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

      // ==============================================
      // GUARDAR SESIÓN
      // ==============================================

      await SessionManager.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresIn: session.expiresIn,
        tokenType: session.tokenType,
        user: UserModel(
          id: session.user.id,
          username: session.user.username,
          name: session.user.name,
          email: session.user.email,
          roles: session.user.roles,
          permissions: session.user.permissions,
        ).toJson(),
      );

      // ==============================================
      // ACTUALIZAR USUARIO ACTUAL
      // ==============================================

      ref.read(currentUserProvider.notifier).setUser(session.user);

      // ==============================================
      // CARGAR SERVICIOS LOCALES / TRAMO
      // ==============================================
      //
      // No validamos roles.
      //
      // Si el usuario tiene permiso 001
      // puede trabajar con Servicios.
      //
      // Consultamos si además tiene un
      // tramo activo asignado.
      // ==============================================

      final hasServicesPermission = session.user.permissions.contains(
        PermissionCodes.viewServices,
      );

      if (hasServicesPermission) {
        await ref.read(tramoProvider.notifier).load();
      } else {
        ref.read(tramoProvider.notifier).clear();
      }

      // ==============================================
      // LOGIN COMPLETO
      // ==============================================

      state = AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    // Limpiar tramo antes de eliminar sesión.
    ref.read(tramoProvider.notifier).clear();

    await SessionManager.clearSession();

    ref.read(currentUserProvider.notifier).clear();

    state = AuthState.initial();
  }
}
