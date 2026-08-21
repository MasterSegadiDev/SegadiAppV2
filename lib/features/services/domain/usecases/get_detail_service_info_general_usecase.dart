import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';

class GetServiceGeneralUseCase {
  final ServiceRepository repository;

  GetServiceGeneralUseCase(this.repository);

  Future<ServiceGeneralEntity> call(
    String referralId,
  ) {
    return repository.getServiceGeneral(
      referralId,
    );
  }
}
