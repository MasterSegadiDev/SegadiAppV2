import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/auth/domain/entities/user_entity.dart';
import 'package:segadi/core/security/session_manager.dart';

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserEntity?>(
  (ref) => CurrentUserNotifier(),
);

class CurrentUserNotifier extends StateNotifier<UserEntity?> {
  CurrentUserNotifier() : super(null);

  /// Cargar usuario desde storage (app restart)
  Future<void> loadUser() async {
    final user = await SessionManager.getCurrentUser();
    state = user;
  }

  /// Setear usuario después del login
  void setUser(UserEntity user) {
    state = user;
  }

  /// Logout
  void clear() {
    state = null;
  }

  bool get isLoggedIn => state != null;

  List<String> get roles => state?.roles ?? [];

  List<String> get permissions => state?.permissions ?? [];

  bool hasPermission(String p) => permissions.contains(p);
}
