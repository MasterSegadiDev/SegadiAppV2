import 'package:segadi/features/services_assigned/domain/repositories/service_repository.dart';
import '../entities/service_entity.dart';

class GetAssignedServices {
  final ServicesRepository repository;

  GetAssignedServices(this.repository);

  Future<List<ServiceEntity>> call() {
    return repository.getAssignedServices();
  }
}
