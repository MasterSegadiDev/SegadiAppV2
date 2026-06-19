import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class RoleService {
  static bool hasRole(
    UserEntity user,
    String role,
  ) {
    return user.roles.contains(
      role,
    );
  }

  static bool hasAnyRole(
    UserEntity user,
    List<String> roles,
  ) {
    return roles.any(
      user.roles.contains,
    );
  }
}
