import '../models/auth_session_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthSessionModel> login({
    required String username,
    required String password,
  });
}
