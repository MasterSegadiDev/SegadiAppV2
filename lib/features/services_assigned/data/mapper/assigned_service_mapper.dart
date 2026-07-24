import '../../domain/entities/assigned_service.dart';
import '../dto/assigned_service_dto.dart';

class AssignedServiceMapper {
  static AssignedService toEntity(
    AssignedServiceDto dto,
  ) {
    return AssignedService(
      id: dto.id,
      serviceNumber: dto.serviceNumber,
      customer: dto.customer,
      origin: dto.origin,
      destination: dto.destination,
      serviceType: dto.serviceType,
      responsible: dto.responsible,
      serviceStatus: dto.serviceStatus,
      tripStatus: dto.tripStatus,
      loadingDate: dto.loadingDate,
      unloadingDate: dto.unloadingDate,
      stops: dto.stops,
    );
  }
}
