import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/exceptions.dart';

import 'package:segadi/core/network/network_info.dart';
import 'package:segadi/features/services_assigned/domain/entities/services_result.dart';

import 'package:segadi/features/services_assigned/domain/failures/failure.dart';
import 'package:segadi/features/services_assigned/domain/repositories/service_repository.dart';
import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ServicesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ServicesResult>> getAssignedServices() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAssignedServices();
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        // Captura cualquier error no controlado (Parseo, etc.)
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
