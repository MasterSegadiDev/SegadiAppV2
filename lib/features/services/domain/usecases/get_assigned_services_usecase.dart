import 'package:segadi/core/result/result.dart';
import 'package:segadi/features/services/domain/entities/assigned_service.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';

class GetAssignedServicesUseCase {
  final ServiceRepository repository;

  const GetAssignedServicesUseCase(
    this.repository,
  );

  Future<Result<List<AssignedService>>> call() {
    return repository.getAssignedServices();
  }
}
