import '../models/auth_session_model.dart';

abstract class RefreshRemoteDatasource {
  Future<AuthSessionModel> refreshToken({
    required String refreshToken,
  });
}
