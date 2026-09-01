import '../../domain/repositories/georoute_repository.dart';
import '../datasources/georoute_remote_datasource.dart';
import '../models/georoute_model.dart';

class GeorouteRepositoryImpl implements GeorouteRepository {
  final GeorouteRemoteDatasource remoteDataSource;

  GeorouteRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<GeorouteModel> getGeoroute(
    String serviceRequestId,
  ) {
    return remoteDataSource.getGeoroute(
      serviceRequestId,
    );
  }
}
