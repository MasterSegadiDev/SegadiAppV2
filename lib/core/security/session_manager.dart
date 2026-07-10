import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/features/auth/data/models/user_model.dart';

class SessionManager {
  SessionManager._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String expiresAtKey = 'expires_at';
  static const String tokenTypeKey = 'token_type';
  static const String userKey = 'user';

  /// ===============================
  /// Guardar sesión
  /// ===============================
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String tokenType,
    required Map<String, dynamic> user,
  }) async {
    final expiresAt = DateTime.now()
        .add(
          Duration(seconds: expiresIn),
        )
        .millisecondsSinceEpoch;

    await _storage.write(
      key: accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: refreshTokenKey,
      value: refreshToken,
    );

    await _storage.write(
      key: expiresAtKey,
      value: expiresAt.toString(),
    );

    await _storage.write(
      key: tokenTypeKey,
      value: tokenType,
    );

    await _storage.write(
      key: userKey,
      value: jsonEncode(user),
    );
  }

  /// ===============================
  /// Access Token
  /// ===============================
  static Future<String?> getAccessToken() async {
    return _storage.read(
      key: accessTokenKey,
    );
  }

  /// ===============================
  /// Refresh Token
  /// ===============================
  static Future<String?> getRefreshToken() async {
    return _storage.read(
      key: refreshTokenKey,
    );
  }

  /// ===============================
  /// Token Type
  /// ===============================
  static Future<String?> getTokenType() async {
    return _storage.read(
      key: tokenTypeKey,
    );
  }

  /// ===============================
  /// Usuario JSON
  /// ===============================
  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(
      key: userKey,
    );

    if (userJson == null) {
      return null;
    }

    return jsonDecode(userJson);
  }

  /// ===============================
  /// Usuario Model
  /// ===============================
  static Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.read(
      key: userKey,
    );

    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(
      jsonDecode(userJson),
    );
  }

  /// ===============================
  /// Fecha de expiración
  /// ===============================
  static Future<int?> getExpiresAt() async {
    final value = await _storage.read(
      key: expiresAtKey,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  /// ===============================
  /// ¿Existe sesión?
  /// ===============================
  static Future<bool> hasSession() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }

  /// ===============================
  /// ¿Token expirado?
  /// ===============================
  static Future<bool> isTokenExpired() async {
    final expiresAt = await getExpiresAt();

    if (expiresAt == null) {
      return true;
    }

    return DateTime.now().millisecondsSinceEpoch >= expiresAt;
  }

  /// ===============================
  /// ¿Debe renovarse?
  /// 60 segundos antes
  /// ===============================
  static Future<bool> shouldRefreshToken() async {
    final expiresAt = await getExpiresAt();

    if (expiresAt == null) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    return (expiresAt - now) <= 60000;
  }

  /// ===============================
  /// Limpiar sesión
  /// ===============================
  static Future<void> clearSession() async {
    await _storage.delete(
      key: accessTokenKey,
    );

    await _storage.delete(
      key: refreshTokenKey,
    );

    await _storage.delete(
      key: expiresAtKey,
    );

    await _storage.delete(
      key: tokenTypeKey,
    );

    await _storage.delete(
      key: userKey,
    );
  }
}
