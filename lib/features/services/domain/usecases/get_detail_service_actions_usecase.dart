import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';

class GetServiceActionsUseCase {
  final ServiceRepository repository;

  GetServiceActionsUseCase(this.repository);

  Future<ServiceActionsEntity> call(
    String referralId,
  ) {
    return repository.getServiceActions(
      referralId,
    );
  }
}
