import 'package:segadi/features/services/data/models/service_detail_dto.dart';

import '../dto/assigned_service_dto.dart';

abstract class ServicesRemoteDatasource {
  Future<List<AssignedServiceDto>> getAssignedServices();
  Future<ServiceDetailDto> getServiceDetail(
    String referralId,
  );
}
