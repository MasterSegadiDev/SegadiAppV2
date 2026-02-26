import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportStatusApi {
  final DioClient _dio;

  // Recibe el dio del DioClient().dio que tienes
  SupportStatusApi(this._dio);

  Future<Response> sendSupportStatus({
    required int serviceId,
    required int statusId,
    required String type,
  }) async {
    // Mantener SharedPreferences para obtener el token manualmente
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Preparar el mapa de datos (Dio lo convierte a JSON automáticamente)
    final data = {
      "service_id": serviceId,
      "status_id": statusId,
      "type": type,
      "token": token, // Se envía en el cuerpo como lo tenías originalmente
    };

    // Realizar la petición POST
    // Nota: Si tu baseUrl termina en 'web/', aquí solo pones el endpoint
    final response = await _dio.dio.post(
      'index.php?r=esegadi/estatus-soportepost',
      data: data,
    );

    return response;
  }
}
