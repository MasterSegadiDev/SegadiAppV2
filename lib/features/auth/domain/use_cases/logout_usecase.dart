import 'package:segadi/core/security/session_manager.dart';

class LogoutUseCase {
  Future<void> call() async {
    await SessionManager.clearSession();
  }
}
