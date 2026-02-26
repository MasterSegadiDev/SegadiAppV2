import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:segadi/models/services/detail_finished.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail {
  final Dio _dio;

  // Constructor para inyectar Dio y evitar errores en los ViewModels
  Detail(this._dio);

  Future<DetailFinished> getService(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var userRollPrefs = prefs.getString('user_roll') ?? '';

    try {
      // En Dio, los queryParameters se pasan en un Map aparte
      // No necesitas armar el Uri manual con replace ni parse
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getterminadasdetalle',
          'id': userId.toString(),
          'service_id': id.toString(),
          'token': token,
        },
      );

      // Dio ya convierte el body a Map automáticamente (response.data)
      if (response.statusCode == 200) {
        inspect(response.data);

        // Usamos response.data directamente sin json.decode
        var result = DetailFinished.fromJson(response.data);

        if (userRollPrefs == 'Si') {
          result.userRoll = true;
        }

        inspect(result);
        return result;
      } else {
        throw Exception('Failed to load detail');
      }
    } on DioException catch (e) {
      // Manejo de errores específico de Dio
      inspect(e);
      throw Exception('Error de red al obtener detalle: ${e.message}');
    }
  }
}
