import '../../data/models/georoute_model.dart';

abstract class GeorouteRepository {
  Future<GeorouteModel> getGeoroute(
    String serviceRequestId,
  );
}
