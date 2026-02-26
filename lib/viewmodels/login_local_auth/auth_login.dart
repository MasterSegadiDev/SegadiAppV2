import 'package:dio/dio.dart';

class AuthServices {
  final Dio _dio;

  // Constructor que recibe Dio para que los ViewModels dejen de dar error
  AuthServices(this._dio);

  Future<Response> login(String user, String password) async {
    // Tu lógica de datos exacta
    Map data = {"usuario": user, "password": password, "apptoken": "prueba"};

    // Petición directa con Dio
    final response = await _dio.post(
      'index.php?r=esegadi/autenticapost', // La BaseURL ya debe venir configurada en el Dio del main
      data: data,
    );

    return response;
  }
}
