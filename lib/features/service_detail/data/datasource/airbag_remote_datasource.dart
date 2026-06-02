import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_config.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:flutter/foundation.dart';

class AirbagRemoteDataSource {
  final Dio _dio;

  AirbagRemoteDataSource(this._dio);

  Future<bool> changeStatusOperator({
    required String userId,
    required String status,
  }) async {
    // Limpiamos los datos para evitar espacios invisibles que rompan el formato
    final cleanUserId = userId.trim();
    final cleanStatus = status.trim().toLowerCase();

    debugPrint(
        '🚀 Iniciando cambio de status Airbag: $cleanStatus para usuario: $cleanUserId');

    try {
      final response = await _dio.post(
        '${ApiConfig.airbagBaseUrl}$cleanUserId/changeAppStatus',
        data: {
          "force":
              cleanStatus, // Enviamos el String literal 'active' o 'inactive'
        },
        options: Options(
          headers: {
            ...ApiConfig.airbagHeaders,
            // Forzamos explícitamente el tipo de contenido
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: ApiConfig.timeout,
          receiveTimeout: ApiConfig.timeout,
          // Evita que Dio lance excepción en 400 para poder leer el mensaje del error
          validateStatus: (status) => status! < 500,
        ),
      );

      // Logs detallados para depuración
      debugPrint('📡 Airbag HTTP Status: ${response.statusCode}');
      debugPrint('📦 Airbag Body Response: ${response.data}');

      if (response.statusCode == 200) {
        // Verificamos si el body trae un status: false interno
        final data = response.data;
        if (data is Map && data['status'] == false) {
          debugPrint('⚠️ Airbag rechazó la operación: ${data['message']}');
          return false;
        }
        return true;
      } else if (response.statusCode == 400) {
        // Aquí capturamos el "Bad Force formatting"
        final message =
            response.data['message'] ?? 'Error de formato desconocido';
        throw ApiException(
            "Error 400 Airbag: $message. Revisa si el campo 'force' sigue siendo String.");
      }

      return false;
    } on DioException catch (e) {
      debugPrint('❌ Error de red/Dio en Airbag: ${e.message}');
      throw ApiException(_mapDioError(e));
    } catch (e) {
      debugPrint('💥 Error inesperado: $e');
      throw ApiException("Error inesperado al conectar con Airbag: $e");
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Timeout de conexión con Airbag";
      case DioExceptionType.sendTimeout:
        return "Timeout al enviar datos a Airbag";
      case DioExceptionType.receiveTimeout:
        return "Timeout al recibir respuesta de Airbag";
      case DioExceptionType.connectionError:
        return "Sin conexión a internet";
      case DioExceptionType.badResponse:
        return "Respuesta inválida de Airbag: ${e.response?.data}";
      default:
        return "Error de red con Airbag";
    }
  }
}
