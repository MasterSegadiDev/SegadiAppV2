import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_config.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.segadiBaseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: ApiConfig.headers,
      ),
    );

    dio.interceptors.add(PrettyDioLogger(
      requestBody: true, // Ver qué mandas (útil para errores)
      // responseBody: true, // <--- ESTO QUITA EL LISTADO GIGANTE
      error: true, // Ver si algo truena
      compact: true,
    ));
  }
}
