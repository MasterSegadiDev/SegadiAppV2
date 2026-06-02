class AuthToken {
  final String accessToken;
  final String refreshToken;

  AuthToken({required this.accessToken, required this.refreshToken});
}

class UserEntity {
  final int id;
  final String name;
  final String employeeNumber;
  final String role; // Recibirá 'OPERADOR_TRAILER' o 'OPERADOR_GRUA'

  UserEntity({
    required this.id,
    required this.name,
    required this.employeeNumber,
    required this.role,
  });
}

class AuthResult {
  final AuthToken token;
  final UserEntity user;

  AuthResult({required this.token, required this.user});
}
