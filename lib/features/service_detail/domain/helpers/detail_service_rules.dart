import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';

class DetailServiceRules {
  final DetailServiceEntity entity;
  DetailServiceRules(this.entity);

  bool get isContenedor => entity.serviceType.toLowerCase() == 'contenedor';
  bool get isCajaSeca => entity.serviceType.toLowerCase() == 'cajaseca';

  bool get shouldAutoClose {
    return isCajaSeca &&
        entity.nextMandatoryStatusId == 23 &&
        !entity.pendingMoneyChecks &&
        !entity.serviceClosed;
  }

  bool get canUploadEIR {
    return isContenedor && !entity.serviceClosed;
  }
}
