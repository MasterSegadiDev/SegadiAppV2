import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../features/auth/data/models/user_model.dart';
import '../../../features/auth/domain/use_cases/refresh_token_usecase.dart';
import '../../security/session_manager.dart';
import '../dio_client.dart';

class AuthInterceptor extends Interceptor {
  final GetIt _getIt = GetIt.instance;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await SessionManager.getAccessToken();
    final tokenType = await SessionManager.getTokenType();

    print('');
    print('========== REQUEST ==========');
    print('${options.method} ${options.path}');
    print('TOKEN TYPE: $tokenType');

    if (accessToken != null && accessToken.isNotEmpty) {
      print(
        'ACCESS TOKEN: ${accessToken.substring(0, accessToken.length > 30 ? 30 : accessToken.length)}...',
      );
    }

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        tokenType != null &&
        tokenType.isNotEmpty) {
      options.headers['Authorization'] = '$tokenType $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    /// Solo hacemos refresh cuando sea 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    print('');
    print('========== 401 DETECTADO ==========');

    /// Evitar múltiples refresh simultáneos
    if (_isRefreshing) {
      print('Ya existe un refresh en proceso.');
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await SessionManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('Refresh Token inexistente.');

        await SessionManager.clearSession();

        return handler.next(err);
      }

      print('Intentando renovar Access Token...');

      final refreshUseCase = _getIt<RefreshTokenUseCase>();

      final session = await refreshUseCase(
        refreshToken: refreshToken,
      );

      print('Refresh exitoso.');

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

      print('Nueva sesión almacenada.');

      /// Reintentamos la petición original
      final options = err.requestOptions;

      options.headers['Authorization'] =
          '${session.tokenType} ${session.accessToken}';

      print('Reintentando petición...');
      print('${options.method} ${options.path}');

      final response = await DioClient.instance.fetch(options);

      print('Petición reintentada correctamente.');

      return handler.resolve(response);
    } catch (e) {
      print('');
      print('========== REFRESH FALLÓ ==========');
      print(e);

      await SessionManager.clearSession();

      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
