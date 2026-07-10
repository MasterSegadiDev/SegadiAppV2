import 'package:segadi/features/auth/domain/entities/auth_session_entity.dart';

import '../repositories/refresh_repository.dart';

class RefreshTokenUseCase {
  final RefreshRepository repository;

  RefreshTokenUseCase(
    this.repository,
  );

  Future<AuthSessionEntity> call({
    required String refreshToken,
  }) {
    return repository.refreshToken(
      refreshToken: refreshToken,
    );
  }
}
