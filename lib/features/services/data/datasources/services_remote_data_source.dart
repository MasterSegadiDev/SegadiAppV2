import 'package:segadi/features/services/data/dto/assigned_service_dto.dart';
import 'package:segadi/features/services/data/dto/service_general_dto.dart';
import 'package:segadi/features/services/data/dto/service_status_dto.dart';
import 'package:segadi/features/services/data/models/service_actions_model.dart';
import 'package:segadi/features/services/domain/entities/mandatory_status_result_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';

abstract class ServicesRemoteDatasource {
  Future<List<AssignedServiceDto>> getAssignedServices();

  Future<ServiceGeneralDto> getServiceGeneral(
    String referralId,
  );

  Future<ServiceActionsModel> getServiceActions(
    String referralId,
  );

  Future<ServiceStatusDto> getServiceStatus(
    String referralId,
  );

  Future<MandatoryStatusResultEntity> updateMandatoryStatus(
    UpdateMandatoryStatusParams params,
  );
}
