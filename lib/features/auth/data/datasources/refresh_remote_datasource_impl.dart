import 'package:dio/dio.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import '../../../../core/network/refresh_dio.dart';

import 'refresh_remote_datasource.dart';

class RefreshRemoteDatasourceImpl implements RefreshRemoteDatasource {
  final Dio _dio = RefreshDio.instance;

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
