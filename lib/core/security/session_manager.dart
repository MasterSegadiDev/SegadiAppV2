import 'dart:convert';

import 'package:segadi/core/security/token_keys.dart';
import 'package:segadi/core/storage/secure_storage_service.dart';
import 'package:segadi/features/auth/data/models/auth_session_model.dart';

class SessionManager {
  SessionManager._();

  static final instance = SessionManager._();

  final _storage = SecureStorageService.instance;

  Future<void> saveSession(
    AuthSessionModel session,
  ) async {
    await _storage.write(
      TokenKeys.accessToken,
      session.accessToken,
    );

    await _storage.write(
      TokenKeys.refreshToken,
      session.refreshToken,
    );

    // await _storage.write(
    //   TokenKeys.userData,
    //   jsonEncode(
    //     session.user,
    //   ),
    // );
  }

  Future<String?> getAccessToken() async {
    return _storage.read(
      TokenKeys.accessToken,
    );
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(
      TokenKeys.refreshToken,
    );
  }

  Future<void> clearSession() async {
    await _storage.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }
}
