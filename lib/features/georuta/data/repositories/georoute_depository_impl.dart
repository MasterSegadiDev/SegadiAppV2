import '../../domain/entities/geofence_entity.dart';
import '../../domain/repositories/georoute_repository.dart';
import '../datasources/georoute_remote_datasource.dart';

class GeorouteRepositoryImpl implements GeorouteRepository {
  final GeorouteRemoteDatasource remoteDataSource;

  GeorouteRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<GeofenceEntity> getGeofences(
    String serviceRequestId,
  ) async {
    final model = await remoteDataSource.getGeofences(
      serviceRequestId,
    );

    return model;
  }
}
