import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FracttalApiClient {
  FracttalApiClient({
    required Dio segadiDio,
    Dio? fracttalDio,
  })  : _segadiDio = segadiDio,
        _fracttalDio = fracttalDio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://app.fracttal.com/api/',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 40),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _segadiDio;
  final Dio _fracttalDio;

  String? _token;
  DateTime? _expiration;
  Future<String>? _pendingTokenRequest;

  bool get _hasValidToken =>
      _token != null &&
      _expiration != null &&
      DateTime.now().isBefore(_expiration!);

  Future<String> getValidToken({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _hasValidToken) {
      return _token!;
    }

    if (_pendingTokenRequest != null) {
      return _pendingTokenRequest!;
    }

    final future = _fetchToken(
      forceRefresh: forceRefresh,
    );

    _pendingTokenRequest = future;

    try {
      return await future;
    } finally {
      _pendingTokenRequest = null;
    }
  }

  Future<String> _fetchToken({
    required bool forceRefresh,
  }) async {
    final response = await _segadiDio.get(
      '/fracttal/token',
      queryParameters: forceRefresh ? {'force_refresh': 'true'} : null,
    );

    final body = response.data;

    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      throw const FormatException(
        'Respuesta inválida del ERP al solicitar token.',
      );
    }

    final data = body['data'] as Map;
    final accessToken = data['access_token'];

    debugPrint('token: ${data['access_token']}');

    if (accessToken is! String || accessToken.trim().isEmpty) {
      throw const FormatException(
        'El ERP no devolvió un token válido.',
      );
    }

    final expiresAt = data['expires_at'];
    final expiresIn = data['expires_in'];

    DateTime expiration;

    if (expiresAt is num) {
      expiration = DateTime.fromMillisecondsSinceEpoch(
        expiresAt.toInt() * 1000,
      );
    } else if (expiresIn is num) {
      expiration = DateTime.now().add(
        Duration(seconds: expiresIn.toInt()),
      );
    } else {
      throw const FormatException(
        'El ERP no devolvió la expiración del token.',
      );
    }

    _token = accessToken.trim();
    _expiration = expiration.subtract(
      const Duration(seconds: 60),
    );

    debugPrint('Fracttal: token obtenido correctamente');

    return _token!;
  }

  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await getValidToken();

    try {
      return await _send(
        path,
        method: method,
        token: token,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        rethrow;
      }

      debugPrint(
        'Fracttal: 401, solicitando renovación forzada',
      );

      // Si otra petición ya renovó el token,
      // reutilizamos el nuevo en lugar de invalidarlo.
      final refreshedToken = _token != null && _token != token && _hasValidToken
          ? _token!
          : await getValidToken(forceRefresh: true);

      return _send(
        path,
        method: method,
        token: refreshedToken,
        data: data,
        queryParameters: queryParameters,
      );
    }
  }

  Future<Response<dynamic>> _send(
    String path, {
    required String method,
    required String token,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _fracttalDio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        method: method,
        contentType: Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void clearToken() {
    _token = null;
    _expiration = null;
  }
}
