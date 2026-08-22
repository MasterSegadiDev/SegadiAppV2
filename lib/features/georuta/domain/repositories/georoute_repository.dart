import '../entities/geofence_entity.dart';

abstract class GeorouteRepository {
  Future<GeofenceEntity> getGeofences(
    String serviceRequestId,
  );
}
