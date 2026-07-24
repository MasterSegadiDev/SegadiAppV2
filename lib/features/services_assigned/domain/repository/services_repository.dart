import 'package:segadi/core/result/result.dart';

import '../entities/assigned_service.dart';

abstract class ServicesRepository {
  Future<Result<List<AssignedService>>> getAssignedServices();
}
