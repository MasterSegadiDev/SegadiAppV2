import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:segadi/core/constants/app_config.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(
        seconds: 120,
      ),
      receiveTimeout: const Duration(
        seconds: 120,
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
      ),
    );
}
