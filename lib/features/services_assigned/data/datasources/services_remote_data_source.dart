import '../dto/assigned_service_dto.dart';

abstract class ServicesRemoteDatasource {
  Future<List<AssignedServiceDto>> getAssignedServices();
}
