import 'package:segadi/core/security/session_manager.dart';

class CheckSessionUseCase {
  Future<bool> call() async {
    final token = await SessionManager.getAccessToken();

    return token != null && token.isNotEmpty;
  }
}
