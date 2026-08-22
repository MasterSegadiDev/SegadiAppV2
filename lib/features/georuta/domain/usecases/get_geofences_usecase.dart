import '../entities/geofence_entity.dart';
import '../repositories/georoute_repository.dart';

class GetGeofencesUseCase {
  final GeorouteRepository repository;

  GetGeofencesUseCase(
    this.repository,
  );

  Future<GeofenceEntity> call(
    String serviceRequestId,
  ) {
    return repository.getGeofences(
      serviceRequestId,
    );
  }
}
