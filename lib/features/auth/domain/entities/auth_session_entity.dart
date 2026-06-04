import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class AuthSessionEntity {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserEntity user;

  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });
}
