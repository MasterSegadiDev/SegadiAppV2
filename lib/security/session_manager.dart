import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/features/auth/data/models/user_model.dart';

class SessionManager {
  SessionManager._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  static const String userKey = 'user';

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(
      key: accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: refreshTokenKey,
      value: refreshToken,
    );

    await _storage.write(
      key: userKey,
      value: jsonEncode(user),
    );
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(
      key: accessTokenKey,
    );
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(
      key: refreshTokenKey,
    );
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(
      key: userKey,
    );

    if (userJson == null) {
      return null;
    }

    return jsonDecode(userJson);
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  static Future<UserModel?> getCurrentUser() async {
    final userJson = await _storage.read(
      key: userKey,
    );

    if (userJson == null) {
      return null;
    }

    return UserModel.fromJson(
      jsonDecode(
        userJson,
      ),
    );
  }
}
