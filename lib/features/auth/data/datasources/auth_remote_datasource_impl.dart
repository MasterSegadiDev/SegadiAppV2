import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/autenticapost',
      data: {
        'apptoken': 'prueba',
        'username': username,
        'password': password,
      },
    );

    return response.data;
  }
}
