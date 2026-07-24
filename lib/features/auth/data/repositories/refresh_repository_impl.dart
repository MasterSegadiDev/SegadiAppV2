import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/refresh_repository.dart';
import '../datasources/refresh_remote_datasource.dart';

class RefreshRepositoryImpl implements RefreshRepository {
  final RefreshRemoteDatasource datasource;

  RefreshRepositoryImpl(
    this.datasource,
  );

  @override
  Future<AuthSessionEntity> refreshToken({
    required String refreshToken,
  }) {
    return datasource.refreshToken(
      refreshToken: refreshToken,
    );
  }
}
