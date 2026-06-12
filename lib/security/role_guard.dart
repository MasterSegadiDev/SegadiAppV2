import 'package:segadi/security/session_manager.dart';

class RoleGuard {
  static Future<bool> hasRole(
    String role,
  ) async {
    final user = await SessionManager.getCurrentUser();

    if (user == null) {
      return false;
    }

    return user.roles.contains(
      role,
    );
  }
}
