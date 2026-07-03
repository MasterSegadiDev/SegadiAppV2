import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/security/session_manager.dart';
import '../../domain/entities/user_entity.dart';

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserEntity?>(
  (ref) => CurrentUserNotifier(),
);

class CurrentUserNotifier extends StateNotifier<UserEntity?> {
  CurrentUserNotifier() : super(null);

  Future<void> loadUser() async {
    state = await SessionManager.getCurrentUser();
  }

  void setUser(UserEntity user) {
    state = user;
  }

  void clear() {
    state = null;
  }

  bool get isLoggedIn => state != null;

  bool hasPermission(String permission) {
    return state?.permissions.contains(permission) ?? false;
  }

  bool hasRole(String role) {
    return state?.roles.contains(role) ?? false;
  }
}
