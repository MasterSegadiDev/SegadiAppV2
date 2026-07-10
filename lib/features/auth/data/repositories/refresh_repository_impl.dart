import 'package:segadi/features/auth/data/datasources/refresh_remote_datasource.dart';
import 'package:segadi/features/auth/data/models/auth_session_model.dart';
import 'package:segadi/features/auth/domain/entities/auth_session_entity.dart';
import 'package:segadi/features/auth/domain/repositories/refresh_repository.dart';

class RefreshRepositoryImpl implements RefreshRepository {
  final RefreshRemoteDatasource datasource;

  RefreshRepositoryImpl(
    this.datasource,
  );

  @override
  Future<AuthSessionEntity> refreshToken({
    required String refreshToken,
  }) async {
    final response = await datasource.refreshToken(
      refreshToken: refreshToken,
    );

    final session = AuthSessionModel.fromJson(response);

    return session;
  }
}
