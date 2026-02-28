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
          // 🚀 Prioridad absoluta a 'error_message' que es el que usa tu backend.
          // Usamos .toString() para evitar errores si el valor no es un String puro.
          final String? serverMessage =
              (data['error_message'] ?? data['message'])?.toString();

          if (serverMessage != null && serverMessage.isNotEmpty) {
            return ApiException(serverMessage);
          }
        }

        // Si no hay un mensaje claro en el JSON, damos el código de estado
        return _handleStatusCode(error.response?.statusCode);

      case DioExceptionType.cancel:
        return ApiException("La solicitud fue cancelada.");

      default:
        // Verificamos si hay un error de socket manual (pérdida de red repentina)
        if (error.message?.contains('SocketException') ?? false) {
          return ApiException("Error de conexión: Verifica tu red.");
        }
        return ApiException("Ocurrió un error de red inesperado.");
    }
  }

  /// Manejo de errores por código de estado (cuando el body viene vacío)
  static ApiException _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ApiException("Solicitud incorrecta (400).");
      case 401:
        return ApiException("Sesión caducada o no autorizado (401).");
      case 403:
        return ApiException(
            "No tienes permiso para realizar esta acción (403).");
      case 404:
        return ApiException("El recurso solicitado no existe (404).");
      case 500:
        return ApiException("Error interno del servidor (500).");
      default:
        return ApiException("Error del servidor: $statusCode");
    }
  }

  @override
  String toString() => message;
}
