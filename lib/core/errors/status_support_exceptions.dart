import 'package:dio/dio.dart';

class StatusSupport implements Exception {
  late String message;

  StatusSupport.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Solicitud al servidor cancelada";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Tiempo de conexión agotado";
        break;
      case DioExceptionType.receiveTimeout:
        message = "El servidor tardó demasiado en responder";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        message = "Tiempo de envío agotado";
        break;
      case DioExceptionType.connectionError:
        message = "Sin conexión a internet. Revisa tu red.";
        break;
      default:
        message = "Algo salió mal de forma inesperada";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Petición incorrecta (400)';
      case 401:
        return 'Sesión expirada. Por favor, reingresa.';
      case 403:
        return 'No tienes permiso para realizar esta acción (403)';
      case 404:
        return 'El servicio solicitado no existe (404)';
      case 500:
        return 'Error interno del servidor (500)';
      case 502:
        return 'Error de enlace (Bad gateway)';
      default:
        return '¡Ups! Error de servidor ($statusCode)';
    }
  }

  @override
  String toString() => message;
}
