import 'package:dio/dio.dart';

import '../constants/app_config.dart';

class RefreshDio {
  RefreshDio._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(
        seconds: 30,
      ),
      receiveTimeout: const Duration(
        seconds: 30,
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
}
