import 'package:segadi/features/auth/domain/entities/auth_session_entity.dart';

abstract class AuthRepository {
  Future<AuthSessionEntity> login({
    required String username,
    required String password,
  });

  Future<void> logout();
}
