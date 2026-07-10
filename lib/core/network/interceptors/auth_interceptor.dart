import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../security/session_manager.dart';
import '../../../features/auth/domain/use_cases/refresh_token_usecase.dart';
import '../refresh_dio.dart';

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

    print('========== AUTH INTERCEPTOR ==========');
    print('TOKEN TYPE: $tokenType');
    print('ACCESS TOKEN: $accessToken');

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
    // Solo intentamos refresh cuando sea 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Evitar loops infinitos
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await SessionManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await SessionManager.clearSession();

        return handler.next(err);
      }

      final refreshUseCase = _getIt<RefreshTokenUseCase>();

      final session = await refreshUseCase(
        refreshToken: refreshToken,
      );

      await SessionManager.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresIn: session.expiresIn,
        tokenType: session.tokenType,
        user: session.user.toJson(),
      );

      // Repetimos la petición original

      final options = err.requestOptions;

      final token = await SessionManager.getAccessToken();

      final tokenType = await SessionManager.getTokenType();

      options.headers['Authorization'] = '$tokenType $token';

      final dio = Dio();

      final response = await dio.fetch(
        options,
      );

      return handler.resolve(response);
    } catch (e) {
      await SessionManager.clearSession();

      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
