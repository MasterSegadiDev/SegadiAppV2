import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class PermissionService {
  static bool hasPermission(UserEntity user, String permission) {
    return user.permissions.contains(
      permission,
    );
  }

  static bool hasAnyPermission(UserEntity user, List<String> permissions) {
    return permissions.any(
      (user.permissions.contains),
    );
  }

  static bool hasAllPermissions(
    UserEntity user,
    List<String> permissions,
  ) {
    return permissions.every(
      user.permissions.contains,
    );
  }
}
