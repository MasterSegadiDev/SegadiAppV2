import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(
    this.remoteDatasource,
  );

  @override
  Future<AuthSessionEntity> login({
    required String username,
    required String password,
  }) async {
    final response = await remoteDatasource.login(
      username: username,
      password: password,
    );

    return AuthSessionModel.fromJson(
      response,
    );
  }

  @override
  Future<AuthSessionEntity?> getCurrentSession() async {
    return null;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSessionEntity> refreshToken() {
    throw UnimplementedError();
  }
}
