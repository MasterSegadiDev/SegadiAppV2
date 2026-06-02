import 'package:dio/dio.dart';
import 'package:segadi/features/auth/data/models/auth_token_model.dart';
import 'package:segadi/features/auth/domain/entities/auth_result.dart';
import 'package:segadi/features/auth/domain/entities/auth_token.dart';
import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDatasource {
  // final Dio dio;

  // AuthRemoteDatasource(this.dio);

  // Future<AuthToken> login(
  //   String user,
  //   String password,
  // ) async {
  //   final response = await dio.post(
  //     'index.php',
  //     queryParameters: {
  //       'r': 'esegadi/autenticapost',
  //     },
  //     data: {
  //       "usuario": user,
  //       "password": password,
  //       "apptoken": "prueba",
  //     },
  //   );

  //   return AuthTokenModel.fromJson(response.data);
  // }

  // Future<AuthToken> refresh(
  //   String refreshToken,
  // ) async {
  //   final response = await dio.post(
  //     '/refresh',
  //     data: {
  //       'refresh_token': refreshToken,
  //     },
  //   );

  //   return AuthToken.fromJson(response.data);
  // }

  Future<AuthResult> login(String user, String password) async {
    // Simulamos un retraso de red de 1 segundo
    await Future.delayed(const Duration(seconds: 1));

    if (user.trim().toLowerCase() == 'trailer') {
      return AuthResult(
        token: AuthToken(
          accessToken: 'mock_access_token_trailer_123',
          refreshToken: 'mock_refresh_token_trailer_456',
        ),
        user: UserEntity(
          id: 100086,
          name: 'Brian Alejandro (Tráiler)',
          employeeNumber: '389',
          role: 'OPERADOR_TRAILER',
        ),
      );
    } else if (user.trim().toLowerCase() == 'grua') {
      return AuthResult(
        token: AuthToken(
          accessToken: 'mock_access_token_grua_789',
          refreshToken: 'mock_refresh_token_grua_987',
        ),
        user: UserEntity(
          id: 100087,
          name: 'Brian Alejandro (Grúa)',
          employeeNumber: '390',
          role: 'OPERADOR_GRUA',
        ),
      );
    } else {
      // Si escriben cualquier otra cosa, simula credenciales incorrectas
      throw Exception('Usuario o contraseña incorrectos');
    }
  }
}
