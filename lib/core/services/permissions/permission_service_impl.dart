import 'package:permission_handler/permission_handler.dart';

import 'permission_service.dart';
import 'permission_type.dart';

class PermissionServiceImpl implements PermissionService {
  Permission _mapPermission(
    PermissionType permission,
  ) {
    switch (permission) {
      case PermissionType.camera:
        return Permission.camera;

      case PermissionType.location:
        return Permission.locationWhenInUse;

      case PermissionType.notification:
        return Permission.notification;
    }
  }

  @override
  Future<bool> request(
    PermissionType permission,
  ) async {
    final status = await _mapPermission(permission).request();

    return status.isGranted;
  }

  @override
  Future<bool> isGranted(
    PermissionType permission,
  ) async {
    final status = await _mapPermission(permission).status;

    return status.isGranted;
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
