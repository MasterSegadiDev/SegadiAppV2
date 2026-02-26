import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
            "El servidor está tardando demasiado en responder.");
      case DioExceptionType.connectionError:
        return ApiException(
            "No tienes conexión a internet, revisa tu conexión.");
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map) {
          return ApiException(
              data['message'] ?? data['error_message'] ?? "Error del servidor");
        }
        return ApiException(
            "Error del servidor: ${error.response?.statusCode}");
      default:
        return ApiException("Ocurrió un error de red inesperado.");
    }
  }

  @override
  String toString() => message;
}
