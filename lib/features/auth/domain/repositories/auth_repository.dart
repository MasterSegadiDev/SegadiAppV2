import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failures.dart';
import 'package:segadi/features/auth/domain/entities/auth_result.dart';
import 'package:segadi/features/auth/domain/entities/auth_token.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login(
    String user,
    String password,
  );
  // Future<Either<Failure, AuthToken>> refresh(
  //   String refreshToken,
  // );
  // Future<Either<Failure, AuthToken>> saveToken(
  //   String token,
  // );
  Future<void> logout();
  Future<Either<Failure, AuthToken?>> getPersistedToken();
}
