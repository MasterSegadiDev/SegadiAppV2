import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/features/auth/domain/entities/auth_token.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage storage;

  AuthLocalDatasource(this.storage);

  Future<void> saveToken(AuthToken token) async {
    await storage.write(
      key: 'access_token',
      value: token.accessToken,
    );

    await storage.write(
      key: 'refresh_token',
      value: token.refreshToken,
    );
  }

  Future<AuthToken?> getToken() async {
    final access = await storage.read(
      key: 'access_token',
    );

    final refresh = await storage.read(
      key: 'refresh_token',
    );

    if (access == null || refresh == null) {
      return null;
    }

    return AuthToken(
      accessToken: access,
      refreshToken: refresh,
    );
  }

  Future<void> logout() async {
    await storage.deleteAll();

    if (await storage.containsKey(key: 'access_token') ||
        await storage.containsKey(key: 'refresh_token')) {
      throw Exception('Error al eliminar tokens');
    } else {
      print('Tokens eliminados correctamente');
    }
  }
}
