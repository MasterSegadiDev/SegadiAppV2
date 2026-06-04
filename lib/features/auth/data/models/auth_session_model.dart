import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresIn,
    required super.user,
  });

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthSessionModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 0,
      user: UserModel.fromJson(
        json['user'],
      ),
    );
  }
}
