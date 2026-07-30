import 'package:segadi/core/result/result.dart';
import 'package:segadi/features/services/domain/entities/service_detail_entity.dart';

import '../entities/assigned_service.dart';

abstract class ServicesRepository {
  Future<Result<List<AssignedService>>> getAssignedServices();
  Future<ServiceDetailEntity> getServiceDetail(
    String referralId,
  );
}
