import '../models/georoute_model.dart';

abstract class GeorouteRemoteDatasource {
  Future<GeorouteModel> getGeoroute(
    String serviceRequestId,
  );
}
