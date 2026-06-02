import 'package:segadi/features/auth/domain/entities/auth_token.dart';
import 'package:segadi/features/auth/domain/entities/user_entity.dart';

class AuthResult {
  final AuthToken token;
  final UserEntity user;
  AuthResult({
    required this.token,
    required this.user,
  });
}
