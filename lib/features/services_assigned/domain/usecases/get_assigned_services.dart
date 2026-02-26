import 'package:dartz/dartz.dart';
import 'package:segadi/features/services_assigned/domain/entities/services_result.dart';
import 'package:segadi/features/services_assigned/domain/failures/failure.dart';
import '../repositories/service_repository.dart';

class GetAssignedServices {
  final ServicesRepository repository;

  GetAssignedServices(this.repository);

  Future<Either<Failure, ServicesResult>> call() async {
    return await repository.getAssignedServices();
  }
}
