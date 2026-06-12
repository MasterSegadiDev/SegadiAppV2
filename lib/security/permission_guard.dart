import 'package:segadi/security/session_manager.dart';

class PermissionGuard {
  static Future<bool> hasPermission(
    String permission,
  ) async {
    final user = await SessionManager.getCurrentUser();

    if (user == null) {
      return false;
    }

    return user.permissions.contains(
      permission,
    );
  }
}
