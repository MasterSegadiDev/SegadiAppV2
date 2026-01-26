import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';

abstract class ServicesRepository {
  Future<List<ServiceEntity>> getAssignedServices();
}
