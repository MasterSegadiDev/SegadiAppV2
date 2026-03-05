import 'package:dio/dio.dart';

class TravelExpensesFailure {
  final String message;
  final int? statusCode;

  TravelExpensesFailure({required this.message, this.statusCode});

  factory TravelExpensesFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return TravelExpensesFailure(
            message: "El servidor tarda en responder. Revisa tu señal.");
      case DioExceptionType.receiveTimeout:
        return TravelExpensesFailure(
            message: "Respuesta lenta del servidor. Intenta de nuevo.");
      case DioExceptionType.connectionError:
        return TravelExpensesFailure(
            message: "Sin conexión a internet. Verifica tus datos.");
      case DioExceptionType.badResponse:
        return TravelExpensesFailure._handleBadResponse(dioError.response);
      default:
        return TravelExpensesFailure(
            message: "Error inesperado al registrar el viático.");
    }
  }

  static TravelExpensesFailure _handleBadResponse(Response? response) {
    final int? statusCode = response?.statusCode;
    final dynamic data = response?.data;

    // PRIORIDAD 1: Buscar el mensaje exacto del Backend (Tu log de Dio)
    if (data is Map && data.containsKey('error_message')) {
      return TravelExpensesFailure(
        message: data[
            'error_message'], // "No se actualizo el viatico. Favor de revisar..."
        statusCode: statusCode,
      );
    }

    // PRIORIDAD 2: Mensajes por Código de Estado si no hay JSON
    switch (statusCode) {
      case 400:
        return TravelExpensesFailure(
            message: "Datos del viático incorrectos.", statusCode: 400);
      case 413:
        return TravelExpensesFailure(
            message: "La foto del ticket es demasiado pesada.",
            statusCode: 413);
      case 500:
        return TravelExpensesFailure(
            message: "Error en el servidor de Segadi (500).", statusCode: 500);
      default:
        return TravelExpensesFailure(
            message: "Error del servidor (Código: $statusCode)",
            statusCode: statusCode);
    }
  }
}
