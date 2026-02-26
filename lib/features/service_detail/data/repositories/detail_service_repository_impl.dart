import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_result.dart';
import 'package:segadi/features/service_detail/core/errors/dio_exceptions.dart';
import 'package:segadi/features/service_detail/core/errors/failures.dart';
import 'package:segadi/features/service_detail/data/mappers/detail_service_mapper.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/network/network_info.dart'; // Para usar Either

class DetailServiceRepositoryImpl {
  final DetailServiceApi api;
  final NetworkInfo networkInfo; // <-- 1. Inyectamos la info de red

  DetailServiceRepositoryImpl({
    required this.api,
    required this.networkInfo,
  });

  // Ahora devolvemos Either: a la izquierda (Failure), a la derecha (Éxito)
  Future<Either<Failure, DetailServiceEntity>> getDetail(int id) async {
    try {
      // 2. Filtro de Internet: Si no hay, ni siquiera molestamos al servidor
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure("No tienes conexión a internet."));
      }

      final raw = await api.fetchDetailRaw(id);
      final entity = DetailServiceMapper.fromJson(raw);

      return Right(entity); // Todo bien
    } on DioException catch (e) {
      // 3. Filtro de Red: Usamos tu traductor de la carpeta core/errors
      final errorMessage = DioExceptions.fromDioError(e).toString();
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      // 4. Filtro General: Por si algo truena en el Mapper
      return Left(ServerFailure("Error inesperado al procesar datos: $e"));
    }
  }

  // También ajustamos el cambio de estado
  Future<Either<Failure, ApiResult>> changeStatus({
    required int serviceId,
    required int statusId,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(
            NetworkFailure("Revisa tu conexión para cambiar el estado."));
      }

      final result =
          await api.changeStatus(serviceId: serviceId, statusId: statusId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(DioExceptions.fromDioError(e).toString()));
    } catch (e) {
      return Left(ServerFailure("No se pudo cambiar el estado."));
    }
  }

  Future<Either<Failure, ApiResult>> closeService({
    required int id,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure("Revisa tu conexión a internet."));
      }

      final result = await api.cloaseService(id: id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(DioExceptions.fromDioError(e).toString()));
    } catch (e) {
      return Left(ServerFailure("No se pudo cerrar la remisión."));
    }
  }
}
