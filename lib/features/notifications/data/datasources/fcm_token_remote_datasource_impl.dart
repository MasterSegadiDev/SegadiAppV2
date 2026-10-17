import 'package:dio/dio.dart';

import 'fcm_token_remote_datasource.dart';

class FcmTokenRemoteDatasourceImpl implements FcmTokenRemoteDatasource {
  final Dio _dio;

  FcmTokenRemoteDatasourceImpl({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<void> registerToken(String token) async {
    if (token.trim().isEmpty) {
      throw ArgumentError('El token FCM no puede estar vacío.');
    }

    final response = await _dio.post(
      '/appUser/fcm-token',
      data: {
        'strFcmToken': token,
      },
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al registrar el token FCM.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo registrar el token FCM.',
      );
    }
  }
}
