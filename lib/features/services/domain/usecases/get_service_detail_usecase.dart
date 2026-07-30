import '../entities/service_detail_entity.dart';
import '../repository/services_repository.dart';

class GetServiceDetailUseCase {
  final ServicesRepository repository;

  const GetServiceDetailUseCase(
    this.repository,
  );

  Future<ServiceDetailEntity> call(
    String referralId,
  ) {
    return repository.getServiceDetail(
      referralId,
    );
  }
}
