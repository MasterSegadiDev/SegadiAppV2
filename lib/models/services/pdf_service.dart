import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfService {
  final Dio _dio;

  // Inyectamos la instancia de Dio configurada
  PdfService(this._dio);

  Future<Map<String, dynamic>> getPdf(dynamic serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('id') ?? 0;
      final String token = prefs.getString('token') ?? '';

      // Con Dio usamos queryParameters para que la URL sea limpia y segura
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getcfdi',
          'token': token,
          'id': userId.toString(),
          'service_id': serviceId.toString(),
        },
      );

      // Dio ya nos entrega el body decodificado en .data como un Map
      if (response.data == null) {
        throw ApiException("El servidor no devolvió información del PDF.");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Usamos nuestro unificador de errores para detectar falta de internet
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException("Error inesperado al intentar obtener el PDF.");
    }
  }
}
