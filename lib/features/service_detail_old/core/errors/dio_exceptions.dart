import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "La petición al servidor fue cancelada.";
        break;
      case DioExceptionType.connectionTimeout:
        message = "No hay respuesta del servidor (Timeout).";
        break;
      case DioExceptionType.receiveTimeout:
        message = "El servidor tardó demasiado en responder.";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Error al subir los datos. Revisa tu conexión.";
        break;
      case DioExceptionType.connectionError:
        message = "Sin conexión a internet detectada.";
        break;
      default:
        message = "Algo salió mal de forma inesperada.";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return "Información inválida enviada al servidor.";
      case 401:
        return "Sesión expirada. Ingresa de nuevo.";
      case 403:
        return "No tienes permiso para realizar esta acción.";
      case 404:
        return "El recurso solicitado no existe.";
      case 413:
        return "El archivo es demasiado grande para ser enviado.";
      case 500:
        return "Error interno del servidor. Contacta a soporte.";
      case 502:
        return "El servidor está temporalmente fuera de servicio.";
      default:
        return "Error desconocido (Código: $statusCode).";
    }
  }

  @override
  String toString() => message;
}
