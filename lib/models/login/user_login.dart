import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class UserLogin {
  String? username;
  final String password;
  final String token;

  UserLogin(
      {required this.username, required this.password, required this.token});
}

class AuthService {
  final Dio _dio;

  // Inyectamos la instancia de Dio configurada
  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final Map<String, dynamic> data = {
        "usuario": username,
        "password": password,
        "apptoken": "prueba" // Considera mover esto a ApiConfig si es constante
      };

      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/autenticapost'},
        data: data,
      );

      // Dio ya nos da el Map decodificado en .data
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Si no hay internet o el servidor falla, ApiException dará un mensaje claro
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException("Error inesperado al intentar iniciar sesión");
    }
  }

  Future<Map<String, dynamic>> getTokenWithFirebaseBeforeLogin(
      int id, String token, String firebaseToken) async {
    try {
      final Map<String, dynamic> data = {
        "user_id": id,
        "token": token,
        "token_firebase": firebaseToken
      };

      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/tokenfirebasepost'},
        data: data,
      );

      // Verificamos que la respuesta no sea nula (Dio maneja los status != 200 como excepciones)
      if (response.data == null) {
        throw ApiException('El servidor respondió sin datos.');
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error al vincular el token de notificaciones.');
    }
  }
}
