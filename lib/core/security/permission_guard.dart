import 'permission_service.dart';

abstract final class PermissionGuard {
  PermissionGuard._();

  static bool hasAccess(
    PermissionService permissionService,
    String permission,
  ) {
    return permissionService.hasPermission(
      permission,
    );
  }
}
