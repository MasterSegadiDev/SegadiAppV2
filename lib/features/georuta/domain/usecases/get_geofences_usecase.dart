import '../../data/models/georoute_model.dart';
import '../repositories/georoute_repository.dart';

class GetGeorouteUseCase {
  final GeorouteRepository repository;

  GetGeorouteUseCase(
    this.repository,
  );

  Future<GeorouteModel> call(
    String serviceRequestId,
  ) {
    return repository.getGeoroute(
      serviceRequestId,
    );
  }
}
