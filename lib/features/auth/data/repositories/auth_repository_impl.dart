import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(
    this.remoteDatasource,
  );

  @override
  Future<AuthSessionEntity> login({
    required String username,
    required String password,
  }) {
    return remoteDatasource.login(
      username: username,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    // Se implementará cuando el backend habilite el endpoint
  }
}
