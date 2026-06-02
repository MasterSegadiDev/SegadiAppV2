import 'package:segadi/features/auth/domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokenModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthTokenModel(
      accessToken: json['token'],
      refreshToken: json['user']['remember_token'],
    );
  }
}
