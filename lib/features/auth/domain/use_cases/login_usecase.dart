import 'package:segadi/features/auth/domain/entities/auth_session_entity.dart';
import 'package:segadi/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthSessionEntity> call({
    required String username,
    required String password,
  }) async {
    return repository.login(
      username: username,
      password: password,
    );
  }
}
