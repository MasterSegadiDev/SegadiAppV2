import 'package:segadi/features/services/domain/repository/services_repository.dart';

import '../entities/service_status_entity.dart';

class GetServiceStatusUseCase {
  final ServiceRepository repository;

  const GetServiceStatusUseCase({
    required this.repository,
  });

  Future<ServiceStatusEntity> call(
    String referralId,
  ) {
    return repository.getServiceStatus(
      referralId,
    );
  }
}
