import 'package:dio/dio.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/features/auth/data/models/auth_session_model.dart';
import '../../../../core/network/refresh_dio.dart';

import 'refresh_remote_datasource.dart';

class RefreshRemoteDatasourceImpl implements RefreshRemoteDatasource {
  final Dio _dio = RefreshDio.instance;

  @override
  Future<AuthSessionModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      print('reponse body. ${response.data}');

      return AuthSessionModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
