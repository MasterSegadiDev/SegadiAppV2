import 'package:flutter/foundation.dart';

import '../../app/di/injection_container.dart';
import '../security/session_manager.dart';
import '../../features/auth/domain/entities/auth_session_entity.dart';
import '../../features/auth/domain/use_cases/refresh_token_usecase.dart';
import '../../features/auth/data/models/user_model.dart';

class TokenRefreshService {
  TokenRefreshService._();

  static bool _isRefreshing = false;

  static Future<AuthSessionEntity?> refresh() async {
    if (_isRefreshing) {
      debugPrint(
        '⏳ Ya existe un refresh en proceso...',
      );

      return null;
    }

    try {
      _isRefreshing = true;

      debugPrint('');
      debugPrint('══════════════════════════════════════════════');
      debugPrint('🔄 REFRESH TOKEN');
      debugPrint('══════════════════════════════════════════════');

      final refreshToken = await SessionManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint(
          '❌ Refresh Token no encontrado',
        );

        return null;
      }

      debugPrint(
        'Refresh Token encontrado',
      );

      final useCase = getIt<RefreshTokenUseCase>();

      final session = await useCase(
        refreshToken: refreshToken,
      );

      debugPrint(
        '✅ Nuevo Access Token recibido',
      );

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

      debugPrint(
        '💾 Nueva sesión guardada',
      );

      return session;
    } catch (e) {
      debugPrint(
        '❌ Error Refresh Token',
      );

      debugPrint(
        e.toString(),
      );

      await SessionManager.clearSession();

      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
