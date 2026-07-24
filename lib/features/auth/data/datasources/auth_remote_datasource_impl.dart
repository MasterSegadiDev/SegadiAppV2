import 'package:dio/dio.dart';

import '../../../../core/errors/dio_exception_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_session_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<AuthSessionModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return AuthSessionModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
