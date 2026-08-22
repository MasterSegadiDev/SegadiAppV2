import '../models/geofence_model.dart';

abstract class GeorouteRemoteDatasource {
  Future<GeofenceModel> getGeofences(
    String serviceRequestId,
  );
}
