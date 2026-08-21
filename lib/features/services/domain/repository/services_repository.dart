import 'package:segadi/core/result/result.dart';
import 'package:segadi/features/services/domain/entities/assigned_service.dart';
import 'package:segadi/features/services/domain/entities/mandatory_status_result_entity.dart';
import 'package:segadi/features/services/domain/entities/service_actions_entity.dart';
import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';

abstract class ServiceRepository {
  Future<Result<List<AssignedService>>> getAssignedServices();

  Future<ServiceGeneralEntity> getServiceGeneral(
    String referralId,
  );

  Future<ServiceActionsEntity> getServiceActions(
    String referralId,
  );

  Future<ServiceStatusEntity> getServiceStatus(
    String referralId,
  );

  Future<MandatoryStatusResultEntity> updateMandatoryStatus(
    UpdateMandatoryStatusParams params,
  );
}
