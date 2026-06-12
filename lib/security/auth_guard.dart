import 'package:segadi/security/session_manager.dart';

class AuthGuard {
  static Future<bool> isAuthenticated() async {
    final token = await SessionManager.getAccessToken();

    return token != null && token.isNotEmpty;
  }
}
