import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/features/service_detail/data/datasource/airbag_remote_datasource.dart';
import 'package:segadi/features/service_detail/domain/repositories/airbag_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AirbagRepositoryImpl implements AirbagRepository {
  final AirbagRemoteDataSource remote;

  AirbagRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, bool>> changeOperatorStatus({
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('number_employe') ?? '';

      if (userId.isEmpty) {
        return Left(ServerFailure("Usuario no encontrado"));
      }

      final result = await remote.changeStatusOperator(
        userId: userId,
        status: status,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
