import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class PermissionManager {
  PermissionManager._();

  static bool hasPermission({
    required UserEntity user,
    required String permission,
  }) {
    return user.permissions.contains(
      permission,
    );
  }

  static bool hasAnyPermission({
    required UserEntity user,
    required List<String> permissions,
  }) {
    return permissions.any(
      user.permissions.contains,
    );
  }

  static bool hasAllPermissions({
    required UserEntity user,
    required List<String> permissions,
  }) {
    return permissions.every(
      user.permissions.contains,
    );
  }
}
