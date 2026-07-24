import 'package:segadi/core/result/result.dart';

import '../entities/assigned_service.dart';
import '../repository/services_repository.dart';

class GetAssignedServicesUseCase {
  final ServicesRepository repository;

  const GetAssignedServicesUseCase(
    this.repository,
  );

  Future<Result<List<AssignedService>>> call() {
    return repository.getAssignedServices();
  }
}
