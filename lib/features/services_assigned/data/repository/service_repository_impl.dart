import 'package:dio/dio.dart';

import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/core/result/result.dart';
import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source.dart';

import '../../domain/entities/assigned_service.dart';
import '../../domain/repository/services_repository.dart';

import '../mapper/assigned_service_mapper.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDatasource remoteDatasource;

  const ServicesRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<Result<List<AssignedService>>> getAssignedServices() async {
    try {
      final dtoList = await remoteDatasource.getAssignedServices();

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
}
