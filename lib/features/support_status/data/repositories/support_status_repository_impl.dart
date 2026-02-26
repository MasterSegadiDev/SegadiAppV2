import 'package:dio/dio.dart';
import 'dart:io';
import 'package:segadi/features/support_status/data/api/support_status_api.dart';

class SupportStatusRepositoryImpl {
  final SupportStatusApi api;

  SupportStatusRepositoryImpl(this.api);

  Future<bool> sendStatus({
    required int serviceId,
    required int statusId,
    required String type,
  }) async {
    try {
      final response = await api.sendSupportStatus(
        serviceId: serviceId,
        statusId: statusId,
        type: type,
      );

      // Verificamos si el backend mandó error con estatus 200
      if (response.data is Map && response.data['success'] == false) {
        throw response.data['message'] ?? 'Error al procesar la solicitud';
      }

      return true;
    } on DioException catch (e) {
      // Usamos el mapeador para lanzar solo el texto amigable
      throw _mapDioErrorToString(e);
    } catch (e) {
      // Captura cualquier otro error (como errores de casteo de datos)
      if (e is String) throw e;
      throw 'Ocurrió un error inesperado. Inténtalo de nuevo.';
    }
  }

  String _mapDioErrorToString(DioException e) {
    // Verificamos si es timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'El servidor tardó demasiado en responder. Reintenta.';
    }

    // Verificamos conexión (Aquí está el truco para el SocketException)
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException ||
        e.message?.contains('SocketException') == true ||
        e.message?.contains('Network is unreachable') == true) {
      // <--- Agregado por tu log
      return 'Sin conexión a internet. Verifica tu red o datos móviles.';
    }

    // Error de Respuesta (400, 500, etc)
    if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Error en el servicio (${e.response?.statusCode})';
    }

    return 'Ocurrió un error inesperado de red.';
  }
}
