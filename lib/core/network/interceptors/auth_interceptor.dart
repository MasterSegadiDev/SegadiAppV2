import 'package:dio/dio.dart';
import 'package:segadi/core/security/session_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('INTERCEPTOR ACTIVO');

    final token = await SessionManager.getAccessToken();

    print(
      'TOKEN GUARDADO EN AUTH INTERCEPTOR: $token',
    );

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(
      options,
    );
  }
}
