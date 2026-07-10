import 'package:segadi/features/auth/domain/entities/auth_session_entity.dart';

abstract class RefreshRepository {
  Future<AuthSessionEntity> refreshToken({
    required String refreshToken,
  });
}
