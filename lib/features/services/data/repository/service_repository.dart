import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/features/services/domain/entities/services_result.dart';

abstract class ServicesRepository {
  Future<Either<Failure, ServicesResult>> getAssignedServices();
}
