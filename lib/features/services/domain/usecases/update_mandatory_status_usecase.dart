import 'package:segadi/features/services/domain/entities/mandatory_status_result_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';

class UpdateMandatoryStatusUseCase {
  final ServiceRepository repository;

  UpdateMandatoryStatusUseCase(
    this.repository,
  );

  Future<MandatoryStatusResultEntity> call(
    UpdateMandatoryStatusParams params,
  ) {
    return repository.updateMandatoryStatus(
      params,
    );
  }
}
