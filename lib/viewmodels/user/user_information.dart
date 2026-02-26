import 'package:dio/dio.dart';
import 'package:segadi/models/user/UserInformation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final Dio _dio;

  // Recibimos Dio por constructor para mantener la sesión activa
  User(this._dio);

  // En tu archivo User.dart
  Future<Photo> getUserPhot() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;
    final token = prefs.getString('token') ?? '';

    try {
      // 1. Asegúrate de que la ruta sea EXACTAMENTE la que espera el servidor
      // Si tu baseUrl en DioClient termina en '/', aquí solo pon 'index.php'
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getfoto',
          'id': userId.toString(),
          'token': token,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Importante: Verifica si 'photo' existe en la respuesta antes de mapear
        if (response.data["photo"] != null) {
          return Photo.fromJson(response.data["photo"] as Map<String, dynamic>);
        } else {
          throw Exception('El campo photo no viene en la respuesta');
        }
      }
      throw Exception('Error del servidor');
    } on DioException catch (e) {
      // 2. Imprime la URL completa que intentó llamar Dio para ver dónde está el error
      print("❌ URL INTENTADA: ${e.requestOptions.uri}");
      print("❌ ERROR DIO: ${e.message}");
      rethrow;
    }
  }
}
