import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failures.dart';
import 'package:segadi/core/network/api_handler.dart';
import 'package:segadi/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:segadi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:segadi/features/auth/domain/entities/auth_result.dart';

import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, AuthResult>> login(
      String user, String password) async {
    return ApiHandler.handleRequest<AuthResult>(
      request: () async {
        // 1. Llama al remoto (que tiene la simulación por usuario)
        final authResult = await remoteDatasource.login(user, password);

        // 2. Guarda los tokens en el storage local seguro
        await localDatasource.saveToken(authResult.token);

        // 3. Devuelve el combo completo a la presentación
        return authResult;
      },
    );
  }

  // @override
  // Future<Either<Failure, AuthToken>> refresh(
  //   String refreshToken,
  // ) async {
  //   return ApiHandler.handleRequest<AuthToken>(
  //     request: () async {
  //       final token = await remoteDatasource.refresh(
  //         refreshToken,
  //       );

  //       await localDatasource.saveToken(token);

  //       return token;
  //     },
  //   );
  // }

  @override
  Future<Either<Failure, AuthToken?>> getPersistedToken() async {
    return ApiHandler.handleRequest<AuthToken?>(
      request: () async {
        return await localDatasource.getToken();
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return ApiHandler.handleRequest<void>(
      request: () async {
        await localDatasource.logout();
      },
    );
  }
}
