import 'package:dio/dio.dart';

import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/core/result/result.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services/domain/entities/mandatory_status_result_entity.dart';
import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';

import '../../domain/entities/assigned_service.dart';

import '../mapper/assigned_service_mapper.dart';

class ServicesRepositoryImpl implements ServiceRepository {
  final ServicesRemoteDatasource remoteDataSource;

  const ServicesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<AssignedService>>> getAssignedServices() async {
    try {
      final dtoList = await remoteDataSource.getAssignedServices();

      final services = dtoList
          .map(
            AssignedServiceMapper.toEntity,
          )
          .toList();

      return Result.success(
        services,
      );
    } on DioException catch (e) {
      return Result.failure(
        ServerFailure(
          e.message ?? 'Error del servidor.',
        ),
      );
    } on FormatException {
      return Result.failure(
        const ParsingFailure(),
      );
    } catch (_) {
      return Result.failure(
        const NetworkFailure(),
      );
    }
  }

  @override
  Future<ServiceGeneralEntity> getServiceGeneral(
    String referralId,
  ) async {
    return remoteDataSource.getServiceGeneral(
      referralId,
    );
  }

  @override
  Future<ServiceActionsEntity> getServiceActions(
    String referralId,
  ) async {
    final model = await remoteDataSource.getServiceActions(
      referralId,
    );

    return model;
  }

  @override
  Future<ServiceStatusEntity> getServiceStatus(
    String referralId,
  ) async {
    return remoteDataSource.getServiceStatus(
      referralId,
    );
  }

  @override
  Future<MandatoryStatusResultEntity> updateMandatoryStatus(
    UpdateMandatoryStatusParams params,
  ) {
    return remoteDataSource.updateMandatoryStatus(
      params,
    );
  }
}
