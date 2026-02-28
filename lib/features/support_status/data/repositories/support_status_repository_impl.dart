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
    // 1. Timeouts
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'El servidor tardó demasiado en responder. Reintenta.';
    }

    // 2. Errores de Conexión Física
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException ||
        e.message?.contains('SocketException') == true) {
      return 'Sin conexión a internet. Verifica tu red.';
    }

    // 3. Error de Respuesta (Bad Response - 401, 400, 500)
    if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;

      if (data is Map) {
        // 🚀 EL CAMBIO ESTÁ AQUÍ:
        // Buscamos 'error_message' (que es el que mandó tu log) o 'message'
        final serverMessage = data['error_message'] ?? data['message'];

        if (serverMessage != null) {
          return serverMessage.toString();
        }
      }

      // Si no hay mensaje en el body, al menos damos contexto del código
      return 'Error ${e.response?.statusCode}: No se puede procesar la solicitud.';
    }

    return 'Ocurrió un error inesperado de red.';
  }
}
