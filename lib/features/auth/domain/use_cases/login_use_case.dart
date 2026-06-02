import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failures.dart';
import 'package:segadi/features/auth/domain/entities/auth_result.dart';
import 'package:segadi/features/auth/domain/entities/auth_token.dart';
import 'package:segadi/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResult>> execute(
    String user,
    String password,
  ) {
    return repository.login(
      user,
      password,
    );
  }
}
