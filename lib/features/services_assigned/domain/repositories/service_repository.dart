import 'package:dartz/dartz.dart';
import 'package:segadi/features/services_assigned/domain/entities/services_result.dart';
import 'package:segadi/features/services_assigned/domain/failures/failure.dart';

abstract class ServicesRepository {
  Future<Either<Failure, ServicesResult>> getAssignedServices();
}
