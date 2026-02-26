import 'package:dartz/dartz.dart';
import 'package:segadi/core/network/network_info.dart';
import 'package:segadi/features/check_list/data/datasources/checklist_remote_dataosurce.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';
import 'package:segadi/features/service_detail/core/errors/failures.dart';

class ChecklistRepositoryImpl {
  final ChecklistRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChecklistRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<Either<Failure, List<ChecklistItemEntity>>> getChecklistCatalog(
      String token) async {
    // 1. PRIMERO validamos la conexión
    final hasConnection = await networkInfo.isConnected;

    if (!hasConnection) {
      // Si no hay conexión, retornamos Left inmediatamente
      return Left(NetworkFailure('No hay conexión a internet'));
    }

    // 2. SOLO si hay conexión, entramos al bloque try
    try {
      final List<ChecklistItemEntity> models =
          await remoteDataSource.getChecklistCatalog(token);
      return Right(models);
    } on Exception catch (e) {
      return Left(
          ServerFailure('Error al cargar el checklist: ${e.toString()}'));
    }
  }

  Future<Either<Failure, bool>> saveChecklist(
      {required int serviceId,
      required List<int> ids,
      required String token}) async {
    if (await networkInfo.isConnected) {
      try {
        final bool isSaved = await remoteDataSource.saveChecklist(
          serviceId: serviceId,
          checkedIds: ids,
          token: token,
        );
        return Right(isSaved);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(
          NetworkFailure("No hay internet. Los cambios no se enviaron."));
    }
  }
}
