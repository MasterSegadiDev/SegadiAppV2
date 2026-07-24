import '../../features/auth/domain/entities/user_entity.dart';
import 'permission_codes.dart';

class PermissionService {
  final UserEntity? currentUser;

  const PermissionService({
    required this.currentUser,
  });

  bool hasPermission(String permission) {
    if (currentUser == null) {
      return false;
    }

    return currentUser!.permissions.contains(permission);
  }

  //==========================
  // Módulos
  //==========================

  bool get canViewServices => hasPermission(PermissionCodes.viewServices);

  bool get canViewContainers => hasPermission(PermissionCodes.viewContainers);

  bool get canViewTrips => hasPermission(PermissionCodes.viewTrips);

  bool get canViewExpenses => hasPermission(PermissionCodes.viewExpenses);

  bool get canViewDashboard => hasPermission(PermissionCodes.viewDashboard);

  bool get canViewUsers => hasPermission(PermissionCodes.viewUsers);
}
