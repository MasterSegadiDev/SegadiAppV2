import 'package:dio/dio.dart';

import '../../../../core/errors/dio_exception_handler.dart';
import '../../../../core/network/dio_client.dart';
import 'user_profile_remote_datasource.dart';

class UserProfileRemoteDatasourceImpl implements UserProfileRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
  }) async {
    try {
      final response = await _dio.get(
        '/appUser/info/$userId',
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
